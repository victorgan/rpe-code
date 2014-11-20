function svm = hogInitDetector(svm, bb, featurePym)
%init Detector, do the first training 
%get positive Ex
bbh=bb(4)-bb(2);
bbw=bb(3)-bb(1);
pscale=(4000/(bbh*bbw))^0.5;
[~,level]=findnearest(pscale,featurePym.scale);
rscale=featurePym.scale(level);

F=featurePym.feat{level};
[fh fw fz]=size(F);
template_width = round(bbw*rscale/8);
template_height= round(bbh*rscale/8);
featureDim=[template_height template_width fz];
svm.scale=rscale;
svm.featureDim=featureDim;
svm.level=level;
%first training-------------------------------
%get pEx
[pex,level]=hogGetfeature(bb,featurePym, featureDim);
pEx=[svm.pSV pex];
%get nEx
num_nex=100;%number of neigetive example will be generate
[nex,numN]=hogGenerateNex(bb,featurePym,featureDim,num_nex,level);
nEx=[svm.nSV nex];

svm.tpex=[svm.tpex pex];
svm.tnex=[svm.tnex nex];
w0=svm.w;
b0=0;
svind=[ones(1,size(svm.pSV,2)) zeros(1,size(nex,2)) ones(1,size(svm.nSV,2)) zeros(1,size(pex,2))];
for it=1:3

[w0,b0,pSV,nSV]=hogTrainSVMonce(  pEx,nEx,svind, featureDim,w0(:));

[ matchMatrix,match ] = hogEvaluate( featurePym,w0,b0);
bb_tar_score=[bb(:)' 1];
fullMatrix=[bb_tar_score; matchMatrix'];


% get high cof matches that not overlap with tarbb
indexes = nmsMe(fullMatrix, 0.1); 
hardnegativebb= fullMatrix(indexes,:);
hardnegativebb=hardnegativebb';
hard_score=max(hardnegativebb(5,2:size(hardnegativebb,2)));
hardnegativebb=hardnegativebb(1:4,2:size(hardnegativebb,2));

%show training process
if 0
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
    %text(matchMatrix(b,1),matchMatrix(b,2),sprintf('%d',matchMatrix(b,5)),'FontSize',14)
    end
    hold off
    pause
end
if isempty(hard_score),
    break;
end
hardnEx=hogGetfeature(hardnegativebb,featurePym,featureDim);

nEx=[nSV' hardnEx];
pEx=pSV';
svm.tnex=[svm.tnex  hardnEx];
svind=[ones(1,(size(nSV,1)+size(pSV,1))),zeros(1,size(hardnEx,2))];
end
%output
svm.w=w0;
svm.b=0;%b0;
svm.pSV=pEx;
svm.nSV=nEx;
svm.thr=0.5*w0(:)'*pEx+0.5*max(w0(:)'*nEx);
svm.match=match;
end

