function iscInRoi = GetIscInRoi(subj_sorted,roiFile,iRoi)

% Created 5/22/18 by DJ.
% Updated 5/30/18 by DJ - _d2 results.
% Updated 4/8/19 by DJ - v2 analysis.

if ~exist('roiFile','var') || isempty(roiFile)
    roiFile = '3dLME_2Grps_readScoreMedSplit_n42_Automask_top-bot_clust_p0.01_a0.05_bisided_map.nii.gz';
end
if ~exist('iRoi','var') || isempty(iRoi)
    iRoi = 1;
end

%% Get files
info = GetStoryConstants();
cd(sprintf('%s/IscResults/Pairwise',info.dataDir));
iscTable = readtable('StoryPairwiseIscTable.txt','Delimiter','\t','ReadVariableNames',true);

%% Load Mask data
fprintf('Loading ROI mask...\n')
cd(sprintf('%s/IscResults/Group',info.dataDir));
rois = BrikLoad(roiFile);

%% Load ROI data
cd(sprintf('%s/IscResults/Pairwise',info.dataDir));
nSubj = numel(subj_sorted);
iscFiles = cell(nSubj);
iscInRoi = nan(nSubj,nSubj,numel(iRoi));
for i=1:nSubj
    for j=(i+1):nSubj
        fprintf('subj %d vs. %d...\n',i,j);
        % find file
        isFile = strcmp(iscTable.Subj,subj_sorted{i}) & strcmp(iscTable.Subj2,subj_sorted{j}) | ...
            strcmp(iscTable.Subj,subj_sorted{j}) & strcmp(iscTable.Subj2,subj_sorted{i});
        iscFiles{i,j} = iscTable.InputFile{isFile};
        % load file
        V = BrikLoad(iscFiles{i,j});
        % Get mean ISC in mask
        for k=1:numel(iRoi)
            isInRoi = rois==iRoi(k);
            fprintf('found %d voxels in ROI %d.\n',sum(isInRoi(:)),iRoi(k));
            iscInRoi(i,j,k) = mean(V(isInRoi));
        end
    end
end
fprintf('Done!\n');
