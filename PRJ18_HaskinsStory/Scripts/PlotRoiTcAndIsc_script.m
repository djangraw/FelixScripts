% PlotRoiTcAndIsc_script.m
%
% Created 5/30/18 by DJ.

% [subj_sorted,readScore_sorted] = GetStoryReadingScores();
roiFile = '3dLME_2Grps_readScoreMedSplit_n42_Automask_top-bot_clust_p0.01_a0.05_bisided_map.nii.gz';
roiNames = {'lpTG+AG','thalamus','lSFG','lSMG+lIPL','lSFG','lSupMedG+lACC',...
    'lAmyg+PHCG','laPFC','rAmyg+rPHCG+rIns','lIFG'};

nSubj = numel(subj_sorted);
nRoi = numel(roiNames);
% tcInRoi = GetTcInRoi(subj_sorted,roiFile,1:nRoi);
iscInRoi = GetIscInRoi(subj_sorted,roiFile,1:nRoi);

%%
for iRoi = 1%:nRoi
    PlotRoiTimecourseByReadingScore(tcInRoi(:,iRoi),readScore_sorted,roiFile,iRoi,roiNames{iRoi});
%     saveas(562,sprintf('%s/IscResults_d2/Group/SUMA_IMAGES/top-bot_roi%02d-%s_tc.png',info.dataDir,iRoi,roiNames{iRoi}));
    PlotPairwiseIscMatrices(iscInRoi(:,:,iRoi),readScore_sorted,roiFile,iRoi,roiNames{iRoi});
    set(subplot(2,2,2),'clim',[-.2 .2]);
%     saveas(334,sprintf('%s/IscResults_d2/Group/SUMA_IMAGES/top-bot_roi%02d-%s_iscmat.png',info.dataDir,iRoi,roiNames{iRoi}));
end