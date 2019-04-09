% PlotRoiTcAndIsc_script.m
%
% Created 5/30/18 by DJ.
% Updated 4/8/19 by DJ - new version of analyses

% roiFile = '3dLME_2Grps_readScoreMedSplit_n42_Automask_top-bot_clust_p0.01_a0.05_bisided_map.nii.gz';
% roiNames = {'lpTG+AG','thalamus','lSFG','lSMG+lIPL','lSFG','lSupMedG+lACC',...
%     'lAmyg+PHCG','laPFC','rAmyg+rPHCG+rIns','lIFG'};
% roiFile = '3dLME_2Grps_readScoreMedSplit_n42_TrainingDayTimecourseClusters+tlrc';
% roiNames = {'lSMG','lFus','laPFC','lBroca'};

roiFile = 'top-bot_p1e-6_a0.01_mask+tlrc';
roiNames = {'rMidOrbGyr','rSupCer','rSPL','lITG','lSupMedGyr','lMidTempGyr'};

[readScores, IQs,weights,weightNames] = GetStoryReadingScores(info.okReadSubj);
[readScore_sorted,order] = sort(readScores,'ascend');
subj_sorted = info.okReadSubj(order);

nSubj = numel(subj_sorted);
nRoi = numel(roiNames);
tcInRoi = GetTcInRoi(subj_sorted,roiFile,1:nRoi);
iscInRoi = GetIscInRoi(subj_sorted,roiFile,1:nRoi);

%%
for iRoi = 1:nRoi
    PlotRoiTimecourseByReadingScore(tcInRoi(:,:,iRoi),readScore_sorted,roiFile,iRoi,roiNames{iRoi});
    saveas(562,sprintf('%s/IscResults/Group/SUMA_IMAGES/top-bot_roi%02d-%s_tc.png',info.dataDir,iRoi,roiNames{iRoi}));
    PlotPairwiseIscMatrices(iscInRoi(:,:,iRoi),readScore_sorted,roiFile,iRoi,roiNames{iRoi});
    set(subplot(2,2,2),'clim',[-.2 .2]);
    saveas(334,sprintf('%s/IscResults/Group/SUMA_IMAGES/top-bot_roi%02d-%s_iscmat.png',info.dataDir,iRoi,roiNames{iRoi}));
end

%% Plot ISC matrices next to each other
nBot = sum(readScore_sorted>median(readScore_sorted));

figure(246);
for iRoi = 1:nRoi
    
    
    subplot(nRoi,1,iRoi); cla; hold on;
    imagesc(iscInRoi(:,:,iRoi));
    plot([0,nBot,nBot,0]+0.5,[0,nBot,0,0]+0.5,'b-','LineWidth',2);
    plot([nBot,nSubj,nSubj,nBot]+0.5,[nBot,nSubj,nBot,nBot]+0.5,'y-','LineWidth',2);
    plot([nBot,nBot,nSubj,nSubj,nBot]+0.5,[0,nBot,nBot,0,0]+0.5,'g-','LineWidth',2);

    % annotate plot
    axis square
    xlabel(sprintf('better reader-->'))
    ylabel(sprintf('participant\nbetter reader-->'))
    set(gca,'ydir','normal');
    set(gca,'xtick',[],'ytick',[]);
    title(roiNames{iRoi})
    set(gca,'clim',[-.2 .2]);
    colorbar
    
end
saveas(246,sprintf('%s/IscResults/Group/SUMA_IMAGES/top-bot_roi_isccol.png',info.dataDir));
