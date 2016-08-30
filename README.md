# matlab-imagej-image-cytometry
This is Matlab software. 

process_imagej.m will segment .lsm microscopy files into regions of interest and compute metrics with the function computeROIFeatures.m. The resulting features are output in a .mat file containing a structure with a substructure for each channel containing the individual features. 

process_imagej_directories. will run process_imagej.m on all *.lsm files in the selected directoreies. 

ImageJ directory contains a .zip of a ImageJ release this code is known to work with. Unzip this into the IJ150 folder such that ij.jar is in the IJ150 folder. 

Tested on Matlab 2015a
