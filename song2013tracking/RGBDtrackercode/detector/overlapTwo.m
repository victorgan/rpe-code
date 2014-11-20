function [ out ] = overlapTwo(BB1,BB2)
%OVERLAPTWO Summary of this function goes here
%   Detailed explanation goes here
out=nan(1,size(BB2,2));
for i=1:size(BB2,2),
out(i)=overlapSingle(BB1,BB2(:,i));

end
end

function out= overlapSingle(bb1,bb2)

if bb1(1) > bb2(3),out =0 ;return ;end
	if (bb1(2) > bb2(4)),out =0 ; return ; end
	if (bb1(3) < bb2(1)),out =0 ;return ; end
	if (bb1(4) < bb2(2)),out =0 ;return ; end

b=min(bb1(3:4),bb2(3:4))-max(bb1(1:2),bb2(1:2));
b(b<0)=0;
inter =b(1).*b(2);
area1=(bb1(3)-bb1(1))*(bb1(4)-bb1(2));
area2=(bb2(3)-bb2(1))*(bb2(4)-bb2(2));
out =inter/(area1 + area2 - inter);
end