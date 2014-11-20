function [ dis ] = bb_dis( tBB,dBB )
cp_dis=abs(bb_center(dBB)-repmat(bb_center(tBB),1,size(dBB,2)));
dis=0.5*(cp_dis(1,:)+cp_dis(2,:));
end

