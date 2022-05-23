% RunRoiIscVsBehaviorRsa.m
%
% Run a representational similarity analysis (RSA) comparing the behavioral
% similarity of each subject pair with the ISC of each subject pair (in
% various ROIs).
%
% For details, see comment from Emily Finn in draft of Haskins Story paper,
% which cites her 2020 NeuroImage paper explaining details:
% https://www.sciencedirect.com/science/article/pii/S1053811920303153
%
% Created 5/18-19/22 by DJ.
% Updated 5/23/22 by DJ - updated ROI name/numbers from recent paper draft.

%% Get behavior scores (from PlotReadingSubscoreHistos.m)

constants = GetStoryConstants();
subjects = constants.okReadSubj;
% get standard reading scores
[readScores, weights,weightNames,IQs,ages] = GetStoryReadingScores(subjects);
% sort subjects by their reading score
[readScore_sorted,order] = sort(readScores,'ascend');
subj_sorted = constants.okReadSubj(order);

% Read behavior file
behTable = readtable(constants.behFile);
% TODO: SORT behTable




% Append all reading scores
allReadScores = [behTable.TOWREVerified__SWE_SS,behTable.TOWREVerified__PDE_SS,behTable.TOWREVerified__TWRE_SS,...
    behTable.WoodcockJohnsonVerified__BscR_SS, behTable.WoodcockJohnsonVerified__LW_SS, behTable.WoodcockJohnsonVerified__WA_SS,...
    behTable.WASIVerified__Perf_IQ,behTable.EdinburghHandedness__LiQ,behTable.MRIScans__ProfileAge];
% weightNames = {'TOWRE_SWE_SS','TOWRE_PDE_SS','TOWRE_TWRE_SS','WJ3_BscR_SS','WJ3_LW_SS','WJ3_WA_SS'};
weightNames = {'TOWRE Sight-Word','TOWRE Phoenetic Decoding','TOWRE Total Word Reading','WJ3 Basic Reading','WJ3 Letter-Word ID','WJ3 Word Attack','WASI Performance IQ','Edinburgh Handedness LiQ','Age (years)'};

% TODO: Try other collections of scores that we might hypothesize match the
% function of a certain ROI

