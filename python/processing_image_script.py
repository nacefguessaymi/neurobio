import os
from imagej import IJ, ImagePlus, WindowManager
from imagej.plugin.frame import RoiManager
from imagej.measure import Measurements

# Automated analysis script to be used with images from CABIS/MBIC
# ... (Rest of the comments remain the same)

# Closing everything
IJ.run("Close All")
IJ.run("Clear Results")

# GUI Inputs
directory = IJ.getDirectory("Select your root image directory")
whole_slice_ROI = IJ.openImage("Select your whole slice ROI")
insertion_site_ROI = IJ.openImage("Select your insertion site ROI")
whole_slice_file = IJ.getString("Select your whole slice file name")
insertion_site_file = IJ.getString("Select your insertion site file name")
whole_slice_pixel_size = IJ.getString("Select your whole slice pixel size")
insertion_site_pixel_size = IJ.getString("Select your insertion site pixel size")
number_of_channels = IJ.getString("Select your number of channels")
units = IJ.getString("Select your units", "nm|µm|mm|cm")

# Setting up base directory
directory = directory + "/"
directory_name = IJ.getDirectory("Directory")
directory_folders = os.listdir(directory)

# This iterates through all the folders in the base directory
for folder_name in directory_folders:
    if os.path.isdir(os.path.join(directory, folder_name)):
        sub_dir = os.path.join(directory, folder_name)
        sub_dir_files = os.listdir(sub_dir)

        # CABI/MBIC CZI file processor
        if any(re.match(r".*czi.*", file_name) for file_name in sub_dir_files):
            insertion_site_folder = os.path.join(sub_dir, "Insertion_Site")
            IJ.run("Make Subdirectory...", "name=Insertion_Site")
            whole_slice_folder = os.path.join(sub_dir, "Whole_Slice")
            IJ.run("Make Subdirectory...", "name=Whole_Slice")

            # ... (Rest of the script remains the same, with necessary modifications)
            # Process Whole Slice Images

# Splitting channels
IJ.run("Close All")
IJ.open(subDir + "/" + whole_slice_file + ".czi")
width = WindowManager.getCurrentImage().getWidth()
height = WindowManager.getCurrentImage().getHeight()
channels = WindowManager.getCurrentImage().getNChannels()
IJ.waitForUser("Splitting channels. Ready to split?")
IJ.run("Split Channels")
for n in range(1, int(number_of_channels) + 1):
    WindowManager.getImage("C" + str(n) + "-" + whole_slice_file + ".czi").show()
    IJ.saveAs(
        "Tiff",
        whole_slice_folder
        + folder_name
        + "_"
        + whole_slice_file
        + "_"
        + str(n)
        + ".tif",
    )

# Merging whole site images
IJ.waitForUser("Merging channels. Ready to merge?")
if channels == 3:
    IJ.run(
        "Merge Channels...",
        "c1="
        + folder_name
        + "_"
        + whole_slice_file
        + "_NeuN.tif"
        + " c2="
        + folder_name
        + "_"
        + whole_slice_file
        + "_GFAP.tif"
        + " c3="
        + folder_name
        + "_"
        + whole_slice_file
        + "_Iba1.tif"
        + " create",
    )
elif channels == 2:
    IJ.run(
        "Merge Channels...",
        "c1="
        + folder_name
        + "_"
        + whole_slice_file
        + "_NeuN.tif"
        + " c2="
        + folder_name
        + "_"
        + whole_slice_file
        + "_GFAP.tif"
        + " create",
    )

# Background Subtraction and Brightness/Contrast Adjustment
IJ.waitForUser("Subtracting background and adjusting brightness and contrast. Ready?")
IJ.selectWindow("Composite")
IJ.run("Subtract Background...", "rolling=50")
IJ.run("Brightness/Contrast...")
IJ.run("Enhance Contrast", "saturated=0.35")
IJ.run("Enhance Contrast", "saturated=0.35")
if channels == 3:
    IJ.run("Enhance Contrast", "saturated=0.35")
IJ.saveAs(
    "Tiff",
    whole_slice_folder + folder_name + "_" + whole_slice_file + "_Merged_BG_BC.tif",
)

# ROI Selection
IJ.run("ROI Manager...")
IJ.run(
    "Open...",
    "path='"
    + whole_slice_ROI.getOriginalFileInfo().directory
    + "', filename='"
    + whole_slice_ROI.getOriginalFileInfo().fileName
    + "'",
)
IJ.run("Select All")
IJ.waitForUser("Select the ROI with the whole slice.")
IJ.run("Crop")
IJ.run("ROI Manager...", "delete")

# Setting scale bar
IJ.waitForUser("Setting scale bar and saving images. Ready?")
IJ.run("Set Scale...", "distance=1 known=" + whole_slice_pixel_size + " unit=" + units)
IJ.run("Scale Bar...", "width=1500 height=200 thickness=20 font=75 bold overlay")
IJ.waitForUser("Saving merged images.")
IJ.saveAs(
    "Tiff", whole_slice_folder + folder_name + "_" + whole_slice_file + "_Processed.tif"
)
IJ.saveAs(
    "JPEG",
    whole_slice_folder + folder_name + "_" + whole_slice_file + "_Processed.jpeg",
)
IJ.run("Split Channels")

