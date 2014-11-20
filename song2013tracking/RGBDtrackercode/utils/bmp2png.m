clear all
close all
clc

dataPath = 'D:\vs2010projects\kinectRecord\kinectRecord\bear_back\';
numOfPoints = 30;
[imageNames, numOfFrames] = loadInput('bmp', dataPath);

for frameId = 1:numOfFrames
    fprintf('converting frame %d...\n', frameId);
    [rgb, depth] = readFrame('bmp', imageNames, frameId);

    depthImName = imageNames{2*frameId-1};
    depthImName = [depthImName(1:end-4) '.png'];
    imwrite(depth/255,depthImName);
end