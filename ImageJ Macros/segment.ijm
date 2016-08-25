// Copyright (C) 2016  Gregory L. Futia
// This work is licensed under a Creative Commons Attribution 4.0 International License.


// Fast but script doesn't open ROI manager and
// doesn't label text right in batch mode
// functionality with MIJ broken
//setBatchMode("hide");

fileName = getInfo("image.filename");
fileName = substring(fileName, 0, lengthOf(fileName)-4);
fileDir = getInfo("image.directory");
//call("ij.io.OpenDialog.setDefaultDirectory", fileDir);

// get file information
getDimensions(width, height, channels, slices, frames)
// ImageJ 1.50d no longer reads units from LSM5 files
getVoxelSize(pixWidth, pixHeight, pixDepth, pixUnit); // save it here
setVoxelSize(pixWidth, pixHeight, pixDepth*slices, "um");

// if zstack, zproject
if (slices > 1){
	run("Z Project...", "projection=[Sum Slices]");
} else
{
           // the splitting of the channels that followes will close the origonal image 
	run("Duplicate...", "duplicate"); 
}


maxCounts = slices*65536;

if(channels == 4)
 {
//split up the channels
run("Split Channels");
selectImage(2);
bodipy_title = getTitle();
selectImage(3);
panCK_title = getTitle();
selectImage(4);
DAPI_title = getTitle();
selectImage(5);
CD45_title = getTitle();
print(CD45_title);
 }


if(channels == 3)
 {
//split up the channels
run("Split Channels");
selectImage(2);
DAPI_title = getTitle();
selectImage(3);
bodipy_title = getTitle();
selectImage(4);
panCK_title = getTitle();
selectImage(4);
CD45_title = getTitle();

 }


// threshold the bodipy background
selectWindow(bodipy_title);
run("Green");
// make the coler range the same for all images
setMinAndMax(2000, maxCounts*0.7); 
run("Duplicate...", "title=Bodipy_Mask");
run("Gaussian Blur...", "sigma=1.5 scaled");
//setAutoThreshold("Default dark");
getMinAndMax(minT, maxT);
//setMinAndMax(minT+maxT*0.07, maxT*1.0); old verson
//previous at 18000
// using maxT has problems if levels are low in image
getStatistics(BodipyArea, BodipyMean, BodipyMin, BodipyMax, BodipySTD, BodipyHist);
setMinAndMax(BodipyMax-1, BodipyMax); // new version, this pretty much is turning off this mask
setOption("BlackBackground", false);
run("Convert to Mask");
selectWindow("Bodipy_Mask");
//run("Dilate");
//run("Dilate");
run("Watershed");
run("Add Slice");
mask_title = getTitle();

// threshold the pan CK
selectWindow(panCK_title);
getStatistics(PanCKArea, PanCKMean, PanCKMin, PanCkMax, PanCKSTD, PanCKHist);
run("Yellow");
// make the coler range the same for all images
setMinAndMax(1500, PanCkMax*0.65); 
run("Duplicate...", "title=PanCK_Mask");
run("Gaussian Blur...", "sigma=1.5 scaled");
//setAutoThreshold("Default dark");
getMinAndMax(minT, maxT);
//setMinAndMax(minT+maxT*0.04,maxT);
// previous at 8000
setMinAndMax((PanCkMax-1), (PanCkMax));
setOption("BlackBackground", false);
run("Convert to Mask");
selectWindow("PanCK_Mask");
print("PCK8");
// when called from Matlab this shows at the begining of the script
//waitForUser("Is Mask Image Selected?");
run("Watershed");
print("PCK9");
PanCK_mask = getTitle();
//print(PanCK_mask);
selectWindow(mask_title);


// threshold the DAPI channel
selectWindow(DAPI_title);
run("Blue");
// make the color range the same for all images
setMinAndMax(1500, maxCounts*0.7); 
run("Duplicate...", "title=DAPI_Mask");
run("Gaussian Blur...", "sigma=1.5 scaled");
//setAutoThreshold("Default dark");
getMinAndMax(minT, maxT);
// different for DAPI, use a % of maximum
// to keep code working on 5 slice z stacks
getStatistics(DAPIArea, DAPIMean, DAPIMin, DAPIMax, DAPISTD, DAPIHist);
setMinAndMax(2500, (DAPIMax));
//setMinAndMax(3200, maxT*1.0);
setOption("BlackBackground", false);
run("Convert to Mask");
selectWindow("DAPI_Mask");
run("Dilate");
run("Dilate");
run("Dilate");
//run("Dilate");
run("Watershed");
DAPI_mask = getTitle();
print("DAPI Mask:" + DAPI_mask);
run("Select All");
run("Copy");
selectWindow(mask_title);
run("Paste");
run("Add Slice");

