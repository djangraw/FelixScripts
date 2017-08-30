function idx2 = ClusterRoisSpatially(atlas,nClusters)

% idx2 = ClusterRoisSpatially(atlas,nClusters)
%
% Created 11/24/15 by DJ.

roiPos = GetAtlasRoiPositions(atlas);

center = size(atlas)/2;
isR = roiPos(:,1)>center(1); % right side


idx = nan(size(roiPos,1),1);
idx(isR) = kmeans(roiPos(isR,:),nClusters);
idx(~isR) = kmeans(roiPos(~isR,:),nClusters)+nClusters;

% Reorder according to y (a-p) position
atlas2 = atlas;
for i=1:nClusters*2
    atlas2(ismember(atlas,find(idx==i))) = i;
end

roiPos2 = GetAtlasRoiPositions(atlas2);
isR2 = roiPos2(:,1)>center(1); % right side

[~,orderR] = sort(roiPos2(isR2,2),'ascend');
[~,orderL] = sort(roiPos2(~isR2,2),'ascend');

idx2 = nan(size(idx));
for i=1:nClusters
    idx2(idx==orderR(i)) = i;
    idx2(idx==orderL(i)+nClusters) = i+nClusters;
end

% Plot results
% GUI_3View(atlas2);