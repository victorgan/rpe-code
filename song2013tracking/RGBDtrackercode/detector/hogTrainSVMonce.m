function [ template, b, pSV,nSV] = hogTrainSVMonce(  pEx, nEx,svind, featureDim,w0)
nP = size(pEx,2); % get the number of positive example 
nN = size(nEx,2); % get the number of negative examples
size(w0)
x = [pEx';nEx'];
y = [ones(nP,1); -1*ones(nN,1)];
notnanInd=~isnan(sum(x,2));
x=x(notnanInd,:);
y=y(notnanInd,:);
svind=svind';
svind=svind(notnanInd,:);
opt=struct('w0',w0);
if sum(isnan(x(:)))==0
    [w,b,sv]=primal_svm(1,x,y,1,opt);
    newsvInd=zeros(size(x,1),1);
    newsvInd(sv)=1;
    fullsvInd=svind|newsvInd;
    pSV = x(fullsvInd&y==1,:);
    nSV = x(fullsvInd&y==-1,:);
    px=pSV*w;
    nx=nSV*w;
    px=min(px(:));
    nx=max(nx(:));
    template=reshape(w,featureDim);
    template = template - mean(template(:));
end

end

