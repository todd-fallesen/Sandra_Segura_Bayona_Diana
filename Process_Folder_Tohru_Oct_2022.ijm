/*
 * Macro template to process multiple images in a folder
 * Todd Fallesen, October 25, 2022.  CALM Facility, Francis Crick Institute
 */

#@ File (label = "Input directory", style = "directory") image_dir
#@ File (label = "Output directory", style = "directory") output_dir
#@ String (label = "File suffix", value = ".tif") suffix
#@ String (label="Select segmentation channel", choices={"1", "2", "3", "4" }, style="listBox") DAPI_Ch

//TODO : Check if code works if there is but one series


run("Bio-Formats Macro Extensions");
close("*");  //close all open image windows
roiManager("reset"); //reset the ROI manager
run("Clear Results");
min_size = 500;
processFolder(image_dir);
print("Done!");

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(image_dir) {
	list = getFileList(image_dir);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(image_dir + File.separator + list[i]))
			//processFolder(image_dir + File.separator + list[i]);
			print("oh well");
		if(endsWith(list[i], suffix))
			processFile(image_dir, output_dir, list[i], DAPI_Ch);
	}
}

function processFile(image_dir, output_dir, file, DAPI_Ch) {
	// This function runs just on the file, and it'll run through the series in the ND2 file. 
	print("Processing: " + image_dir + File.separator + file);
	//TODO : Check to see if the file is an ND2 file with series
	run_file = image_dir+File.separator+file;
	Ext.setId(run_file);
	Ext.getSeriesCount(seriesCount);
	runAcrossSeries(run_file, seriesCount, DAPI_Ch, output_dir);
	print("Saving to: " + output_dir);
}


function runAcrossSeries(file, seriesCount, DAPI_Ch, output_dir){
	for (series = 1; series <= seriesCount; series++) {
	//record the Bio-Formats importer with the setup you need if different from below and change accordingly
		run("Bio-Formats Importer", "open=[" + file + "] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_"+series);
		imageTitle=getTitle();
		image_name = getTitle();
		//file_folder= output_dir + File.separator+image_name+File.separator+"output";
		//File.makeDirectory(file_folder);
		
		
		run("Duplicate...", "duplicate channels="+DAPI_Ch);
		rename("DAPI duplicate");
		run("Z Project...", "projection=[Max Intensity]");
		rename("MAX");
		selectWindow("DAPI duplicate");
		close();
		selectWindow("MAX");
		run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':'MAX', 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'1.0', 'percentileTop':'99.8', 'probThresh':'0.5', 'nmsThresh':'0.5', 'outputType':'Both', 'nTiles':'1', 'excludeBoundary':'2', 'roiPosition':'Automatic', 'verbose':'false', 'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");
		
		//make directory for each file or series
		File.makeDirectory(output_dir+File.separator+image_name);
		roi_dir = output_dir+File.separator+image_name+File.separator+"ROI_Overlay";
		File.makeDirectory(roi_dir);
		img_output_dir = output_dir+File.separator+image_name+File.separator+"input_folder";
		File.makeDirectory(img_output_dir);
	
			//make the ROI table
			list_size = roiManager("count");
			temp_array = newArray(list_size);
			table1 = "Area_table";
			Table.create(table1);
			Table.setColumn("Row", temp_array);
			Table.setColumn("Area", temp_array);
		
	for (r=0; r<roiManager("count");r++){  
		//this loop goes over the segmentation block, and finds the ROI's smaller than min_area, and removes them
	
					 selectWindow("Label Image");
					 roiManager("Select", r); 
					 //print(r);
					 run("Properties...", "channels=1 slices=1 frames=1 pixel_width=1 pixel_height=1 voxel_depth=1");
					 roiManager("Measure");
					 area = getResult("Area", r);
					 print("Row: ", r, "has area: ", area);
					 	
					Table.set("Row", r, r, table1);
	           		Table.set("Area", r, area, table1);
	           		Table.update;
										    			
		} //end of for loop
	
	selectWindow("MAX");
	roiManager("Show All");
	saveAs("tiff",roi_dir+File.separator+image_name+"_ROIs_OVERLAY.tiff");  //save the ROI overlay
	
	selectWindow("Label Image");
	roiManager("Show All");
	saveAs("tiff",roi_dir+File.separator+image_name+"_Label_OVERLAY.tiff");  //save the ROI overlay
	
	
	print("saved");
	for (r=0; r<roiManager("count");r++){ 
		
					 selectWindow("Area_table");
					 area = Table.get("Area", r);
					 if(area>min_size) {
					 	
					 	print(area);
					   	selectWindow(imageTitle);
					    roiManager("Select", r); 
					    
					    run("Duplicate...", "duplicate");	
					    ROITitle=getTitle(); 
					    saveAs("tif",img_output_dir+File.separator+ROITitle+'-'+r);
					    close();
					 }
					    			
					}
		
		run("Clear Results");
		
		
		
		
		print("Processing: " + image_dir + File.separator + image_name);	
		print("Saving : " + output_dir+File.separator+ image_name);
		close("*");  //close all open image windows
		roiManager("reset"); //reset the ROI manager
		
		Table.reset(table1);
			
			
			
			

		
			}// end of function runAcrossSeries