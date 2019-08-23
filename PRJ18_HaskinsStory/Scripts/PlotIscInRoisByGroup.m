 function PlotIscInRoisByGroup()

% Make a barplot with the aud, vis, and trans ISC in various ROIs.
%
% Created 8/22/19 by DJ.

% Set up
constants = GetStoryConstants();
resDir = sprintf('%s/IscResults/Group/',constants.dataDir);

$ Load ROIs
Vrois = BrikLoad(sprintf('%s/atlasRois/8Rois+tlrc',constants.dataDir));
roiNames = {'ACC','IFG-pOp','IFG-pOrb','IFG-pTri','ITG','SMG','STG (Aud)','CalcGyr (Vis)'};


% Load ISCs
Vaud = BrikLoad(sprintf('%s/3dLME_2Grps_readScoreMedSplit_n68_Automask_aud+tlrc',resDir));
Vvis = BrikLoad(sprintf('%s/3dLME_2Grps_readScoreMedSplit_n68_Automask_vis+tlrc',resDir));
Vtrans = BrikLoad(sprintf('%s/3dLME_2Grps_readScoreMedSplit_n68_Automask_trans+tlrc',resDir));
%Vdiff = BrikLoad(sprintf('%s/3dLME_2Grps_readScoreMedSplit_n68_Automask_aud-vis+tlrc',resDir));

% Get mean in ROIs
nRois = numel(roiNames);
nVoxels = nan(1,nRois);
meanInRoi = nan(3,2,nRois);
iGood = 3; % subbrick containing z scores for group 2 (good readers)
iPoor = 5; % subbrick containing z scores for group 1 (poor readers)
for iRoi=1:nRois
    Vaud_good = Vaud(:,:,:,iGood);
    Vaud_poor = Vaud(:,:,:,iPoor);
    meanInRoi(1,1,iRoi) = nanmean(Vaud_good(Vrois==iRoi));
    meanInRoi(1,2,iRoi) = nanmean(Vaud_poor(Vrois==iRoi));

    Vvis_good = Vvis(:,:,:,iGood);
    Vvis_poor = Vvis(:,:,:,iPoor);
    meanInRoi(2,1,iRoi) = nanmean(Vvis_good(Vrois==iRoi));
    meanInRoi(2,2,iRoi) = nanmean(Vvis_poor(Vrois==iRoi));

    Vtrans_good = Vtrans(:,:,:,iGood);
    Vtrans_poor = Vtrans(:,:,:,iPoor);
    meanInRoi(3,1,iRoi) = nanmean(Vtrans_good(Vrois==iRoi));
    meanInRoi(3,2,iRoi) = nanmean(Vtrans_poor(Vrois==iRoi));

    nVoxels(iRoi) = sum(Vrois(:)==iRoi);
end

% Plot results
figure(754); clf;
nCols = 4;
nRows = 2;
for iRoi=1:nRois
    subplot(nRows,nCols,iRoi);
    bar(meanInRoi(:,:,iRoi));
    xlabel('Reading Group')
    set(gca,'xticklabel',{'good readers','poor readers'})
    ylabel('Mean ISC in ROI')
    title(sprintf('%s (%d voxels)',roiNames,nVoxels(iRoi)));
end
