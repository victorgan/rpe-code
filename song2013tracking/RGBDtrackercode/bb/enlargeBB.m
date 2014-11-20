function bb = enlargeBB(smallBB,a,size)
x = a * (smallBB(3)-smallBB(1));
y = a * (smallBB(4)-smallBB(2));
bb(1)=max(1,smallBB(1)-x);
bb(2)=max(1,smallBB(2)-y);
bb(3)=min(size(2),smallBB(3)+x);
bb(4)=min(size(1),smallBB(4)+y);
bb=round(bb(:));
end

