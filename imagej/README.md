# imagej

ImageJ/Fiji macro for histology image processing.

| File | Purpose |
| --- | --- |
| `Histology_Insertion_Image_Processing.ijm` | Batch-processes confocal images acquired at CABIS/MBIC using the Whole Slice and Insertion Site profiles. For each subfolder of CZI files it splits channels, merges, subtracts background, runs brightness/contrast enhancement, crops to a supplied ROI, adds scale bars, and saves all channels as TIFF and JPEG. Also collects intensity and insertion-site geometry measurements to a results CSV. |

## Usage
Run in Fiji (`Plugins > Macros > Run...`), or headless via `../python/Running.py`, which initializes ImageJ2 with Fiji and executes this macro. The macro prompts for the root directory, ROI files, file names, pixel sizes, and units.

Channels are assumed to be NeuN / GFAP / Iba1 (2- or 3-channel).
