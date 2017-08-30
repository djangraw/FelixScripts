% SweepRosenbergThresholds_script.m
%
% Created 12/20/16 by DJ.

%% Load FC and behavior
subjects = [9:11 13:19 22 24:25 28 30:33 36];
% subjects = [9:11 13:19 22 24:25 28 30:34 36];afniProcFolder = 'AfniProc_MultiEcho_2016-09-22';
afniProcFolder = 'AfniProc_MultiEcho_2016-09-22';
tsFilePrefix = 'shen268_withSegTc2';
runComboMethod = 'avgRead';
[FC,isMissingRoi_anysubj,FC_runs] = GetFc_AllSubjects(subjects,afniProcFolder,tsFilePrefix,runComboMethod);
[fracCorrect, medRT] = GetFracCorrect_AllSubjects(subjects);
% Load atlas
shenFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_2mm_268_parcellation.nii.gz';
[shenErr,shenAtlas,shenInfo,shenErrMsg] = BrikLoad(shenFilename);
[shenLabels,shenLabelNames,shenLabelColors] = GetAttnNetLabels(false);
%% Get rosenberg GradCPT networks
rose = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/Rosenberg2016_weights.mat');
rose.cp_all = UnvectorizeFc(cat(2,rose.cp{:}));
rose.cr_all = UnvectorizeFc(cat(2,rose.cr{:}));

%% Combine across subjects
cp_max_rose = max(rose.cp_all,[],3);
cr_min_rose = mean(rose.cr_all,3);
isMixedSign = ~(all(rose.cr_all<0,3) | all(rose.cr_all>0,3));
cr_min_rose(isMixedSign) = 0;

%% Sweep threshold
nSubj = numel(subjects);
thresholds = .001:.001:.1; % .0001:.0001:.01; % .00001:.00001:.001;
figure(61); clf;
[maskSizePos,maskSizeNeg,Rsq,p] = SweepRosenbergThresholds(repmat(cp_max_rose,[1 1 nSubj]),repmat(cr_min_rose,[1 1 nSubj]),FC,fracCorrect,thresholds);
MakeFigureTitle('GradCPT Networks Applied to Reading Data');
%% Visualize network at a given threshold
threshold_rose = 0.0001;%0.01;%0.0002;
isInNetwk = cp_max_rose<threshold_rose;
cr_plot_rose = cr_min_rose;
cr_plot_rose(~isInNetwk) = 0;
figure(62); clf;
VisualizeFcIn3d(cr_plot_rose,shenAtlas,attnNetLabels,colors,labelNames,shenInfo.Orientation);
MakeFigureTitle(sprintf('GradCPT Networks Applied to Reading Data, threshold=%.3g',threshold_rose));


%% Get Reading (distraction) networks
read = load('/data/jangrawdc/PRJ03_SustainedAttention/Results/ReadingCpCr_19subj_2016-12-19.mat');

%% Sweep threshold
nSubj = numel(subjects);
thresholds = .001:.001:.1;
figure(63); clf;
[maskSizePos,maskSizeNeg,Rsq,p] = SweepRosenbergThresholds(read.cp_all,read.cr_all,FC,fracCorrect,thresholds);
MakeFigureTitle('Reading Comprehension Networks');


%% Combine across subjects
cp_max_read = max(read.cp_all,[],3);
cr_min_read = mean(read.cr_all,3);
isMixedSign = ~(all(read.cr_all<0,3) | all(read.cr_all>0,3));
cr_min_read(isMixedSign) = 0;

%% Visualize network at a given threshold
threshold_read = 0.006;%0.01; % 0.005;
isInNetwk = cp_max_read<threshold_read;
cr_plot_read = cr_min_read;
cr_plot_read(~isInNetwk) = 0;
figure(64); clf;
VisualizeFcIn3d(cr_plot_read,shenAtlas,shenLabels,shenLabelColors,shenLabelNames,shenInfo.Orientation);
MakeFigureTitle(sprintf('Reading Comprehension Networks, threshold=%.3g',threshold_read));

%% Plot Networks as squares
figure(65); clf;
subplot(131);
PlotFcMatrix(sign(cr_plot_rose),[-1 1]*18,shenAtlas,shenLabels,true,shenLabelColors,'sum');
% PlotFcMatrix(sign(cr_plot_rose),[-1 1],shenAtlas,shenLabels,true,shenLabelColors,false);
title(sprintf('GradCPT Network, threshold = %.3g',threshold_rose));
subplot(132);
PlotFcMatrix(sign(cr_plot_read),[-1 1]*7,shenAtlas,shenLabels,true,shenLabelColors,'sum');
% PlotFcMatrix(sign(cr_plot_read),[-1 1],shenAtlas,shenLabels,true,shenLabelColors,false);
title(sprintf('Reading Network, threshold = %.3g',threshold_read));

subplot(133);
PlotFcMatrix((cr_plot_rose>0 & cr_plot_read>0) - (cr_plot_rose<0 & cr_plot_read<0),[-1 1],shenAtlas,shenLabels,true,shenLabelColors,'sum');
% PlotFcMatrix((cr_plot_rose>0 & cr_plot_read>0) - (cr_plot_rose<0 & cr_plot_read<0),[-1 1],shenAtlas,shenLabels,true,shenLabelColors,false);
title(sprintf('GradCPT and Reading Overlap, threshold = %.3g',threshold_read));




%%
uppertri = triu(ones(size(FC,1)),1)>0;
% Get numbers
isRosePos = cp_max_rose<threshold_rose & cr_min_rose>0 & uppertri;
isRoseNeg = cp_max_rose<threshold_rose & cr_min_rose<0 & uppertri;
isReadPos = cp_max_read<threshold_read & cr_min_read>0 & uppertri;
isReadNeg = cp_max_read<threshold_read & cr_min_read<0 & uppertri;

% Get overlap
figure(2);
PlotOverlapBetweenFcNetworks(isRosePos-isRoseNeg,isReadPos-isReadNeg,shenAtlas,shenLabels,shenLabelColors,shenLabelNames,{'GradCPT','Reading'})
