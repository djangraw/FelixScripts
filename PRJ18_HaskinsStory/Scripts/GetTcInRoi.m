function tcInRoi = GetTcInRoi(subjects,roiFile,iRoi)

% tcInRoi = GetTcInRoi(subjects,roiFile,iRoi)
%
% Created 5/22/18 by DJ.
% Updated 5/30/18 by DJ - _d2 results.
% Updated 4/8/19 by DJ - v2 analysis.
% Updated 5/22/19 by DJ - accept matrix as roiFile input

if ~exist('roiFile','var') || isempty(roiFile)
    roiFile = '3dLME_2Grps_readScoreMedSplit_n42_Automask_top-bot_clust_p0.01_a0.05_bisided_map.nii.gz';
end
if ~exist('iRoi','var') || isempty(iRoi)
    iRoi = 1;
end

%% Load Mask data
info = GetStoryConstants();
cd(sprintf('%s/IscResults/Group',info.dataDir));
if ischar(roiFile)
    fprintf('Loading ROI mask...\n')
    rois = BrikLoad(roiFile);
else
    rois = roiFile;
end
%% Load timecourses (after 3dDeconvolve)
tcInRoi = nan(info.nT,numel(subjects),numel(iRoi));
fprintf('Loading timecourses for %d subjects...\n',numel(subjects));
for i=1:numel(subjects)
    fprintf('Loading timecourse %d/%d...\n',i,numel(subjects));
    tsFile = sprintf('%s/%s/%s.story/errts.%s.fanaticor+tlrc',info.dataDir,subjects{i},subjects{i},subjects{i});
    ts = BrikLoad(tsFile);
    ts_vec = reshape(ts,[numel(ts)/info.nT,info.nT])'; %time x voxels
    for j=1:numel(iRoi)
        isInRoi = rois==iRoi(j);
        fprintf('found %d voxels in ROI %d.\n',sum(isInRoi(:)),iRoi(j));
        isInRoi_vec = isInRoi(:);
        tcInRoi(:,i,j) = mean(ts_vec(:,isInRoi_vec),2);
    end
end
fprintf('Done!\n');
