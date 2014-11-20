function [imageNames, numOfFrames,seq_name] = loadInput(dataType, directory)
    ind=find(directory=='\'|directory=='/');
    seq_name=directory(ind(end-1)+1:ind(end)-1);
    if strcmp(dataType, 'png')
        load([directory 'frames'])
        numOfFrames = frames.length;
        imageNames = cell(1,numOfFrames*2);
        for i = 1:numOfFrames
            imageNames{2*i-1} = fullfile(directory,sprintf('rgb/r-%d-%d.png', frames.imageTimestamp(i), frames.imageFrameID(i)));
            imageNames{2*i} = fullfile(directory,sprintf('depth/d-%d-%d.png', frames.depthTimestamp(i), frames.depthFrameID(i)));

        end
    elseif strcmp(dataType, 'bmppng')
        ext = {'*.bmp','*.png'};
    
        images = [];
        for i = 1:length(ext)
            images = [images;dir([directory ext{i}])];
        end
        numOfFrames = length(images)/2;

        imageNames = cell(1,length(images));
        for i = 1:numOfFrames
            imageNames{2*i-1} = [directory images(i).name];
            imageNames{2*i}   = [directory images(i+numOfFrames).name];
        end
    else
        fprintf('input type "%s" unrecognized.\n', dataType);
    end
end