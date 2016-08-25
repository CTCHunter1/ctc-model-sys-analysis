% Copyright (C) 2015  Gregory L. Futia
% This work is licensed under a Creative Commons Attribution 4.0 International License.

% Description: Processes all lsm5 files in each imagej directory selected

directory_names{1} = uigetdir(pwd, ...
    'Select a Directory for Processing');
index = 1;

while ~isequal(directory_names{index},0)
    index = index + 1;
    directory_names{index} = uigetdir(directory_names{index-1}, ...
    'Select a Directory for Processing');        
end

NumDirectories = index -1;

if NumDirectories == 0
    return;
end

processCase = 1; % processImageJ
%processCase = 2; % createhistograms

for jj = 1:NumDirectories
    if processCase == 1
        fileNames = dir([directory_names{jj}, '/*.lsm']);
    elseif processCase == 2
        fileNames = dir([directory_names{jj}, '/*.mat']);
    end    
        
    Nfiles = length(fileNames);

    % no *lsm files found
    if Nfiles <= 0
        return;
    end

    fsepchar = filesep();
    for ii = 1:Nfiles
       fprintf('Starting File: %d\n', ii);
      
       % execute process imagej
       if processCase == 1         
           % only do this if there is no .mat file with the same name
           if(~exist([directory_names{jj}, fsepchar , fileNames(ii).name(1:end-4), '.mat'], 'file'))
               process_imagej([directory_names{jj}, fsepchar , fileNames(ii).name]);
           end
           close all;
           closeImageJ;
           % create histograms
       elseif processCase == 2
           create_histograms([directory_names{jj}, fsepchar , fileNames(ii).name]);
       end
    end
end