function tcInRoi = GetTcInRoi(subjects,roiFile,iRoi)

% tcInRoi = GetTcInRoi(subjects,roiFile,iRoi)
%
% Created 5/22/18 by DJ.

if ~exist('roiFile','var') || isempty(roiFile)
    roiFile = '3dLME_3Grps_readScoreMedSplit_n42_Automask_clusters+tlrc';
end
if ~exist('iRoi','var') || isempty(iRoi)
    iRoi = 6;
end

%% Load Mask data
info = GetStoryConstants();
cd(sprintf('%s/IscResults/Pairwise',info.dataDir));
rois = BrikLoad(roiFile);
isInRoi = rois==iRoi;
fprintf('Loaded mask... %d voxels in ROI %d.\n',sum(isInRoi(:)),iRoi);
isInRoi_vec = isInRoi(:);

%% Load timecourses (after 3dDeconvolve)
tcInRoi = nan(info.nT,numel(subjects));
fprintf('Loading timecourses for %d subjects...\n',numel(subjects));
for i=1:numel(subjects)
    fprintf('Loading timecourse %d/%d...\n',i,numel(subjects));
    tsFile = sprintf('%s/%s/%s.storyISC/errts.%s.tproject+tlrc',info.dataDir,subjects{i},subjects{i},subjects{i});
    ts = BrikLoad(tsFile);
    ts_vec = reshape(ts,[numel(ts)/info.nT,info.nT])'; %time x voxels
    tcInRoi(:,i) = mean(ts_vec(:,isInRoi_vec),2);
end
fprintf('Done!\n');
