function [X,sizeT,pEx] = getTemplate( feature, bb)
% get feature image
%feature = feature_pyramid(image);
bbh=bb(4)-bb(2);
bbw=bb(3)-bb(1);
pscale=(4000/(bbh*bbw))^0.5;
[~,level]=findnearest(pscale,feature.scale);
rscale=feature.scale(level);
%imgs=imresize(image,rscale);
%figure(2)
%imshow(imgs(round(rscale*(bb(2):bb(4))),round(rscale*(bb(1):bb(3)))))
%get positive example
template_level = level;
F=feature.feat{template_level};
[fh fw fz]=size(F);
template_width = round(bbw*rscale/8);
template_height= round(bbh*rscale/8);
template_left  = max(1,floor(bb(1)*rscale/8)+1);
template_top  = max(1,floor(bb(2)*rscale/8)+1);
pEx = feature.feat{template_level}(template_top:(template_top+template_height-1),template_left:(template_left+template_width-1),:);
sizeT=size(pEx);
pEx=pEx(:)';
[ patt ] = hogGetfeature( bb, feature,sizeT );
%get neigative example 
k=50;
x=randvalues([1:template_left-round(0.5*template_width) template_left+round(0.5*template_width):fw-template_width],k);
y=randvalues([1:template_top-round(0.5*template_height) template_top+round(0.5*template_height):fh-template_height],k);
num_N=min([k length(x) length(y)]);

nEx=nan(num_N,sizeT(1)*sizeT(2)*sizeT(3));
for n=1:num_N,
nex=F(y(n):y(n)+template_height-1,x(n):x(n)+template_width-1,:);
nEx(n,:)=nex(:)';
end
%first training 
X=[pEx;nEx];

end

function out = randvalues(in,k)
% Randomly selects 'k' values from vector 'in'.

out = [];

N = size(in,2);

if k == 0
  return;
end

if k > N
  k = N;
end

if k/N < 0.0001
 i1 = unique(ceil(N*rand(1,k)));
 out = in(:,i1);
 
else
 i2 = randperm(N);
 out = in(:,sort(i2(1:k)));
end
end
function [y,ind]=findnearest(x,array)
if isempty (array), y=-99999;return ; end
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
ind=n;
end