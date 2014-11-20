function svm = testingSVM(svm, frameId, conf)
%TESTINGSVM Summary of this function goes here
%   Detailed explanation goes here
w = svm.w;
w=w(:);
b=svm.b;
pscore=w'*svm.tpex+b;
nscore=w'*svm.tnex+b;
pscore=sort(pscore);
nscore=sort(nscore);
pind=max(1,round(0.5*length(pscore)));
nind=max(1,round(0.95*length(nscore)));
c=(0.6*pscore(pind)+0.4*nscore(nind));
if isnan(svm.thr)
    svm.thr=c;
else
    svm.thr=0.7*svm.thr+0.3*c;
end
%{
figure(11)
hold on 
plot(pscore,frameId,'xr');
plot([svm.thr pscore(pind) nscore(nind)],[frameId frameId frameId],'xy','LineWidth',3)
plot(conf,frameId,'xb','LineWidth',3)
plot(nscore,frameId,'xg');
hold off
end
%}

