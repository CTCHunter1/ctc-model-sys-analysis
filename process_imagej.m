% Copyright (C) 2016  Gregory L. Futia
% This work is licensed under a Creative Commons Attribution 4.0 International License.

% Description: Processes .lsm image data into a .mat file containing image
% features for the 4 channels. Expected 4 channels are DAPI, Bodipy, CD45,
% and PanCK. 

function [] = process_imagej(inputFileName)
%nargin=0;

% the Java variables need to be deleted before reinitializing
clear roiManager;
clear roisArr;
clear poly;
clear CH2imagePlusObj;
clear CH2imagePlusObjCal;
 
close all;

% Preliminary
% Put the transformers path into the path if it isn't already
if(exist('transformer', 'file') == 0)
    path(path, 'Transformers');
end    

if(exist('findFWHM', 'file') == 0)
    path(path, 'Utility');
end  

% if(exist('Miji', 'file') == 0)
%     % needs to be conditional on the machine we are using.
%     path(path, 'C:\Users\Researcher\Documents\FIJI\fiji-nojre\Fiji.app\scripts');
% end

% wdir = pwd;
% %replaced below code with this call
% Miji();
% cd(wdir);

if exist(['ImageJ', filesep, 'IJ150'], 'dir') == 0
    fprintf('First Run. Unzipping ImageJ...\n');
    unzip(['ImageJ', filesep, 'ij150.zip'], ['ImageJ']);
    movefile(['ImageJ', filesep, 'ImageJ'], ['ImageJ', filesep, 'IJ150']);    
end

%Add imagej path
if(exist('MIJ') ~= 8)
    javaaddpath 'MIJ\MIJ1.3.9\mij.jar'
    javaaddpath 'ImageJ\IJ150\ij.jar'    
end



closeImageJ;

%MIJ.start('C:\Git Repository\ctc-model-sys-analysis\ImageJ\IJ150\plugins');
MIJ.start([pwd, filesep, 'ImageJ', filesep, 'IJ150' filesep, 'plugins']); 


