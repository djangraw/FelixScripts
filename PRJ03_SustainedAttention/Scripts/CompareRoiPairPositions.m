function roiPairDistances = CompareRoiPairPositions(fcMask1,fcMask2,atlas)

% CompareRoiPairPositions(fcMask1,fcMask2,atlas)
%
% Created 10/11/16 by DJ.

roiPos = GetAtlasRoiPositions(atlas);

roiDist = pdist2(roiPos,roiPos);

nNodes = size(fcMask1,1);
uppertri = triu(ones(nNodes),1); % above the diagonal
isUpperTri = uppertri>0;

[iEdges1,jEdges1] = find(fcMask1>0 & isUpperTri);
[iEdges2,jEdges2] = find(fcMask2>0 & isUpperTri);

nEdges1 = numel(iEdges1);
nEdges2 = numel(iEdges2);

roiPairDistances = nan(nEdges1,nEdges2);
for i=1:nEdges1
    for j=1:nEdges2
        dist1 = roiDist(iEdges1(i),iEdges2(j)) + roiDist(jEdges1(i),jEdges2(j));
        dist2 = roiDist(iEdges1(i),jEdges2(j)) + roiDist(jEdges1(i),iEdges2(j));
        roiPairDistances(i,j) = min(dist1,dist2);
    end
end









