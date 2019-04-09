% PlotMeanIscToTopScorers.m
%
% Created 5/8/19 by DJ.

%% Load ISC
info = GetStoryConstants();
readScores = GetStoryReadingScores(info.okReadSubj);
meanIscToTop = GetMeanIscToTopScorers(info.okReadSubj,readScores);
nSubj = size(meanIscToTop,4);

%% Load ROI
roiFile = sprintf('%s/IscResults/Group/3dLME_2Grps_readScoreMedSplit_n69_Automask_aud-vis_top-bot_clust_p0.01_a0.05_bisided_map.nii.gz',info.dataDir);
ROIs = BrikLoad(roiFile);

%% Get mean timecourse in ROI
nRois = max(ROIs(:));
nRows = ceil(sqrt(nRois));
nCols = ceil(nRois/nRows);
for iRoi = 1:nRois
    % Get mean in mask
    meanIscToTop_2d = reshape(meanIscToTop,[numel(meanIscToTop)/nSubj,nSubj]);
    ROIs_2d = ROIs(:);
    meanIscInRoi = mean(meanIscToTop_2d(ROIs_2d==iRoi,:),1);

    % Plot
    subplot(nRows,nCols,iRoi);
    plot(meanIscInRoi,readScores,'o');
    xlabel(sprintf('mean ISC in ROI %d',iRoi));
    ylabel('reading score');
end