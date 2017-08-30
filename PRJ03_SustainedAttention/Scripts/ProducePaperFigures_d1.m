% ProducePaperFigures_d1.m
%
% Created 1/9/17 by DJ.

subjects = [9:11 13:19 22 24:25 28 30:33 36];

afniProcFolder = 'AfniProc_MultiEcho_2016-09-22'; % 9-22 = MNI
tsFilePrefix = 'shen268_withSegTc'; % 'withSegTc' means with BPFs
runComboMethod = 'avgRead'; % average of run-wise FC, limited to reading samples
doPlot = false;

%% Get FC
[FC,isMissingRoi,FC_runs] = GetFc_AllSubjects(subjects,afniProcFolder,tsFilePrefix,runComboMethod);

%% Get performance
[fracCorrect, RT] = GetFracCorrect_AllSubjects(subjects);

%% Get GradCPT Network
fprintf('Loading attention network matrices...\n')
[shenAtlas,shenInfo] = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/EPIres_shen_1mm_268_parcellation+tlrc.BRIK');
attnNets = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/attn_nets_268.mat');
[shenLabels,shenLabelNames,shenColors] = GetAttnNetLabels(false);
[shenLabels_hem,shenLabelNames_hem,shenColors_hem] = GetAttnNetLabels('region-hem');

% Get cpcr
gradcpt_struct = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/Rosenberg2016_weights.mat');
gradcpt_cp = UnvectorizeFc(cat(2,gradcpt_struct.cp{:}));
gradcpt_cr = UnvectorizeFc(cat(2,gradcpt_struct.cr{:}));

%% Get DanDmn Network
% posFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth/NeuroSynth_dorsalattention_pAgF_z_FDR_0.01_EpiRes_MNI+tlrc';
% negFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth/NeuroSynth_defaultmode_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc';
% posFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth/NeuroSynth_v4-topics-100_87_sentences_language_comprehension_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc';
posFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth/NeuroSynth_v4-topics-100_9_attention_attentional_visual_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc';
negFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth/NeuroSynth_v4-topics-100_59_network_default_dmn_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc';
atlasFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/MNI_EPIres_shen_1mm_268_parcellation+tlrc';
posMaskThreshold = 0;
negMaskThreshold = 0;
posMatchThreshold = 0.15;
negMatchThreshold = 0.15;
DanDmnNetwork = GetNeurosynthNetworks(posFilename,negFilename,atlasFilename,posMaskThreshold,negMaskThreshold,posMatchThreshold,negMatchThreshold);

%% Get Reading Network and predictions
thresh = 0.01;
corr_method = 'robustfit';
mask_method = 'one';
[read_pos, read_neg, read_combo,read_posMask_all,read_negMask_all] = RunLeave1outBehaviorRegression(FC,fracCorrect,thresh,corr_method,mask_method);

%% Get cpcr
corr_method = 'robustfit';
mask_method = 'cpcr';
thresh = 0;
[~,~,~,read_cp,read_cr] = RunLeave1outBehaviorRegression(FC,fracCorrect,thresh,corr_method,mask_method);

%% Get Predictions from Other networks

