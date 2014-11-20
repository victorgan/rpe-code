function [ bbOut,occ_mask  ] = singleSegRGBD( ct_diff,rgbIm,depthIm,depthValue,bbIn,gm,debug )
occ_mask =ones(size(depthIm));
bbOut=nan(4,1);
a=0.5*(bbIn(3)-bbIn(1));
bbE(1)=max(1,bbIn(1)-a);
bbE(2)=max(1,bbIn(2)-a);
bbE(3)=min(size(rgbIm,2),bbIn(3)+a);
bbE(4)=min(size(rgbIm,1),bbIn(4)+a);
bbE=round(bbE(:));
im=double(rgbIm(bbE(2):bbE(4),bbE(1):bbE(3),:));
depth=depthIm(bbE(2):bbE(4),bbE(1):bbE(3));
[H W Z]=size(im);
bbBw=zeros([H W]);
numfront=(bbIn(3)-bbIn(1))*(bbIn(4)-bbIn(2));

%bbBw(bbIn(2):bbIn(4),bbIn(1):bbIn(3))=1;
%front_rgb=im(max(1,bbIn(2)):min(H,bbIn(4)),max(1,bbIn(1)):min(W,bbIn(3)),:);
bbBw(max(1,bbIn(2)-bbE(2)):min(H,bbIn(4)-bbE(2)),max(1,bbIn(1)-bbE(1)):max(W,bbIn(3)-bbE(1)))=1;
front_rgb=rgbIm(bbIn(2):bbIn(4),bbIn(1):bbIn(3),:);
front_r_hist=imhist(front_rgb(:,:,1))/numfront;
front_g_hist=imhist(front_rgb(:,:,2))/numfront;
front_b_hist=imhist(front_rgb(:,:,3))/numfront;

%{
figure(3);
hold on; 
plot(front_r_hist,'r');
plot(front_g_hist,'g');
plot(front_b_hist,'b');
hold off;
%}
rgb_seg=zeros(H,W);
depth_seg=zeros(H,W);
final_seg=zeros(H,W);
%p=zeros(H,W);
[x y]=meshgrid(1:W,1:H);
k=sub2ind([H W],y,x);
c_r=im(:,:,1);
c_g=im(:,:,2);
c_b=im(:,:,3);
f_rgb(k)=front_r_hist(c_r(k)+1).*front_g_hist(c_g(k)+1).*front_b_hist(c_b(k)+1);
b_rgb=pdf(gm.back,[c_r(:) c_g(:) c_b(:)]);
b_rgb=b_rgb';
rgb_seg(k)= 5*(f_rgb./(f_rgb+b_rgb));
depth_seg(k)=10*(normpdf(depth(k),depthValue,2*gm.depth.Sigma));
final_seg(k)=(1.3*rgb_seg(k)+0.1*depth_seg(k)).*(depth_seg(k)>max(graythresh(depth_seg),0));
%process segmentation result 
   se = strel('rectangle',[14 6]);
   final_seg=imclose(final_seg,se);
   level = graythresh(final_seg);
   final_seg=final_seg>level;
   %find connected component
   cc = bwconncomp(final_seg,8);
   sizes = zeros(length(cc.PixelIdxList),1);
    for i = 1:length(sizes)
        sizes(i) = length(cc.PixelIdxList{i});
    end
   validIndices = 1:length(sizes);
   sortedSizes=sortrows([validIndices(:) sizes(:)],-2);
   tar_mask =zeros([H W]);
   find=0;
   for i = 1:length(sizes)
      pointslocs= cc.PixelIdxList{sortedSizes(i,1)};
      intersectwithBB=bbBw(pointslocs);
      if sum(intersectwithBB(:))>10,
          tar_mask(pointslocs)=1;
          [I,J]=ind2sub(size(tar_mask),pointslocs) ;
          occlocs=[I,J];
          occlocs=occlocs+repmat([bbE(2)-1,bbE(1)-1],size(occlocs,1),1);
          occlocs=sub2ind(size(occ_mask),occlocs(:,1),occlocs(:,2));
          occ_mask(occlocs)=0;
          %figure(1000),imshow(occ_mask)
          find=1;
          break;
      end
   end
   
if find==1,
   if sum(tar_mask(:))<40||sum(tar_mask(:))>80000;
       disp('signle segment area too small or too large')
       return;
   end
   tarBB=regionprops(tar_mask,'BoundingBox');
   tarBB=tarBB.BoundingBox;
   %bbOut=[tarBB(1);tarBB(2);tarBB(1)+tarBB(3);min(tarBB(2)+tarBB(4),bbIn(4))]; 
   bbOut=[bbE(1)+tarBB(1)-1;bbE(2)+tarBB(2)-1;bbE(1)+tarBB(1)+tarBB(3)-1;bbE(2)+tarBB(2)+tarBB(4)-1];
if debug>0;   
   figure(4);
   subplot(2,3,4)
   imshow(depth_seg);
   title('occluder depth seg');
   subplot(2,3,5)
   imshow(rgb_seg);
   title('occluder rgb seg');
   subplot(2,3,6)
   imshow(tar_mask);
   title('occluder final seg');
   hold on;
   rectangle('Position',tarBB,'LineWidth',3,'edgecolor','g');
   hold off
   if debug>1,
        pause;
   end
end 
else
       disp('not find conected component inside BB');
end


end

