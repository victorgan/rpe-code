function svm = hogTrainSVM(image, bbTar, featurePym, svm, trainItr,show)
%output w0, b0, pEx, nEx
%input image,  featurePym,featureDim
    featureDim = svm.featureDim;
    %get pEx
    [pex,~] = hogGetfeature(bbTar, featurePym, featureDim);
    if ~isnan(pex(1)),
        pEx=[svm.pSV pex];
        new_tar_score=svm.w(:)'*pex(:);
    else
        new_tar_score=99;
        pex=[];
        pEx=svm.pSV;
    end
    svm.tpex=[svm.tpex pex];
    nEx=svm.nSV;
    %get nEx
    w0 = svm.w;
    b0 = 0; %svm.b;
    for it=1:trainItr
    [matchMatrix,~] = hogEvaluate(featurePym, w0, b0);
    bb_tar_score=[bbTar(:)' 99];
    fullMatrix=[bb_tar_score; matchMatrix'];
    indexes = nmsMe(fullMatrix, 0.1); 
    hardnegativebb= fullMatrix(indexes,:);
    hardnegativebb=hardnegativebb';
    hard_score=max(hardnegativebb(5,2:size(hardnegativebb,2)));
    hardnegativebb=hardnegativebb(1:4,2:size(hardnegativebb,2));

    %show training process
    if show
        figure(12)
        imshow(image);
        hold on
        matchMatrix=matchMatrix';
        for b=1:min(7,size(matchMatrix))
        plot(matchMatrix(b,[1 3 3 1 1]),matchMatrix(b,[2 2 4 4 2]),'-y');
        text(matchMatrix(b,1),matchMatrix(b,2),sprintf('%.3f',matchMatrix(b,5)),'FontSize',20)
        end

        for b=1:min(7,size(hardnegativebb,2))
        plot(hardnegativebb([1 3 3 1 1],b),hardnegativebb([2 2 4 4 2],b),'-g');
        end
        hold off
        pause
    end

    if isempty(hard_score)||(hard_score<0.7*svm.thr&& new_tar_score>1.6*svm.thr),
        break;
    end
    hardnEx=hogGetfeature(hardnegativebb,featurePym,featureDim);
    nEx=[nEx hardnEx];
    svm.tnex=[svm.tnex hardnEx];
    %training -----------------------------------------------------
    svind=[ones(1,(size(pEx,2)+size(nEx,2)-size(hardnEx,2))),zeros(1,size(hardnEx,2))];
    [w0,b0,pSV,nSV]=hogTrainSVMonce(  pEx,nEx,svind, featureDim,w0(:));
    pEx=pSV';
    nEx=nSV';
    end
    %output------------------------------------------------------
    svm.w=w0;
    svm.b=0;%b0;
    if(size(pEx,2)>svm.maxsv),
        svm.pSV=pEx(:,end - svm.maxsv:end);
    else
        svm.pSV=pEx;
    end
    if size(nEx,2)>svm.maxsv,
        svm.nSV=nEx(:,end - svm.maxsv:end);
    else
        svm.nSV=nEx;
    end
end
