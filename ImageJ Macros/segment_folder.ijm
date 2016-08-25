/*
 * Macro template to process multiple images in a folder
 Modified to run segment.ijm on a folde of .lsm files 
 */

input = getDirectory("Input directory");
output = input;
//output = getDirectory("Output directory");

//Dialog.create("File type");
//Dialog.addString("File suffix: ", ".tif", 5);
//Dialog.show();
//suffix = Dialog.getString();

suffix = '.lsm';

setBatchMode("hide");
processFolder(input);
setBatchMode("exit and display");


function processFolder(input) {
	list = getFileList(input);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + list[i]))
			processFolder("" + input + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	// do the processing here by replacing
	// the following two lines by your own code
	print("Processing: " + input + file);
	
	open(input + file);
	runMacro("C:\\Vespucci Repository\\Projects\\Nuclear Second Moment\\Code\\ImageJ Macros\\segment.ijm");
	
run("Close All");
}
