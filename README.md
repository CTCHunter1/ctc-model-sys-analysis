# matlab-imagej-image-cytometry
This is Matlab software. 

process_imagej.m will segment .lsm microscopy files into regions of interest and compute metrics with the function computeROIFeatures.m. The resulting features are output in a .mat file containing a structure with a substructure for each channel containing the individual features. Example data is included in teh Example Data folder more data has been made [publically available http://dx.doi.org/10.5281/zenodo.44884](http://dx.doi.org/10.5281/zenodo.44884). 

process_imagej_directories. will run process_imagej.m on all *.lsm files in the selected directoreies. 

ImageJ directory contains a .zip of a ImageJ release this code is known to work with. First time runs of process_imagej.m will unzip this directory and rename it from ImageJ to IJ150. If Matlab isn't finding ImageJ it may be a permission issue in this process.  

Tested on Matlab 2015a
