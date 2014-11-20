function [ matchMatrix,match ] = hogEvaluate( featurePym,template,b0 )
%evaluste the image by conv it with template and output high conf bounding
%boxes (each col) and its' conf value

%% template matching
matchMatrix = [];
for level=1:length(featurePym.feat)
    % convolution
    if sum(size(featurePym.feat{level})<size(template))>0,
        break;
    end
    match{level} = fconvblas(featurePym.feat{level}, {template}, 1, 1);
    match{level} = match{level}{1};

    % pick the top 5000 results
    [scores,indexes] = sort(match{level}(:),'descend');
    
    %scores=scores+b0;
    if numel(scores)>100
        choosen = 1:100;
        indexes = indexes(choosen);
        scores  = scores(choosen);
    end  
    % obtain window pixel locations
    [indexes1 indexes2] = ind2sub(size(match{level}),indexes);
    %get the bbs that has same size with template in each level
    %translate to real cordinate
    bbs{level} = ([indexes2 indexes1 ...
                   indexes2+size(template,2)...
                   indexes1+size(template,1)]...
                   - 1) * 8 / featurePym.scale(level) + repmat([1 1 0 0],numel(indexes),1);
    bbs{level} = [bbs{level} scores];
    
    % non maximal suppression to remove windows too close
    indexes = nmsMe(bbs{level}, 0.8); % pascal voc 0.5 criteria
    bbs{level} = bbs{level}(indexes,:);     
    matchMatrix = [matchMatrix; bbs{level}];
end

% overall best match
indexes = nmsMe(matchMatrix, 0.8); % pascal voc 0.5 criteria
matchMatrix = matchMatrix(indexes,:);
matchMatrix =matchMatrix';
end