[gradcpt_pos,gradcpt_neg,gradcpt_combo] = GetFcMaskMatch(FC,attnNets.pos_overlap,attnNets.neg_overlap);
[gradcpt_pos,gradcpt_neg,gradcpt_combo] = deal(gradcpt_pos',gradcpt_neg',gradcpt_combo');
[dandmn_pos,dandmn_neg,dandmn_combo] = GetFcMaskMatch(FC,DanDmnNetwork>0,DanDmnNetwork<0);
[dandmn_pos,dandmn_neg,dandmn_combo] = deal(dandmn_pos',dandmn_neg',dandmn_combo');

%% FIGURE 2: 
% Compare predictions across tasks

% Set up
figure(277); clf;
set(gcf,'Position',[159         122        1660        1165]);
% set(gcf,'Position',[159         122        1660        435]);
networks = {'gradcpt','dandmn','read'};
networkNames = {'gradCPT','DAN/DMN','Reading'};
types = {'pos','neg','combo'};
typeNames = {'High-Attention','Low-Attention','Combined'};
% types = {'combo'};
% typeNames = {'combined network'};
isPosExpected = [true false true];
for i=1:numel(types)
    for j=1:numel(networks)
        % Regress
        eval(sprintf('x = %s_%s;',networks{j},types{i}));
        [p,Rsq,lm] = Run1tailedRegression(fracCorrect*100,x,isPosExpected(i));
        r = corr(fracCorrect*100,x);
        % Plot and annotate
        iPlot = (i-1)*numel(networks)+j;
        subplot(numel(types),numel(networks),iPlot); cla; hold on;
        h = lm.plot;
        xlabel('% correct');
        ylabel(sprintf('%s %s Network score',networkNames{j},typeNames{i}));
        title(sprintf('%s %s Network Prediction\nr=%.3g, p=%.3g',networkNames{j},typeNames{i},r,p));
        legend('Subject','Linear Fit');%,'Location','Northwest')
    end
end


%% TEXT: Compare network sizes
read_comboMask = all(read_posMask_all>0,3) - all(read_negMask_all>0,3);
gradcpt_comboMask = attnNets.pos_overlap - attnNets.neg_overlap;

fprintf('GradCPT: %d high-attention, %d low-attention\n',sum(VectorizeFc(gradcpt_comboMask>0)), sum(VectorizeFc(gradcpt_comboMask<0)))
fprintf('DAN/DMN: %d high-attention, %d low-attention\n',sum(VectorizeFc(DanDmnNetwork>0)), sum(VectorizeFc(DanDmnNetwork<0)))
fprintf('Reading: %d high-attention, %d low-attention\n',sum(VectorizeFc(read_comboMask>0)), sum(VectorizeFc(read_comboMask<0)))

% Find # of permutation tests with more than this many edges
mask_size_pos = sum(VectorizeFc(read_comboMask>0));
mask_size_neg = sum(VectorizeFc(read_comboMask<0));
permtests = load('/data/jangrawdc/PRJ03_SustainedAttention/Results/PermTests_Take2_2016-12-28');
p1 = mean(permtests.mask_size_pos>=mask_size_pos);
p2 = mean(permtests.mask_size_neg>=mask_size_neg);
fprintf('odds of this many edges by chance: pos = %.3g, neg = %.3g\n',p1,p2);

%% Use mean activation in each ROI to predict behavior
% Get meanInRoi for each subject
nSubj=numel(subjects);
nROIs = numel(shenLabels_hem);
meanInRoi_subj = nan(nROIs, nSubj);
goodLabels = {'ReadingVsFixation_GLT#0_Coef'}; % Just one
[~,brickInfo] = BrikInfo(sprintf('/data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ%02d/AfniProc_MultiEcho_2016-09-22/coef_stimOnly.SBJ%02d.blur_fwhm4p0.scale+tlrc',subjects(1),subjects(1)));
brickLabels = strsplit(brickInfo.BRICK_LABS,'~');
iBrick = find(ismember(brickLabels,goodLabels));
for i=1:nSubj
    fprintf('Loading subj %d/%d...\n',i,nSubj);
    cd(sprintf('/data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ%02d/AfniProc_MultiEcho_2016-09-22',subjects(i)));
    foo = BrikLoad(sprintf('coef_stimOnly.SBJ%02d.blur_fwhm4p0.scale+tlrc',subjects(i)));
    foo = foo(:,:,:,iBrick);
    for j=1:nROIs
        meanInRoi_subj(j,i) = mean(foo(shenAtlas==j));
    end
end
fprintf('Done!\n');
% Use to predict behavior
thresh = 1;
[activityScore,networks_activ,cp_activ,cr_activ] = RunLeaveOneOutRegressionWithActivity(meanInRoi_subj,fracCorrect,thresh);
% Plot results
isPosExpected = true;
[p,Rsq,lm] = Run1tailedRegression(fracCorrect*100,activityScore,isPosExpected);
% r = sqrt(lm.Rsquared.Ordinary);
r = corr(fracCorrect*100,activityScore);
fprintf('%s activity, thresh %d: r = %.3g, p = %.3g\n',goodLabels{1},thresh,r,p);

%% Figure 3: Plot Networks as Matrices

read_comboMask = all(read_posMask_all>0,3)-all(read_negMask_all>0,3);
% clim = [18 18 18];
clim = [75 30 18];

figure(278); clf;
set(gcf,'Position',[62 722 1731 613]);
subplot(131);
[~,~,~,~,hRect] = PlotFcMatrix(attnNets.pos_overlap-attnNets.neg_overlap,[-1 1]*clim(1),shenAtlas,shenLabels_hem,true,shenColors_hem,'sum');
title('GradCpt Networks')
delete(hRect);
subplot(132);
[~,~,~,~,hRect] = PlotFcMatrix(DanDmnNetwork,[-1 1]*clim(2),shenAtlas,shenLabels_hem,true,shenColors_hem,'sum');
title('DAN/DMN Networks')
delete(hRect);
subplot(133);
[~,~,~,~,hRect] = PlotFcMatrix(read_comboMask,[-1 1]*clim(3),shenAtlas,shenLabels_hem,true,shenColors_hem,'sum');
title('Reading Networks')
delete(hRect);

cmap = othercolor('BuOr_8',128);
% cmap(:,2) = cmap(:,2)*1.5-.5;
colormap(cmap);

for i=1:3
    subplot(1,3,i);
%     set(gca,'ytick',1:numel(shenLabelNames_hem),'yticklabel',show_symbols(shenLabelNames_hem));
%     set(gca,'xtick',1:numel(shenLabelNames_hem),'xticklabel',show_symbols(shenLabelNames_hem));
    set(gca,'ytick',1.5:2:20,'yticklabel',show_symbols(shenLabelNames));
    set(gca,'xtick',1.5:2:20,'xticklabel',show_symbols(shenLabelNames));
    xticklabel_rotate;
end

%% Figure 3 (alt): Plot on circle
invorder = [20:-2:2, 19:-2:1];
order = nan(size(invorder));
for i=1:numel(invorder), order(i) = find(invorder==i); end

shenLabels_hem_circle = order(shenLabels_hem);
shenLabelNames_hem_circle = shenLabelNames_hem(invorder);
shenColors_hem_circle = shenColors_hem(invorder,:);

figure(655); clf;
% plot_mask = read_comboMask*0.5;
% plot_mask = gradcpt_comboMask*0.5;
% plot_mask(read_comboMask==gradcpt_comboMask) = plot_mask(read_comboMask==gradcpt_comboMask)*8;
plot_mask = DanDmnNetwork*0.5;
plot_mask(read_comboMask==DanDmnNetwork) = plot_mask(read_comboMask==DanDmnNetwork)*8;
[hCircle,hArc] = PlotConnectivityOnCircle(shenAtlas,shenLabels_hem_circle,plot_mask,0,shenLabelNames_hem_circle,true,shenColors_hem_circle);
axis square

set(hCircle,'Marker','none','linewidth',10)
hPos = hArc(UnvectorizeFc(VectorizeFc(plot_mask),0,false)>0);
hNeg = hArc(UnvectorizeFc(VectorizeFc(plot_mask),0,false)<0);
set(hPos,'color',cmap(end,:));
set(hNeg,'color',cmap(1,:));
set(gca,'visible','off')
axis([-1 1 -1 1]);


%% Figure 3: Compare in 3D
% Combine GradCpt CRs across subjects
cr_min_gradcpt = min(abs(gradcpt_cr),[],3).*sign(gradcpt_cr(:,:,1));
isMixedSign = ~(all(gradcpt_cr<0,3) | all(gradcpt_cr>0,3));
cr_min_gradcpt(isMixedSign) = 0;
% Threshold
threshold_gradcpt = GetValueAtPercentile(abs(VectorizeFc(cr_min_gradcpt)),99.75);
isInNetwk = abs(cr_min_gradcpt)>threshold_gradcpt;
cr_plot_gradcpt = cr_min_gradcpt;
cr_plot_gradcpt(~isInNetwk) = 0;

% Get just the most matching edges
mask_plot_dandmn = GetNeurosynthNetworks(posFilename,negFilename,atlasFilename,posMaskThreshold,negMaskThreshold,10,10);


% Combine Reading CRs across subjects
% cp_max_read = max(read_cp,[],3);
cr_min_read = min(abs(read_cr),[],3).*sign(read_cr(:,:,1));
isMixedSign = ~(all(read_cr<0,3) | all(read_cr>0,3));
cr_min_read(isMixedSign) = 0;
% Threshold
threshold_read = GetValueAtPercentile(abs(VectorizeFc(cr_min_read)),99.75);
isInNetwk = abs(cr_min_read)>threshold_read;
cr_plot_read = cr_min_read;
cr_plot_read(~isInNetwk) = 0;

% Plot results
clear h
figure(280); clf;
subplot(2,3,1);
h(1) = VisualizeFcIn3d(sign(cr_plot_gradcpt),shenAtlas,shenLabels,shenColors,[],shenInfo.Orientation,'top');
title(sprintf('GradCPT Networks, threshold=%.3g',threshold_gradcpt));
subplot(2,3,2);
h(2) = VisualizeFcIn3d(sign(mask_plot_dandmn),shenAtlas,shenLabels,shenColors,[],shenInfo.Orientation,'top');
title('DAN/DMN Networks');
subplot(2,3,3);
h(3) = VisualizeFcIn3d(sign(cr_plot_read),shenAtlas,shenLabels,shenColors,[],shenInfo.Orientation,'top');
title(sprintf('Reading Networks, threshold=%.3g',threshold_read));
subplot(2,3,4);
h(4) = VisualizeFcIn3d(sign(cr_plot_gradcpt),shenAtlas,shenLabels,shenColors,[],shenInfo.Orientation,'right');
title(sprintf('GradCPT Networks, threshold=%.3g',threshold_gradcpt));
subplot(2,3,5);
h(5) = VisualizeFcIn3d(sign(mask_plot_dandmn),shenAtlas,shenLabels,shenColors,[],shenInfo.Orientation,'right');
title('DAN/DMN Networks');
subplot(2,3,6);
h(6) = VisualizeFcIn3d(sign(cr_plot_read),shenAtlas,shenLabels,shenColors,[],shenInfo.Orientation,'right');
title(sprintf('Reading Networks, threshold=%.3g',threshold_read));


%% Figure 4 (alt): Get spatial overlap of combined networks
gradcpt_thresh = 0.01;
read_thresh = 0.01;
gradcptNetwork = all(gradcpt_cp<gradcpt_thresh & gradcpt_cr>0,3) - all(gradcpt_cp<gradcpt_thresh & gradcpt_cr<0,3);
readingNetwork = all(read_cp<read_thresh & read_cr>0,3) - all(read_cp<read_thresh & read_cr<0,3);
% DanDmnNetwork = DanDmnNetwork;

PlotOverlapBetweenFcNetworks(readingNetwork,gradcptNetwork,shenAtlas,...
    shenLabels_hem,shenColors_hem,shenLabelNames_hem,{'Reading','GradCPT'});
% PlotOverlapBetweenFcNetworks(gradcptNetwork,readingNetwork,shenAtlas,...
%     shenLabels_hem,shenLabelColors_hem,shenLabelNames_hem,{'GradCPT','Reading'});
% PlotOverlapBetweenFcNetworks(readingNetwork,DanDmnNetwork,shenAtlas,...
%     shenLabels_hem,shenColors_hem,shenLabelNames_hem,{'Reading','DAN/DMN'});

%% Figure 4: Sweep thresholds and show effect on performance

thresholds = .0001:.0001:.06;
figure(63); clf;
[maskSizePos,maskSizeNeg,Rsq,p,r] = SweepRosenbergThresholds(read_cp,read_cr,FC,fracCorrect,thresholds);
% MakeFigureTitle('Reading Comprehension Networks');

% Produce figure
figure(63); clf;
set(gcf,'Position',[997   912   732   423]);
plot(maskSizePos+maskSizeNeg,r(:,4));
hold on;
xlabel('# edges included in Reading Network')
ylabel('LOSO correlation with reading comprehension')
xlim([0 500]);
lineThresholds = [0.0001, 0.0005, 0.001, 0.005, 0.01];
for i=1:numel(lineThresholds)
    iThresh = find(thresholds==lineThresholds(i));
    plot([1 1]*(maskSizePos(iThresh)+maskSizeNeg(iThresh)), [0 r(iThresh,4)],'k--');
    plot((maskSizePos(iThresh)+maskSizeNeg(iThresh)), r(iThresh,4),'ko');
    text((maskSizePos(iThresh)+maskSizeNeg(iThresh))+5, r(iThresh,4)-.03,sprintf('p=%.1g',lineThresholds(i)));
end


%% Supplementary Figure 1: Motion
figure(362);
[meanMotion,meanMotion_notCensored,pctCensored,fracCorrect2] = CheckMotionAndComprehension(subjects);

% Overwrite figure
% clf;
set(gcf,'Position',[183 645 1300 690]);
subplot(2,3,1);
[p,Rsq,lm] = Run1tailedRegression(fracCorrect*100,meanMotion,false);
lm.plot();
ylabel('Mean motion (mm/TR)')
xlabel('Comprehension Accuracy (%)');
title(sprintf('r = %.3g, p = %.3g',sqrt(lm.Rsquared.Ordinary),p));
legend('Subject','Linear fit','95% confidence')
axis square

%% Supplementary Figure 1: behavior-based prediction based on page time
homedir = '/data/jangrawdc/PRJ03_SustainedAttention/Results';
[meanPageDur, stdPageDur] = deal(nan(nSubj,1));
for i=1:nSubj
    fprintf('Getting behavior for subject %d/%d...\n',i,nSubj);
    beh = load(sprintf('%s/SBJ%02d/Distraction-SBJ%02d-Behavior.mat',homedir,subjects(i),subjects(i)),'data');
    nRuns = numel(beh.data);
    pageDur_ms = cell(1,nRuns);
    for j=1:nRuns
        iStartPage = find(strncmpi('Page',beh.data(j).events.display.name,4));
        pageDur_ms{j} = beh.data(j).events.display.time(iStartPage+1) - beh.data(j).events.display.time(iStartPage);
    end
    pageDur_s = cat(1,pageDur_ms{:})/1000; % and convert to seconds
    meanPageDur(i) = mean(pageDur_s);
    stdPageDur(i) = std(pageDur_s);
end
fprintf('Done!\n');

% Plot
subplot(2,3,2);
[p,Rsq,lm] = Run1tailedRegression(fracCorrect*100,meanPageDur,false);
lm.plot();
ylabel('Mean page duration (s)')
xlabel('Comprehension Accuracy (%)');
title(sprintf('Page Duration\nr = %.3g, p = %.3g',sqrt(lm.Rsquared.Ordinary),p));
% subplot(1,2,2);
% [p,Rsq,lm] = Run1tailedRegression(stdPageDur,fracCorrect*100,false);
% lm.plot();

%% Supplementary Figure 1: Global correlation

globalFc = nan(numel(subjects),1);
for i=1:numel(subjects)
    globalFc(i) = mean(mean(FC(:,:,i)));
end

% Plot
figure(362);% clf;
% set(gcf,'Position',[22 850 750 486]);
subplot(2,3,3);
[p,Rsq,lm] = Run1tailedRegression(fracCorrect*100,globalFc,false);
lm.plot();
ylabel('mean FC across all ROI pairs')
xlabel('Comprehension Accuracy (%)');
title(sprintf('r = %.3g, p = %.3g',corr(globalFc(:),fracCorrect(:)*100),p));
legend('Subject','Linear fit','95% confidence')
axis square

%% Supplementary figure 1: ocular metrics 
% saccade/blink rate
[saccadeRate,blinkRate,sacRate_runs] = GetSaccadeRate(subjects, onlyOkSamples);
% pupil metrics
delay = 0;
[pupilDilation,pd_runs] = GetSubjectPupilDilation(subjects,delay);

% Plot
figure(362);
[r,p] = corr(fracCorrect,saccadeRate');
fprintf('fracCorrect vs. # saccades/sec: r=%.3g, p=%.3g\n',r,p);
subplot(2,3,4);
lm = fitlm(fracCorrect*100,saccadeRate,'Linear');
lm.plot;
xlabel('Comprehension Accuracy (%)');
ylabel('mean # saccades per second');
title(sprintf('saccade rate vs. reading comprehension\nr=%.3g, p=%.3g',r,p));
axis square

[r,p] = corr(fracCorrect,blinkRate');
fprintf('fracCorrect vs. # blinks/sec: r=%.3g, p=%.3g\n',r,p);
subplot(2,3,5);
lm = fitlm(fracCorrect*100,blinkRate,'Linear');
lm.plot;
xlabel('Comprehension Accuracy (%)');
ylabel('mean # blinks per second');
title(sprintf('blink rate vs. reading comprehension\nr=%.3g, p=%.3g',r,p));
axis square

[r,p] = corr(fracCorrect,pupilDilation');
fprintf('fracCorrect vs. # blinks/sec: r=%.3g, p=%.3g\n',r,p);
subplot(2,3,6);
lm = fitlm(fracCorrect*100,pupilDilation,'Linear');
lm.plot;
xlabel('Comprehension Accuracy (%)');
ylabel('mean pupil dilation');
title(sprintf('pupil dilation vs. reading comprehension\nr=%.3g, p=%.3g',r,p));
axis square

%% Supplementary Figure 2: comparing various metrics

metrics = {'-meanMotion','-blinkRate','saccadeRate','pupilDilation','-globalFc','activityScore','gradcpt_combo','dandmn_combo','read_combo','fracCorrect'};
nMets = numel(metrics);
rVals = nan(nMets);
for i=1:nMets
    for j=1:nMets
        rVals(i,j) = eval(sprintf('corr(%s(:),%s(:));',metrics{i},metrics{j}));
    end
end
figure(734); clf;
subplot(1,3,1);
imagesc(rVals)
colorbar
set(gca,'clim',[0 1]);
set(gca,'ytick',1:nMets,'yticklabel',show_symbols(metrics));
set(gca,'xtick',1:nMets,'xticklabel',show_symbols(metrics));
xticklabel_rotate
title('correlation of metrics across subjects');
axis square

% Project out one
[rVals_proj, p_proj] = deal(nan(nMets-1));
for i=1:nMets-1
    for j=1:nMets-1
        % project out
        a = eval(sprintf('normalise(%s(:)-mean(%s));',metrics{i},metrics{i}));
        b = eval(sprintf('normalise(%s(:)-mean(%s));',metrics{j},metrics{j}));
        proj = (a'*b)/(b'*b)*b;
        projout = a-proj;
        [rVals_proj(i,j),p_proj(i,j)] = corr(projout(:),fracCorrect(:));
    end
    [rVals_proj(i,nMets),p_proj(i,nMets)] = eval(sprintf('corr(%s(:),fracCorrect(:));',metrics{i}));    
end
p_proj = p_proj/2; % one-tailed
% q_proj = reshape(mafdr(p_proj(:),'bhfdr',true),size(p_proj));
subplot(1,3,2);
imagesc(rVals_proj)
colorbar
set(gca,'clim',[0 1]);
set(gca,'ytick',1:nMets-1,'yticklabel',show_symbols(metrics(1:end-1)));
set(gca,'xtick',1:nMets,'xticklabel',show_symbols([metrics(1:end-1), {'none'}]));
xlabel('Metric X')
ylabel('Metric Y');
title(sprintf('correlation of metric Y with fracCorrect\n after regressing out metric X'));
xticklabel_rotate
axis square

% convert to % remaining variance explained
subplot(1,3,3);
pctVarEx_proj = nan(size(rVals_proj));
for i=1:nMets-1
    fracLeft = 1-rVals_proj(i,nMets)^2;
    fracExplained = rVals_proj(:,i).^2;
    pctVarEx_proj(:,i) = fracExplained/fracLeft*100;
end
pctVarEx_proj(:,end) = rVals_proj(:,end).^2*100;

imagesc(pctVarEx_proj)
colorbar
set(gca,'clim',[0 100]);
set(gca,'ytick',1:nMets-1,'yticklabel',show_symbols(metrics(1:end-1)));
set(gca,'xtick',1:nMets,'xticklabel',show_symbols([metrics(1:end-1),{'none'}]));
xlabel('Metric X')
ylabel('Metric Y');
title(sprintf('%% variance of fracCorrect explained by\n metric Y after regressing out metric X'));
xticklabel_rotate
axis square

%% Text: Compare correlation values
rVals = struct();
% fields = {'meanMotion','globalFc','read_combo','gradcpt_combo','dandmn_combo'};
fields = {'meanMotion','blinkRate','saccadeRate','pupilDilation','globalFc','activityScore','gradcpt_combo','dandmn_combo','read_combo'};
for i=1:numel(fields)
    rVals.(fields{i}) = eval(sprintf('corr(%s(:),fracCorrect(:));',fields{i}));
end
[z,p] = deal(nan(numel(fields)));
fprintf('=== Steiger''s Z tests ===\n');
for i=1:numel(fields)
    for j=(i+1):numel(fields)
        r12 = eval(sprintf('corr(%s(:),%s(:));',fields{i},fields{j}));
        r13 = rVals.(fields{i});
        r23 = rVals.(fields{j});
%         fprintf('%s vs. %s: r12=%.3g, r13=%.3g, r23=%.3g\n',fields{i},fields{j},r12,r13,r23);
        [z(i,j), p(i,j)] = SteigersZTest(abs(r12),abs(r13),abs(r23),numel(subjects));
        z(j,i) = z(i,j);
        p(j,i) = p(i,j);
        fprintf('%s vs. %s: z=%.3g, p=%.3g\n',fields{i},fields{j},z(i,j),p(i,j)/2) % one-tailed p values
    end
end
figure(622); clf;
hold on;
imagesc(z);
for i=1:numel(fields)
    for j=(i+1):numel(fields)
        if p(i,j)<0.1 % one-tailed
            plot(i,j,'r*');
            plot(j,i,'r*');
        end
    end
end
colorbar
set(gca,'YDir','reverse');
set(gca,'ytick',1:numel(fields),'yticklabel',show_symbols(fields));
set(gca,'xtick',1:numel(fields),'xticklabel',show_symbols(fields));
xticklabel_rotate;


%% Supplementary Figure 3: Correlations of activity with behavior
% Use to predict behavior
% thresh = 1;
% [activityScore,networks_activ,cp_activ,cr_activ] = RunLeaveOneOutRegressionWithActivity(meanInRoi_subj,fracCorrect,thresh);
% set up
meanCr = mean(cr_activ,2);
nReg = numel(shenLabelNames_hem);

% plot spatially
% figure(446); clf;
% iSlices = round(linspace(4,46,16));
% clim = .5;%1;%.25;
% % iSlices = round(linspace(1,size(shenAtlas,1),9));
% shenTemp = MapValuesOntoAtlas(shenAtlas,meanCr);
% DisplaySlices(shenTemp,1,iSlices,[],[-1 1],true);
% colorbar off
% title(sprintf('Reading Network Activity'),'interpreter','none')

% % Save spatially
% meanCp = mean(cp_activ,2);
% meanCz = norminv(meanCp);
% shenTemp = MapValuesOntoAtlas(shenAtlas,meanCr);
% shenTemp2 = MapValuesOntoAtlas(shenAtlas,meanCz);
% shenInfoTemp = shenInfo;
% shenInfoTemp.BRICK_LABS = '#0_CR~#1_CP(z)';
% shenInfoTemp.TYPESTRING = '3DIM_HEAD_FUNC';
% shenInfoTemp.BRICK_TYPES = [3 3];
% shenInfoTemp.SCENE_DATA(3) = 1;
% shenInfoTemp.BRICK_STATAUX = [1 5 0];
% filenameTemp = 'Distraction-ShenActivationVsPerformanceCrCp';
% fprintf('Saving as %s...\n',filenameTemp);
% WriteBrik(cat(4,shenTemp,shenTemp2),shenInfoTemp,struct('Prefix',filenameTemp,'OverWrite','y'));
% clear *Temp

% Plot by region
figure(447); clf; hold on;
set(gcf,'Position',[183 904 1030 399]);
% group by region
meanCrInRegion = nan(1,nReg);
% meanFcCr = mean(mean(read_cr,3),2);
% meanFcCrInRegion = nan(1,nReg);
for i=1:nReg
    meanCrInRegion(i) = mean(meanCr(shenLabels_hem==i));
%     meanFcCrInRegion(i) = mean(meanFcCr(shenLabels_hem==i));
    hBar = bar(i,meanCrInRegion(i),'FaceColor',shenColors_hem(i,:));
end
% bar([meanCrInRegion; meanFcCrInRegion*10]');
xlim([0 nReg+1]);
set(gca,'xtick',1:nReg,'xticklabel',show_symbols(shenLabelNames_hem));
xticklabel_rotate;
ylabel(sprintf('mean correlation between ROIs in region\nand reading comprehension'))


%% Supplementary? Most-participating regions 
fooPos = GroupFcByRegion(read_comboMask>0,shenLabels_hem,'sum',true);
fooNeg = GroupFcByRegion(read_comboMask<0,shenLabels_hem,'sum',true);
figure(449); clf; hold on;
set(gcf,'Position',[183 904 1503 399]);
for i=1:nReg
    hBar = bar(i,sum(fooPos(i,:)),'FaceColor',shenColors_hem(i,:));
    hBar = bar(i,-sum(fooNeg(i,:)),'FaceColor',shenColors_hem(i,:));
end
xlim([0 nReg+1]);
ylabel(sprintf('ROI pairs in high-performance network\n - low-performance network'))
set(gca,'xtick',1:nReg,'xticklabel',show_symbols(shenLabelNames_hem));
xticklabel_rotate;

%% Same broken down by hemisphere
shenLabels_LorR = (mod(shenLabels_hem,2)==0)+1;
fooPos = GroupFcByRegion(read_comboMask>0,shenLabels_LorR,'sum',true);
fooNeg = GroupFcByRegion(read_comboMask<0,shenLabels_LorR,'sum',true);
% print results
fprintf('---High-Performance---\n')
fprintf('L-L: %d\n',fooPos(1,1));
fprintf('R-R: %d\n',fooPos(2,2));
fprintf('L-R: %d\n',fooPos(1,2));

fprintf('---Low-Performance---\n')
fprintf('L-L: %d\n',fooNeg(1,1));
fprintf('R-R: %d\n',fooNeg(2,2));
fprintf('L-R: %d\n',fooNeg(1,2));

%% Plot # ROIs in each region
clf; hold on;
for i=1:nReg
    hBar = bar(i,sum(shenLabels_hem==i),'FaceColor',shenColors_hem(i,:));
end
xlim([0 nReg+1]);
ylabel(sprintf('# ROIs in region'))
set(gca,'xtick',1:nReg,'xticklabel',show_symbols(shenLabelNames_hem));
xticklabel_rotate;
