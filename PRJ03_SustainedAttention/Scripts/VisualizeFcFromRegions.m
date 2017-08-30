function VisualizeFcFromRegions(FC,regionNames,atlas,atlasLabels,labelNames,labelColors,orientation)

% VisualizeFcFromRegion(FC,regionNames,atlas,atlasLabels,labelNames,labelColors,orientation)
%
% Created 1/4/16 by DJ.

if ischar(regionNames)
    regionNames = {regionNames};
elseif isnumeric(regionNames)
    regionNames = labelNames(regionNames);
end
iRegions = find(ismember(labelNames,regionNames));
iKeep = find(ismember(atlasLabels,iRegions));
masktmp = zeros(size(FC));
masktmp(iKeep,:) = FC(iKeep,:);
masktmp(:,iKeep) = FC(:,iKeep);
figure(834); clf;
VisualizeFcIn3d(masktmp,atlas,atlasLabels,labelColors,labelNames,orientation);
