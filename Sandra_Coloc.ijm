/* Colocoliazation Script for Sandra Segura-Bayona
 * This is a script to do segmentation of the dapi channel for Sandra, and keep the images in the same format she was using 
 * previously, so things are backwards compatiable
 * Todd Fallesen, CALM Facility, Crick Institute, April 2022
 * 
 *
 * 
 */


#@ File (label = "Input folder", style = "directory") dir
#@ string (choices={"1","2","3","4","none"}, style="listBox") DAPI
#@ string (choices={"1","2","3","4","none"}, style="listBox") Telomeres
#@ string (choices={"1","2","3","4","none"}, style="listBox") Marker_1
#@ string (choices={"1","2","3","4","none"}, style="listBox") Marker_2
#@ File (label = "Results folder", style = "directory") dirOutput

DAPI_Ch = parseInt(DAPI);
Telo_Ch = parseInt(Telomeres);
Mark1_Ch = parseInt(Marker_1);
Mark2_Ch = parseInt(Marker_2);


//dir = getDirectory("input_folder");
//dirOutput = getDirectory ("Results_folder");

list = getFileList(dir);

//2 channel detection
if(isNaN(Mark1_Ch)) {
	if(Telo_Ch > 0){
				list_size = list.length;
				temp_array = newArray(list_size);
				table1 = "Number_Spots";
				Table.create(table1);
				Table.setColumn("File", temp_array);
				Table.setColumn("Number_of_Spots", temp_array);
				
			for (i=0; i<list.length; i++) {
           		open(dir+File.separator+list[i]);
           		print("Working on image: ",i, " of ", list.length);
           		print(list[i]);
           		Table.set("File", i, list[i], table1);
           		Table.set("Number_of_Spots", i, i*0, table1);
				Table.update;

				imageTitle=getTitle();
           		run("Split Channels");
           	
           		selectWindow("C"+DAPI_Ch+"-"+imageTitle); //DAPI channel will be closed
           		close();
           	
		    	selectWindow("C"+Telo_Ch+"-"+imageTitle); 
           		run("Subtract Background...", "rolling=40 stack");
           		run("Gaussian Blur 3D...", "x=1 y=1 z=1");
           		rename("Telo");
           		
           		run("DiAna_Segment", "img=Telo peaks=1.5-1.5-50.0 spots=20-5-1-1-2000-true");
           		selectWindow("Telo-labelled");
           		run("Z Project...", "projection=[Max Intensity]");
           		Num_spots = parseInt(getValue("Max"));
           		print("Number of spots is: ", Num_spots);
           		Table.set("Number_of_Spots", i, Num_spots, table1);
           		Table.update;
           		
           		run("Close All");
           		
           		
           	

        //run("DiAna_Segment", "img=Telo peaks=1.5-1.5-50.0 spots=20-5-1-1-2000-true");
		//for two color, just run the same image twice through, to get the count through diana
		//run("DiAna_Analyse", "img1=Telo img2=Telo lab1=Telo-labelled lab2=Telo-labelled coloc distc=50.0 measure");
		
		//if (isOpen("ObjectsMeasuresResults-B")) {
		//	selectWindow("ObjectsMeasuresResults-B");
		//	saveAs("Text", dirOutput+File.separator+"Measurements_B_TELO_TELO_1_"+imageTitle);
		//	run("Close");
		//}
		//else{
		//	Table.create("ObjectsMeasuresResults-B");
		//	values1 = newArray(0,0);
		//	Table.setColumn("Numbers", values1);
		//	selectWindow("ObjectsMeasuresResults-B");
		//	saveAs("Text", dirOutput+File.separator+"Measurements_B_TELO_TELO_1_"+imageTitle);
		//	run("Close");
		//}
		
		//if else block for results A
		//if (isOpen("ObjectsMeasuresResults-A")) {
		//	selectWindow("ObjectsMeasuresResults-A");
		//	saveAs("Text", dirOutput+File.separator+"Measurements_A_TELO_1_"+imageTitle);      
		//	run("Close");
		//}
		//else{
		//	Table.create("ObjectsMeasuresResults-A");
		//	values1 = newArray(0,0);
		//	Table.setColumn("Numbers", values1);
		//	selectWindow("ObjectsMeasuresResults-A");
		//	saveAs("Text", dirOutput+File.separator+"Measurements_A_TELO_1_"+imageTitle);
		//	run("Close");
		//}
		
	}
	selectWindow(table1);
	saveAs("Text", dirOutput+File.separator+"Measurements_2_Channel_Number_Spots"+imageTitle);
	//close("*");
	}
}






