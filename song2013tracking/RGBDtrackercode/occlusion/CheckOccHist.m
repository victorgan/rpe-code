function [p, depthCurr, reduceA] = CheckOcc(framePrev, frameCurr, bb, targetInfo, control, frameId)
depthMapPrev = framePrev.depth;
depthMapCurr = frameCurr.depth;
bbPrev = framePrev.bb;
depthPrev = framePrev.targetDepth;
refBB = targetInfo.firstBB;
gm = framePrev.distribution;

%tld,tld.img{I}.depth,tld.bb(:,I-1),i 
%p occluder area percentage of bounding box in fram i
%depth_i: target depth in this fram
%depth_diff: depth distribution distance compare with last frame

sd=gm.depth.Sigma;
if isempty(bb),
    p=999;
    depthCurr=depthPrev;
    reduceA=NaN;
    return;
end 

bbIn=bb;
bb=enlargeBB(bb ,0.1,size(depthMapCurr));

bbA=(bbIn(2)-bbIn(4))*(bbIn(1)-bbIn(3));
bbAPrev=(refBB(2)-refBB(4))*(refBB(1)-refBB(3));
reduceA=(bbAPrev-bbA)/bbAPrev;

%get current depth histogram
bin=100;
cur_depth_bb = depthMapCurr(bb(2):bb(4),bb(1):bb(3));
[N D]=hist(double(cur_depth_bb(:)),bin);
binsize=D(2)-D(1);
H = fspecial('gaussian',[1,5],0.5);
N = convn(N, H, 'same');
[P LOC]=findpeaks([0 N 0],'SORTSTR','descend','MINPEAKDISTANCE',5,'MINPEAKHEIGHT',20);

%pervious depth map
if ~isnan(bbPrev), bbp=round(bbPrev);else bbp=bb(:); end 
per_depth_bb=depthMapPrev(max(1,bbp(2)):min(bbp(4),size(depthMapPrev,1)),max(1,bbp(1)):min(bbp(3),size(depthMapPrev,2)));
[N2 D2]=hist(double(per_depth_bb(:)),bin);
N2 = convn(N2, H, 'same');

%find closest peak to tld.depth
L=min(length(LOC),4);
if isnan(depthPrev),
    depthCurr=max(D(LOC(1:2)-1));
    p=0;
else
    [new_target_depth,~,~]=findnearest(depthPrev,D(LOC(1:L)-1));
    if abs(new_target_depth-depthPrev)<1.5*sd || abs(new_target_depth-depthPrev)<100,
        depthCurr=new_target_depth;
    else
        depthCurr=depthPrev;
    end
normN=N/sum(N(:));
normN2=N2/sum(N2(:));
sfN2=zeros(size(N));

offset=round((depthCurr-depthPrev)/binsize);
sf=max(1,1-offset):min(length(N),length(N)-offset);
org=1:length(sf);
sfN2(org)=normN2(sf);
sub=N-N2;
normsub=normN-sfN2;
s2=sum(normsub(normsub>0));
s3=sum(sub(D>depthCurr&sub>0));
%s4: change in depth hist that occure at depth closer than target
s4=sum(normsub((D>(depthCurr+sd))&normsub>0));
%p: absulute percentage of points have closer depth 
p=sum(normN(D>(depthCurr+sd)));

if control.debug>0,
figure(4)
hold off
subplot(2,3,1)%pervious taget hist
bar(D2,normN2);
hold on
%bar(D2,sfN2,'y');
plot(depthPrev,0.2,'xr')
hold off
axis([1 256 0 0.5]);
title(sprintf('target depth: %d', frameId-1));

subplot(2,3,2)%current target hist 
bar(D(D<=(depthCurr+sd)),normN(D<=(depthCurr+sd)));
x=(1:250);x=x(:);
hold on
P=plot(depthCurr,0.2,'xr',D(LOC(1:L)-1),0.1,'xg',x,pdf(gm.depth,x),'y');
set(P,'LineWidth',1.3)
nnv=normN;
nnv(D<=(depthCurr+sd))=0;
bar(D,nnv,'y')
axis([1 256 0 0.5]);
title(sprintf('target depth: %d', frameId));
hold off
end

end
end
function [y,n,lastpeak]=findnearest(x,array)
if isempty (array), 
    y=-99999;
    lastpeak=1;
    return ; 
end
mind=999999;
n=0;
for i=1:length(array)
    d=abs(x-array(i));
    if d<mind,
        mind=d;
        n=i;
    end
end
y=array(n);
if y==max(array),
    lastpeak=1;
else
    lastpeak=0;
end
end