%% TODO: Get & Plot "ISC" matrices from behavioral scores 
% (i.e., how much does each pair's behavioral profile match?)


%% Get ISC in clusters (from GetPairwiseIscInClusters.m)


% groupDiffMaps = {sprintf('%s/IscResults/Group/3dLME_2Grps_readScoreMedSplit_n69_Automask_top-bot_clust_p0.01_a0.05_bisided_EE.nii.gz',constants.dataDir), ''};
groupDiffMaps = {sprintf('%s/IscResults/Group/3dLME_2Grps_readScoreMedSplit_n40-iqMatched_Automask_top-bot_clust_p0.002_a0.05_bisided_map.nii.gz',constants.dataDir)};
% roiTerms = {'anteriorcingulate','dlpfc','inferiorfrontal','inferiortemporal','supramarginalgyrus','primaryauditory','primaryvisual','frontaleye'};
% roiNames = {'ACC','DLPFC','IFG','ITG','SMG','A1','V1','FEF'};
roiIndices = 1:11;
%roiNames =
%{'lITG/lFus','lSPL/lPrecun','lMidFG/lSFG','lMidOG','rSPL/rPostCG','lAG','rIOG/rITG','lParaCL/rParaCL','lPrecun/rCG','lSMG/lIPL','lSMedG/lSFG'}; % full names from MATLAB bar plots
roiNames = {'lITG','lSPL','lSFG','lMidOG','rSPL','lAG','rIOG','paraCL','Precun','lSMG','lSMedG'};% names from powerpoint results summaries (and paper draft)
% roiNames = {'IFG-pTri/MidFG','lITG/lMidTG','lSPL/Precun','rSPL/rPostCG','rCer(V1/Crus1)','lIns','lSMedG/lSFG','rMidTG','lPrec/lCalcG','midbrain/VTA','lMidTG/lSTG','laSTG','lMidFG/lSFG','rIOG/rITG'};
% roiTerms = {'ACC','IFG-pOp','IFG-pOrb','IFG-pTri','ITG','SMG','STG','CG'};
% roiNames = {'ACC','IFG-pOp','IFG-pOrb','IFG-pTri','ITG','SMG','STG (Aud)','CalcGyr (Vis)'};
% sides={'r','l',''};
sides = {''};


nRoi = numel(roiNames);

mapName = cell(1,nRoi);
for i=1:length(groupDiffMaps)
    groupDiffMap = groupDiffMaps{i};
    roiMap = BrikLoad(groupDiffMap);
    for j=1:length(roiNames)
        fprintf('===ROI %d/%d...\n',j,length(roiNames));
        neuroSynthMask = roiMap==roiIndices(j);
        for k=1:numel(sides)

            roiName = sprintf('%s%s',sides{k},roiNames{j});


            olap = GetMaskOverlap(neuroSynthMask);

            % handle hemisphere splits
%             if roiName(1)=='r'
%                 midline = size(olap,1)/2;
%                 olap(1:midline,:,:) = false;
%             elseif roiName(1)=='l'
%                 midline = size(olap,1)/2;
%                 olap(midline:end,:,:) = false;
%             end
            nVoxels = sum(olap(:));
            fprintf('%d voxels in mask %s.\n',nVoxels,roiName);
            if isempty(groupDiffMap)
                mapName{j} = sprintf('cluster %d: %s (%d voxels)',roiIndices(j),roiName,nVoxels);
            else
                mapName{j} = sprintf('cluster %d: %s * top-bot p<0.01, a<0.05 (%d voxels)',roiIndices(j),roiName,nVoxels);
            end

            if j==1
                roiBrik = olap;
            else
                roiBrik = roiBrik + j*olap;
            end  
        end
    end
end
%% Get ISC in each of these ROIs
% tcInRoi = GetTcInRoi(subj_sorted,roiBrik,1:nRoi);
iscInRoi = GetIscInRoi(subj_sorted,roiBrik,1:nRoi);


%% Plot ISC matrices next to each other
nBot = sum(readScore_sorted<=median(readScore_sorted));


figure(246); clf;
nCols = ceil(sqrt(nRoi));
nRows = ceil(nRoi/nCols);
set(246,'Position',[10,10,1400,1000]);
for iRoi = 1:nRoi
    % plot pairwise ISC
    subplot(nRows,nCols,iRoi); cla; hold on;
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
% save figure
%saveas(246,sprintf('%s/IscResults/Group/SUMA_IMAGES/readScoreSplit_n40-iqMatched_top-bot_p0.002_a0.05_clusterRois_pairwiseIsc.png',constants.dataDir));




%% Run permutation tests to get stats
iscInRoi_z = atanh(iscInRoi);

isTop = (readScore_sorted>median(readScore_sorted));
isBot = ~isTop;
meanTopTop = squeeze(nanmean(nanmean(iscInRoi_z(isTop,isTop,:),1),2));
meanTopBot = squeeze(nanmean(nanmean(iscInRoi_z(isBot,isTop,:),1),2));
meanBotBot = squeeze(nanmean(nanmean(iscInRoi_z(isBot,isBot,:),1),2));

tic;
nRand = 10000;
[meanTopTop_rand,meanTopBot_rand,meanBotBot_rand] = deal(nan(nRoi,nRand));
for i=1:nRand
    if mod(i,1000)==0
        fprintf('running permutation %d/%d...\n',i,nRand);
    end
    isTop = isTop(randperm(nSubj));
    isBot = ~isTop;
    meanTopTop_rand(:,i) = squeeze(nanmean(nanmean(iscInRoi_z(isTop,isTop,:),1),2));
    meanTopBot_rand(:,i) = squeeze(nanmean(nanmean(iscInRoi_z(isBot,isTop,:),1),2));
    meanBotBot_rand(:,i) = squeeze(nanmean(nanmean(iscInRoi_z(isBot,isBot,:),1),2));
end
fprintf('Done! Took %.1f seconds.\n',toc);

%% Get perm test result
[pTopTop,pTopBot,pBotBot,pTTmTB,pTBmBB,pTTmBB] = deal(nan(1,nRoi));
for i = 1:nRoi
    pTopTop(i) = mean(meanTopTop_rand(i,:)>meanTopTop(i));
    pTopBot(i) = mean(meanTopBot_rand(i,:)>meanTopBot(i));
    pBotBot(i) = mean(meanBotBot_rand(i,:)>meanBotBot(i));
    pTTmTB(i) = mean((meanTopTop_rand(i,:)-meanTopBot_rand(i,:))>(meanTopTop(i)-meanTopBot(i)));
    pTBmBB(i) = mean((meanTopBot_rand(i,:)-meanBotBot_rand(i,:))>(meanTopBot(i)-meanBotBot(i)));
    pTTmBB(i) = mean((meanTopTop_rand(i,:)-meanBotBot_rand(i,:))>(meanTopTop(i)-meanBotBot(i)));
end

%% Make barplots with stars
isTop = (readScore_sorted>median(readScore_sorted));
isBot = (readScore_sorted<=median(readScore_sorted));

meanTopTop_r = tanh(squeeze(nanmean(nanmean(iscInRoi_z(isTop,isTop,:),1),2)));
meanTopBot_r = tanh(squeeze(nanmean(nanmean(iscInRoi_z(isBot,isTop,:),1),2)));
meanBotBot_r = tanh(squeeze(nanmean(nanmean(iscInRoi_z(isBot,isBot,:),1),2)));
% steTopTop = squeeze(nanstd(nanstd(iscInRoi(isTop,isTop,:),[],1),[],2)./sqrt(sum(sum(~isnan(iscInRoi(isTop,isTop,:))))));
% steTopBot = squeeze(nanstd(nanstd(iscInRoi(isBot,isTop,:),[],1),[],2)./sqrt(sum(sum(~isnan(iscInRoi(isBot,isTop,:))))));
% steBotBot = squeeze(nanstd(nanstd(iscInRoi(isBot,isBot,:),[],1),[],2)./sqrt(sum(sum(~isnan(iscInRoi(isBot,isBot,:))))));


nCols = ceil(sqrt(nRoi));
nRows = ceil(nRoi/nCols);
figure(247); clf;
set(247,'Position',[10,10,1400,1000]);
for iRoi = 1:nRoi
    subplot(nRows,nCols,iRoi); cla; hold on;
    bar(1,meanTopTop_r(iRoi),'r');
    bar(2,meanTopBot_r(iRoi),'y');%'faceColor',[184 24 80]/255);
    bar(3,meanBotBot_r(iRoi),'faceColor',[112 48 160]/255);
