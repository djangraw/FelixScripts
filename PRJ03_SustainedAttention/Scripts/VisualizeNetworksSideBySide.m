% VisualizeNetworksSideBySide.m
%
% Created 11/9/16 by DJ.
% Updated ~12/12/16 by DJ - changed from CompareNeuroSynthAndRosenberg to
%   VisualizeNetworksSideBySide.m.

%% Load networks
% Load atlas
shenAtlas = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_2mm_268_parcellation.nii.gz');
[attnNetLabels,labelNames,colors] = GetAttnNetLabels(false);
% Load networks
danDmn = load('/data/jangrawdc/PRJ03_SustainedAttention/Results/NeurosynthDanDmnNetwork.mat');
readCpCr = load('/data/jangrawdc/PRJ03_SustainedAttention/Results/ReadingCpCr_25subj.mat');
% From CompareRosenbergAndReadingCpCr.m
roseCpCr_cell = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/Rosenberg2016_weights.mat');

% convert Rosenberg version to match reading version
n_node = size(readCpCr.cp_all,1);
uppertri = triu(ones(n_node),1)==1;
n_sub_rose = numel(roseCpCr_cell.cp);
roseCpCr.cp_all = nan(n_node,n_node,n_sub_rose);
roseCpCr.cr_all = nan(n_node,n_node,n_sub_rose);
for j=1:n_sub_rose
    tmp = zeros(n_node);
    tmp(uppertri) = roseCpCr_cell.cp{j};
    roseCpCr.cp_all(:,:,j) = tmp;
    tmp(uppertri) = roseCpCr_cell.cr{j};
    roseCpCr.cr_all(:,:,j) = tmp;
end

%% Get Averages

meancr_read = mean(readCpCr.cr_all,3);
meancr_read(abs(meancr_read)<0.3) = 0;
meancr_rose = mean(roseCpCr.cr_all,3);
meancr_rose(abs(meancr_rose)<0.3) = 0;
danDmnNetwork = danDmn.DanDmnNetwork;
danDmnNetwork(~uppertri) = 0;

%% Visualize
figure(245);
VisualizeFcIn3d(meancr_rose,atlas,attnNetLabels,colors,labelNames);
figure(246);
VisualizeFcIn3d(meancr_read,atlas,attnNetLabels,colors,labelNames);
figure(247);
VisualizeFcIn3d(danDmnNetwork,atlas,attnNetLabels,colors,labelNames);
set(245,'Position',[50 50 1000 1000])
set(246,'Position',[250 50 1000 1000])
set(247,'Position',[450 50 1000 1000])

%% Visualize in matrices

roseNetwork = all(roseCpCr.cp_all<0.01 & roseCpCr.cr_all>0,3) - all(roseCpCr.cp_all<0.01 & roseCpCr.cr_all<0,3);
readNetwork = all(readCpCr.cp_all<0.05 & readCpCr.cr_all>0,3) - all(readCpCr.cp_all<0.05 & readCpCr.cr_all<0,3);

groupMode = false;% 'sum';
if isequal(groupMode,'sum')
    clims = [100 30 48];
else
    clims = [1 1 1];
end

figure(248); clf;
subplot(1,3,1);
PlotFcMatrix(roseNetwork,[-1 1]*clims(1),shenAtlas,attnNetLabels,true,colors,groupMode);
title('Grad-CPT Network')
subplot(1,3,2);
PlotFcMatrix(danDmnNetwork,[-1 1]*clims(2),shenAtlas,attnNetLabels,true,colors,groupMode);
title('DAN/DMN Network')
subplot(1,3,3);
PlotFcMatrix(readNetwork,[-1 1]*clims(3),shenAtlas,attnNetLabels,true,colors,groupMode);
title('Reading Network')
set(gcf,'Position',[659 304 1643 512]);
%% Plot CRs
figure(249); clf;
subplot(1,3,1);
PlotFcMatrix(meancr_rose,[-1 1]*clims(1),shenAtlas,attnNetLabels,true,colors,groupMode);
title('Grad-CPT Network')
subplot(1,3,2);
PlotFcMatrix(danDmnNetwork,[-1 1]*clims(2),shenAtlas,attnNetLabels,true,colors,groupMode);
title('DAN/DMN Network')
subplot(1,3,3);
PlotFcMatrix(meancr_read,[-1 1]*clims(3),shenAtlas,attnNetLabels,true,colors,groupMode);
title('Reading Network')

linkaxes(GetSubplots(gcf),'xy');
set(gcf,'Position',[659 304 1643 512]);




