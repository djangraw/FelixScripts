function roiSizes = GetRandParcRoiSizes(parc)

% Created 2/23/16 by DJ.

if ischar(parc)
    fprintf('Loading %s...\n',parc);
    [err,parc,Info] = BrikLoad(parc);
end

% Get roi #s
iParcs = unique(parc(parc>0));

roiSizes = nan(size(iParcs));
for i=1:numel(iParcs)
    roiSizes(i) = sum(parc(:)==iParcs(i));
end