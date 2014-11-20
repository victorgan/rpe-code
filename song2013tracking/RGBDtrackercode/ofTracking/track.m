function [BB2, conf] = track(BB, IM1, IM2, featurePym, svm,id)
    BB = round(BB);

    width = size(IM1,2);
    height = size(IM1,1);

    %% choose relavent area
    BBx = round((BB(1) + BB(3)) / 2);
    BBy = round((BB(2) + BB(4)) / 2);
    bb = [max(1,2*BB(1)-BBx); max(1,2*BB(2)-BBy); min(width,2*BB(3)-BBx); min(height,2*BB(4)-BBy)];
    im1 = IM1(bb(2):bb(4),bb(1):bb(3),:);
    im2 = IM2(bb(2):bb(4),bb(1):bb(3),:);
    
    width = size(im1,2);
    height = size(im1,1);
    offset = [bb(1)-1; bb(2)-1];
    BBOff = [BB(1)-offset(1); BB(2)-offset(2); BB(3)-offset(1); BB(4)-offset(2)];
    BBOff = [max(1,BBOff(1)); max(1,BBOff(2)); min(width,BBOff(3)); min(height,BBOff(4))];
    
    %% optical flow
    X1 = repmat(1:width, [height,1]);
    Y1 = repmat((1:height)', [1,width]);
    [X2,Y2,isValid] = ofTracking(im1,im2);
    
    grid = 10;
    sample = zeros(height,width); 
    sample(round(1:height/grid:height),round(1:width/grid:width)) = 1;
    isValid = isValid & sample;
    
    %% pick valid points
    inBB = zeros(height,width);
    inBB(BBOff(2):BBOff(4),BBOff(1):BBOff(3)) = ones(size(inBB(BBOff(2):BBOff(4),BBOff(1):BBOff(3))));
    isValid = isValid & inBB;
    tmp1 = X1(isValid); tmp2 = Y1(isValid);
    points1 = [tmp1(:)'; tmp2(:)'];
    tmp1 = X2(isValid); tmp2 = Y2(isValid);
    points2 = [tmp1(:)'; tmp2(:)'];

    clear tmp1 tmp2 inBB;
    
    %% calculate new bounding box
    bb2 = bb_predict(BBOff,points1,points2);
    BB2 = [bb2(1)+offset(1); bb2(2)+offset(2); bb2(3)+offset(1); bb2(4)+offset(2)];
    
    %% calculate tracking confidence
    conf  = hogGetConf(BB2,featurePym,svm);
    
    %{    
    temp=load('Demo_track.mat');
    Demo_track=temp.Demo_track;
    Demo_track.point1{id}=points1+repmat([offset(1);offset(2)],1,size(points1,2));
    Demo_track.point2{id}=points2+repmat([offset(1);offset(2)],1,size(points2,2));
    Demo_track.bb1{id}=BB;
    Demo_track.bb2{id}=BB2;
    save('Demo_track.mat','Demo_track');
    %}
end