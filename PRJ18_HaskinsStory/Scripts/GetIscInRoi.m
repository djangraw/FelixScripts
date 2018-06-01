function iscInRoi = GetIscInRoi(subj_sorted,roiFile,iRoi)

% Created 5/22/18 by DJ.
% Updated 5/30/18 by DJ - _d2 results.

if ~exist('roiFile','var') || isempty(roiFile)
    roiFile = '3dLME_2Grps_readScoreMedSplit_n42_Automask_top-bot_clust_p0.01_a0.05_bisided_map.nii.gz';
end
if ~exist('iRoi','var') || isempty(iRoi)
    iRoi = 1;
end

%% Get files
info = GetStoryConstants();
cd(sprintf('%s/IscResults_d2/Pairwise',info.dataDir));
iscTable = readtable('StoryPairwiseIscTable.txt','Delimiter','\t','ReadVariableNames',true);

%% Load Mask data
cd(sprintf('%s/IscResults_d2/Group',info.dataDir));
rois = BrikLoad(roiFile);
isInRoi = rois==iRoi;
fprintf('Loaded mask... %d voxels in ROI %d.\n',sum(isInRoi(:)),iRoi);

%% Load ROI data
cd(sprintf('%s/IscResults_d2/Pairwise',info.dataDir));
nSubj = numel(subj_sorted);
iscFiles = cell(nSubj);
iscInRoi = nan(nSubj);
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
        iscInRoi(i,j) = mean(V(isInRoi));
    end
end
fprintf('Done!\n');
