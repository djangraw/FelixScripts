% ComparePredictions_GradcptDandmnReading.m
%
% Created 1/3/17 by DJ.

% subjects = [9:11 13:19 22 24:25 28 30:33 36];
subjects = [9:11 13:19 22 24:25 28 30:34 36];

afniProcFolder = 'AfniProc_MultiEcho_2016-09-22'; % 9-22 = MNI
tsFilePrefix = 'shen268_withSegTc'; % 'withSegTc' means with BPFs
tsFilePrefix2 = 'shen268_withSegTc2'; % 'withSegTc2' means with BPFs
% tsFilePrefix = 'shen268_withSegTc_Rose'; % _Rose means with motion squares regressed out and gaussian filter
runComboMethod = 'avgRead'; % average of run-wise FC, limited to reading samples
doPlot = false;

%% Get FC
[FC,isMissingRoi,FC_runs] = GetFc_AllSubjects(subjects,afniProcFolder,tsFilePrefix,runComboMethod);
[FC2,~,~] = GetFc_AllSubjects(subjects,afniProcFolder,tsFilePrefix2,runComboMethod);

%% Get performance
[fracCorrect, RT] = GetFracCorrect_AllSubjects(subjects);

%% Get GradCPT Network
fprintf('Loading attention network matrices...\n')
[shenAtlas,shenInfo] = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_2mm_268_parcellation.nii.gz');
attnNets = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/attn_nets_268.mat');
[shenLabels,shenLabelNames,shenColors] = GetAttnNetLabels(false);
% Get cpcr
gradcpt_struct = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/Rosenberg2016_weights.mat');
gradcpt_cp = UnvectorizeFc(cat(2,gradcpt_struct.cp{:}));
gradcpt_cr = UnvectorizeFc(cat(2,gradcpt_struct.cr{:}));

%% Get DanDmn Network
posFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth/NeuroSynth_dorsalattention_pAgF_z_FDR_0.01_EpiRes_MNI+tlrc';
negFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth/NeuroSynth_defaultmode_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc';
posFilename2 = '/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth/NeuroSynth_v4-topics-100_9_attention_attentional_visual_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc';
negFilename2 = '/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth/NeuroSynth_v4-topics-100_59_network_default_dmn_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc';
atlasFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/MNI_EPIres_shen_1mm_268_parcellation+tlrc';
posMaskThreshold = 0;
negMaskThreshold = 0;
posMatchThreshold = 0.15;
negMatchThreshold = 0.15;
DanDmnNetwork = GetNeurosynthNetworks(posFilename,negFilename,atlasFilename,posMaskThreshold,negMaskThreshold,posMatchThreshold,negMatchThreshold);
DanDmnNetwork2 = GetNeurosynthNetworks(posFilename2,negFilename2,atlasFilename,posMaskThreshold,negMaskThreshold,posMatchThreshold,negMatchThreshold);

%% Get Reading Network and predictions
thresh = 0.01;
corr_method = 'robustfit';
mask_method = 'one';
[read_pos, read_neg, read_glm,read_posMask_all,read_negMask_all] = RunLeave1outBehaviorRegression(FC,fracCorrect,thresh,corr_method,mask_method);
[read_pos2, read_neg2, read_glm2,read_posMask_all2,read_negMask_all2] = RunLeave1outBehaviorRegression(FC2,fracCorrect,thresh,corr_method,mask_method);

%% Get cpcr
corr_method = 'robustfit';
mask_method = 'cpcr';
thresh = 0;
[~,~,~,read_cp,read_cr] = RunLeave1outBehaviorRegression(FC,fracCorrect,thresh,corr_method,mask_method);
[~,~,~,read_cp2,read_cr2] = RunLeave1outBehaviorRegression(FC2,fracCorrect,thresh,corr_method,mask_method);

%% Get Predictions from Other networks

[gradcpt_pos,gradcpt_neg,gradcpt_combo] = GetFcMaskMatch(FC,attnNets.pos_overlap,attnNets.neg_overlap);
[gradcpt_pos2,gradcpt_neg2,gradcpt_combo2] = GetFcMaskMatch(FC2,attnNets.pos_overlap,attnNets.neg_overlap);

