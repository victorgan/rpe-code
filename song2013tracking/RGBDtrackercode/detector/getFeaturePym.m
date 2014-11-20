function featurePym = getFeaturePym(mode, rgb, depth, tarscale)
    if strcmp(mode, 'rgb')
        featurePym = feature_pyramid(rgb,tarscale);
    elseif strcmp(mode, 'd')
        featurePym = feature_pyramid(repmat(depth,[1,1,3]),tarscale);
    elseif strcmp(mode, 'rgbd')
        rgbPym = feature_pyramid(rgb,tarscale);
        depthPym = feature_pyramid(repmat(depth,[1,1,3]),tarscale);
        featurePym.feat = {};
        for i = 1:length(rgbPym.feat)
        [x y z] = size(rgbPym.feat{i});
        feat = zeros(x,y,2*z);
        feat(:,:,1:z) = rgbPym.feat{i};
        feat(:,:,z+1:2*z) = depthPym.feat{i};
        featurePym.feat{i} = feat;
        end
        featurePym.scale = rgbPym.scale;
    end
end