// threshold the CD45 channel
selectWindow(CD45_title);
getStatistics(CD45Area, CD45Mean, CD45Min, CD45Max, CD45STD, CD45Hist);
run("Red");
// make the coler range the same for all images
setMinAndMax(1500, maxCounts*0.75); 
run("Duplicate...", "title=CD45_Mask");
run("Gaussian Blur...", "sigma=1.5 scaled");
//setAutoThreshold("Default dark");
getMinAndMax(minT, maxT);
// setMinAndMax(minT+maxT*0.03, maxT*1.0);
setMinAndMax(CD45Max-1, CD45Max);
setOption("BlackBackground", false);
run("Convert to Mask");
selectWindow("CD45_Mask");
run("Watershed");
CD45_mask = getTitle();
run("Select All");
run("Copy");
selectWindow(mask_title);
run("Paste");


run("Z Project...", "projection=[Max Intensity]");
//run("Watershed");
// the mask has been flattened

// save the masked image
saveAs("PNG", fileDir + "/" + fileName + "_mask.png");
print(fileName);
//call("ij.io.OpenDialog.setDefaultDirectory", fileDir);
//call("ij.io.OpenDialog.setLastName", fileDir);

// if the mask was modified us it instead otherwise proceed
if(File.exists(fileDir + "/" + fileName + "_mask_mod.png"))
{
	open(fileDir + "/" + fileName + "_mask_mod.png");
	getDimensions(widthMask, heightMask, channelsMask, slicesMask, framesMask);
	// some kind of bug sometimes the BMPs load as one slice sometimes 3
            if(slicesMask>1 || channelsMask>1)
	{
            	run("Z Project...", "Projection=[Max Intensity]");
	}
	run("Convert to Mask");
	setVoxelSize(pixWidth, pixHeight, 1, "um");
}

maskedImage = getTitle();

run("Analyze Particles...", "size=10.00-1000.00 um circularity=0.00-1.00 show=Nothing exclude clear add");


// close the masks
selectWindow(PanCK_mask);
close(); // don't use run close -> errors use close(); instead
selectWindow(DAPI_mask);
close();
selectWindow(CD45_mask);
close();


getPixelSize(unit, pixelwidth, pixelheight);


// merge can't handle file names with spaces
if (channels==4)
run("Merge Channels...", "c1=[" + CD45_title +
	"] c2=[" + bodipy_title + 
	"] c3=[" + DAPI_title + 
	"] c7=[" + panCK_title + "] create keep");

else if (channels==3)
	run("Merge Channels...",  "c1=[" + CD45_title +
	"] c2=[" + bodipy_title + 
	"] c3=[" + DAPI_title + "] create keep");

else if (channels==2)
	run("Merge Channels...",  "c2=[" + bodipy_title + 
	"] c3=[" + DAPI_title + "] create keep");

selectWindow("Composite");
run("RGB Color");
rgbImage_title = getTitle();


// create directories incase they don't exist
File.makeDirectory(fileDir + "/zoomed");
File.makeDirectory(fileDir + "/zoomed/channels");
File.makeDirectory(fileDir + "/channels");
File.makeDirectory(fileDir + "/600x600");