[dandmn_pos,dandmn_neg,dandmn_combo] = GetFcMaskMatch(FC,DanDmnNetwork>0,DanDmnNetwork<0);
[dandmn_pos2,dandmn_neg2,dandmn_combo2] = GetFcMaskMatch(FC2,DanDmnNetwork>0,DanDmnNetwork<0);

[dandmn2_pos,dandmn2_neg,dandmn2_combo] = GetFcMaskMatch(FC,DanDmnNetwork2>0,DanDmnNetwork2<0);
[dandmn2_pos2,dandmn2_neg2,dandmn2_combo2] = GetFcMaskMatch(FC2,DanDmnNetwork2>0,DanDmnNetwork2<0);


%% Compare predictions across tasks and FCs
% Set up
figure(277); clf;
set(gcf,'Position',[159         122        1660        1165]);
networks = {'gradcpt','dandmn','dandmn2','read'};
networkNames = {'gradCPT','DAN/DMN','Topic9/59','Reading'};
types = {'pos','neg','combo'};
isPosExpected = [true false true];
for i=1:numel(networks)
    for j=1:numel(types)
        % Regress
        eval(sprintf('x = %s_%s;',networks{i},types{j}));
        [p,Rsq,lm] = Run1tailedRegression(fracCorrect*100,x,isPosExpected(j));
        eval(sprintf('x = %s_%s2;',networks{i},types{j}));
        [p2,Rsq2,lm2] = Run1tailedRegression(fracCorrect*100,x,isPosExpected(j));
        % Plot and annotate
        iPlot = (i-1)*numel(types)+j;
        subplot(3,3,iPlot); cla; hold on;
        h = lm.plot;
        set(h,'color','r');
        h = lm2.plot;
        set(h,'color','b');
        xlabel('% correct');
        ylabel(sprintf('%s %s score',networkNames{i},types{j}));
        title(sprintf('%s %s: R^2= %.3g, p=%.3g\nR^2_{GSR}= %.3g, p_{GSR}=%.3g',networkNames{i},types{j},Rsq,p,Rsq2,p2));
    end
end

%% Compare reading networks with/without GSR

read_comboMask = all(read_posMask_all>0,3)-all(read_negMask_all>0,3);
read_comboMask2 = all(read_posMask_all2>0,3)-all(read_negMask_all2>0,3);
clim = 100;

figure(278); clf;
subplot(231);
PlotFcMatrix(read_comboMask,[-1 1]*clim,shenAtlas,shenLabels,true,shenColors,'sum');
title('Reading Networks without GSR')
subplot(234);
PlotFcMatrix(read_comboMask2,[-1 1]*clim,shenAtlas,shenLabels,true,shenColors,'sum');
title('Reading Networks with GSR')
subplot(232);
PlotFcMatrix(DanDmnNetwork,[-1 1]*50,shenAtlas,shenLabels,true,shenColors,'sum');
title('DAN/DMN Networks')
subplot(235);
PlotFcMatrix(DanDmnNetwork2,[-1 1]*100,shenAtlas,shenLabels,true,shenColors,'sum');
title('Topic9/59 Networks')
subplot(233);
PlotFcMatrix(attnNets.pos_overlap-attnNets.neg_overlap,[-1 1]*clim,shenAtlas,shenLabels,true,shenColors,'sum');
title('GradCpt Networks without GSR')

%% Compare in 3D
% Combine across subjects
% cp_max_read = max(read_cp,[],3);
cr_min_read = min(abs(read_cr),[],3).*sign(read_cr(:,:,1));
isMixedSign = ~(all(read_cr<0,3) | all(read_cr>0,3));
cr_min_read(isMixedSign) = 0;

% Visualize network at a given threshold
% threshold_read = 0.01; % 0.005;
% isInNetwk = cp_max_read<threshold_read;
threshold_read = GetValueAtPercentile(abs(VectorizeFc(cr_min_read)),99.75);
isInNetwk = abs(cr_min_read)>threshold_read;
cr_plot_read = cr_min_read;
cr_plot_read(~isInNetwk) = 0;
figure(279); clf;
VisualizeFcIn3d(cr_plot_read,shenAtlas,shenLabels,shenColors,shenLabelNames,shenInfo.Orientation);
MakeFigureTitle(sprintf('Reading Comprehension Networks (no GSR), threshold=%.3g',threshold_read));

