function [bbo, gm_new_color] = recenterRGBD(depthIm, rgbIm, bbin, gm, debug,id)
    bbo=nan(4,1); 
    gm_new_color=gm.front;
    if isempty(bbin),bbo=[]; return;end
    bb=round(bbin);
    a=8;
    bb(2)=max(1,bb(2)-a);
    bb(4)=min(size(depthIm,1),bb(4)+a);
    bb(1)=max(1,bb(1)-a);
    bb(3)=min(size(depthIm,2),bb(3)+a);
    depth_bb=depthIm(bb(2):bb(4),bb(1):bb(3));
    im_bb=double(rgbIm(bb(2):bb(4),bb(1):bb(3),:));
    %% do RGBD segmentation in BB 
    [H W Z]=size(im_bb);
    c_r=im_bb(:,:,1);
    c_g=im_bb(:,:,2);
    c_b=im_bb(:,:,3);
    % evalue possibility
    rgb_seg=zeros(H,W);
    depth_seg=zeros(H,W);
    final_seg=zeros(H,W);
    [x y]=meshgrid(1:W,1:H);
    k=sub2ind([H W],y,x);
    f_rgb=pdf(gm.front,[c_r(:) c_g(:) c_b(:)]);
    b_rgb=pdf(gm.back,[c_r(:) c_g(:) c_b(:)]);
    p=0.4;
    rgb_seg(k)= (p*f_rgb./(p*f_rgb+(1-p)*b_rgb));
    depthv=10*(normpdf(depth_bb(:),gm.depth.mu,gm.depth.Sigma));
    depth_seg(k)=depthv(k);
    final_seg(k)=(1.3*rgb_seg(k)+0.1*depth_seg(k)).*(depth_seg(k)>0.15);
    %process segmentation result 
       se = strel('rectangle',[14 6]);
       final_seg=imclose(final_seg,se);
       %final_seg = img_blur(final_seg,2);
       level = graythresh(final_seg);
       Demo_tar_Segconf=final_seg;
       final_seg=final_seg>level;

    %find connected component
       cc = bwconncomp(final_seg,8);
       sizes = zeros(length(cc.PixelIdxList),1);
       tar_mask =zeros([H W]);
       tarBB=zeros(4,1);
    if ~isempty(sizes),
         for i = 1:length(sizes)
            sizes(i) = length(cc.PixelIdxList{i});
         end
         validIndices = 1:length(sizes);
         sortedSizes=sortrows([validIndices(:) sizes(:)],-2);
         pointslocs= cc.PixelIdxList{sortedSizes(1,1)};
         tar_mask(pointslocs)=1;
            if sum(tar_mask(:))>60&&sum(tar_mask(:))<80000;
                %{
                [rows,cols,~] = find(tar_mask);
                cp(1)=median(cols);
                cp(2)=median(rows);
                dx=cp(1)-0.5*(bb(3)-bb(1));
                dy=cp(2)-0.5*(bb(4)-bb(2));
                bbo=[bbin(1)+dx;bbin(2)+dy;bbin(3)+dx;bbin(4)+dy];
                %}
                tarBB=regionprops(tar_mask,'BoundingBox');
                tarBB=tarBB.BoundingBox;
                bbo=[tarBB(1)+bb(1);tarBB(2)+bb(2);bb(1)+tarBB(1)+tarBB(3);min(bb(2)+tarBB(2)+tarBB(4),bb(4))];
                bbo=0.7*bbin+0.3*bbo;
            end
    else
        bbo=bbin;
    end

    if debug>0&&sum(tar_mask(:))>60&&sum(tar_mask(:))<80000;
       figure(4);
       subplot(2,3,4)
       imshow(depth_seg);
       title(sprintf('tar depth'));
       subplot(2,3,5)
       imshow(rgb_seg);
       title(sprintf('tar rgb'));
       subplot(2,3,6)
       imshow(tar_mask);hold on;
       %plot(cp(1),cp(2),'xr',0.5*(bb(3)-bb(1)),0.5*(bb(4)-bb(2)),'ob');
       %title(sprintf('dx:%d dy:%d', dx,dy));
       rectangle('Position',tarBB,'LineWidth',2,'edgecolor','g');
       hold off
    end 
end

