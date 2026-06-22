//Automated analysis script to be used with images from CABIS/MBIC
//This script will take all your images that were imaged using the Whole Slice profile
//and insertion site profile at CABIS/MBIC, and process all images. The script will subtract the background,
//run brightness and contrast, crop the images to take only the slice or insertion site, and add scale bars.
//All channels will be saved as TIF and JPEG for further analysis if required. 

close("*");//Closing everything
run("Clear Results"); //Clearing everything so it doesn't get saved later on


//GUI Inputs

#@ File (label="Select your root image directory", style="directory") directory
#@ File (label="Select your whole slice ROI", style="file") whole_slice_ROI
#@ File (label="Select your insertion site ROI", style="file") insertion_site_ROI
#@ String (label="Select your whole slice file name", style="text field") whole_slice_file
#@ String (label="Select your insertion site file name", style="text field") insertion_site_file
#@ String (label="Select your whole slice pixel size", style="text field") whole_slice_pixel_size
#@ String (label="Select your insertion site pixel size", style="text field") insertion_site_pixel_size
#@ String (choices={"nm", "µm", "mm" , "cm"}, style="listBox") units

//Can probably add a channel input here that asks for the number of channels to be used and their names
//and colors. This will make it more ammenable for other people

//Setting up base directory
directory = directory + "/";
directory_name = File.getName(directory);//Gets Name of Directory
directory_folders = getFileList(directory); //This gets all the folder names


