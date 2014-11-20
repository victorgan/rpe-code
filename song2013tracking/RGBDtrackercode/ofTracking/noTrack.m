function [ BB2, conf] = noTrack( BB, featurePym, svm)

    BB2 = round(BB);
    conf  = hogGetConf(BB2,featurePym,svm);

end

