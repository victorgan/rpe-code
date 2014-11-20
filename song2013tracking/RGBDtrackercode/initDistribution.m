function [gm, targetDepth] = initDistribution(bbIn, rgb, depth, control)
%INITTAR Summary of this function goes here
%   Detailed explanation goes here
im=double(rgb);
depthIm=double(depth);
[H W Z]=size(rgb);
%background rgb distibution 
a=max(200,4*(bbIn(3)-bbIn(1)));
bbE(1)=max(1,bbIn(1)-2*a);
bbE(2)=max(1,bbIn(2)-a);
bbE(3)=min(W,bbIn(3)+2*a);
bbE(4)=min(H,bbIn(4)+a);
back_rgb=double(rgb(bbE(2):bbE(4),bbE(1):bbE(3),:));
back_rgb(max(1,bbIn(2)):min(H,bbIn(4)),max(1,bbIn(1)):min(W,bbIn(3)),:)=nan;
br=back_rgb(:,:,1);bg=back_rgb(:,:,2);bb=back_rgb(:,:,3);

try
    gm.back= gmdistribution.fit([br(:) bg(:) bb(:)],3);
catch
    try
     gm.back= gmdistribution.fit([br(:) bg(:) bb(:)],2);
    catch
     gm.back= gmdistribution.fit([br(:) bg(:) bb(:)],1);
    end
end
%target depth ditribution 
front_depth=double(depthIm(bbIn(2):bbIn(4),bbIn(1):bbIn(3)));
[h,w]=size(front_depth);
bin=150;
[N D]=hist(double(front_depth(:)),bin);
H = fspecial('gaussian',[1,5],0.5);
N = convn(N, H, 'same');
[P LOC]=findpeaks([0 N 0],'SORTSTR','descend','MINPEAKDISTANCE',5,'MINPEAKHEIGHT',20);
if size(LOC,2)>1
    F=max(D(LOC(1)-1),D(LOC(2)-1));
else
    F=D(LOC(1)-1);
end
front_depth(front_depth<0.9*F)=nan;
D= gmdistribution.fit(front_depth(:),1);

G1=pdf(gmdistribution(D.mu(1),D.Sigma(1)),front_depth(:));
G1=reshape(G1,[h,w]);
front_depth2=front_depth;
front_depth2(G1<0.01)=nan;

try 
    D2= gmdistribution.fit(front_depth2(:),1);
catch
    D2=D;
end
[~,cInd]=max(D2.PComponents);
sd=max(1,D2.Sigma(cInd)/sqrt(2));
gm.depth=gmdistribution(D2.mu(cInd),sd);
targetDepth=D2.mu(cInd);

%target rgb ditribution 
depthv=10*(pdf(gm.depth,front_depth(:)));
depth_seg=reshape(depthv,[h,w]);
if control.debug>0,
    figure(10)
    hold on
    hist(front_depth(:),256);
    x=1:256;x=x(:);
    plot(x,5000*pdf(gm.depth,x),'r');
    hold off
end
front_rgb=double(im(bbIn(2):bbIn(4),bbIn(1):bbIn(3),:));
fr=front_rgb(:,:,1).*(depth_seg>0.2);
fg=front_rgb(:,:,2).*(depth_seg>0.2);
fb=front_rgb(:,:,3).*(depth_seg>0.2);

ims=zeros(h,w,3);
ims(:,:,1)=fr;
ims(:,:,2)=fg;
ims(:,:,3)=fb;
fr(fr==0)=nan;
fb(fb==0)=nan;
fg(fg==0)=nan;
try
    gm.front= gmdistribution.fit([fr(:) fg(:) fb(:)],3);
catch
    try
        gm.front= gmdistribution.fit([fr(:) fg(:) fb(:)],2);
    catch
        gm.front= gmdistribution.fit([fr(:) fg(:) fb(:)],1);
    end
end
%}
end

