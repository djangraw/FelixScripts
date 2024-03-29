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
sides = {''};


nRoi = numel(roiNames);

mapName = cell(1,nRoi);
for i=1:length(groupDiffMaps)
    groupDiffMap = groupDiffMaps{i};
    for j=1:length(roiTerms)
        fprintf('===ROI %d/%d...\n',j,length(roiTerms));
        for k=1:numel(sides)
    %             neuroSynthMask = sprintf('%s/NeuroSynthTerms/%s_association-test_z_FDR_0.01_epiRes.nii.gz',constants.dataDir,roiTerms{j});
            neuroSynthMask = sprintf('%s/atlasRois/atlas_%s+tlrc',constants.dataDir,roiTerms{j});
            roiName = sprintf('%s%s',sides{k},roiNames{j});


            olap = GetMaskOverlap(neuroSynthMask);

            % handle hemisphere splits
            if roiName(1)=='r'
                midline = size(olap,1)/2;
                olap(1:midline,:,:) = false;
            elseif roiName(1)=='l'
                midline = size(olap,1)/2;
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
    end
end
%%
% tcInRoi = GetTcInRoi(subj_sorted,roiBrik,1:nRoi);
iscInRoi = GetIscInRoi(subj_sorted,roiBrik,1:nRoi);




%% Plot ISC matrices next to each other
nBot = sum(readScore_sorted>median(readScore_sorted));

figure(246);
set(246,'Position',[10,10,600,1000]);
for iRoi = 1:nRoi
    
    
    subplot(ceil(nRoi/2),2,iRoi); cla; hold on;
    imagesc(iscInRoi(:,:,iRoi));
%     plot([nBot,nBot,nSubj,nSubj,nBot]+1.5,[0,nBot,nBot,0,0]-0.5,'g-','LineWidth',2);
    plot([0,nBot,nBot,0]+0.5,[0,nBot,0,0]+0.5,'-','color',[112 48 160]/255,'LineWidth',2);
    plot([nBot,nSubj,nSubj,nBot]+0.5,[nBot,nSubj,nBot,nBot]+0.5,'r-','LineWidth',2);


    % annotate plot
    axis square
    xlabel(sprintf('better reader-->'))
    ylabel(sprintf('participant\nbetter reader-->'))
    set(gca,'ydir','normal');
    set(gca,'xtick',[],'ytick',[]);
    title(roiNames{iRoi})
    if strcmp(roiNames{iRoi},'STG (Aud)')
        set(gca,'clim',[-.3 .3]);
    elseif strcmp(roiNames{iRoi},'CalcGyr (Vis)')
        set(gca,'clim',[-.15 .15]);
    else
        set(gca,'clim',[-.075 .075]);
    end
    ylim([1 nSubj]-0.5)
%     colormap jet
    colorbar
    
end
saveas(246,sprintf('%s/IscResults/Group/SUMA_IMAGES/top-bot_atlasRois_isccol.png',constants.dataDir));
