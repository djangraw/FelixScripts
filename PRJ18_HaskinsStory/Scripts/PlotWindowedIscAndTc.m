% PlotWindowedIscAndTc.m
% 
% Created 4/11/19 by DJ.

constants = GetStoryConstants();

groupDiffMap = sprintf('%s/IscResults/Group/3dLME_2Grps_readScoreMedSplit_n69_Automask_top-bot_clust_p0.01_a0.05_bisided_EE.nii.gz',constants.dataDir);

% neuroSynthMask = sprintf('%s/NeuroSynthTerms/anteriorcingulate_association-test_z_FDR_0.01_epiRes.nii.gz',constants.dataDir);
% roiName = 'ACC';

% neuroSynthMask = sprintf('%s/NeuroSynthTerms/dlpfc_association-test_z_FDR_0.01_epiRes.nii.gz',constants.dataDir);
% roiName = 'rDLPFC';

% neuroSynthMask = sprintf('%s/NeuroSynthTerms/inferiorfrontal_association-test_z_FDR_0.01_epiRes.nii.gz',constants.dataDir);
% roiName = 'rIFG';

neuroSynthMask = sprintf('%s/NeuroSynthTerms/inferiortemporal_association-test_z_FDR_0.01_epiRes.nii.gz',constants.dataDir);
roiName = 'lITG';

% neuroSynthMask = sprintf('%s/NeuroSynthTerms/supramarginalgyrus_association-test_z_FDR_0.01_epiRes.nii.gz',constants.dataDir);
% roiName = 'rSMG';

olap = GetMaskOverlap(groupDiffMap,neuroSynthMask);
if roiName(1)=='r'
    midline = size(olap,1)/2;
    olap(1:midline,:,:) = false;
elseif roiName(1)=='l'
    midline = size(olap,1);
    olap(midline:end,:,:) = false;
end
fprintf('%d voxels in mask %s.\n',sum(olap(:)),roiName);
%%
winLength = 15;
TR = 2;
clear iscInRoi
topResult = sprintf('%s/IscResults/Group/SlidingWindowIsc_win15_toptop+tlrc',constants.dataDir);
iscInRoi(:,1) = GetTimecourseInRoi(topResult,olap);
botResult = sprintf('%s/IscResults/Group/SlidingWindowIsc_win15_botbot+tlrc',constants.dataDir);
iscInRoi(:,2) = GetTimecourseInRoi(botResult,olap);

tIsc = ((1:length(iscInRoi)) + winLength/2)*TR;

%%
clear tcInRoi
topResult = sprintf('%s/MeanErrtsFanaticor_top+tlrc',constants.dataDir);
tcInRoi(:,1) = GetTimecourseInRoi(topResult,olap);
botResult = sprintf('%s/MeanErrtsFanaticor_bot+tlrc',constants.dataDir);
tcInRoi(:,2) = GetTimecourseInRoi(botResult,olap);

t = (1:length(tcInRoi))*TR;

%%
figure(523); clf;
PlotTimecoursesWithConditions(tIsc,iscInRoi)
ylabel('ISC')
xlabel('time of window center (sec)')
title(sprintf('Sliding window correlation in %s, %ds window',roiName,winLength*TR));
MakeLegend({'r','g'},{'Top Readers','Bottom Readers'},[2,2]);
xlim([0,t(end)])

%%
figure(524); clf;
PlotTimecoursesWithConditions(t,tcInRoi)
ylabel('% BOLD signal change')
title(sprintf('Mean signal in %s during task',roiName));
MakeLegend({'r','g'},{'Top Readers','Bottom Readers'},[2,2]);
xlim([0,t(end)])