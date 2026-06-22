import imagej as IJ
import subprocess

# initialize ImageJ2 with Fiji plugins
ij = IJ.init("sc.fiji:fiji")
print(f"ImageJ2 version: {ij.getVersion()}")

ij.py.run_macro("../imagej/Histology_Insertion_Image_Processing.ijm")
