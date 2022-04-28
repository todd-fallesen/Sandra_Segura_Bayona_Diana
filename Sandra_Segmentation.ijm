/* Segmentation Script for Sandra Segura-Bayona
 * This is a script to do segmentation of the dapi channel for Sandra, and keep the images in the same format she was using 
 * previously, so things are backwards compatiable
 * Todd Fallesen, CALM Facility, Crick Institute, April 2022
 * 
 * TO DO--Solve the issue about filtering by size
 * 
 */
#@ File (label = "Image directory", style = "directory") image_dir
#@ String (label = "File suffix", value = ".nd2") suffix
#@ File (label = "Output directory", style = "directory") output_dir
#@ String (label="Select segmentation channel", choices={"1", "2", "3", "4" }, style="listBox") DAPI_Ch

	close("*");  //close all open image windows
	roiManager("reset"); //reset the ROI manager
	run("Clear Results");
min_size = 1000;
processFolder(image_dir);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(image_dir) {
	list = getFileList(image_dir);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(image_dir + File.separator + list[i]))
			processFolder(image_dir + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(image_dir, output_dir, DAPI_Ch, list[i]);
	}
}

function processFile(image_dir, output_dir, DAPI_ch, file) {
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
	
	
	
	img=image_dir+File.separator+file; //this is the image file that we'll be working on this loop
	run("Bio-Formats (Windowless)", "open="+img);
	imageTitle=getTitle();
	file_name = File.getNameWithoutExtension(file);
	run("Duplicate...", "duplicate channels="+DAPI_Ch);
	rename("DAPI duplicate");
	run("Z Project...", "projection=[Max Intensity]");
	rename("MAX");
	selectWindow("DAPI duplicate");
	close();
	selectWindow("MAX");
	run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':'MAX', 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'1.0', 'percentileTop':'99.8', 'probThresh':'0.5', 'nmsThresh':'0.5', 'outputType':'Both', 'nTiles':'1', 'excludeBoundary':'2', 'roiPosition':'Automatic', 'verbose':'false', 'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");
	
	
	File.makeDirectory(output_dir+File.separator+file_name);
	roi_dir = output_dir+File.separator+file_name+File.separator+"ROI_Overlay";
	File.makeDirectory(roi_dir);
	img_output_dir = output_dir+File.separator+file_name+File.separator+"input_folder";
	File.makeDirectory(img_output_dir);

//make the ROI table
list_size = roiManager("count");
temp_array = newArray(list_size);
table1 = "Area_table";
Table.create(table1);
Table.setColumn("Row", temp_array);
Table.setColumn("Area", temp_array);
	
for (r=0; r<roiManager("count");r++){   //this loop goes over the segmentation block, and finds the ROI's smaller than min_area, and removes them
				 selectWindow("Label Image");
				 roiManager("Select", r); 
				 //print(r);
				 run("Properties...", "channels=1 slices=1 frames=1 pixel_width=1 pixel_height=1 voxel_depth=1");
				 roiManager("Measure");
				 area = getResult("Area", r);
				 print("Row: ", r, "has area: ", area);
				 	
				Table.set("Row", r, r, table1);
           		Table.set("Area", r, area, table1);
									    			
	}

selectWindow("MAX");
roiManager("Show All");
saveAs("tiff",roi_dir+File.separator+file_name+"_ROIs_OVERLAY.tiff");  //save the ROI overlay

selectWindow("Label Image");
roiManager("Show All");
saveAs("tiff",roi_dir+File.separator+file_name+"_Label_OVERLAY.tiff");  //save the ROI overlay


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
	
	
	
	
	print("Processing: " + image_dir + File.separator + file);	
	print("Saving : " + output_dir+File.separator+ File.getNameWithoutExtension(file));
	close("*");  //close all open image windows
	roiManager("reset"); //reset the ROI manager
	
	Table.reset(table1);
	
}// end of function







