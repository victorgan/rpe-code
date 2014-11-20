function tld = tldLearning(tld,I,update)
if tld.conf(I)<2*tld.svm.thr&&(mod(I,3)==1||I<5)||update,
    tld =hogTrainSVM(tld,I,1,0);
    tld.valid(I)=1;
else
    tld.valid(I)=0;
end
% Check consistency -------------------------------------------------------

fprintf('pSV num= %f nSV num = %f\n', size(tld.svm.pSV,2),size(tld.svm.nSV,2));
 