if (nargin < 1)
    [filename, pathname] = uigetfile('*.oib; *.lsm', 'Pick a Image file (OIB, LSM)', 'Example Data\');    
    if isequal(filename,0) || isequal(pathname,0)
       return; % user pressed cancel
    end    
elseif nargin == 1
     [pathname,filename,extension] = fileparts(inputFileName);
     filename = [filename, extension];
     % if the file is in the current working directory
     if(length(pathname) < 1)
         pathname = pwd;
     end
end

fullFileName = fullfile(pathname, filename);

% Start imagej will all plugins
% Only need to start MIJ once

if strcmp(filename(end-2:end), 'oib')
    MIJ.run('Bio-Formats Importer', ['open=[', fullFileName, '] ',...
        'view=Hyperstack stack_order=XYCZT']);
elseif strcmp(filename(end-2:end), 'lsm')
    MIJ.run('Open...', ['path=[' , fullFileName , ']']);
end

mainIJObj = ij.IJ.getImage();
numColors = get(mainIJObj, 'NChannels');

% this imagej macro preforms the segmentation
windowNames = ij.IJ.runMacroFile([pwd, filesep, 'ImageJ Macros', filesep, 'segment.ijm']);
% the names of the 4 color windows of interest are returned in a
% ; separated list followed by the name of the masked image
windowNames = strsplit(char(windowNames), ';'); 


% Lagacy flexiblity for lower channel count images

% If numColors is 2, channel 1 is Bodipy, channel 2 is dye cycle ruby
% if numColors is 3, channel 1 is CD45, channel 2, is bodipy, 
% and channel 3 is dye cycle ruby
switch numColors    
    case 2
        colorNames{1} = 'Green';
        colorNames{2} = 'Blue';    
        bodipyIndex = 1;
        DCRIndex = 2;
    case 3
        channelNames{3} = 'DAPI';
        channelNames{1} = 'Bodipy';
        channelNames{2} = 'PanCK';
        channelNames{4} = 'CD45';
        
        CD45Index = 4;
        bodipyIndex = 1;
        DCRIndex = 3;
        PANCKIndex = 2;
    case 4
        channelNames{3} = 'DAPI';
        channelNames{1} = 'Bodipy';
        channelNames{2} = 'PanCK';
        channelNames{4} = 'CD45';
        
        CD45Index = 4;
        bodipyIndex = 1;
        DCRIndex = 3;
        PANCKIndex = 2;
end
   
% Get image IDs for each windo
for ii = 1:numColors
ij.IJ.selectWindow(windowNames{1}); 
CHimagePlusObj{ii} = ij.IJ.getImage();
CHIds(ii) = CHimagePlusObj{ii}.getID();
end

CH1imagePlusObjCal = CHimagePlusObj{1}.getCalibration();
CH1Dimensions = CHimagePlusObj{1}.getDimensions();
% only programed for units of microns
if(strcmp(CH1imagePlusObjCal.getYUnit(), 'µm'))
    dx = CH1imagePlusObjCal.getX(1)*10^-6;
    dy = CH1imagePlusObjCal.getY(1)*10^-6;
else
    % somethign else, hard code if you like
    dx = 200E-9;
    dy = 300E-9;
end


clear('ND(1)'); 
% Get the ROI mamager
roiManager = ij.plugin.frame.RoiManager.getInstance;
% Get the results table
resultsTable = ij.plugin.filter.Analyzer.getResultsTable();
areaColumnIndex = resultsTable.getColumnIndex('Area');
if(areaColumnIndex ~= ij.measure.ResultsTable.COLUMN_NOT_FOUND) % check if this measurement is there
    areaArr_um2 = resultsTable.getColumnAsDoubles(areaColumnIndex).';    
end 


numParticles = roiManager.getCount();
roisArr = roiManager.getRoisAsArray(); 

% get the thresholded image
ij.IJ.selectWindow(windowNames{end});
MaskedImage = double(MIJ.getCurrentImage);

% get the single color images
ij.IJ.selectWindow(windowNames{bodipyIndex});
zProjectImg{1} = double(MIJ.getCurrentImage);

ij.IJ.selectWindow(windowNames{DCRIndex});
zProjectImg{3} = double(MIJ.getCurrentImage);

ij.IJ.selectWindow(windowNames{CD45Index});
zProjectImg{4}= double(MIJ.getCurrentImage);

ij.IJ.selectWindow(windowNames{PANCKIndex});
zProjectImg{2}= double(MIJ.getCurrentImage);


%%
ND.fileName = filename;
ND.numROIs = numParticles;

for ii = 1:length(zProjectImg)
    ND.Channels.(channelNames{ii}) = computeROIFeatures(zProjectImg{ii}, roisArr, dx, dy);
end

ND(1).roisArr = roisArr;
ND(1).dx = dx;
ND(1).dy = dy;
 
delete([fullFileName(1:end-4), '.mat']);
save([fullFileName(1:end-4), '.mat'], 'ND');

%imagesc(zProjectImgCh2.*poly2mask(double(poly.xpoints), double(poly.ypoints), M, N));
[xArr, yArr, ROIImg, ROImask] = getROIframe(zProjectImg{3}, roisArr, dx, dy, round(numParticles/2));
figure;
imagesc(xArr*10^6, yArr*10^6, ROIImg);

bounds = struct(roisArr(round(numParticles/2)).getBounds());
poly = struct(roisArr(round(numParticles/2)).getPolygon());     
%bounds = struct(roisArr(kk).getPolygon().getBounds());       

% have to use get field to avoid dot name ref to non scalar struct
% error 
x = getfield(poly, 'xpoints') - getfield(bounds, 'x');
y = getfield(poly, 'ypoints') - getfield(bounds, 'y');

mask = poly2mask(double(x),  double(y), bounds.height, bounds.width);
xClip = [bounds.x:bounds.x+bounds.width-1];
yClip = [bounds.y:bounds.y+bounds.height-1];    

figure;
imagesc(xArr*10^6, yArr*10^6, zProjectImg{3}(yClip, xClip));

%figure;
%imagesc(xArr*10^6, yArr*10^6, R2);


figure;
subplot(3, 1, 1);
% the (:) fixed dot name reference error
hist(ND.Channels.DAPI.totalSig_dBc(:), 50); 
title('Total Signal(dBCounts) - DAPI');
subplot(3, 1, 2);
hist(ND.Channels.DAPI.radius_m(1, :)*10^6, 50)
title('Second Moment Radius - DAPI');
xlabel('in (um)');
subplot(3, 1, 3);
hist(ND.Channels.DAPI.numPixels(:), 50)
title('ImageJ Radius(From Area) - DAPI');

figure;
subplot(4, 1, 1);
% the (:) fixed dot name reference error
hist(ND.Channels.DAPI.totalSig_dBc(:), 50); 
title('Total Signal(Counts) - DAPI');
subplot(4, 1, 2);
hist(ND.Channels.Bodipy.totalSig_dBc(:), 50)
title('Total Signal(Counts) - Bodipy');
xlabel('in (um)');
subplot(4, 1, 3);
hist(ND.Channels.CD45.totalSig_dBc(:), 50)
title('Total Signal(Counts) - CD45');
subplot(4, 1, 4);
hist(ND.Channels.PanCK.totalSig_dBc(:), 50)
title('Total Signal(Counts) - PanCK');



figure;
subplot(3, 1, 1);
hist(ND.Channels.Bodipy.totalSig_dBc(:), 50)
title('Total Signal(dB Counts) - Bodipy');
subplot(3, 1, 2);
hist(ND.Channels.Bodipy.radius_m(1, :)*10^6, 50)
title('Second Moment Radius - Bodipy');
xlabel('in (um)');
subplot(3, 1, 3);
hist(ND.Channels.Bodipy.radius_invm(:), 50)
title('ImageJ Radius(From Area) - NA');

figure;
subplot(3, 1, 1);
hist(ND.Channels.PanCK.radius_m(1,:)*10^6, 50)
title({filename, 'Second Moment Radius - DAPI'});
xlabel('in (um)');
subplot(3, 1, 2);
hist(ND.Channels.PanCK.radius_invm(1,:), 50)
title('Radius in Spatial Frequency - DAPI');
subplot(3, 1, 3);
hist(ND.Channels.PanCK.M2(1,:), 50)
title('M2  - DAPI');

figure;
subplot(3, 1, 1);
hist(ND.Channels.CD45.radius_m(1,:)*10^6, 50)
title({filename, 'Second Moment Radius - CD45'});
xlabel('in (um)');
subplot(3, 1, 2);
hist(ND.Channels.CD45.radius_invm(1,:), 50)
title('Radius in Spatial Frequency - CD45');
subplot(3, 1, 3);
hist(ND.Channels.CD45.M2(1,:), 50)
title('M2 - CD45');

%end