//This iterates through all the folders in the base directory
for (i=0; i < directory_folders.length; i++) { 
      if(endsWith(directory_folders[i], "/")){ 
      	subDir = directory + directory_folders[i];
      	subDirFiles = getFileList(subDir);
      	subDirFilesNames = " ";
      	for (j=0; j < subDirFiles.length; j++) {
      		subDirFilesNames = subDirFilesNames + " " + subDirFiles[j];
      	}
      		//This generates a list of every file within the subdirectory
      	
      	
      	
      	//CABI/MBIC CZI file processor
      	if(matches(subDirFilesNames, ".*czi.*")) {
	      	folder_name = directory_folders[i].replace("/","");
	      	File.makeDirectory(subDir + "Insertion_Site");
	      	insertion_site_folder = subDir + "Insertion_Site/";
	      	File.makeDirectory(subDir + "Whole_Slice");
	      	whole_slice_folder = subDir + "Whole_Slice/";
			//This is a check if there are any czi files within the subdirectory file list
			
			
	//Process Whole Slice Images 
	
	      	//split insertion site images
	      	close("*");//important to close everything so view doesn't get cluttered. preserves memory
	      	open(subDir + "/" + whole_slice_file +".czi");
	      	Stack.getDimensions(width, height, channels, slices, frames);
	      	waitForUser("Splitting channels. Ready to split?");
	      	run("Split Channels");
			selectImage("C1-" + whole_slice_file + ".czi");
			saveAs("Tiff", whole_slice_folder + folder_name + "_" + whole_slice_file + "_DAPI.tif"); //blue
			selectImage("C2-" + whole_slice_file + ".czi");
			saveAs("Tiff", whole_slice_folder + folder_name + "_" + whole_slice_file + "_GFAP.tif"); //green
			if (channels == 3) {
			selectImage("C3-" + whole_slice_file + ".czi");
			saveAs("Tiff", whole_slice_folder + folder_name + "_" + whole_slice_file + "_NeuN.tif"); //red
			};
			//This splits the images and saves them as tifs preserving the names
			//You can change this to the file names based on the channels you imaged
			//Here they are labeled blue, green, red, but any color can be used
			//If someone images less channels I can fix this and throw in a for loop for all channels split
			
			
		//merge whole site images
			waitForUser("Merging channels. Ready to merge?");
			if (channels == 3) {
			run("Merge Channels...", "c1=" + folder_name + "_" + whole_slice_file + "_NeuN.tif" + " c2=" + folder_name + "_" + whole_slice_file + "_GFAP.tif" + " c3=" + folder_name + "_" + whole_slice_file + "_DAPI.tif" + " create");
			}
			else if (channels == 2) {
			run("Merge Channels...", "c1=" + folder_name + "_" + whole_slice_file + "_NeuN.tif" + " c2=" + folder_name + "_" + whole_slice_file + "_GFAP.tif" + " create");
			}; //this then remerges the image from the tifs generated in lines 52-59
			
			
		//Background Substraction and Brightness/Contrast Adjust
			waitForUser("Subtracting background and adjusting brightness and contrast. Ready?");
			selectImage("Composite");
			run("Subtract Background...", "rolling=50");
			run("Brightness/Contrast...");
			Stack.setChannel(1); 
			run("Enhance Contrast", "saturated=0.35");
			Stack.setChannel(2); 
			run("Enhance Contrast", "saturated=0.35");
			if (channels == 3) {
			Stack.setChannel(3); 
			run("Enhance Contrast", "saturated=0.35");
			}
			saveAs("Tiff", whole_slice_folder + folder_name + "_" + whole_slice_file + "_Merged_BG_BC.tif"); //merged
			//Images are now merged and backgroung is subtracted and brightness and contrast is fixed. 
			//These values can be played around with to generate cleaner images. I kept it as the auto values for now
			//This image is saved as a tif
			
			
		//ROI Selection
			roiManager("Open", whole_slice_ROI);
			roiManager("Select", 0);
			waitForUser("Select the ROI with the whole slice.");
			run("Crop");
			roiManager("Delete");
			//Crops image to only area with ROI selected
			
		//Setting scale bar
			waitForUser("Setting scale bar and saving images. Ready?");
			run("Set Scale...", "distance=1 known=" + whole_slice_pixel_size + " unit=" + units);
			run("Scale Bar...", "width=1500 height=200 thickness=20 font=75 bold overlay");
			waitForUser("Saving merged images.");
			saveAs("Tiff", whole_slice_folder + folder_name + "_" + whole_slice_file + "_Processed.tif");
			saveAs("JPEG", whole_slice_folder + folder_name + "_" + whole_slice_file + "_Processed.jpeg");
			run("Split Channels");
			//Sets a scale bar based on imaging parameters. If someone changes microscope settings leading to different pixel size
			//this value will need to be changed
			
		//Splitting Images
			waitForUser("Saving unmerged images.");
			selectImage("C1-" + folder_name + "_" + whole_slice_file + "_Processed.tif");
			saveAs("Tiff", whole_slice_folder + folder_name + "_" + whole_slice_file + "_Merged_NeuN_Processed.tif"); //red
			saveAs("JPEG", whole_slice_folder + folder_name + "_" + whole_slice_file + "_Merged_NeuN_Processed.jpef"); //red
			selectImage("C2-" + folder_name + "_" + whole_slice_file + "_Processed.tif");
			saveAs("Tiff", whole_slice_folder + folder_name + "_" + whole_slice_file + "_Merged_GFAP_Processed.tif"); //green
			saveAs("JPEG", whole_slice_folder + folder_name + "_" + whole_slice_file + "_Merged_GFAP_Processed.jpeg"); //green
			if (channels == 3) {
			selectImage("C3-" + folder_name + "_" + whole_slice_file + "_Processed.tif");
			saveAs("Tiff", whole_slice_folder + folder_name + "_" + whole_slice_file + "_Merged_DAPI_Processed.tif"); //blue
			saveAs("JPEG", whole_slice_folder + folder_name + "_" + whole_slice_file + "_Merged_DAPI_Processed.jpeg"); //blue
			};
			//This saves unmerged images with the scale bars.
			      	
	//Process Insertion Site Images 
	
	
      	//Split Insertion Site Images
	      	close("*");
	      	open(subDir + "/" + insertion_site_file + ".czi");
	      	Stack.getDimensions(width, height, channels, slices, frames);
	      	waitForUser("Splitting channels. Ready to split?");
	      	run("Split Channels");
			selectImage("C1-" + insertion_site_file + ".czi");
			saveAs("Tiff", insertion_site_folder + folder_name + "_" + insertion_site_file + "_NeuN.tif"); //red
			selectImage("C2-" + insertion_site_file + ".czi");
			saveAs("Tiff", insertion_site_folder + folder_name + "_" + insertion_site_file + "_GFAP.tif"); //green
			if (channels == 3) {
			selectImage("C3-" + insertion_site_file + ".czi");
			saveAs("Tiff", insertion_site_folder + folder_name + "_" + insertion_site_file + "_DAPI.tif"); //blue
			};
			//This splits the channels then saves them as tifs like earlier
			
		//Merge Insertion Site Images
			waitForUser("Merging channels. Ready to merge?");
			if (channels == 3) {
			run("Merge Channels...", "c1=" + folder_name + "_" + insertion_site_file + "_NeuN.tif" + " c2=" + folder_name + "_" + insertion_site_file + "_GFAP.tif" + " c3=" + folder_name + "_" + insertion_site_file + "_DAPI.tif" + " create");
			}
			else if (channels == 2) {
			run("Merge Channels...", "c1=" + folder_name + "_" + insertion_site_file + "_NeuN.tif" + " c2=" + folder_name + "_" + insertion_site_file + "_GFAP.tif" + " create");
			};
			//Merges channels again 
			
		//Background Substraction and Brightness/Contrast Adjust
			waitForUser("Subtracting background and adjusting brightness and contrast. Ready?");
			selectImage("Composite");
			run("Subtract Background...", "rolling=50");
			run("Brightness/Contrast...");
			Stack.setChannel(1); 
			run("Enhance Contrast", "saturated=0.35");
			Stack.setChannel(2); 
			run("Enhance Contrast", "saturated=0.35");
			if (channels == 3) {
			Stack.setChannel(3); 
			run("Enhance Contrast", "saturated=0.35");
			}
			saveAs("Tiff", insertion_site_folder + folder_name + "_" + insertion_site_file + "_Merged_BG_BC.tif"); 
			//Images are now merged and backgroung is subtracted and brightness and contrast is fixed. 
			
		//ROI Selection
			roiManager("Open", insertion_site_ROI);
			roiManager("Select", 0);
			waitForUser("Select the ROI with the insertion site.");
			run("Crop");
			roiManager("Delete");
			//Crops image to selected ROI
			
		//Setting scale bar
			waitForUser("Setting scale bar and saving images. Ready?");
			run("Set Scale...", "distance=1 known=" + insertion_site_pixel_size + " unit=" + units);
			run("Scale Bar...", "width=100 height=50 bold overlay");
			//Scale bar is set based on insertion site imaging parameters
			
		//Splitting Images
			waitForUser("Saving merged images.");
			saveAs("Tiff", insertion_site_folder + folder_name + "_" + insertion_site_file + "_Processed.tif");
			saveAs("JPEG", insertion_site_folder + folder_name + "_" + insertion_site_file + "_Processed.jpeg");
			run("Split Channels");
			waitForUser("Saving unmerged images.");
			selectImage("C1-" + folder_name + "_" + insertion_site_file + "_Processed.tif");
			saveAs("Tiff", insertion_site_folder + folder_name + "_" + insertion_site_file + "_NeuN_Processed.tif"); //red
			saveAs("JPEG", insertion_site_folder + folder_name + "_" + insertion_site_file + "_NeuN_Processed.jpef"); //red
			selectImage("C2-" + folder_name + "_" + insertion_site_file + "_Processed.tif");
			saveAs("Tiff", insertion_site_folder + folder_name + "_" + insertion_site_file + "_GFAP_Processed.tif"); //green
			saveAs("JPEG", insertion_site_folder + folder_name + "_" + insertion_site_file + "_GFAP_Processed.jpeg"); //green
			if (channels == 3) {
			selectImage("C3-" + folder_name + "_" + insertion_site_file + "_Processed.tif");
			saveAs("Tiff", insertion_site_folder + folder_name + "_" + insertion_site_file + "_DAPI_Processed.tif"); //blue
			saveAs("JPEG", insertion_site_folder + folder_name + "_" + insertion_site_file + "_DAPI_Processed.jpeg"); //blue
			};
			//Images are split again and saved
			
		//Get measurements
			close("*");
	      	open(insertion_site_folder + folder_name + "_" + insertion_site_file + "_Processed.tif");
			waitForUser("Getting intensity measurements.");
			Stack.setChannel(1); 
			run("Set Measurements...", "area mean min display redirect=None decimal=3");
			run("Measure");
			Stack.setChannel(2); 
			run("Set Measurements...", "area mean min display redirect=None decimal=3");
			run("Measure");
			if (channels == 3) {
			Stack.setChannel(3); 
			run("Set Measurements...", "area mean min display redirect=None decimal=3");
			run("Measure");
				};
			//This gets intensity measurements of all channels of the insertion site image
			
		//Get Insertion Radius
			setTool("line");
			waitForUser("Select the insertion site hole");
			run("Measure");
			//This gets the insertion radius from the image
			};
      };
}

//Results Save
	saveAs("Results",directory + directory_name + "_Results.csv");
	//Results are saved in the base directory as the directory name_Results in a CSV file