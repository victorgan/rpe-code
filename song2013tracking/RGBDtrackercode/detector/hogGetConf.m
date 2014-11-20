function conf = hogGetConf(bb, featurePym, svm)
    [patt,levels] = hogGetfeature(bb, featurePym, svm.featureDim);
    if isnan(patt(1))||abs(levels(1)-svm.level)>10,
        conf=-999;
    else 
        conf=svm.w(:)'*patt(:)+svm.b;
    end
end

