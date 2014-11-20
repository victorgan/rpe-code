function [frameCurr, svm] = processFrame(frameId, frameCurr, framePrev, svm,targetInfo, control)
    frameCurr.occBB=[];
    frameCurr.distribution = framePrev.distribution;
    frameCurr.totalOcc=0;
    frameCurr.targetDepth = framePrev.targetDepth;
    frameCurr.learned = 0;
    frameCurr.tarList = [];
    frameCurr.choice = [];
    if control.filterRGB, frameCurr.rgb = frameCurr.rgb .* uint8(repmat((frameCurr.depth>(frameCurr.distribution.depth.mu-5* frameCurr.distribution.depth.Sigma)), [1 1 3])); end
    if ~control.occlusionhandle,framePrev.underOcclusion=0;end
    %% no occlusion
    if ~framePrev.underOcclusion,
        % extract feature
        featurePym = getFeaturePym(control.detectionMode, frameCurr.rgb, frameCurr.depth, svm.scale);
        % detection
        [dBB, dConf] = hogDetection(featurePym, svm);
        % tracking
        if control.enableOF
            [tBB, tConf] = track(framePrev.bb, framePrev.rgb, frameCurr.rgb, featurePym, svm,frameId);
        else
            [tBB,tConf] = noTrack(framePrev.bb,featurePym, svm);
        end
        
        % pick bb with highest confidence
        if tConf > 0,
            % calculate detection and tracking consistency
            overlap = bb_overlap(tBB,dBB);
            distance = bb_dis(tBB,dBB) / sqrt(bb_area(tBB));
            finalConf = dConf + tConf*max(0,overlap-0.5) - tConf*distance;
            [winnerConf, winnerId]= max(finalConf);
            w=tConf/(winnerConf+tConf);
            winnerBB = (1-w)*dBB(:,winnerId)+w*tBB;
        else
            finalConf = dConf;
            [winnerConf, winnerId]= max(finalConf);
            winnerBB = dBB(:,winnerId);
        end
        % check validity
        frameCurr.choice = 'd';
        toLearn = 1;

        if isempty(winnerConf) || winnerConf < tConf,
            winnerBB = tBB;
            winnerConf = tConf;
            frameCurr.choice = 't';
            toLearn = 0;
        elseif winnerConf < svm.thr,
            toLearn = 0;
        end
        frameCurr.bb = winnerBB;
        frameCurr.conf = winnerConf;
        % check occlusion
        [p, depthCurr, reduceA] = CheckOcc(framePrev, frameCurr, frameCurr.bb, targetInfo, control, frameId);
 
        frameCurr.underOcclusion = frameCurr.conf < 0.8*svm.thr || reduceA>0.6 || abs(p)>0.26;
        if ~control.occlusionhandle||frameId<4,frameCurr.underOcclusion = 0;end
        
        if ~frameCurr.underOcclusion,frameCurr.targetDepth = depthCurr;end
        
        if frameCurr.underOcclusion,
            % initialize occlusion
            [tmpBB, tmpOccBB, ~, ~] = segOccRGBD(framePrev.bb, framePrev.occBB, frameCurr, featurePym, svm, targetInfo, control,frameId);
            if isempty(tmpOccBB)
                frameCurr.underOcclusion = 0;
            else
                if frameCurr.conf <1.6*svm.thr,
                    frameCurr.bb = tmpBB;
                end
                frameCurr.occBB = tmpOccBB;
            end
        end;
       
        % whether to learn
        if control.enableLearning && toLearn && ~frameCurr.underOcclusion && ...
        frameCurr.conf < 2.5*svm.thr && (mod(frameId,3)==1 || frameId<5),
            svm = hogTrainSVM(frameCurr.rgb, frameCurr.bb, featurePym, svm, 1, 0);
            learned = 1;
        else 
            learned = 0;
        end
        
        if control.enableRecenter && ~frameCurr.underOcclusion,
            % adjust bb according to depth
            frameCurr.bb = recenterRGBD(frameCurr.depth, frameCurr.rgb, frameCurr.bb, framePrev.distribution, control.debug,frameId);
        end
        svm = testingSVM(svm, frameId, frameCurr.conf);
        % update
        frameCurr.learned=learned;
        frameCurr.distribution.depth=gmdistribution(frameCurr.targetDepth, frameCurr.distribution.depth.Sigma);

    %% pervious frame under occlusion
    else
        % extract feature
        featurePym = getFeaturePym(control.detectionMode, frameCurr.rgb, frameCurr.depth, svm.scale);
        % track occluder
        [frameCurr.occBB, ~] = track(framePrev.occBB, framePrev.rgb, frameCurr.rgb, featurePym, svm,frameId);
        if isempty(frameCurr.occBB), frameCurr.occBB = framePrev.occBB; end;
        % detection
        [dBB, dConf] = hogDetection(featurePym, svm);
        % seg
        [tarBB, frameCurr.occBB, targetList, targetIndex] = segOccRGBD(framePrev.occBB, framePrev.occBB, frameCurr, featurePym, svm, targetInfo, control,frameId);
        frameCurr.tarList = targetList;
        % calculate detection and segmentation consistency
        maxTBB = tarBB;
        maxTConf = targetList.Conf_class(targetIndex);
        overlap = bb_overlap(maxTBB,dBB);
        % pick bb with highest confidence
        if maxTConf > 0,
            finalConf = dConf + maxTConf*max(0,overlap);
        else
            finalConf = dConf;
        end
        [winnerConf, winnerId]= max(finalConf);
        winnerBB = dBB(:,winnerId);
        disToocc=bb_dis(frameCurr.occBB,winnerBB)/ sqrt(bb_area(targetInfo.firstBB));
        if ~isempty(framePrev.bb)
            disToTar=bb_dis(framePrev.bb,winnerBB)/ sqrt(bb_area(targetInfo.firstBB));
            disToocc=min (disToocc,disToTar);
        end
        % choose target bb
        if winnerConf > 0.8*svm.thr,
            frameCurr.bb =winnerBB;
            frameCurr.conf= winnerConf;
            fromlist=0;
        else
            frameCurr.bb = tarBB;
            frameCurr.conf = targetList.Conf_class(targetIndex);
            fromlist=1;
        end
        % check recovery
        frameCurr.underOcclusion =1;
        if ~isempty(frameCurr.bb)
            [p, depthCurr, reduceA] = CheckOcc(framePrev, frameCurr, frameCurr.bb, targetInfo, control, frameId);
            %if p<0.3&&bb_area(frameCurr.bb)>0.5*bb_area(targetInfo.firstBB) && bb_area(frameCurr.bb)<2*bb_area(targetInfo.firstBB),
            if frameCurr.conf > 1.6 * svm.thr||p<0.3&&bb_area(frameCurr.bb)>0.5*bb_area(targetInfo.firstBB) && bb_area(frameCurr.bb)<2*bb_area(targetInfo.firstBB),
                if frameCurr.conf > 0.6 * svm.thr && fromlist,
                    frameCurr.underOcclusion =0;
                elseif frameCurr.conf > 0.8 * svm.thr && ~fromlist,
                    frameCurr.underOcclusion =0;
                elseif ~fromlist && disToocc>2,%don't show the detection result when it is far away and not reliable
                    frameCurr.bb=[];
                end
            end
            
            if control.debug>0,
                figure(4), subplot(2,3,3);
                text(0.1,0.3,sprintf('area ratio: %f',bb_area(frameCurr.bb)/bb_area(targetInfo.firstBB)),'Color','b');
                text(0.1,0.4,sprintf('fromlist: %f',fromlist),'Color','b');
                text(0.1,0.5,sprintf('thr: %f',svm.thr),'Color','b');
            end

            
            if ~frameCurr.underOcclusion,
                tmpWeight = max(0,min(1,frameCurr.conf));
            else
                tmpWeight = 0;
            end
            frameCurr.targetDepth = tmpWeight * depthCurr + (1-tmpWeight) * framePrev.targetDepth;
            frameCurr.distribution.depth = gmdistribution(frameCurr.targetDepth,framePrev.distribution.depth.Sigma);
        else
            frameCurr.targetDepth = framePrev.targetDepth;
        end
      
    end
end