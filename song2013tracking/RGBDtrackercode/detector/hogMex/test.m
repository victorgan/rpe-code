clear
close all
image=imread('/csail/vision-videolabelme/people/www/tracking/data/tracking6/tracking3/00001.bmp');
image1 =imread('/csail/vision-videolabelme/people/www/tracking/data/tracking6/tracking3/00010.bmp');
featurePym = feature_pyramid(image,nan);
featurePymtest =feature_pyramid(image1,nan);
bb=[258;197;362;403];% [379;219;420;370];

[X,sizeT,pEx] = getTemplate( featurePym,bb);
Y=[1; -1*ones(size(X,1)-1,1)];
[template1,b0 ]=primal_svm(1,X,Y,1); 
template1=reshape(template1,sizeT);

featureDim=sizeT;
[ template, b] = hogTrainSVM( bb, featurePym,featureDim,image);
[ BB Conf ] = hogDetection( featurePymtest,template,b0);
ind=Conf>0;
figure(2)
imshow(image1)
hold on 
%bb_draw([BB;Conf])
bb_draw([BB(:,ind);Conf(:,ind)])