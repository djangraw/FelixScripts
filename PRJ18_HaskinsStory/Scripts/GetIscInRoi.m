function iscInRoi = GetIscInRoi(subj_sorted,roiFile,iRoi)

% Created 5/22/18 by DJ.

if ~exist('roiFile','var') || isempty(roiFile)
    roiFile = '3dLME_3Grps_readScoreMedSplit_n42_Automask_clusters+tlrc';
end
if ~exist('iRoi','var') || isempty(iRoi)
    iRoi = 6;
end

%% Get files
info = GetStoryConstants();
cd(sprintf('%s/IscResults/Pairwise',info.dataDir));
iscTable = readtable('StoryPairwiseIscTable.txt','Delimiter','\t','ReadVariableNames',true);

%% Load Mask data
cd(sprintf('%s/IscResults/Pairwise',info.dataDir));
rois = BrikLoad(roiFile);
isInRoi = rois==iRoi;
fprintf('Loaded mask... %d voxels in ROI %d.\n',sum(isInRoi(:)),iRoi);

%% Load ROI data
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
