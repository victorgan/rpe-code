function [X, Y, isValid] = ofTracking(im1, im2)
    im1 = double(im1);
    im2 = double(im2);
    width = size(im1,2);
    height = size(im1,1);

    if sum(size(im1)>1) < 3,
        im1 = double(repmat(im1, [1 1 3]));
        im2 = double(repmat(im2, [1 1 3]));
    end
    
    % calculate flow
    flowForward = mex_LDOF(im1,im2);
    flowBackward = mex_LDOF(im2,im1);
    %flowForward = mex_OF(im1,im2);
    %flowBackward = mex_OF(im2,im1);
    %[flowForward(:,:,1),flowForward(:,:,2),~]=Coarse2FineTwoFrames(im1,im2);
    %[flowBackward(:,:,1),flowBackward(:,:,2),~]=Coarse2FineTwoFrames(im2,im1);
    
    %% check validity: consistency
    ax = repmat(1:width, [height,1]);
    ay = repmat((1:height)', [1,width]);
    bx = ax + flowForward(:,:,1);
    by = ay + flowForward(:,:,2);
    bx1 = floor(bx); bx2 = bx1 + 1;
    by1 = floor(by); by2 = by1 + 1;
    alphaBx = bx - bx1;
    alphaBy = by - by1;
    isValid = bx1>=1 & bx2<=width & by1>=1 & by2<=height;
    bx1(~isValid) = 1; bx2(~isValid) = 1; by1(~isValid) = 1; by2(~isValid) = 1;
    u = (1-alphaBy).*((1-alphaBx).*flowBackward(sub2ind(size(flowBackward),by1,bx1,ones(size(bx1))))...
                        + alphaBx.*flowBackward(sub2ind(size(flowBackward),by1,bx2,ones(size(bx1)))))...
          + alphaBy.*((1-alphaBx).*flowBackward(sub2ind(size(flowBackward),by2,bx1,ones(size(bx1))))...
                        + alphaBx.*flowBackward(sub2ind(size(flowBackward),by2,bx2,ones(size(bx1)))));
    v = (1-alphaBy).*((1-alphaBx).*flowBackward(sub2ind(size(flowBackward),by1,bx1,2*ones(size(bx1))))...
                        + alphaBx.*flowBackward(sub2ind(size(flowBackward),by1,bx2,2*ones(size(bx1)))))...
          + alphaBy.*((1-alphaBx).*flowBackward(sub2ind(size(flowBackward),by2,bx1,2*ones(size(bx1))))...
                        + alphaBx.*flowBackward(sub2ind(size(flowBackward),by2,bx2,2*ones(size(bx1)))));
    cx = bx + u;
    cy = by + v;
    isValid = isValid & (cx-ax).^2 + (cy-ay).^2 < 0.01 * (flowForward(:,:,1).^2 + flowForward(:,:,2).^2 + u.^2 + v.^2);
    
    %% check validity: motion edge
    dyFilter = fspecial('sobel');
    dxFilter = dyFilter';
    motionEdge = conv2(flowForward(:,:,1), dxFilter, 'same').^2 ...
               + conv2(flowForward(:,:,1), dyFilter, 'same').^2 ...
               + conv2(flowForward(:,:,2), dxFilter, 'same').^2 ...
               + conv2(flowForward(:,:,2), dyFilter, 'same').^2;
    isValid = isValid & motionEdge < 0.01*(u.^2+v.^2)+0.002;
    X = round(bx);
    Y = round(by);
end