%     errorbar([meanTopTop_r(iRoi),meanTopBot_r(iRoi),meanBotBot_r(iRoi)], [steTopTop(iRoi),steTopBot(iRoi),steBotBot(iRoi)],'k.');
    if pTTmTB(iRoi)<0.05
        plot([1,2],[1,1]*(meanTopTop_r(iRoi)+0.01),'k-');
        plot(1.5,meanTopTop_r(iRoi)+0.02,'k*');
    end
    if pTBmBB(iRoi)<0.05
        plot([2,3],[1,1]*(meanTopBot_r(iRoi)+0.01),'k-');
        plot(2.5,meanTopBot_r(iRoi)+0.02,'k*');
    end
    set(gca,'xtick',1:3,'xticklabels',{'good','mixed','poor'});
    xlabel('Reader Pair Type');
    ylabel('mean ISC in ROI');
    title(roiNames{iRoi});
    ylim([0,0.13]);
    grid on;
end
% save figure
%saveas(247,sprintf('%s/IscResults/Group/SUMA_IMAGES/readScoreSplit_n40-iqMatched_top-bot_p0.002_a0.05_clusterRois_groupIscBars.png',constants.dataDir));

%% TODO: Match upper triangle of behavioral ISC with upper triangle of each ROI ISC
% This is the "RSA": the similarity between brain and behavior across ppl



%% TODO: Calculate statistics
% Shuffle brain-behavior mappings many times to get a null distribution
% Compare actual values to this null distribution



