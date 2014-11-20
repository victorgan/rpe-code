function [rgb, depth] = readFrame(dataType, imageNames, frameId)
    if strcmp(dataType, 'oni')
        fprintf('???,???????...\n');
    elseif strcmp(dataType, 'img') || strcmp(dataType, 'bmp') || strcmp(dataType, 'bmppng'),
        % read rgb data
        rgb = imread(imageNames{frameId*2-1});
        % read depth data
        depth = double(imread(imageNames{frameId*2}));
        depth=depth(:,:,1);
    elseif strcmp(dataType, 'png')
        % read rgb data
        rgb = imread(imageNames{frameId*2-1});
        % read depth data
        depth = imread(imageNames{frameId*2});
        depth = bitor(bitshift(depth,-3), bitshift(depth,16-3));
        depth = double(depth);
        depth(depth==0) = 10000;
        % rescale depth
        depth = (depth-500)/8500;%only use the data from 0.5-8m
        depth(depth<0) = 0;
        depth(depth>1) = 1;
        depth = 255*(1 - depth);
    else
        fprintf('input type "%s" unrecognized.\n', dataType);
    end
end