# Splitting Images
IJ.waitForUser("Saving unmerged images.")
for n in range(1, int(number_of_channels) + 1):
    IJ.selectImage(
        "C" + str(n) + "-" + folder_name + "_" + whole_slice_file + "_Processed.tif"
    )
    IJ.saveAs(
        "Tiff",
        whole_slice_folder
        + folder_name
        + "_"
        + whole_slice_file
        + "_Merged_"
        + "NeuN_GFAP_Iba1"[n - 1]
        + "_Processed.tif",
    )
    IJ.saveAs(
        "JPEG",
        whole_slice_folder
        + folder_name
        + "_"
        + whole_slice_file
        + "_Merged_"
        + "NeuN_GFAP_Iba1"[n - 1]
        + "_Processed.jpeg",
    )

# Process Insertion Site Images

# Split Insertion Site Images
IJ.run("Close All")
IJ.open(subDir + "/" + insertion_site_file + ".czi")
width = WindowManager.getCurrentImage().getWidth()
height = WindowManager.getCurrentImage().getHeight()
channels = WindowManager.getCurrentImage().getNChannels()
IJ.waitForUser("Splitting channels. Ready to split?")
IJ.run("Split Channels")
for n in range(1, int(number_of_channels) + 1):
    WindowManager.getImage("C" + str(n) + "-" + insertion_site_file + ".czi").show()
    IJ.saveAs(
        "Tiff",
        insertion_site_folder
        + folder_name
        + "_"
        + insertion_site_file
        + "_"
        + "NeuN_GFAP_Iba1"[n - 1]
        + ".tif",
    )

# Merge Insertion Site Images
IJ.waitForUser("Merging channels. Ready to merge?")
if channels == 3:
    IJ.run(
        "Merge Channels...",
        "c1="
        + folder_name
        + "_"
        + insertion_site_file
        + "_NeuN.tif"
        + " c2="
        + folder_name
        + "_"
        + insertion_site_file
        + "_GFAP.tif"
        + " c3="
        + folder_name
        + "_"
        + insertion_site_file
        + "_Iba1.tif"
        + " create",
    )
elif channels == 2:
    IJ.run(
        "Merge Channels...",
        "c1="
        + folder_name
        + "_"
        + insertion_site_file
        + "_NeuN.tif"
        + " c2="
        + folder_name
        + "_"
        + insertion_site_file
        + "_GFAP.tif"
        + " create",
    )

# Background Subtraction and Brightness/Contrast Adjustment
IJ.waitForUser("Subtracting background and adjusting brightness and contrast. Ready?")
IJ.selectWindow("Composite")
IJ.run("Subtract Background...", "rolling=50")
IJ.run("Brightness/Contrast...")
IJ.run("Enhance Contrast", "saturated=0.35")
IJ.run("Enhance Contrast", "saturated=0.35")
if channels == 3:
    IJ.run("Enhance Contrast", "saturated=0.35")
IJ.saveAs(
    "Tiff",
    insertion_site_folder
    + folder_name
    + "_"
    + insertion_site_file
    + "_Merged_BG_BC.tif",
)

# ROI Selection
IJ.run("ROI Manager...")
IJ.run(
    "Open...",
    "path='"
    + insertion_site_ROI.getOriginalFileInfo().directory
    + "', filename='"
    + insertion_site_ROI.getOriginalFileInfo().fileName
    + "'",
)
IJ.run("Select All")
IJ.waitForUser("Select the ROI with the insertion site.")
IJ.run("Crop")
IJ.run("ROI Manager...", "delete")

# Setting scale bar
IJ.waitForUser("Setting scale bar and saving images. Ready?")
IJ.run(
    "Set Scale...", "distance=1 known=" + insertion_site_pixel_size + " unit=" + units
)
IJ.run("Scale Bar...", "width=100 height=50 bold overlay")

# Splitting Images
IJ.waitForUser("Saving merged images.")
IJ.saveAs(
    "Tiff",
    insertion_site_folder + folder_name + "_" + insertion_site_file + "_Processed.tif",
)
IJ.saveAs(
    "JPEG",
    insertion_site_folder + folder_name + "_" + insertion_site_file + "_Processed.jpeg",
)
IJ.run("Split Channels")

# Saving unmerged images
IJ.waitForUser("Saving unmerged images.")
for n in range(1, int(number_of_channels) + 1):
    IJ.selectImage(
        "C" + str(n) + "-" + folder_name + "_" + insertion_site_file + "_Processed.tif"
    )
    IJ.saveAs(
        "Tiff",
        insertion_site_folder
        + folder_name
        + "_"
        + insertion_site_file
        + "_Merged_"
        + "NeuN_GFAP_Iba1"[n - 1]
        + "_Processed.tif",
    )
    IJ.saveAs(
        "JPEG",
        insertion_site_folder
        + folder_name
        + "_"
        + insertion_site_file
        + "_Merged_"
        + "NeuN_GFAP_Iba1"[n - 1]
        + "_Processed.jpeg",
    )

# Get measurements
IJ.run("Close All")
IJ.openImage(
    insertion_site_folder + folder_name + "_" + insertion_site_file + "_Processed.tif"
)
IJ.waitForUser("Getting intensity measurements.")
IJ.run("Set Measurements...", "area mean min display redirect=None decimal=3")
IJ.run("Measure")
IJ.run("Set Measurements...", "area mean min display redirect=None decimal=3")
IJ.run("Measure")
if channels == 3:
    IJ.run("Set Measurements...", "area mean min display redirect=None decimal=3")
    IJ.run("Measure")

# Replace with CV
# Get Insertion Radius
IJ.setTool("line")
IJ.waitForUser("Select the insertion site hole")
IJ.run("Measure")

# Replace with CV
# Get insertion area
IJ.setTool("freehand")
IJ.waitForUser("Select the insertion site hole area")
IJ.run("Measure")

# Results Save
results_file_path = os.path.join(directory, directory_name + "_Results.csv")
IJ.saveAs("Results", results_file_path)
