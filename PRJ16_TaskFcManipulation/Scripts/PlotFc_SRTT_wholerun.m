% PlotFc_SRTT_wholerun.m
%
% Created 2/5/18 by DJ.

% Load
load('FC_wholerun_2018-02-05.mat');

%% Plot ROIxROI
meanFisherFc = mean(atanh(FC_wholerun),3);
clim = [-.5 1];
[shenAtlas,shenInfo] = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_1mm_268_parcellation+tlrc.BRIK');
[shenLabels_hem,shenLabelNames_hem,shenColors_hem] = GetAttnNetLabels(true);
figure(1); clf;
PlotFcMatrix(meanFisherFc,clim,shenAtlas,shenLabels_hem,true,shenColors_hem,false);
title(sprintf('Mean Fisher-normed FC across %d SRTT subjects',numel(subjects)));
colormap jet
%% Plot ClusterxCluster
% newShenLabels = [1 11 2 12 3 13 4 14 5 15 6 16 7 17 8 18 9 19 10 20];
newShenLabels = [1:2:20 2:2:20];
newShenLabels_inv = nan(1,20);
for i=1:20
    newShenLabels_inv(i) = find(newShenLabels==i);
end
shenLabels_RL = newShenLabels(shenLabels_hem);
shenColors_RL = shenColors_hem(newShenLabels_inv,:);
clim_RL = [-.1 .65];
figure(2); clf;
[~,~,~,FC_grouped] = PlotFcMatrix(meanFisherFc,clim_RL,shenAtlas,shenLabels_RL,true,shenColors_RL,true);
title(sprintf('Mean Fisher-normed FC across %d SRTT subjects',numel(subjects)));
colormap jet