roiManager("Set Color", "white");
roiManager("Set Line Width", 0);
// save single channels
if(1)
{
	// Cut & Paste Job for doing all 4 channels
	// could do better but not familar with arrays in ImageJ macro language
	// bodipy
	selectWindow(bodipy_title);
	//run("RGB Color");
	roiManager("Show All with labels");
	run("Flatten");
	scalefactor = getWidth()/(1024*8);
	fontsize = 168*scalefactor;
	run("Scale Bar...",  "width=" + 10 + " height=" + 20*scalefactor + 
		" font=" +168*scalefactor + " color=White background=None location=[Lower Right] bold");
	saveAs("jpeg", fileDir + "/channels/" +fileName
 		+ "bodipy_jpeg.jpeg");

	windowWidth = getWidth();
	windowHeight = getHeight();
	subImageWidth = 1024;
	subImageHeight = 1024;
	makeRectangle(windowWidth/2 - subImageWidth/2, 
		windowHeight/2 - subImageHeight/2, subImageWidth, subImageHeight);
	run("Copy");
	newImage("composite", "RGB", subImageWidth, subImageHeight, 1 );
	run("Paste");
	scalefactor = getWidth()/(1024*8);
	fontsize = 168*scalefactor;
	run("Properties...", 
		"channels=1 slices=1 frames=1 unit=" + unit + 
	" pixel_width=" + pixelwidth +
	" pixel_height=" + pixelheight + " voxel_depth=" + pixelheight);
	run("Scale Bar...",  "width=" + 10 + " height=" + 20*scalefactor + 
		" font=" +168*scalefactor + " color=White background=None location=[Lower Right] bold");
	saveAs("jpeg", fileDir + "/zoomed/channels/" +fileName
 		+ "bodipy_zoomed_jpeg.jpeg");
	
	selectWindow(bodipy_title);
    run("Duplicate...", "Bodipy600x600");
	run("RGB Color");
	roiManager("Show All with labels");
	run("Flatten");
	makeRectangle(1, 1, windowWidth, windowHeight );
	run("Size...", "width=600 height=600 constrain average interpolation=Bilinear");
	saveAs("jpeg", fileDir + "/channels/" +fileName  + "bodipy_600x600_jpeg.jpeg");

	// copy and paste for other channels
	// panCK
	selectWindow(panCK_title);
	//run("RGB Color");
	roiManager("Show All with labels");
	run("Flatten");
	scalefactor = getWidth()/(1024*8);
	
	run("Scale Bar...",  "width=" + 10 + " height=" + 20*scalefactor + 
		" font=" +168*scalefactor + " color=White background=None location=[Lower Right] bold");

	saveAs("jpeg", fileDir + "/channels/" +fileName
 		+ "panCK_jpeg.jpeg");

	windowWidth = getWidth();
	windowHeight = getHeight();
	subImageWidth = 1024;
	subImageHeight = 1024;
	makeRectangle(windowWidth/2 - subImageWidth/2, 
		windowHeight/2 - subImageHeight/2, subImageWidth, subImageHeight);
	run("Copy");
	newImage("composite", "RGB", subImageWidth, subImageHeight, 1 );
	run("Paste");
	scalefactor = getWidth()/(1024*8);
	fontsize = 168*scalefactor;
	run("Properties...", 
		"channels=1 slices=1 frames=1 unit=" + unit + 
	" pixel_width=" + pixelwidth +
	" pixel_height=" + pixelheight + " voxel_depth=" + pixelheight);
	run("Scale Bar...",  "width=" + 10 + " height=" + 20*scalefactor + 
		" font=" +168*scalefactor + " color=White background=None location=[Lower Right] bold");
	saveAs("jpeg", fileDir + "/zoomed/channels/" +fileName
 		+ "panCK_zoomed_jpeg.jpeg");
	
	selectWindow(panCK_title);
	makeRectangle(1, 1, windowWidth, windowHeight );
	run("Duplicate...", "panCK600x600");
	run("RGB Color");
	roiManager("Show All with labels");
	run("Flatten");

	run("Size...", "width=600 height=600 constrain average interpolation=Bilinear");
	saveAs("jpeg", fileDir + "/channels/" +fileName  + "panCK_600x600_jpeg.jpeg");

	// DAPI
	selectWindow(DAPI_title);
	//run("RGB Color");
	roiManager("Show All with labels");	
	run("Flatten");
	scalefactor = getWidth()/(1024*8);
	fontsize = 168*scalefactor;
	run("Scale Bar...",  "width=" + 10 + " height=" + 20*scalefactor + 
		" font=" +168*scalefactor + " color=White background=None location=[Lower Right] bold");
	saveAs("jpeg", fileDir + "/channels/" +fileName
 		+ "DAPI_jpeg.jpeg");

	windowWidth = getWidth();
	windowHeight = getHeight();
	subImageWidth = 1024;
	subImageHeight = 1024;
	makeRectangle(windowWidth/2 - subImageWidth/2, 
		windowHeight/2 - subImageHeight/2, subImageWidth, subImageHeight);
	run("Copy");
	newImage("composite", "RGB", subImageWidth, subImageHeight, 1 );
	run("Paste");
	scalefactor = getWidth()/(1024*8);
	fontsize = 168*scalefactor;
	run("Properties...", 
		"channels=1 slices=1 frames=1 unit=" + unit + 
	" pixel_width=" + pixelwidth +
	" pixel_height=" + pixelheight + " voxel_depth=" + pixelheight);
	run("Scale Bar...",  "width=" + 10 + " height=" + 20*scalefactor + 
		" font=" +168*scalefactor + " color=White background=None location=[Lower Right] bold");
	saveAs("jpeg", fileDir + "/zoomed/channels/" +fileName
 		+ "DAPI_zoomed_jpeg.jpeg");
	
	selectWindow(DAPI_title);
    run("Duplicate...", "DAPI600x600");
    run("RGB Color");
	roiManager("Show All with labels");
	run("Flatten");
	makeRectangle(1, 1, windowWidth, windowHeight );
	run("Size...", "width=600 height=600 constrain average interpolation=Bilinear");
	saveAs("jpeg", fileDir + "/channels/" +fileName  + "DAPI_600x600_jpeg.jpeg");

	// CD45
	selectWindow(CD45_title);
	roiManager("Show All with labels");	
	run("Flatten");
	scalefactor = getWidth()/(1024*8);
	fontsize = 168*scalefactor;
	run("Scale Bar...",  "width=" + 10 + " height=" + 20*scalefactor + 
		" font=" +168*scalefactor + " color=White background=None location=[Lower Right] bold");
	saveAs("jpeg", fileDir + "/channels/" +fileName
 		+ "CD45_jpeg.jpeg");

	windowWidth = getWidth();
	windowHeight = getHeight();
	subImageWidth = 1024;
	subImageHeight = 1024;
	makeRectangle(windowWidth/2 - subImageWidth/2, 
		windowHeight/2 - subImageHeight/2, subImageWidth, subImageHeight);
	run("Copy");
	newImage("composite", "RGB", subImageWidth, subImageHeight, 1 );
	run("Paste");
	scalefactor = getWidth()/(1024*8);
	fontsize = 168*scalefactor;
	run("Properties...", 
		"channels=1 slices=1 frames=1 unit=" + unit + 
	" pixel_width=" + pixelwidth +
	" pixel_height=" + pixelheight + " voxel_depth=" + pixelheight);
	run("Scale Bar...",  "width=" + 10 + " height=" + 20*scalefactor + 
		" font=" +168*scalefactor + " color=White background=None location=[Lower Right] bold");
	saveAs("jpeg", fileDir + "/zoomed/channels/" +fileName
 		+ "CD45_zoomed_jpeg.jpeg");
	
	selectWindow(CD45_title);
	run("Duplicate...", "CD45_600x600");
	run("RGB Color");
	roiManager("Show All with labels");
	run("Flatten");
	makeRectangle(1, 1, windowWidth, windowHeight );
	run("Size...", "width=600 height=600 constrain average interpolation=Bilinear");
	saveAs("jpeg", fileDir + "/channels/" +fileName  + "CD45_600x600_jpeg.jpeg");

}	

