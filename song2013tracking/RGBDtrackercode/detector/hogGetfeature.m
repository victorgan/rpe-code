function [ patt,levels,lt ] = hogGetfeature( bbIn, featurePym,featureDim )
num_bb = size(bbIn,2);
patt   = nan(prod(featureDim),num_bb);
levels = nan(1,num_bb);
lt=[nan nan];
for i = 1:num_bb
%get patt for one bb
num=1;
bb=bbIn(:,i);
height=featureDim(1) ;
width=featureDim(2);
bbh=bb(4)-bb(2);
bbw=bb(3)-bb(1);
pscale=((height*width*64)/(bbh*bbw))^0.5;
[~,level]=findnearest(pscale,featurePym.scale);
fea=[];
while level>1&& level<length(featurePym.feat)
    rscale=featurePym.scale(level);
    left  = max(1,round(bb(1)*rscale/8)+1);
    top  = max(1,round(bb(2)*rscale/8)+1);
    [fh fw fz]=size(featurePym.feat{level});
if top+height-1<=fh&& left+width-1<=fw,
    fea = featurePym.feat{level}(top:(top+height-1),left:(left+width-1),:);
    break;
else
    level=level-1;
end
end
if ~isempty(fea)&&~isnan(fea(1))
    patt(:,num)=fea(:);
    levels(num)=level;
    num=num+1;
    lt=[left top];
end
if num>1,
    patt=patt(:,1:num-1);
end
end

