function CompareRoiSizeToMaskEdges(fcMask,atlas)

% CompareRoiSizeToMaskEdges(fcMask,atlas)
%
% Created 10/20/16 by DJ.

% Load atlas
if iscell(atlas)
    for i=1:numel(atlas)
        if ischar(atlas{i})
            atlas{i} = BrikLoad(atlas{i});
        end
    end
    atlas = cat(4,atlas{:});
elseif ischar(atlas)
    atlas = BrikLoad(atlas);
end

% Get # voxels in each ROI
nRois = max(atlas(:));
nInRoi = hist(atlas(atlas>0),1:nRois)/size(atlas,4);

% Get # mask edges for each ROI
fcMask = UnvectorizeFc(VectorizeFc(fcMask), 0); % make upper triangular
fcMask = fcMask + fcMask'; % make symmetric
nEdges = sum(fcMask,1);

% Correlate the two
cla;
plot(nInRoi,nEdges,'.');
xlabel('# voxels in ROI')
ylabel('# edges in FC mask')
[r,p] = corr(nInRoi',nEdges');
title(sprintf('r=%.3g, p=%.3g\n',r,p));