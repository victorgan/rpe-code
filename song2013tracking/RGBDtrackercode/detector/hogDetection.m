function [boundingBox, confidence] = hogDetection(featurePym, svm)
    [matchMatrix, ~] = hogEvaluate(featurePym, svm.w, svm.b);
    boundingBox = matchMatrix(1:4,1:size(matchMatrix,2));
    confidence = matchMatrix(5,1:size(matchMatrix,2));
    %{
    figure(2)
    hold on
    matchMatrix=matchMatrix';
    
    for b=1:size(matchMatrix,2)
        plot(matchMatrix(b,[1 3 3 1 1]),matchMatrix(b,[2 2 4 4 2]),'-w');
        text(matchMatrix(b,3),matchMatrix(b,4),sprintf('%.3f',matchMatrix(b,5)),'FontSize',12,'color','w')
    end
    %}
end