%% Combine across subjects
% cp_max_read = max(read_cp2,[],3);
cr_min_read = min(abs(read_cr2),[],3).*sign(read_cr2(:,:,1));
isMixedSign = ~(all(read_cr2<0,3) | all(read_cr2>0,3));
cr_min_read(isMixedSign) = 0;

% Visualize network at a given threshold
% threshold_read = 0.01; % 0.005;
% isInNetwk = cp_max_read<threshold_read;
threshold_read = GetValueAtPercentile(abs(VectorizeFc(cr_min_read)),99.75);
isInNetwk = abs(cr_min_read)>threshold_read;
cr_plot_read = cr_min_read;
cr_plot_read(~isInNetwk) = 0;
figure(280); clf;
VisualizeFcIn3d(cr_plot_read,shenAtlas,shenLabels,shenColors,shenLabelNames,shenInfo.Orientation);
MakeFigureTitle(sprintf('Reading Comprehension Networks (with GSR), threshold=%.3g',threshold_read));

%% GradCPT: Combine across subjects
cr_min_gradcpt = min(abs(gradcpt_cr),[],3).*sign(gradcpt_cr(:,:,1));
isMixedSign = ~(all(gradcpt_cr<0,3) | all(gradcpt_cr>0,3));
cr_min_gradcpt(isMixedSign) = 0;

% Visualize network at a given threshold
threshold_gradcpt = GetValueAtPercentile(abs(VectorizeFc(cr_min_gradcpt)),99.75);
isInNetwk = abs(cr_min_gradcpt)>threshold_gradcpt;
cr_plot_gradcpt = cr_min_gradcpt;
cr_plot_gradcpt(~isInNetwk) = 0;
figure(281); clf;
VisualizeFcIn3d(cr_plot_gradcpt,shenAtlas,shenLabels,shenColors,shenLabelNames,shenInfo.Orientation);
MakeFigureTitle(sprintf('Reading Comprehension Networks (with GSR), threshold=%.3g',threshold_gradcpt));


%% Get spatial overlap of combined networks
gradcpt_thresh = 0.01;
read_thresh = .01;
gradcptNetwork = all(gradcpt_cp<gradcpt_thresh & gradcpt_cr>0,3) - all(gradcpt_cp<gradcpt_thresh & gradcpt_cr<0,3);
readingNetwork = all(read_cp<read_thresh & read_cr>0,3) - all(read_cp<read_thresh & read_cr<0,3);
% DanDmnNetwork = DanDmnNetwork;

PlotOverlapBetweenFcNetworks(readingNetwork,gradcptNetwork,shenAtlas,...
    shenLabels_hem,shenLabelColors_hem,shenLabelNames_hem,{'Reading','GradCPT'});
% PlotOverlapBetweenFcNetworks(gradcptNetwork,readingNetwork,shenAtlas,...
%     shenLabels_hem,shenLabelColors_hem,shenLabelNames_hem,{'GradCPT','Reading'});

% figure(12);

