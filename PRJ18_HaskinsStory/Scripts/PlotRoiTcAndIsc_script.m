% PlotRoiTcAndIsc_script.m
%
% Created 5/30/18 by DJ.

% [subj_sorted,readScore_sorted] = GetStoryReadingScores();
roiFile = '3dLME_2Grps_readScoreMedSplit_n42_Automask_top-bot_clust_p0.01_a0.05_bisided_map.nii.gz';
roiNames = {'lpTG','thalamus','lSFG','lAG'};

for iRoi = 2:numel(roiNames)
    PlotRoiTimecourseByReadingScore(subj_sorted,readScore_sorted,roiFile,iRoi,roiNames{iRoi});
    saveas(562,sprintf('%s/IscResults_d2/Group/SUMA_IMAGES/top-bot_roi%02d-%s_tc.png',info.dataDir,iRoi,roiNames{iRoi}));
    PlotPairwiseIscMatrices(subj_sorted,readScore_sorted,roiFile,iRoi,roiName);
    saveas(334,sprintf('%s/IscResults_d2/Group/SUMA_IMAGES/top-bot_roi%02d-%s_iscmat.png',info.dataDir,iRoi,roiNames{iRoi}));
end