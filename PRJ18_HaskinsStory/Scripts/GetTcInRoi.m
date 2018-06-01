function tcInRoi = GetTcInRoi(subjects,roiFile,iRoi)

% tcInRoi = GetTcInRoi(subjects,roiFile,iRoi)
%
% Created 5/22/18 by DJ.
% Updated 5/30/18 by DJ - _d2 results.

if ~exist('roiFile','var') || isempty(roiFile)
    roiFile = '3dLME_2Grps_readScoreMedSplit_n42_Automask_top-bot_clust_p0.01_a0.05_bisided_map.nii.gz';
end
if ~exist('iRoi','var') || isempty(iRoi)
    iRoi = 1;
end

%% Load Mask data
info = GetStoryConstants();
cd(sprintf('%s/IscResults_d2/Group',info.dataDir));
rois = BrikLoad(roiFile);
isInRoi = rois==iRoi;
fprintf('Loaded mask... %d voxels in ROI %d.\n',sum(isInRoi(:)),iRoi);
isInRoi_vec = isInRoi(:);

%% Load timecourses (after 3dDeconvolve)
tcInRoi = nan(info.nT,numel(subjects));
fprintf('Loading timecourses for %d subjects...\n',numel(subjects));
for i=1:numel(subjects)
    fprintf('Loading timecourse %d/%d...\n',i,numel(subjects));
    tsFile = sprintf('%s/%s/%s.storyISC_d2/errts.%s.fanaticor+tlrc',info.dataDir,subjects{i},subjects{i},subjects{i});
    ts = BrikLoad(tsFile);
    ts_vec = reshape(ts,[numel(ts)/info.nT,info.nT])'; %time x voxels
    tcInRoi(:,i) = mean(ts_vec(:,isInRoi_vec),2);
end
fprintf('Done!\n');
