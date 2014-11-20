function [ template, b, pSV,nSV] = hogTrainSVMonceFast(  pEx, nEx,svind, featureDim,w0)
nP = size(pEx,2); % get the number of positive example 
nN = size(nEx,2); % get the number of negative examples
size(w0)
x = [pEx';nEx'];
y = [ones(nP,1); -1*ones(nN,1)];
opt=struct('w0',w0);
if sum(isnan(x(:)))==0
    %[w,b,sv]=primal_svm(1,x,y,1,opt);
    model = train(y, x, '-s 2 -t 0 -B 1');
    w=model.w;
    b=model.bias;
end
newsvInd=zeros(size(x,1),1);
newsvInd(sv)=1;
fullsvInd=svind'|newsvInd;
pSV = x(fullsvInd&y==1,:);
nSV = x(fullsvInd&y==-1,:);
px=pSV*w;
nx=nSV*w;
px=min(px(:));
nx=max(nx(:));
%b=(px+nx)*-0.5;
template=reshape(w,featureDim);
template = template - mean(template(:));
end
