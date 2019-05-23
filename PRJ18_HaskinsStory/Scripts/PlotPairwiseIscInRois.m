constants = GetStoryConstants();
[readScores, IQs,weights,weightNames] = GetStoryReadingScores(constants.okReadSubj);
[readScore_sorted,order] = sort(readScores,'ascend');
subj_sorted = constants.okReadSubj(order);
nSubj = numel(subj_sorted);

%%


% groupDiffMaps = {sprintf('%s/IscResults/Group/3dLME_2Grps_readScoreMedSplit_n69_Automask_top-bot_clust_p0.01_a0.05_bisided_EE.nii.gz',constants.dataDir), ''};
groupDiffMaps = {''};
% roiTerms = {'anteriorcingulate','dlpfc','inferiorfrontal','inferiortemporal','supramarginalgyrus','primaryauditory','primaryvisual','frontaleye'};
% roiNames = {'ACC','DLPFC','IFG','ITG','SMG','A1','V1','FEF'};
roiTerms = {'ACC','IFG-pOp','IFG-pOrb','IFG-pTri','ITG','SMG','STG','CG'};
roiNames = {'ACC','IFG-pOp','IFG-pOrb','IFG-pTri','ITG','SMG','STG (Aud)','CalcGyr (Vis)'};
% sides={'r','l',''};
side = {''};


nRoi = numel(roiNames);

mapName = cell(1,nRoi);
for j=1:length(roiTerms)
    fprintf('===ROI %d/%d...\n',j,length(roiTerms));

%             neuroSynthMask = sprintf('%s/NeuroSynthTerms/%s_association-test_z_FDR_0.01_epiRes.nii.gz',constants.dataDir,roiTerms{j});
    neuroSynthMask = sprintf('%s/atlasRois/atlas_%s+tlrc',constants.dataDir,roiTerms{j});
    roiName = sprintf('%s%s',sides{k},roiNames{j});


    olap = GetMaskOverlap(neuroSynthMask);

    % handle hemisphere splits
    if roiName(1)=='r'
        midline = size(olap,1)/2;
        olap(1:midline,:,:) = false;
    elseif roiName(1)=='l'
        midline = size(olap,1);
        olap(midline:end,:,:) = false;
    end
    nVoxels = sum(olap(:));
    fprintf('%d voxels in mask %s.\n',nVoxels,roiName);
    if isempty(groupDiffMap)
        mapName{j} = sprintf('%s (%d voxels)',roiName,nVoxels);
    else
        mapName{j} = sprintf('%s * top-bot p<0.01, a<0.05 (%d voxels)',roiName,nVoxels);
    end
    
    if j==1
        roiBrik = olap;
    else
        roiBrik = roiBrik + j*olap;
    end  
    
end
%%
tcInRoi = GetTcInRoi(subj_sorted,roiBrik,1:nRoi);
iscInRoi = GetIscInRoi(subj_sorted,roiBrik,1:nRoi);




%% Plot ISC matrices next to each other
nBot = sum(readScore_sorted>median(readScore_sorted));

figure(246);
set(246,'Position',[10,10,100,1000]);
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
saveas(246,sprintf('%s/IscResults/Group/SUMA_IMAGES/top-bot_atlasRois_isccol.png',constants.dataDir));
