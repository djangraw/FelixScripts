function roiMean = GetMeanTsInRois(brick,rois)

% roiMean = GetMeanTsInRois(brick,rois)
%
% Created 1/26/18 by DJ.

nRois = nanmax(rois(:));
nT = size(brick,4);
roiMean = nan(nT,nRois);
for i=1:nT
    brickThis = brick(:,:,:,i);
    for j=1:nRois
        roiMean(i,j) = nanmean(brickThis(rois==j));
    end
end