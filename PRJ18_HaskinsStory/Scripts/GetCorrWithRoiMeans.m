function GetCorrWithRoiMeans()

% Created 10/23/19 by DJ.

constants = GetStoryConstants();

readScores = GetStoryReadingScores(constants.okReadSubj);
[~,order] = sort(readScores,'ascend');
subj_sorted = constants.okReadSubj(order);
nSubj = numel(subj_sorted);

%% Get timecourse in ROI for each subject
roiMask = BrikLoad(sprintf('%s/IscResults/Group/3dLME_2Grps_readScoreMedSplit_n40-iqMatched_Automask_top-bot_clust_p0.002_a0.05_bisided_map.nii.gz',constants.dataDir));
roiIndices = 1:14;
roiNames = {'IFG-pTri/MidFG','lITG/lMidTG','lSPL/Precun','rSPL/rPostCG','rCer(V1/Crus1)','lIns','lSMedG/lSFG','rMidTG','lPrec/lCalcG','midbrain/VTA','lMidTG/lSTG','laSTG','lMidFG/lSFG','rIOG/rITG'};

topResult = sprintf('%s/MeanErrtsFanaticor_top+tlrc',constants.dataDir);
botResult = sprintf('%s/MeanErrtsFanaticor_bot+tlrc',constants.dataDir);

nRoi = length(roiIndices);
tcInRoi = nan(constants.nT,nRoi);
for iRoi=1:length(roiIndices)
    fprintf('===ROI %d/%d...\n',iRoi,length(roiIndices));

    % extract ROI info
    roiName = roiNames{iRoi};
    isInRoi = (roiMask==roiIndices(iRoi));
    nVoxels = sum(isInRoi(:)); 
    fprintf('%d voxels in mask %s.\n',nVoxels,roiName);
    % mapName = sprintf('ROI%02d: %s (%d voxels)',iRoi,roiName,nVoxels);
    
    % Get timecourses
    topTc = GetTimecourseInRoi(topResult,isInRoi);
    botTc = GetTimecourseInRoi(botResult,isInRoi);
    tcInRoi(:,iRoi) = (topTc+botTc)/2;

end

% Write timecourses to 1D file
Info = struct('FileFormat','1D');
Opt = struct('Prefix',sprintf('%s/RoiTimecourses.1D',constants.dataDir));
WriteBrik(tcInRoi,Info,Opt);

%% Write commands
cmd_file = sprintf('%s/GetCorrWithRoiMeans.tcsh',constants.scriptDir);
fprintf('Writing file %s...\n',cmd_file);

fid = fopen(cmd_file,'w');
fprintf(fid,'#!/bin/tcsh -e\n\n');
fprintf(fid,'# Created %s by MATLAB function GetCorrWithRoiMeans.m\n\n',datestr(now));

fprintf(fid,'# run script\n');
for i=1:nSubj
    subj = subj_sorted{i};
    fprintf(fid,'3dTcorr1D -prefix %s/CorrWithRoiMeans/%s.corrWithRoiMeans %s/%s/%s.story/errts.%s.fanaticor+tlrc %s/RoiTimecourses.1D \n',constants.dataDir,subj,constants.dataDir,subj,subj,subj,constants.dataDir);
end
fclose(fid);

%% Run result
cmd = sprintf('tcsh %s',cmd_file);
fprintf('Running command >> %s...\n',cmd);
system(cmd);
    