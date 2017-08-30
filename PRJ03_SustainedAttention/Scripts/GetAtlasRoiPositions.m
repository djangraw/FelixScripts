function roiPos = GetAtlasRoiPositions(atlasFile,subbrick)

% Return mean (i,j,k) positions of all voxels in each ROI of an atlas.
%
% roiPos = GetAtlasRoiPositions(atlasFile,subbrick)
% 
% INPUTS:
% -atlasFile is a string specifying an AFNI brick file in the current path.
% The atlas should have integer values 1:n, where n is the # of ROIs.
% -subbrick is an integer value indicating which subbrick of the atlas file 
% should be used (1-based, default = 1).
%
% OUTPUTS:
% -roiPos is an nx3 matrix where row m is the mean (i,j,k) position of ROI
% m. Missing ROIs will produce a row of nans.
%
% Created 11/24/15 by DJ.
% Updated 12/16/15 by DJ - nROIs = max(atlas(:)), any missing values will
%  have nan positions.
% Updated 5/8/17 by DJ - added comments, defaults.

if ischar(atlasFile)
    % declare defaults
    if ~exist('subbrick','var') || isempty(subbrick)
        subbrick = 1;
    end
    % load atlas
    fprintf('Loading atlas...\n');
    Opt = struct('Frames',subbrick);
    [err,atlas,atlasInfo,ErrMsg] = BrikLoad(atlasFile,Opt);
else
    atlas = atlasFile; % atlas brick is first input
end

% Get number of ROIs
nROIs = max(atlas(:));
% Get ROI positions
roiPos = nan(nROIs,3);
for i=1:nROIs
    if any(atlas(:)==i)
        [r,c,v] = ind2sub(size(atlas),find(atlas == i));
        roiPos(i,:) = [mean(r),mean(c),mean(v)];
    end
end
    