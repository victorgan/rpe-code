function [tarBB, occBB, tarlist, id] = segOccRGBD(bb, occBBPrev, frameCurr, featurePym, svm, targetInfo, control,frameId)
    rgbIm = frameCurr.rgb;
    depthIm = frameCurr.depth;
    targetDepth = frameCurr.targetDepth;
    gm = frameCurr.distribution;

    tarBB = [];
    occBB = occBBPrev;
    bb=enlargeBB(bb ,0.1,size(depthIm));
    bb=round(bb);
    depthIm_bb=depthIm(bb(2):bb(4), bb(1):bb(3));
    id=[];
    H = fspecial('gaussian',[1,5],0.5);
    bin = 150;
    [X D] = hist(double(depthIm_bb(:)),bin);
    X = convn(X, H, 'same');
    [P LOC]=findpeaks([0 X 0],'SORTSTR','descend','MINPEAKDISTANCE',2,'MINPEAKHEIGHT',20);

    %find occdepth
    occlocs=(LOC(D(LOC-1)>targetDepth+gm.depth.Sigma));
    occ_depth = [];
    occmask=ones(size(depthIm));
    if ~isempty(occlocs),
        occ_depth=D(occlocs(1)-1);
        ct_diff = occ_depth-gm.depth.mu;
        [occBB,occmask] = singleSegRGBD(ct_diff,rgbIm,depthIm,occ_depth,bb,gm,control.debug);
    else
         disp('occ depth is empty');
         ct_diff=gm.depth.Sigma;
    end
    if isempty(occBB),occBB=occBBPrev;end

    %return a list of tarBB in the searching range
    tarBBList = singleSegTar( ct_diff,rgbIm,depthIm,occ_depth,occmask,bb,gm,control.debug,frameId); 
    
    % modify tarBB to fit svm width/height ratio
    tarBBList = bb_changeWHRatio(tarBBList, svm.featureDim(1)/svm.featureDim(2), size(depthIm));
    
    %for each target bb caculate confidience
    tarlist = struct('bb',[],'Conf_color',[],'Conf_class',[]);
    num_tar = size(tarBBList,2);
    if isempty(tarBBList), 
        disp('total occ');
    else
        tarlist.bb=nan(4,num_tar);
        tarlist.Conf_class=nan(1,num_tar);
        tarlist.Area=nan(1,num_tar);
        sdArea = bb_area(targetInfo.firstBB);
        for j=1:size(tarBBList,2),
            conf  = hogGetConf(tarBBList(:,j), featurePym, svm);
            tarlist.bb(:,j)=tarBBList(:,j);
            tarlist.Conf_class(j)= conf;
            tarlist.Area(j)=(bb_area(tarBBList(:,j))-sdArea)/sdArea;
        end
        %output the most possible target BB
        idx =  tarlist.Conf_class>-999;
        tarlist.bb=tarlist.bb(:,idx);
        tarlist.Conf_class=tarlist.Conf_class(idx);
        tarlist.Area=tarlist.Area(idx);
        if sum(idx(:))>0,
            [conf,id]=max(tarlist.Conf_class);
            if ~isempty(id)&&conf>0.3*svm.thr, tarBB=tarlist.bb(:,id);end
        end
    end
    
end