// This is the loop that runs for marker 1
if(Mark1_Ch>0) {
	for (i=0; i<list.length; i++) {
           	open(dir+File.separator+list[i]);
           	print("Working on image: ",i, " of ", list.length);

			imageTitle=getTitle();
           	run("Split Channels");
           	
           	selectWindow("C"+DAPI_Ch+"-"+imageTitle); //DAPI channel will be closed
           	close();
           	
           	selectWindow("C"+Mark1_Ch+"-"+imageTitle); 
           	run("Subtract Background...", "rolling=20 stack");
           	run("Gaussian Blur 3D...", "x=1 y=1 z=1");
           	rename("Marker1");         	
           	selectWindow("C"+Telo_Ch+"-"+imageTitle); 
           	run("Subtract Background...", "rolling=40 stack");
           	run("Gaussian Blur 3D...", "x=1 y=1 z=1");
           	rename("Telo");
		t_start = getTime();
        run("DiAna_Segment", "img=Marker1 peaks=2.0-2.0-20.0 spots=2-7-1.5-3-100-true");
        t_end1 = getTime();
       	duration1 = t_end1-t_start;
       	print("first segmentation took: ", duration1, " ms");
       	
        run("DiAna_Segment", "img=Telo peaks=1.5-1.5-50.0 spots=20-5-1-1-2000-true");
        t_end2 = getTime();
        duration2 = t_end2-t_start;
       	print("second segmentation took: ", duration2, " ms");
        wait(1000);
        run("DiAna_Analyse", "img1=Marker1 img2=Telo lab1=Marker1-labelled lab2=Telo-labelled coloc distc=50.0 measure");
        t_end3=getTime();
        duration3 = t_end3-t_start;
        print("analysis took :", duration3, " ms");
		wait(2000);
		
		//if else block for results b
		if (isOpen("ObjectsMeasuresResults-B")) {
			selectWindow("ObjectsMeasuresResults-B");
			saveAs("Text", dirOutput+File.separator+"Measurements_B_TELO_MARKER_1_"+imageTitle);
			run("Close");
		}
		else{
			Table.create("ObjectsMeasuresResults-B");
			values1 = newArray(0,0);
			Table.setColumn("Numbers", values1);
			selectWindow("ObjectsMeasuresResults-B");
			saveAs("Text", dirOutput+File.separator+"Measurements_B_TELO_MARKER_1_"+imageTitle);
			run("Close");
		}
		
		//if else block for results A
		if (isOpen("ObjectsMeasuresResults-A")) {
			selectWindow("ObjectsMeasuresResults-A");
			saveAs("Text", dirOutput+File.separator+"Measurements_A_MARKER_1_"+imageTitle);      
			run("Close");
		}
		else{
			Table.create("ObjectsMeasuresResults-A");
			values1 = newArray(0,0);
			Table.setColumn("Numbers", values1);
			selectWindow("ObjectsMeasuresResults-A");
			saveAs("Text", dirOutput+File.separator+"Measurements_A_MARKER_1_"+imageTitle);
			run("Close");
		}
		
		//coloc block
		if (isOpen("ColocResults")) {
			selectWindow("ColocResults");
			run("Close");
		}
		
		if (isOpen("Log")){
			selectWindow("Log");
			saveAs("Text", dirOutput+File.separator+"Log_coloc_Marker_1_"+imageTitle);
			run("Close");
			
		}
		run("Close All");
}// close loop
}// close marker 1 branch
		
//This is the loop for marker 2
if(Mark2_Ch>0) {
	print("Running second marker channel");
	for (i=0; i<list.length; i++) {
           	open(dir+File.separator+list[i]);
           	print("Working on image: ",i, " of ", list.length);

			imageTitle=getTitle();
           	run("Split Channels");
           	
           	selectWindow("C"+DAPI_Ch+"-"+imageTitle); //DAPI channel will be closed
           	close();
           	
           	selectWindow("C"+Mark2_Ch+"-"+imageTitle); 
           	run("Subtract Background...", "rolling=20 stack");
           	run("Gaussian Blur 3D...", "x=1 y=1 z=1");
           	rename("Marker2");         	
           	selectWindow("C"+Telo_Ch+"-"+imageTitle); 
           	run("Subtract Background...", "rolling=40 stack");
           	run("Gaussian Blur 3D...", "x=1 y=1 z=1");
           	rename("Telo");

        run("DiAna_Segment", "img=Marker2 peaks=2.0-2.0-20.0 spots=2-7-1.5-3-100-true");
        run("DiAna_Segment", "img=Telo peaks=1.5-1.5-50.0 spots=20-5-1-1-2000-true");
        wait(1000);
        run("DiAna_Analyse", "img1=Marker2 img2=Telo lab1=Marker2-labelled lab2=Telo-labelled coloc distc=50.0 measure");
		wait(2000); //neeeded if running on the cluster
		
		//if else block for measurement b
		if (isOpen("ObjectsMeasuresResults-B")) {
			selectWindow("ObjectsMeasuresResults-B");
			saveAs("Text", dirOutput+File.separator+"Measurements_B_TELO_MARKER_2_"+imageTitle);
			run("Close");
		}
		
		else{
			Table.create("ObjectsMeasuresResults-B");
			values1 = newArray(0,0);
			Table.setColumn("Numbers", values1);
			selectWindow("ObjectsMeasuresResults-B");
			saveAs("Text", dirOutput+File.separator+"Measurements_B_TELO_MARKER_2_"+imageTitle);
			run("Close");
		}
		
		//if else block for measurement a
		if (isOpen("ObjectsMeasuresResults-A")) {
			selectWindow("ObjectsMeasuresResults-A");
			saveAs("Text", dirOutput+File.separator+"Measurements_A_MARKER_2_"+imageTitle);      
			run("Close");
		}
		
		else{
			Table.create("ObjectsMeasuresResults-A");
			values1 = newArray(0,0);
			Table.setColumn("Numbers", values1);
			selectWindow("ObjectsMeasuresResults-A");
			saveAs("Text", dirOutput+File.separator+"Measurements_A_MARKER_2_"+imageTitle);
			run("Close");
		}
		
		//		
		if (isOpen("ColocResults")) {
			selectWindow("ColocResults");
			run("Close");
		}
		
		// 
		if (isOpen("Log")){
			selectWindow("Log");
			saveAs("Text", dirOutput+File.separator+"Log_coloc_marker_2_"+imageTitle);
			run("Close");
		
		}
		run("Close All");
		
}//close loop
}//close if branch if there is 2 markers

		
showMessage("Done!");
		