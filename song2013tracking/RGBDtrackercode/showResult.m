function showResult(framePrev,frameCurr,frameId,source,control)
%DISPLAY Summary of this function goes here
%   Detailed explanation goes here
    f=figure(2);
    
    h = get(gca,'Children'); delete(h(1:end-1));
    %if nargin == 4, text(10,10,varargin{4},'color','white'); end
    
    % Draw image
    %[img, ~] = readFrame(source.dataType, source.imageNames, frameId);
    img=frameCurr.rgb;
    [H,W] = size(img);
    imshow(img); hold on;    
    
    % Draw Track
    linewidth = 2; 
    color = 'y'; 
   
    if control.showtarlist && ~isempty(frameCurr.tarList)
        for j=1:size(frameCurr.tarList.bb,2),
        %conf=    sprintf('color:%d \n class:%d',tld.occlusion.tarList{i}.Conf_color,tld.occlusion.tarList{i}.Conf_class);
        bb = [frameCurr.tarList.bb(:,j); frameCurr.tarList.Conf_class(j)];
        bb_draw(bb,'linewidth',linewidth,'edgecolor','c','curvature',[0 0]);
        end
    end
    
    %draw final detection
    bb = frameCurr.bb;
    bb = [bb; frameCurr.conf];
    if ~frameCurr.underOcclusion,
        bb_draw(bb,'linewidth',linewidth,'edgecolor',color,'curvature',[0 0]);
    elseif frameCurr.totalOcc,
        bb_draw(bb,'linewidth',linewidth,'edgecolor','c','curvature',[0 0]);
    else
        bb_draw(bb,'linewidth',linewidth,'edgecolor','g','curvature',[0 0]);
    end
    
    string = ['#' num2str(frameId) ', fps:' num2str(1/toc,3) ];
    text(10,H-10,string,'color','white','background','black');
    
    if ~frameCurr.underOcclusion && strcmp(frameCurr.choice,'d'), text(10,H-60,'choice: detection','color','white','background','black');
    elseif strcmp(frameCurr.choice,'t'), text(10,H-60,'choice: tracking','color','white');end
    
    if frameCurr.learned, text(10,H-40,'learning','color','white','background','black');end
    if frameCurr.underOcclusion, text(10,H-30,'occlusion state!','color','white','background','black');end
    if frameCurr.totalOcc, text(10,H-30,'target is totally occluded','color','white','background','black');end
    if ~frameCurr.underOcclusion && framePrev.underOcclusion, text(10,H-30,'recover from occlution!','color','white','background','black');end
    
    % Draw
%    if tld.plot.draw, plot(tld.draw(1,:),tld.draw(2,:),'r','linewidth',2);   end
    
    if ~isempty(frameCurr.occBB),
        occ_bb=frameCurr.occBB;
        bb = occ_bb; 
        bb_draw(bb,'linewidth',linewidth,'edgecolor','b','curvature',[0 0]);
    end
    drawnow;
    tic;
    
% Save

end