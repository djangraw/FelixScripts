% VisualizeFcInTopAndBottomPerformers_script.m
%
% Created 2/22/17 by DJ.

% Load FC/fracCorrect
load('ReadingFcAndFracCorrect_19subj_2017-02-09');
FC_fisher = atanh(FC);
FC_fisher = UnvectorizeFc(VectorizeFc(FC_fisher),0,true);
% Loat Altas
[shenAtlas,shenInfo] = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/EPIres_shen_1mm_268_parcellation+tlrc.BRIK');
[shenLabels,shenLabelNames,shenColors] = GetAttnNetLabels(false);
[shenLabels_hem,shenLabelNames_hem,shenColors_hem] = GetAttnNetLabels('region-hem');
%% Get & Plot
[FCtop,FCbottom] = GetFcInGoodAndBadPerformers(FC_fisher,fracCorrect);
PlotFcInGoodAndBadPerformers(FCtop,FCbottom,shenAtlas,shenLabels_hem,shenColors_hem);
cmap = othercolor('BuOr_8',128);
colormap(gcf,cmap);

%% Visualize top/bottom performers in 3D within reading network
% Set up
network = 'Reading';
plotview = 'left'; % 'back'
maxWidth = 10;

switch network
    case 'Reading'
        % load reading network
        load('ReadingNetwork_p01_Fisher.mat');
        isPos = readingNetwork_p01>0;
        isNeg = readingNetwork_p01<0;
        netType = 'Performance';
    case 'GradCpt'
        % load GradCPT network
        load('GradCptNetwork_p01.mat');
        isPos = gradCptNetwork_p01>0;
        isNeg = gradCptNetwork_p01<0;
        netType = 'Attention';
    otherwise
        isPos = [];
        isNeg = [];
end        
% Plot
figure(126); clf;
subplot(2,2,1);
VisualizeFcIn2d(FCtop.*isPos*maxWidth,shenAtlas,shenLabels,shenColors,shenLabelNames,shenInfo.Orientation,plotview);
title(sprintf('Top performers, %s High-%s Network',network,netType));
subplot(2,2,2);
VisualizeFcIn2d(FCtop.*isNeg*maxWidth,shenAtlas,shenLabels,shenColors,shenLabelNames,shenInfo.Orientation,plotview);
title(sprintf('Top performers, %s Low-%s Network',network,netType));
subplot(2,2,3);
VisualizeFcIn2d(FCbottom.*isPos*maxWidth,shenAtlas,shenLabels,shenColors,shenLabelNames,shenInfo.Orientation,plotview);
title(sprintf('Bottom performers, %s High-%s Network',network,netType));
subplot(2,2,4);
VisualizeFcIn2d(FCbottom.*isNeg*maxWidth,shenAtlas,shenLabels,shenColors,shenLabelNames,shenInfo.Orientation,plotview);
title(sprintf('Bottom performers, %s Low-%s Network',network,netType));

%% Make histograms of edge strengths in high and low performers
maxFC = max(abs([FCtop(isPos | isNeg); FCbottom(isPos | isNeg)]));
xHist = linspace(-maxFC,maxFC,40)';
figure(127); clf;
subplot(1,3,1); hold on;
n1 = hist(FCtop(isPos),xHist);
n2 = hist(FCbottom(isPos),xHist);
plot(xHist, cumsum([n1',n2'])/sum(isPos(:))*100,'.-');
PlotVerticalLines(0,'k-');
xlabel('Fisher-normalized FC')
ylabel('% edges below this FC')
legend('top performers','bottom performers');
grid on
title(sprintf('%s High-%s Network',network,netType))

subplot(1,3,2); hold on;
n1 = hist(FCtop(isNeg),xHist);
n2 = hist(FCbottom(isNeg),xHist);
plot(xHist, cumsum([n1',n2'])/sum(isNeg(:))*100,'.-');
PlotVerticalLines(0,'k-');
xlabel('Fisher-normalized FC')
ylabel('% edges below this FC')
legend('top performers','bottom performers');
grid on
title(sprintf('%s Low-%s Network',network,netType))

subplot(1,3,3); hold on;
plot(FCbottom(isPos),FCtop(isPos),'r.');
plot(FCbottom(isNeg),FCtop(isNeg),'b.');
PlotVerticalLines(0,'k-');
PlotHorizontalLines(0,'k-');
curr_xlim = get(gca,'xlim');
curr_ylim = get(gca,'ylim');
plot([-1 1]*3,[-1 1]*3,'k:');
xlim(curr_xlim);
ylim(curr_ylim);
xlabel('Bottom performers');
ylabel('Top performers');
legend('High-Performance Network','Low-Performance Network');
title(sprintf('%s Networks',network))