%% Sweep threshold and get overlap
thresh = 0.01:0.01:1;
gradcpt_maxcp_vec = VectorizeFc(max(gradcpt_cp,[],3));
gradcpt_sign_vec = VectorizeFc(all(gradcpt_cr>0,3)-all(gradcpt_cr<0,3));
read_maxcp_vec = VectorizeFc(max(read_cp,[],3));
read_sign_vec = VectorizeFc(all(read_cr>0,3)-all(read_cr<0,3));
nEdges = numel(read_sign_vec);
nInGradcpt = nan(numel(thresh),2);
nInRead = nan(numel(thresh),2);
olap = nan(2,2,numel(thresh));
chanceOlap = nan(2,2,numel(thresh));
for iThresh = 1:numel(thresh)
    nInGradcpt(iThresh,:) = [sum(gradcpt_maxcp_vec<thresh(iThresh) & gradcpt_sign_vec<0), sum(gradcpt_maxcp_vec<thresh(iThresh) & gradcpt_sign_vec>0)];
    nInRead(iThresh,:) = [sum(read_maxcp_vec<thresh(iThresh) & read_sign_vec<0), sum(read_maxcp_vec<thresh(iThresh) & read_sign_vec>0)];
    olap(1,1,iThresh) = sum(gradcpt_maxcp_vec<thresh(iThresh) & gradcpt_sign_vec<0 & read_maxcp_vec<thresh(iThresh) & read_sign_vec<0);
    olap(1,2,iThresh) = sum(gradcpt_maxcp_vec<thresh(iThresh) & gradcpt_sign_vec<0 & read_maxcp_vec<thresh(iThresh) & read_sign_vec>0);
    olap(2,1,iThresh) = sum(gradcpt_maxcp_vec<thresh(iThresh) & gradcpt_sign_vec>0 & read_maxcp_vec<thresh(iThresh) & read_sign_vec<0);
    olap(2,2,iThresh) = sum(gradcpt_maxcp_vec<thresh(iThresh) & gradcpt_sign_vec>0 & read_maxcp_vec<thresh(iThresh) & read_sign_vec>0);
    chanceOlap(1,1,iThresh) = nInGradcpt(iThresh,1)*nInRead(iThresh,1)/nEdges;
    chanceOlap(1,2,iThresh) = nInGradcpt(iThresh,1)*nInRead(iThresh,2)/nEdges;
    chanceOlap(2,1,iThresh) = nInGradcpt(iThresh,2)*nInRead(iThresh,1)/nEdges;
    chanceOlap(2,2,iThresh) = nInGradcpt(iThresh,2)*nInRead(iThresh,2)/nEdges;
end

figure(892); clf;
subplot(2,2,1);
% plot(thresh,[squeeze(olap(1,:,:))', squeeze(chanceOlap(1,:,:))']);
plot(thresh(2:end),diff([squeeze(olap(1,:,:))', squeeze(chanceOlap(1,:,:))'],[],1));
xlabel('p value threshold');
% ylabel('# edges');
ylabel('# new edges');
title('GradCPT-neg')
legend('GradCPT-neg AND Reading-neg','GradCPT-neg AND Reading-pos','g-r-(chance)','g-r+(chance)');

subplot(2,2,2);
% plot(thresh,[squeeze(olap(2,:,:))', squeeze(chanceOlap(2,:,:))']);
plot(thresh(2:end),diff([squeeze(olap(2,:,:))', squeeze(chanceOlap(2,:,:))'],[],1));
xlabel('p value threshold');
% ylabel('# edges');
ylabel('# new edges');
title('GradCPT-pos')
legend('GradCPT-pos AND Reading-neg','GradCPT-pos AND Reading-pos','g+r-(chance)','g+r+(chance)');

subplot(2,2,3);
% plot(thresh,[squeeze(olap(:,1,:))', squeeze(chanceOlap(:,1,:))']);
plot(thresh(2:end),diff([squeeze(olap(:,1,:))', squeeze(chanceOlap(:,1,:))'],[],1));
xlabel('p value threshold');
% ylabel('# edges');
ylabel('# new edges');
title('Reading-neg')
legend('Reading-neg AND GradCPT-neg','Reading-neg AND GradCPT-pos','r-g-(chance)','r-g+(chance)');
subplot(2,2,4);
% plot(thresh,[squeeze(olap(:,2,:))', squeeze(chanceOlap(:,2,:))']);
plot(thresh(2:end),diff([squeeze(olap(:,2,:))', squeeze(chanceOlap(:,2,:))'],[],1));
xlabel('p value threshold');
% ylabel('# edges');
ylabel('# new edges');
title('Reading-pos')
legend('Reading-pos AND GradCPT-neg','Reading-pos AND GradCPT-pos','r+g-(chance)','r+g+(chance)');

linkaxes(GetSubplots(gcf),'xy');
% ylim([0 100]);

%% OR do a simple correlation... maybe better if everything matters
mincr_gradcpt_vec = VectorizeFc(min(abs(gradcpt_cr),[],3)).*gradcpt_sign_vec;
mincr_read_vec = VectorizeFc(min(abs(read_cr),[],3)).*read_sign_vec;
[r,p] = corr(mincr_gradcpt_vec,mincr_read_vec);
fprintf('r=%.3g, p=%.3g\n',r,p/2);