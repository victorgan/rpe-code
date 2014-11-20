function [y,ind]=findnearest(x,array)
if isempty (array)||isnan(x), 
    y=-99999;
    ind=0;
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
if n==0,y=-99999;return;end
y=array(n);
ind=n;
end



