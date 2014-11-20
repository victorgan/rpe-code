function [mean, sd]=fitgaussian (front_depth)
[N D]=hist(double(front_depth(:)),150);
H = fspecial('gaussian',[1,5],0.5);
N = convn(N, H, 'same');

D= gmdistribution.fit(front_depth(:),1);
H = fspecial('gaussian',[1,150],0.5);
end