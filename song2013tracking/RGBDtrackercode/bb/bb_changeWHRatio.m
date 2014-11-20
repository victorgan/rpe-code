function resizedBBList = bb_changeWHRatio(bbList, ratio, imsize)
    if isempty(bbList),
        resizedBBList = [];
        return;
    end

    center = bb_center(bbList);
    width = round(sqrt(bb_area(bbList)/ratio));
    height = width * ratio;
    
    resizedBBList = zeros(size(bbList));
    resizedBBList(1,:) = max(1, round(center(1,:) - width/2));
    resizedBBList(2,:) = max(1, round(center(2,:) - height/2));
    resizedBBList(3,:) = min(resizedBBList(1,:) + width,imsize(2));
    resizedBBList(4,:) = min(resizedBBList(2,:) + height,imsize(1));
end