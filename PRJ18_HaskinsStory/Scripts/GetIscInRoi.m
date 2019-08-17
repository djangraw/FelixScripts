function iscInRoi = GetIscInRoi(subj_sorted,roiFile,iRoi)

% Created 5/22/18 by DJ.
% Updated 5/30/18 by DJ - _d2 results.
% Updated 4/8/19 by DJ - v2 analysis.
% Updated 5/22/19 by DJ - accept matrix as roiFile input
% Updated 8/16/19 by DJ - convert voxel ISCs (r values) to Fisher z's, 
%                         take mean, then convert back to r

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
info = GetStoryConstants();
cd(sprintf('%s/IscResults/Group',info.dataDir));
if ischar(roiFile)
    fprintf('Loading ROI mask...\n')
    rois = BrikLoad(roiFile);
else
    rois = roiFile;
end
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
            % convert R to z score, mean, and convert back to R
            iscInRoi(i,j,k) = tanh(mean(atanh(V(isInRoi))));
            % take simple mean without converting
%             iscInRoi(i,j,k) = mean(V(isInRoi));
        end
    end
end
fprintf('Done!\n');
