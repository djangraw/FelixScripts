% PlotAllRandParcSizes_script.m
% Created 2/23/16 by DJ.

subjects = [6:13, 16:27]; % removed 14 & 15
nRand = 10;
suffix = '_10VoxelMin+orig';
roiSizes = cell(numel(subjects),nRand);
for i=1:numel(subjects)
    SBJ=subjects(i);  
    dataDir = sprintf('/spin1/users/jangrawdc/PRJ08_CognitiveStateDetection/PrcsData/SBJ%02d/D02_CTask001',SBJ);
    prefix = sprintf('%s/SBJ%02d_CTask001.Craddock_RandParc_200ROIs_',dataDir,SBJ);
    roiSizes(i,:) = GetAllRandParcSizes(nRand,prefix,suffix);
end


%% Plot results
figure(611); clf;
xHist = 5:10:1600;
roiSizes_all = cat(1,roiSizes{:});
n_roiSizes = hist(roiSizes_all,xHist);
n_roiSizes = n_roiSizes/sum(n_roiSizes)*100;
bar(xHist,n_roiSizes);
xlabel('# voxels in ROI')
ylabel('% of ROIs');
title(sprintf('%d Subjects: ROI size histogram',numel(subjects))); 