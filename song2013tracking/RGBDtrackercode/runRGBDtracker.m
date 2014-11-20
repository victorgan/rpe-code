addpath(genpath('.'));
close all;

% source  
source.dataType = 'png';    
source.directory = './data/';

control.detectionMode = 'rgbd';      % 'rgb' or 'd' or 'rgbd'
control.enableRecenter = 1;
control.occlusionhandle=1;
control.enableLearning = 1;
control.enableOF=1;

%display
control.filterRGB = 0; 
control.showtarlist = 0;
control.showResult=1;
control.debug = 1; %show segmentation result and histogram if set 

%output
control.savevideo=1;
outputpath='./output/';

% Run rgbd tracker
rgbdTracking(outputpath,source,control)