function [isPosPosEdge, isNegNegEdge, isPosNegEdge] = GetFcNetworksFromMasks(MaskPos,MaskNeg,atlas,matchThreshold)

% [isPosPosEdge, isNegNegEdge, isPosNegEdge] = GetFcNetworksFromMasks(MaskPos,MaskNeg,atlas,matchThreshold)
%
%
% Created 11/9/16 by DJ.

nROIs = max(atlas(:));
% binarize masks
MaskPos = MaskPos>0;
MaskNeg = MaskNeg>0;
% Get ROIs that match
[fracInPos, fracInNeg] = deal(nan(1,nROIs));
for i=1:nROIs
    isInROI = atlas==i;
    fracInPos(i) = mean(MaskPos(isInROI));
    fracInNeg(i) = mean(MaskNeg(isInROI));
end
% Threshold
if matchThreshold<1
    isInPos = fracInPos > matchThreshold;
    isInNeg = fracInNeg > matchThreshold;
else
    [~,order] = sort(fracInPos,'descend');
    isInPos = false(size(fracInPos));
    isInPos(order(1:matchThreshold)) = true;
    [~,order] = sort(fracInNeg,'descend');
    isInNeg = false(size(fracInNeg));
    isInNeg(order(1:matchThreshold)) = true;
end
% Convert to edges
[isPosPosEdge,isNegNegEdge,isPosNegEdge] = deal(false(nROIs));
isPosPosEdge(isInPos,isInPos) = true;
isNegNegEdge(isInNeg,isInNeg) = true;

isPosNegEdge(isInPos,isInNeg) = true;
isPosNegEdge(isInNeg,isInPos) = true;