selectWindow(rgbImage_title);

// what we want to do is select the middle of the mosaic and make this the zoomed in image
if(getWidth() > 2000)
{
	windowWidth = getWidth();
	windowHeight = getHeight();
	subImageWidth = 1024;
	subImageHeight = 1024;
	makeRectangle(windowWidth/2 - subImageWidth/2, 
		windowHeight/2 - subImageHeight/2, subImageWidth, subImageHeight);
	run("Copy");
	newImage("composite", "RGB", subImageWidth, subImageHeight, 1 );
	run("Paste");
	scalefactor = getWidth()/(1024*8);
	fontsize = 168*scalefactor;
	run("Properties...", 
		"channels=1 slices=1 frames=1 unit=" + unit + 
	" pixel_width=" + pixelwidth +
	" pixel_height=" + pixelheight + " voxel_depth=" + pixelheight);
	run("Scale Bar...",  "width=" + 10 + " height=" + 20*scalefactor + 
		" font=" +168*scalefactor + " color=White background=None location=[Lower Right] bold");
	saveAs("jpeg", fileDir + "/zoomed/" +fileName
 		+ "zoomed_jpeg.jpeg");
}

selectWindow(rgbImage_title);

scalefactor = getWidth()/(1024*8);
fontsize = 168*scalefactor;

run("Scale Bar...",  "width=" + 10 + " height=" + 20*scalefactor + 
	" font=" +168*scalefactor + " color=White background=None location=[Lower Right] bold");
roiManager("Set Color", "white");
roiManager("Show All with labels"); 
run("Flatten");

// set the font color
setColor(255,255,255);
// set the font
setFont("Monospaced", fontsize);
drawString(slices + " Z-Slices Summed \n Num ROIS: " + roiManager("count"), round(getWidth() *0.76), round(getHeight()*0.89), "black");
setFont("Monospaced", fontsize/2);
drawString("(c) Gregory L. Futia 2016", round(getWidth() *0.84), round(getHeight() *0.985), "black");

//Stack.setDisplayMode("composite");
saveAs("jpeg", fileDir + "/" +fileName
 + "_jpeg.jpeg");

run("Size...", "width=600 height=600 constrain average interpolation=Bilinear");
saveAs("jpeg", fileDir + "/600x600/" +fileName  + "600x600_jpeg.jpeg");

print("Select Bodipy Title");
selectWindow(bodipy_title);

print("Select PanCK Title");
selectWindow(panCK_title);

print("Select DAPI Title");
selectWindow(DAPI_title);

print("Select PanCK Title");
selectWindow(CD45_title);

print("Select PanCK Title");
selectWindow(maskedImage);


print("Returning titles");

//setBatchMode("exit and display");

return bodipy_title + ";" + panCK_title + ";" + DAPI_title + ";" + CD45_title + ";" + maskedImage;
