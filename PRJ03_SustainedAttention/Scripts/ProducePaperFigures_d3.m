% ProducePaperFigures_d2.m
%
% Created 2/22/17 based on ProducePaperFigures_d1.m 

subjects = [9:11 13:19 22 24:25 28 30:33 36];

afniProcFolder = 'AfniProc_MultiEcho_2016-09-22'; % 9-22 = MNI
tsFilePrefix = 'shen268_withSegTc'; % 'withSegTc' means with BPFs
runComboMethod = 'avgRead'; % average of run-wise FC, limited to reading samples
doPlot = false;

%% Get FC
[FC,isMissingRoi,FC_runs] = GetFc_AllSubjects(subjects,afniProcFolder,tsFilePrefix,runComboMethod);
FC_fisher = atanh(FC);
FC_fisher = UnvectorizeFc(VectorizeFc(FC_fisher),0,true);
%% Get performance
[fracCorrect, RT] = GetFracCorrect_AllSubjects(subjects);

%% Get GradCPT Network
vars = GetDistractionVariables;
homedir = vars.homedir;
fprintf('Loading attention network matrices...\n')
[shenAtlas,shenInfo] = BrikLoad([homedir '/Results/Shen_2013_atlas/EPIres_shen_1mm_268_parcellation+tlrc.BRIK']);
attnNets = load([homedir '/Collaborations/MonicaRosenberg/attn_nets_268.mat']);
[shenLabels,shenLabelNames,shenColors] = GetAttnNetLabels(false);
[shenLabels_hem,shenLabelNames_hem,shenColors_hem] = GetAttnNetLabels('region-hem');

% Get cpcr
gradcpt_struct = load([homedir '/Collaborations/MonicaRosenberg/Rosenberg2016_weights.mat']);
gradcpt_cp = UnvectorizeFc(cat(2,gradcpt_struct.cp{:}));
gradcpt_cr = UnvectorizeFc(cat(2,gradcpt_struct.cr{:}));

%% Get Vis/Aud Language Network
% posFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth/NeuroSynth_dorsalattention_pAgF_z_FDR_0.01_EpiRes_MNI+tlrc';
% negFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth/NeuroSynth_defaultmode_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc';
% posFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth/NeuroSynth_v4-topics-100_87_sentences_language_comprehension_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc';
% posFilename = [homedir '/Results/NeuroSynth/NeuroSynth_v4-topics-100_9_attention_attentional_visual_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc'];
% negFilename = [homedir '/Results/NeuroSynth/NeuroSynth_v4-topics-100_59_network_default_dmn_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc'];
posFilename = [homedir '/Results/NeuroSynth/NeuroSynth_v4-topics-100_15_reading_words_language_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc'];
negFilename = [homedir '/Results/NeuroSynth/NeuroSynth_v4-topics-100_86_speech_auditory_sounds_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc'];
atlasFilename = [homedir '/Results/Shen_2013_atlas/MNI_EPIres_shen_1mm_268_parcellation+tlrc'];
posMaskThreshold = 0;
negMaskThreshold = 0;
posMatchThreshold = 0.15;%0.5;%
negMatchThreshold = 0.15;%0.5;%
VisAudNetwork = GetNeurosynthNetworks(posFilename,negFilename,atlasFilename,posMaskThreshold,negMaskThreshold,posMatchThreshold,negMatchThreshold);

%% Get DAN/DMN Network
% posFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth/NeuroSynth_dorsalattention_pAgF_z_FDR_0.01_EpiRes_MNI+tlrc';
% negFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth/NeuroSynth_defaultmode_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc';
% posFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth/NeuroSynth_v4-topics-100_87_sentences_language_comprehension_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc';
posFilename = [homedir '/Results/NeuroSynth/NeuroSynth_v4-topics-100_9_attention_attentional_visual_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc'];
negFilename = [homedir '/Results/NeuroSynth/NeuroSynth_v4-topics-100_59_network_default_dmn_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc'];
% posFilename = [homedir '/Results/NeuroSynth/NeuroSynth_v4-topics-100_15_reading_words_language_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc'];
% negFilename = [homedir '/Results/NeuroSynth/NeuroSynth_v4-topics-100_86_speech_auditory_sounds_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc'];
atlasFilename = [homedir '/Results/Shen_2013_atlas/MNI_EPIres_shen_1mm_268_parcellation+tlrc'];
posMaskThreshold = 0;
negMaskThreshold = 0;
posMatchThreshold = 0.15;%0.5;%
negMatchThreshold = 0.15;%0.5;%
DanDmnNetwork = GetNeurosynthNetworks(posFilename,negFilename,atlasFilename,posMaskThreshold,negMaskThreshold,posMatchThreshold,negMatchThreshold);


%% Get Reading Network and predictions
thresh = 0.01;
corr_method = 'robustfit';
mask_method = 'one';
[read_pos, read_neg, read_combo,read_posMask_all,read_negMask_all] = RunLeave1outBehaviorRegression(FC_fisher,fracCorrect,thresh,corr_method,mask_method);
fprintf('Done!\n');
% save ReadingNetworkScores_p01_Fisher read_pos read_neg read_combo subjects
%% Get mask size range
sizePos_all = sum(VectorizeFc(read_posMask_all));
sizeNeg_all = sum(VectorizeFc(read_negMask_all));
fprintf('Pos mask across LOSO iterations: min %d, max %d, mean %.3f, std %.3f\n',min(sizePos_all),max(sizePos_all),mean(sizePos_all),std(sizePos_all))
fprintf('Neg mask across LOSO iterations: min %d, max %d, mean %.3f, std %.3f\n',min(sizeNeg_all),max(sizeNeg_all),mean(sizeNeg_all),std(sizeNeg_all))
fprintf('Combined across all LOSO iterations: pos %d, neg %d\n',sum(all(VectorizeFc(read_posMask_all),2)),sum(all(VectorizeFc(read_negMask_all),2)))

%% Get cpcr
corr_method = 'robustfit';
mask_method = 'cpcr';
thresh = 0;
[~,~,~,read_cp,read_cr] = RunLeave1outBehaviorRegression(FC_fisher,fracCorrect,thresh,corr_method,mask_method);
% save ReadingCpCr_19subj_Fisher_2017-02-22 read_cp read_cr subjects 

%% Get Predictions from Other networks

[gradcpt_pos,gradcpt_neg,gradcpt_combo] = GetFcMaskMatch(FC_fisher,attnNets.pos_overlap,attnNets.neg_overlap);
[gradcpt_pos,gradcpt_neg,gradcpt_combo] = deal(gradcpt_pos',gradcpt_neg',gradcpt_combo');
[visaud_pos,visaud_neg,visaud_combo] = GetFcMaskMatch(FC_fisher,VisAudNetwork>0,VisAudNetwork<0);
[visaud_pos,visaud_neg,visaud_combo] = deal(visaud_pos',visaud_neg',visaud_combo');
[dandmn_pos,dandmn_neg,dandmn_combo] = GetFcMaskMatch(FC_fisher,DanDmnNetwork>0,DanDmnNetwork<0);
[dandmn_pos,dandmn_neg,dandmn_combo] = deal(dandmn_pos',dandmn_neg',dandmn_combo');


%% FIGURE 2: 
% Compare predictions across tasks

% Set up
figure(277); clf;
set(gcf,'Position',[159         122        1660        1165]);
% set(gcf,'Position',[159         122        1660        435]);
networks = {'gradcpt','visaud','read'};
networkNames = {'GradCPT','Vis/Aud Language','Reading'};
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
        xlabel('Comprehension Accuracy (%)');
        ylabel(sprintf('%s %s Network score',networkNames{j},typeNames{i}));
        title(sprintf('%s %s Network Prediction\nr=%.3g, p=%.3g',networkNames{j},typeNames{i},r,p));
        legend('Subject','Linear Fit');%,'Location','Northwest')
    end
end


%% TEXT: Compare network sizes
read_comboMask = all(read_posMask_all>0,3) - all(read_negMask_all>0,3);
gradcpt_comboMask = attnNets.pos_overlap - attnNets.neg_overlap;

fprintf('GradCPT: %d high-attention, %d low-attention\n',sum(VectorizeFc(gradcpt_comboMask>0)), sum(VectorizeFc(gradcpt_comboMask<0)))
fprintf('Vis/Aud: %d high-attention, %d low-attention\n',sum(VectorizeFc(VisAudNetwork>0)), sum(VectorizeFc(VisAudNetwork<0)))
fprintf('Reading: %d high-attention, %d low-attention\n',sum(VectorizeFc(read_comboMask>0)), sum(VectorizeFc(read_comboMask<0)))

% Find # of permutation tests with more than this many edges
mask_size_pos = sum(VectorizeFc(read_comboMask>0));
mask_size_neg = sum(VectorizeFc(read_comboMask<0));
% Load and test permtests
permtests = load([homedir '/Results/PermTests_Reading_Fisher_spearman.mat']);
p1 = (sum(permtests.mask_size_overlap(1,:)>=mask_size_pos)+1)/size(permtests.mask_size_overlap,2);
p2 = (sum(permtests.mask_size_overlap(2,:)>=mask_size_neg)+1)/size(permtests.mask_size_overlap,2);
fprintf('odds of this many edges by chance: pos = %.3g, neg = %.3g\n',p1,p2);


%% Figure 3: Plot Networks as Matrices
% P01 VERSION:
% foo = load('ReadingNetwork_p01_Fisher.mat');
% read_comboMask = foo.readingNetwork_p01;
% gradcpt_comboMask = attnNets.pos_overlap-attnNets.neg_overlap;
% clim = [75 63 16];

% SMALL NETWORK VERSION
foo = load('ReadingSweepResults_Fisher_spearman.mat');
[~,iMax] = max(foo.r(:,4));
threshold_read = foo.thresholds(iMax);
% Get combined mask
read_comboMask = GetNetworkAtThreshold(read_cr,read_cp,threshold_read);
% Get GradCPT network of same size
isAllSameSign = all(gradcpt_cr>0,3) | all(gradcpt_cr<0,3);
gradcpt_cp_max = max(gradcpt_cp,[],3);
gradcpt_cp_max(~isAllSameSign) = 1;
gradcpt_cp_max_sorted = sort(VectorizeFc(gradcpt_cp_max),'ascend');
nEdges = sum(VectorizeFc(read_comboMask)~=0);
threshold_gradcpt = gradcpt_cp_max_sorted(nEdges);
gradcpt_comboMask = GetNetworkAtThreshold(gradcpt_cr,gradcpt_cp,threshold_gradcpt);

% Same for Gradcpt
% foo = load('GradcptSweepResults_Fisher_spearman.mat');
% [~,iMax] = max(foo.r_sweep_gradcpt(:,4));
% threshold_gradcpt = foo.thresholds_gradcpt(iMax);
% % Get combined mask
% gradcpt_comboMask = GetNetworkAtThreshold(gradcpt_cr,gradcpt_cp,threshold_gradcpt);

% Get smaller VisAudNetwork
posMatchThreshold = 0.5;
negMatchThreshold = 0.5;
VisAudNetwork = GetNeurosynthNetworks(posFilename,negFilename,atlasFilename,posMaskThreshold,negMaskThreshold,posMatchThreshold,negMatchThreshold);


% NO THRESHOLD VERSION
% read_comboMask = all(read_posMask_all>0,3)-all(read_negMask_all>0,3);


clim = [5 25 7];


figure(278); clf;
set(gcf,'Position',[62 722 1731 613]);
subplot(131);
[~,~,~,~,hRect] = PlotFcMatrix(gradcpt_comboMask,[-1 1]*clim(1),shenAtlas,shenLabels_hem,true,shenColors_hem,'sum');
title('GradCpt Networks')
delete(hRect);
subplot(132);
[~,~,~,~,hRect] = PlotFcMatrix(VisAudNetwork,[-1 1]*clim(2),shenAtlas,shenLabels_hem,true,shenColors_hem,'sum');
title(sprintf('%s Networks',networkNames{2}))
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


%% Figure 3: Compare in 2D or 3d
version = '3d';
viewtypes = {'top' 'left'};
% Threshold GradCPT
% threshold_gradcpt = GetValueAtPercentile(abs(VectorizeFc(cr_min_gradcpt)),99.75);
% gradcpt_comboMask = GetNetworkAtThreshold(gradcpt_cr,gradcpt_cp,threshold_gradcpt);


% Get just the most matching edges
% posMatchThreshold = 0.5;
% negMatchThreshold = 0.5;
% VisAudNetwork = GetNeurosynthNetworks(posFilename,negFilename,atlasFilename,posMaskThreshold,negMaskThreshold,posMatchThreshold,negMatchThreshold);

% Threshold Reading
% threshold_read = GetValueAtPercentile(abs(VectorizeFc(cr_min_read)),99.75);
% read_comboMask = GetNetworkAtThreshold(read_cr,read_cp,threshold_read);

% Plot results
switch version
    case '2d'
        clear h
        figure(280); clf;
        subplot(2,3,1);
        h(1) = VisualizeFcIn2d(sign(gradcpt_comboMask),shenAtlas,shenLabels,shenColors,[],shenInfo.Orientation,'top');
        title(sprintf('GradCPT Networks, threshold=%.3g',threshold_gradcpt));
        subplot(2,3,2);
        h(2) = VisualizeFcIn2d(sign(VisAudNetwork),shenAtlas,shenLabels,shenColors,[],shenInfo.Orientation,'top');
        title(sprintf('%s Networks',networkNames{2}));
        subplot(2,3,3);
        h(3) = VisualizeFcIn2d(sign(read_comboMask),shenAtlas,shenLabels,shenColors,[],shenInfo.Orientation,'top');
        title(sprintf('Reading Networks, threshold=%.3g',threshold_read));
        subplot(2,3,4);
        h(4) = VisualizeFcIn2d(sign(gradcpt_comboMask),shenAtlas,shenLabels,shenColors,[],shenInfo.Orientation,'right');
        title(sprintf('GradCPT Networks, threshold=%.3g',threshold_gradcpt));
        subplot(2,3,5);
        h(5) = VisualizeFcIn2d(sign(VisAudNetwork),shenAtlas,shenLabels,shenColors,[],shenInfo.Orientation,'right');
        title(sprintf('%s Networks',networkNames{2}));
        subplot(2,3,6);
        h(6) = VisualizeFcIn2d(sign(read_comboMask),shenAtlas,shenLabels,shenColors,[],shenInfo.Orientation,'right');
        title(sprintf('Reading Networks, threshold=%.3g',threshold_read));
    case '3d'
        networks = {sign(gradcpt_comboMask), sign(VisAudNetwork), sign(read_comboMask)};
        h = cell(1,numel(networks));                        
        for i=1:numel(networks)
            h{i} = PlotShenFcIn3d_Conn(networks{i});
            % prep for image
            feval(h{i},'zoomout'); % zoom out one
            feval(h{i},'background',[1 1 1]); % white background
            drawnow;
            for iView = 1:numel(viewtypes)
                % switch view
                switch viewtypes{iView}
                    case 'left'
                        feval(h{i},'view',[-1 0 0],[],0); % left
                    case 'top'
                        feval(h{i},'view',[0,-.01,1],[],0); % superior
                    case 'back'
                        feval(h{i},'view',[0,-1,0],[],0); % posterior
                end
                % Save result to image
                feval(h{i},'print',1); % save image with current view
            end
        end
% uimenu(hc1,'Label','Left view','callback',{@conn_mesh_display_refresh,'view',[-1,0,0],[],0},'tag','view');
% uimenu(hc1,'Label','Right view','callback',{@conn_mesh_display_refresh,'view',[1,0,0],[],0},'tag','view');
% uimenu(hc1,'Label','Left medial view','callback',{@conn_mesh_display_refresh,'view',[1,0,0],[1,0,.5],-1},'tag','view');
% uimenu(hc1,'Label','Right medial view','callback',{@conn_mesh_display_refresh,'view',[-1,0,0],[-1,0,.5],1},'tag','view');
% uimenu(hc1,'Label','Anterior view','callback',{@conn_mesh_display_refresh,'view',[0,1,0],[],0},'tag','view');
% uimenu(hc1,'Label','Posterior view','callback',{@conn_mesh_display_refresh,'view',[0,-1,0],[],0},'tag','view');
% uimenu(hc1,'Label','Superior view','callback',{@conn_mesh_display_refresh,'view',[0,-.01,1],[],0},'tag','view');
% uimenu(hc1,'Label','Inferior view','callback',{@conn_mesh_display_refresh,'view',[0,-.01,-1],[],0},'tag','view');
% uimenu(hc1,'Label','Camera-view copy','callback',{@conn_mesh_display_refresh,'copy'},'separator','on');
% uimenu(hc1,'Label','Camera-view paste','callback',{@conn_mesh_display_refresh,'paste'});
% uimenu(hc1,'Label','Zoom in','separator','on','callback',{@conn_mesh_display_refresh,'zoomin'});
% uimenu(hc1,'Label','Zoom out','callback',{@conn_mesh_display_refresh,'zoomout'});
% uimenu(hc1,'Label','current view','callback',{@conn_mesh_display_refresh,'print',1});
% uimenu(hc1,'Label','4-view mosaic','callback',{@conn_mesh_display_refresh,'print',2});
% uimenu(hc1,'Label','4-view column','callback',{@conn_mesh_display_refresh,'print',3});
% uimenu(hc1,'Label','4-view row','callback',{@conn_mesh_display_refresh,'print',4});
% uimenu(hc1,'Label','8-view mosaic','callback',{@conn_mesh_display_refresh,'print',5});
end

%% Figure 4 (alt): Get spatial overlap of combined networks
% threshold_gradcpt = 0.01;
% threshold_read = 0.01;
gradCptNetwork = GetNetworkAtThreshold(gradcpt_cr,gradcpt_cp,threshold_gradcpt);
readingNetwork = GetNetworkAtThreshold(read_cr,read_cp,threshold_read);
% DanDmnNetwork = DanDmnNetwork;

PlotOverlapBetweenFcNetworks(readingNetwork,gradCptNetwork,shenAtlas,...
    shenLabels_hem,shenColors_hem,show_symbols(shenLabelNames_hem),{'Reading','GradCPT'});
PlotOverlapBetweenFcNetworks(gradCptNetwork,VisAudNetwork,shenAtlas,...
    shenLabels_hem,shenColors_hem,shenLabelNames_hem,{'GradCPT','Vis/Aud'});
PlotOverlapBetweenFcNetworks(readingNetwork,VisAudNetwork,shenAtlas,...
    shenLabels_hem,shenColors_hem,shenLabelNames_hem,{'Reading','Vis/Aud'});

%% Figure 4: Sweep thresholds and show effect on performance

thresholds = .0001:.0001:.1;
[maskSizePos,maskSizeNeg,Rsq,p,r,p_spearman,r_spearman] = SweepRosenbergThresholds(read_cp,read_cr,FC_fisher,fracCorrect,thresholds);
% MakeFigureTitle('Reading Comprehension Networks');

%% Same for GradCPT
thresholds_gradcpt = [0.00001:0.00001:0.00009, .0001:.0001:.06];
% Make fake cp/cr based on min across iterations
isAllSameSign = all(gradcpt_cr>0,3) | all(gradcpt_cr<0,3);
gradcpt_cr_min = min(abs(gradcpt_cr),[],3).*sign(gradcpt_cr(:,:,1)) .* isAllSameSign;
gradcpt_cp_max = max(gradcpt_cp,[],3);
nSubj = numel(subjects);
[maskSizePos_gradcpt,maskSizeNeg_gradcpt,Rsq_sweep_gradcpt,p_sweep_gradcpt,r_sweep_gradcpt,p_spearman_sweep_gradcpt,r_spearman_sweep_gradcpt] = ...
    SweepRosenbergThresholds(repmat(gradcpt_cp_max,[1 1 nSubj]),repmat(gradcpt_cr_min,[1 1 nSubj]),FC_fisher,fracCorrect,thresholds_gradcpt);
% [maskSizePos_gradcpt,maskSizeNeg_gradcpt,Rsq_sweep_gradcpt,p_sweep_gradcpt,r_sweep_gradcpt,p_spearman_sweep_gradcpt,r_spearman_sweep_gradcpt] = ...
%     SweepRosenbergThresholds(gradcpt_cp,gradcpt_cr,FC_fisher,fracCorrect,thresholds_gradcpt);


%% Produce figure
figure(63); clf;
set(gcf,'Position',[260   912   735   423]);
plot(maskSizePos+maskSizeNeg,r(:,4));
hold on;
xlabel('# edges included in Reading Network')
ylabel('LOSO correlation with reading comprehension')
xlim([0 1500]);
ylim([0 1]);
set(gca,'xtick',0:100:1500)
lineThresholds = [0.0001, 0.0005, 0.001, 0.005, 0.01 0.05];
for i=1:numel(lineThresholds)
    iThresh = find(thresholds==lineThresholds(i));
    plot([1 1]*(maskSizePos(iThresh)+maskSizeNeg(iThresh)), [0 r(iThresh,4)],'k--');
    plot((maskSizePos(iThresh)+maskSizeNeg(iThresh)), r(iThresh,4),'ko');
    text((maskSizePos(iThresh)+maskSizeNeg(iThresh))+5, r(iThresh,4)-.03,sprintf('p=%.1g',lineThresholds(i)));
end

figure(64); clf;
set(gcf,'Position',[1000   912   735   423]);
plot(maskSizePos_gradcpt+maskSizeNeg_gradcpt,r_sweep_gradcpt(:,4));
hold on;
xlabel('# edges included in GradCPT Network')
ylabel('Correlation with reading comprehension')
xlim([0 1500]);
ylim([0 1]);
set(gca,'xtick',0:100:1500)
lineThresholds = [0.0001, 0.0005, 0.001, 0.005, 0.01];
for i=1:numel(lineThresholds)
    iThresh = find(thresholds_gradcpt==lineThresholds(i));
    plot([1 1]*(maskSizePos_gradcpt(iThresh)+maskSizeNeg_gradcpt(iThresh)), [0 r_sweep_gradcpt(iThresh,4)],'k--');
    plot((maskSizePos_gradcpt(iThresh)+maskSizeNeg_gradcpt(iThresh)), r_sweep_gradcpt(iThresh,4),'ko');
    text((maskSizePos_gradcpt(iThresh)+maskSizeNeg_gradcpt(iThresh))+5, r_sweep_gradcpt(iThresh,4)-.03,sprintf('p=%.1g',lineThresholds(i)));
end


%% Save sweep results
save ReadingSweepResults_Fisher_spearman maskSizePos maskSizeNeg Rsq p r p_spearman r_spearman thresholds
save GradcptSweepResults_Fisher_spearman.mat maskSizePos_gradcpt maskSizeNeg_gradcpt ...
    Rsq_sweep_gradcpt p_sweep_gradcpt r_sweep_gradcpt p_spearman_sweep_gradcpt r_spearman_sweep_gradcpt thresholds_gradcpt


%% Save optimal networks
[rMax,iMax] = max(r(:,4));
fprintf('Reading network r peaks at %.3f when threshold = %.3g (%d edges)\n',rMax,thresholds(iMax),maskSizePos(iMax)+maskSizeNeg(iMax));
[rMax_grad,iMax_grad] = max(r_sweep_gradcpt(:,4));
fprintf('GradCPT network r peaks at %.3f when threshold = %.3g (%d edges)\n',rMax_grad,thresholds_gradcpt(iMax_grad),maskSizePos_gradcpt(iMax_grad)+maskSizeNeg_gradcpt(iMax_grad));

readingNetwork = (all(read_cp<thresholds(iMax),3).*all(read_cr>0,3)) - (all(read_cp<thresholds(iMax),3).*all(read_cr<0,3));
readingThreshold = thresholds(iMax);
fprintf('Reading: %d edges\n',sum(VectorizeFc(readingNetwork~=0)));
filename = sprintf('ReadingNetwork_%dedge',sum(VectorizeFc(readingNetwork~=0)));
save(filename,'readingNetwork','readingThreshold');

gradCptThreshold = thresholds_gradcpt(find((maskSizePos_gradcpt+maskSizeNeg_gradcpt)==73,1));
if isempty(gradCptThreshold)
    fprintf('Using hard-coded threshold.\n');
    gradCptThreshold = 7.92e-5;
end
gradCptNetwork = (all(gradcpt_cp<gradCptThreshold,3).*all(gradcpt_cr>0,3)) - (all(gradcpt_cp<gradCptThreshold,3).*all(gradcpt_cr<0,3));
% readingThreshold = thresholds(iMax);
fprintf('GradCPT: %d edges\n',sum(VectorizeFc(gradCptNetwork~=0)));
filename = sprintf('GradCptNetwork_%dedge',sum(VectorizeFc(gradCptNetwork~=0)));
save(filename,'gradCptNetwork','gradCptThreshold');


%% TEXT: most informative nodes
% Get Reading Network


nodesInReadingPos = sum(UpperTriToSymmetric(readingNetwork)>0);
nodesInGradCptPos = sum(UpperTriToSymmetric(gradCptNetwork)>0);
nodeOverlap = nodesInReadingPos & nodesInGradCptPos;
fprintf('---HIGH-performance:\n')
fprintf('%d nodes in both:\n',sum(nodeOverlap));
iNode = find(nodeOverlap);
[~,order] = sort(nodesInGradCptPos(iNode)+nodesInReadingPos(iNode),'descend');
for i=order%1:numel(iNode)
    fprintf('ROI %03d (%s): %d gradCpt, %d reading\n',iNode(i),shenLabelNames_hem{shenLabels_hem(iNode(i))},nodesInGradCptPos(iNode(i)),nodesInReadingPos(iNode(i)));
end

% Nodes that overlap in low-performance networks
nodesInReadingNeg = sum(UpperTriToSymmetric(readingNetwork)<0);
nodesInGradCptNeg = sum(UpperTriToSymmetric(gradCptNetwork)<0);
nodeOverlap = nodesInReadingNeg & nodesInGradCptNeg;
fprintf('---LOW-performance:\n')
fprintf('%d nodes in both:\n',sum(nodeOverlap));
iNode = find(nodeOverlap);
[~,order] = sort(nodesInGradCptNeg(iNode)+nodesInReadingNeg(iNode),'descend');
for i=order%1:numel(iNode)
    fprintf('ROI %03d (%s): %d gradCpt, %d reading\n',iNode(i),shenLabelNames_hem{shenLabels_hem(iNode(i))},nodesInGradCptNeg(iNode(i)),nodesInReadingNeg(iNode(i)));
end

% Nodes that overlap in either networks
nodesInReading = sum(UpperTriToSymmetric(readingNetwork)~=0);
nodesInGradCpt = sum(UpperTriToSymmetric(gradCptNetwork)~=0);
nodeOverlap = nodesInReading & nodesInGradCpt;
fprintf('---EITHER:\n')
fprintf('%d nodes in both:\n',sum(nodeOverlap));
iNode = find(nodeOverlap);
[~,order] = sort(nodesInGradCpt(iNode)+nodesInReading(iNode),'descend');
for i=order%1:numel(iNode)
    fprintf('ROI %03d (%s): %d gradCpt, %d reading\n',iNode(i),shenLabelNames_hem{shenLabels_hem(iNode(i))},nodesInGradCpt(iNode(i)),nodesInReading(iNode(i)));
end

%% FIGURE 5: Plot node overlap
nRois = numel(shenLabels);
% iRoi = [50 53 78 88 104 114 156 197 212 213 244];
iRoi = 47;%212; % 197; % 
% iRoi = find(shenLabels_hem==find(strcmp(shenLabelNames_hem,'L_temporal')));
% region = 'Cerebellum'; % 'Occipital';%'Temporal';%
% iRoi = find(shenLabels==find(strcmp(shenLabelNames,region)));
% iRoi = find(shenLabels_hem==find(strcmp(shenLabelNames_hem,region)));
highlow = 'either';
gradCptNetwork = UpperTriToSymmetric(gradCptNetwork);
readingNetwork = UpperTriToSymmetric(readingNetwork);
[gradCptPos_roi,readingPos_roi] = deal(zeros(nRois));
switch highlow    
    case 'high'
        gradCptPos_roi(iRoi,:) = gradCptNetwork(iRoi,:)>0;
        gradCptPos_roi(:,iRoi) = gradCptNetwork(:,iRoi)>0;
        readingPos_roi(iRoi,:) = readingNetwork(iRoi,:)>0;
        readingPos_roi(:,iRoi) = readingNetwork(:,iRoi)>0;        
    case 'low'
        gradCptPos_roi(iRoi,:) = gradCptNetwork(iRoi,:)<0;
        gradCptPos_roi(:,iRoi) = gradCptNetwork(:,iRoi)<0;
        readingPos_roi(iRoi,:) = readingNetwork(iRoi,:)<0;
        readingPos_roi(:,iRoi) = readingNetwork(:,iRoi)<0;        
    case 'either'
        gradCptPos_roi(iRoi,:) = gradCptNetwork(iRoi,:);
        gradCptPos_roi(:,iRoi) = gradCptNetwork(:,iRoi);
        readingPos_roi(iRoi,:) = readingNetwork(iRoi,:);
        readingPos_roi(:,iRoi) = readingNetwork(:,iRoi);  
end
figure(623); clf;
subplot(2,2,1);
VisualizeFcIn2d(readingPos_roi,shenAtlas,shenLabels,shenColors,[],shenInfo.Orientation,'top');
if numel(iRoi)>1
    title(sprintf('Reading Networks, %s ROIs',region));
else
    title(sprintf('Reading Networks, ROI #%d',iRoi));
end
subplot(2,2,2);
VisualizeFcIn2d(gradCptPos_roi,shenAtlas,shenLabels,shenColors,[],shenInfo.Orientation,'top');
title(sprintf('GradCPT Networks, ROI #%d',iRoi));
if numel(iRoi)>1
    title(sprintf('GradCPT Networks, %s ROIs',region));
else
    title(sprintf('GradCPT Networks, ROI #%d',iRoi));
end
subplot(2,2,3);
VisualizeFcIn2d(readingPos_roi,shenAtlas,shenLabels,shenColors,[],shenInfo.Orientation,'left');
subplot(2,2,4);
VisualizeFcIn2d(gradCptPos_roi,shenAtlas,shenLabels,shenColors,[],shenInfo.Orientation,'left');

%% FIGURE 5: Plot this ROI
networks = {readingPos_roi};%, gradCptPos_roi};
clear h
for i=1:numel(networks)
    h{i} = PlotShenFcIn3d_Conn(networks{i});
    % prep for image
    feval(h{i},'zoomout'); % zoom out one
    feval(h{i},'background',[1 1 1]); % white background
    drawnow;
    for iView = 1:numel(viewtypes)
        % switch view
        switch viewtypes{iView}
            case 'left'
                feval(h{i},'view',[-1  0 0],[],0); % left
            case 'top'
                feval(h{i},'view',[0,-.01,1],[],0); % superior
            case 'back'
                feval(h{i},'view',[0,-1,0],[],0); % posterior
        end
        % Save result to image
%         pause;
        feval(h{i},'print',1); % save image with current view
    end
end

%% Supplementary Figure 1: Motion
figure(362);
[meanMotion,meanMotion_notCensored,pctCensored,fracCorrect2] = CheckMotionAndComprehension(subjects);

%% Overwrite figure
clf;
set(gcf,'Position',[183 645 1300 690]);
subplot(2,3,1);
[p,Rsq,lm] = Run1tailedRegression(fracCorrect*100,meanMotion,false);
lm.plot();
ylabel('Mean motion (mm/TR)')
xlabel('Comprehension Accuracy (%)');
title(sprintf('Mean Motion\nr = %.3g, p = %.3g',sqrt(lm.Rsquared.Ordinary),p));
legend('Subject','Linear fit','95% confidence')
axis square

%% Supplementary Figure 1: behavior-based prediction based on page time
nSubj = numel(subjects);
[meanPageDur, stdPageDur] = deal(nan(nSubj,1));
for i=1:nSubj
    fprintf('Getting behavior for subject %d/%d...\n',i,nSubj);
    beh = load(sprintf('%s/Results/SBJ%02d/Distraction-SBJ%02d-Behavior.mat',homedir,subjects(i),subjects(i)),'data');
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
[r,p] = corr(fracCorrect,meanPageDur);
[p,Rsq,lm] = Run1tailedRegression(fracCorrect*100,meanPageDur,false);
lm.plot();
ylabel('Mean page duration (s)')
xlabel('Comprehension Accuracy (%)');
title(sprintf('Page Duration\nr = %.3g, p = %.3g',r,p));
% subplot(1,2,2);
% [p,Rsq,lm] = Run1tailedRegression(stdPageDur,fracCorrect*100,false);
% lm.plot();

%% Supplementary figure 1: ocular metrics 
% saccade/blink rate
onlyOkSamples = true;
[saccadeRate,blinkRate,sacRate_runs] = GetSaccadeRate(subjects, onlyOkSamples);
% pupil metrics
delay = 0;
[pupilDilation,pd_runs] = GetSubjectPupilDilation(subjects,delay);

% Plot
figure(362);
[r,p] = corr(fracCorrect,saccadeRate');
fprintf('fracCorrect vs. # saccades/sec: r=%.3g, p=%.3g\n',r,p);
subplot(2,3,3);
lm = fitlm(fracCorrect*100,saccadeRate,'Linear');
lm.plot;
xlabel('Comprehension Accuracy (%)');
ylabel('mean # saccades per second');
title(sprintf('saccade rate vs. reading comprehension\nr=%.3g, p=%.3g',r,p));
axis square

[r,p] = corr(fracCorrect,blinkRate');
fprintf('fracCorrect vs. # blinks/sec: r=%.3g, p=%.3g\n',r,p);
subplot(2,3,4);
lm = fitlm(fracCorrect*100,blinkRate,'Linear');
lm.plot;
xlabel('Comprehension Accuracy (%)');
ylabel('mean # blinks per second');
title(sprintf('blink rate vs. reading comprehension\nr=%.3g, p=%.3g',r,p));
axis square

[r,p] = corr(fracCorrect,pupilDilation');
fprintf('fracCorrect vs. # blinks/sec: r=%.3g, p=%.3g\n',r,p);
subplot(2,3,5);
lm = fitlm(fracCorrect*100,pupilDilation,'Linear');
lm.plot;
xlabel('Comprehension Accuracy (%)');
ylabel('mean pupil dilation');
title(sprintf('pupil dilation vs. reading comprehension\nr=%.3g, p=%.3g',r,p));
axis square

%% How many eye samples were missing?
[missingSampleRate, missingSampleRate_runs] = GetMissingEyeSampleRate(subjects);

fprintf('mean missing sample rate: %.1f%%\n',mean(missingSampleRate)*100);
%% Supplementary Figure 1: Global correlation

globalFc = nan(numel(subjects),1);
for i=1:numel(subjects)
    globalFc(i) = mean(mean(FC_fisher(:,:,i)));
end

% Plot
figure(362);% clf;
% set(gcf,'Position',[22 850 750 486]);
subplot(2,3,6);
[p,Rsq,lm] = Run1tailedRegression(fracCorrect*100,globalFc,false);
lm.plot();
ylabel('mean Fisher-normed FC across all ROI pairs')
xlabel('Comprehension Accuracy (%)');
title(sprintf('Global FC\nr = %.3g, p = %.3g',corr(globalFc(:),fracCorrect(:)*100),p));
legend('Subject','Linear fit','95% confidence')
axis square

%% Check time with sound, time with condition
[timePerCondition_all,timePerCondition_runs, conditions] = GetTimePerCondition(subjects);
nCond = size(timePerCondition_all,2);
fracPerCondition = timePerCondition_all./repmat(sum(timePerCondition_all,2),1,size(timePerCondition_all,2));
% Print
fprintf('---Correlations (2-tailed) between frac time per condition and fracCorrect:\n');
for i=1:nCond
    [r,p] = corr(fracPerCondition(:,i),fracCorrect);
    fprintf('%s: r=%.3f, p=%.3f\n',conditions{i},r,p);
end
fprintf('---Correlations (2-tailed) between total task time and fracCorrect:\n');
taskTime = sum(timePerCondition_all,2);
[r,p] = corr(taskTime,fracCorrect);
fprintf('r=%.3f, p=%.3f\n',r,p);

%% Check which lecture each person read
[readingLectures, ignoreSoundLectures,attendSoundLectures] = GetLectureNumbers(subjects);
% Get histograms
allLectures = unique(cat(1,readingLectures{:}));
nLec = nan(nSubj,numel(allLectures));
for i=1:nSubj
    nLec(i,:) = hist(readingLectures{i},allLectures);
end
figure(676); clf
plot(fracCorrect*100,read_combo,'.');
hold on;
legendstr = cell(1,numel(allLectures));
for i=1:numel(allLectures)
    isThisLec = nLec(:,i)>0;
    plot(fracCorrect(isThisLec)*100,read_combo(isThisLec)+0.01*i,'o');
    legendstr{i} = sprintf('Lecture %d',allLectures(i));
end
legend([{'Data'},legendstr]);

%% Check question difficulty
[uniqueQuizNames,pctCorrect,p,quizName] = GetQuestionDifficulty(subjects);
%% get difficulty of each subject's quizzes
quizDifficulty = 1-mean(pctCorrect,2);
subjDifficulty= nan(nSubj,1);
for i=1:numel(subjects)
    quizDiff = nan(1,size(quizName{i},2));
    for j=1:size(quizName{i},2)
        iQuiz = find(strcmp(quizName{i}{1,j},uniqueQuizNames));
        quizDiff(j) = quizDifficulty(iQuiz);
    end
    subjDifficulty(i) = mean(quizDiff);
end
fprintf('---Correlations (2-tailed) between quiz difficulty and fracCorrect:\n');
[r,p] = corr(subjDifficulty,fracCorrect);
fprintf('r=%.3f, p=%.3f\n',r,p);




%% DO PERM TESTS

rVals = struct();
fields = {'meanMotion','meanPageDur','saccadeRate','blinkRate','pupilDilation','globalFc'};
isPosExpected = [0 0 1 0 1 0];
for i=1:numel(fields)
    rVals.(fields{i}) = eval(sprintf('corr(%s(:),fracCorrect(:));',fields{i}));
end


% Get permutation versions
nPerms = 10000;
for iPerm = 1:nPerms
    if mod(iPerm,nPerms/10)==0
        fprintf('Permutation %d/%d...\n',iPerm,nPerms);
    end
    fracCorrect_perm = fracCorrect(randperm(nSubj));
    for i=1:numel(fields)
        rVals_perm.(fields{i})(iPerm) = eval(sprintf('corr(%s(:),fracCorrect_perm(:));',fields{i}));
    end
end

% Get % of perms > real
for i=1:numel(fields)
    if isPosExpected(i)
        pVals_perm.(fields{i}) = mean(rVals_perm.(fields{i})>rVals.(fields{i}));
    else
        pVals_perm.(fields{i}) = mean(rVals_perm.(fields{i})<rVals.(fields{i}));
    end
    fprintf('%s: p_perm = %.3g\n',fields{i},pVals_perm.(fields{i}));
end

%% Plot again
ylabels_cell = {'Mean motion (mm/TR)', 'Mean page duration (s)', ...
    'mean # saccades per second', 'mean # blinks per second', ...
    'mean pupil dilation', 'mean Fisher-normed FC across all ROI pairs'};
figure(363); clf;
set(gcf,'Position',[54 455 1380 740]);
for i=1:numel(fields)
    subplot(2,3,i);
    lm = eval(sprintf('fitlm(fracCorrect*100,%s(:),''Linear'');',fields{i}));
    lm.plot();
    ylabel(ylabels_cell{i})
    xlabel('Comprehension Accuracy (%)');
    title(sprintf('%s\nr = %.3g, p = %.3g',fields{i},rVals.(fields{i}),pVals_perm.(fields{i})));
    legend('Subject','Linear fit','95% confidence')
    axis square

end


%% Supplementary Figure 2: comparing various metrics

% metrics = {'-meanMotion','-blinkRate','saccadeRate','pupilDilation','-globalFc','activityScore','gradcpt_combo','dandmn_combo','read_combo','fracCorrect'};
metrics = {'-meanMotion','-blinkRate','saccadeRate','visaud_combo','pupilDilation','-globalFc','dandmn_combo','gradcpt_combo','activityScore','read_combo','fracCorrect'};
nMets = numel(metrics);
[rVals, pVals,rLower,rUpper] = deal(nan(nMets));
for i=1:nMets
    for j=1:nMets
        [rVals(i,j), pVals(i,j)] = eval(sprintf('corr(%s(:),%s(:),''tail'',''right'');',metrics{i},metrics{j}));
        [~,~,rL,rU]= eval(sprintf('corrcoef(%s(:),%s(:));',metrics{i},metrics{j}));
        rLower(i,j) = rL(1,2);
        rUpper(i,j) = rU(1,2);
    end
end
pVals = pVals.*(diag(nan(1,nMets))+1); % set diagonal p's to nan
qVals = mafdr(pVals(1:10,end),'bhfdr',true);
iOs = find(pVals(1:10,end)<0.05 & qVals>=0.05);
iStars = find(qVals<0.05);

figure(733); clf; 
set(gcf,'Position',[195   350   710   380]);
hold on;
bar(1:4,rVals(1:4,end),'g');
bar(5:8,rVals(5:8,end),'m');
bar(9:10,rVals(9:10,end),'facecolor',[1 1 1]*.5);
errorbar(1:10,rVals(1:10,end),rLower(1:10,end)-rVals(1:10,end),rUpper(1:10,end)-rVals(1:10,end),'k.');
plot(iOs,ones(size(iOs)),'ko');
plot(iStars,ones(size(iStars)),'k*');
set(gca,'xtick',1:nMets-1,'xticklabel',show_symbols(metrics(1:end-1)));
xticklabel_rotate;
ylabel('correlation with Reading Comp.');
legend('Control Metrics','Sustained Attention Metrics','Reading Metric','95% CI','p<0.05','q<0.05','Location','SouthEast');

%%
qVals = reshape(mafdr(pVals(:),'bhfdr',true),size(pVals));
figure(734); clf;
set(gcf,'Position',[195  614 1567 620]);
subplot(1,3,1); hold on;
imagesc(rVals)
colorbar
xlim([0 nMets]+0.5);
ylim([0 nMets]+0.5);
set(gca,'clim',[0 1]);
set(gca,'ytick',1:nMets,'yticklabel',show_symbols(metrics));
set(gca,'xtick',1:nMets,'xticklabel',show_symbols(metrics));
xticklabel_rotate
title('correlation of metrics across subjects');
axis square
% Add stars
[iOs,jOs] = find(pVals<0.05 & qVals>=0.05);
plot(jOs,iOs,'ko');
[iStars,jStars] = find(qVals<0.05);
plot(jStars,iStars,'k*');
set(gca,'ydir','reverse');

% Project out one
[rVals_proj, p_proj] = deal(nan(nMets-1));
for i=1:nMets-1
    for j=1:nMets-1
        % project out
        a = eval(sprintf('normalise(%s(:)-mean(%s));',metrics{i},metrics{i}));
        b = eval(sprintf('normalise(%s(:)-mean(%s));',metrics{j},metrics{j}));
        proj = (a'*b)/(b'*b)*b;
        projout = a-proj;
        [rVals_proj(i,j+1),p_proj(i,j+1)] = corr(projout(:),fracCorrect(:),'tail','right');
    end
    [rVals_proj(i,1),p_proj(i,1)] = eval(sprintf('corr(%s(:),fracCorrect(:),''tail'',''right'');',metrics{i}));    
end
q_proj = reshape(mafdr(p_proj(:),'bhfdr',true),size(p_proj));
subplot(1,3,2); hold on;
imagesc(rVals_proj)
colorbar
set(gca,'clim',[0 1]);
set(gca,'ytick',1:nMets-1,'yticklabel',show_symbols(metrics(1:end-1)));
set(gca,'xtick',1:nMets,'xticklabel',show_symbols([{'none'}, metrics(1:end-1)]));
xlabel('Metric X')
ylabel('Metric Y');
xlim([0 nMets]+0.5);
ylim([0 nMets-1]+0.5);
title(sprintf('correlation of metric Y with fracCorrect\n after regressing out metric X'));
xticklabel_rotate
axis square
% Add stars
[iOs,jOs] = find(p_proj<0.05 & q_proj>=0.05);
plot(jOs,iOs,'ko');
[iStars,jStars] = find(q_proj<0.05);
plot(jStars,iStars,'k*');
set(gca,'ydir','reverse');

% convert to % remaining variance explained
subplot(1,3,3);
pctVarEx_proj = nan(size(rVals_proj));
for i=1:nMets-1
    fracLeft = 1-rVals_proj(i,1)^2;
    fracExplained = rVals_proj(:,i+1).^2;
    pctVarEx_proj(:,i+1) = fracExplained/fracLeft*100;
end
pctVarEx_proj(:,1) = rVals_proj(:,1).^2*100;

imagesc(pctVarEx_proj)
colorbar
set(gca,'clim',[0 100]);
set(gca,'ytick',1:nMets-1,'yticklabel',show_symbols(metrics(1:end-1)));
set(gca,'xtick',1:nMets,'xticklabel',show_symbols([{'none'}, metrics(1:end-1)]));
xlabel('Metric X')
ylabel('Metric Y');
title(sprintf('%% variance of fracCorrect explained by\n metric Y after regressing out metric X'));
xticklabel_rotate
axis square
colormap jet

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




%% SUPPLEMENTARY FIG 3: Use mean activation in each ROI to predict behavior
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
%% Use to predict behavior
thresh = 1;
[activityScore,networks_activ,cp_activ,cr_activ] = RunLeaveOneOutRegressionWithActivity(meanInRoi_subj,fracCorrect,thresh);
% Plot results
isPosExpected = true;
[p,Rsq,lm] = Run1tailedRegression(fracCorrect*100,activityScore,isPosExpected);
% r = sqrt(lm.Rsquared.Ordinary);
r = corr(fracCorrect*100,activityScore);
fprintf('%s activity, thresh %d: r = %.3g, p = %.3g\n',goodLabels{1},thresh,r,p);

%% Sweep threshold and check performance
thresholds = 0.01:0.01:1;
[maskSizePos_act,maskSizeNeg_act,Rsq_act,p_act,r_act,p_spearman_act,r_spearman_act] = SweepRosenbergThresholds_activity(cp_activ,cr_activ,meanInRoi_subj,fracCorrect,thresholds,false);
%% Plot
figure(253); clf;
% Plot mask sizes
subplot(2,2,1);
plot(thresholds,[maskSizePos_act,maskSizeNeg_act]);
xlabel('threshold');
ylabel('mask size');
legend('high-attention','low-attention');
% Plot prediction accuracy
subplot(2,2,2);
h = plotyy(thresholds,Rsq_act(:,4),thresholds,p_act(:,4));
xlabel('threshold');
ylabel(h(1),'R^2');
ylabel(h(2),'p');
% Plot size vs. accuracy
subplot(2,1,2);
plot(maskSizePos_act+maskSizeNeg_act,r_act(:,4));
hold on;
xlabel('# edges included in Reading Activity Network')
ylabel('LOSO correlation with reading comprehension')
% xlim([0 268]);
ylim([0 1]);
% set(gca,'xtick',0:100:268)
lineThresholds = [0.01 0.05 0.1 0.5 1];
for i=1:numel(lineThresholds)
    iThresh = find(abs(thresholds-lineThresholds(i))<eps);
    plot([1 1]*(maskSizePos_act(iThresh)+maskSizeNeg_act(iThresh)), [0 r_act(iThresh,4)],'k--');
    plot((maskSizePos_act(iThresh)+maskSizeNeg_act(iThresh)), r_act(iThresh,4),'ko');
    text((maskSizePos_act(iThresh)+maskSizeNeg_act(iThresh))+5, r_act(iThresh,4)-.03,sprintf('p=%.1g',lineThresholds(i)));
end

%% Alternate Figure S3: Show regions at chosen threshold
thresh = 1;%0.15;
iThresh = find(thresholds==thresh);
isPos = all(cp_activ<thresh,2) & all(cr_activ>0,2);
isNeg = all(cp_activ<thresh,2) & all(cr_activ<0,2);
% See output
GUI_3View(MapColorsOntoAtlas(shenAtlas,cat(2,isPos,ones(size(isPos)),isNeg)));
% Save output as AFNI Brik
BrickToWrite = MapValuesOntoAtlas(shenAtlas,isPos-isNeg);
Opt = struct('Prefix',sprintf('Reading_activ_isPos-isNeg_thresh0p%d+tlrc',thresh*100));
WriteBrik(BrickToWrite,shenInfo,Opt);


%% Alternate Figure S3: Regions contributing to activity score

% set up
meanCr = mean(cr_activ,2);
nReg = numel(shenLabelNames_hem);

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


%% Fig 5 or Supplementary? Most-participating regions 
networkNames = {'Reading','GradCPT'};
nReg = numel(shenLabelNames_hem);
figure(449); clf;
set(gcf,'Position',[183 904 1503 800]);
nInRegion = hist(shenLabels_hem,1:nReg);
nEdges = nRois*(nRois-1); % include each edge twice!
for iNet=1:numel(networkNames)
    networkName = networkNames{iNet};
    switch lower(networkName)
        case 'reading'
            fooPos = GroupFcByRegion(readingNetwork>0,shenLabels_hem,'sum',true);
            fooNeg = GroupFcByRegion(readingNetwork<0,shenLabels_hem,'sum',true);
        case 'gradcpt'
            fooPos = GroupFcByRegion(gradCptNetwork>0,shenLabels_hem,'sum',true);
            fooNeg = GroupFcByRegion(gradCptNetwork<0,shenLabels_hem,'sum',true);
    end
    nPos = sum(fooPos,1);
    nNeg = sum(fooNeg,1);
    subplot(numel(networkNames),1,iNet); hold on;
    % Plot number we'd expect by chance given number of cxns
    nPosByChance = nInRegion'*(nRois-1)*sum(fooPos(:))/nEdges;
    nNegByChance = nInRegion'*(nRois-1)*sum(fooNeg(:))/nEdges;
    bar(1:nReg,nPosByChance,1,'FaceColor',[1 1 1]*.5,'EdgeColor','none');
    bar(1:nReg,-nNegByChance,1,'FaceColor',[1 1 1]*.5,'EdgeColor','none');
%     patch([1:nReg, nReg:-1:1],[nPosByChance',-nNegByChance(end:-1:1)'],[1 1 1]*.5);
%     plot(nPosByChance,'k.-');
%     plot(-nNegByChance,'k.-');
    
    % Plot number we actually got
    for i=1:nReg
        hBar = bar(i,nPos(i),'FaceColor',shenColors_hem(i,:));
        hBar = bar(i,-nNeg(i),'FaceColor',shenColors_hem(i,:));
    end

    % Calculate chance of getting this many in a region by chance
    [pPosByChance,pNegByChance] = deal(nan(1,nReg));
    for i=1:nReg
        pPosByChance(i) = binocdf(nPos(i), nInRegion(i)*nRois-1, sum(nPos)/nEdges);
        pNegByChance(i) = binocdf(nNeg(i), nInRegion(i)*nRois-1, sum(nPos)/nEdges);
    end
    try
        qPosByChance = 1-mafdr(1-pPosByChance,'bhfdr','true');
        qNegByChance = 1-mafdr(1-pNegByChance,'bhfdr','true');

        % Plot Stars
        iStarsPos = find(qPosByChance>0.95);
        plot(iStarsPos,nPos(iStarsPos)+5,'k*');
        iStarsNeg = find(qNegByChance>0.95);
        plot(iStarsNeg,-nNeg(iStarsNeg)-5,'k*');
        % Sort and print
        nCxns = sum(fooPos)+sum(fooNeg);
        [~,order] = sort(nCxns,'descend');
        fprintf('---%s Networks: Most informative Areas---\n',networkName);
        for i=1:nReg
            fprintf('%s: %d cxns (%d +, %d -)\n',shenLabelNames_hem{order(i)},...
                nCxns(order(i)),sum(fooPos(order(i),:)),sum(fooNeg(order(i),:)));
        end
    end
    
    % Annotate Plot
    PlotHorizontalLines(0,'k');
    title(sprintf('%s Networks',networkName));
    xlim([0 nReg+1]);
    ylim([-30 30]);
    ylabel(sprintf('ROI pairs in high-performance network\n - low-performance network'))
    set(gca,'xtick',1:nReg,'xticklabel',show_symbols(shenLabelNames_hem));
    xticklabel_rotate;
end

%% Same broken down by hemisphere
shenLabels_LorR = (mod(shenLabels_hem,2)==0)+1;
fooPos = GroupFcByRegion(readingNetwork>0,shenLabels_LorR,'sum',true);
fooNeg = GroupFcByRegion(readingNetwork<0,shenLabels_LorR,'sum',true);
% print results
fprintf('---Reading High-Performance---\n')
fprintf('L-L: %d\n',fooPos(1,1)/2);
fprintf('R-R: %d\n',fooPos(2,2)/2);
fprintf('L-R: %d\n',(fooPos(1,2)+fooPos(2,1))/2);

fprintf('---Reading Low-Performance---\n')
fprintf('L-L: %d\n',fooNeg(1,1)/2);
fprintf('R-R: %d\n',fooNeg(2,2)/2);
fprintf('L-R: %d\n',(fooNeg(1,2)+fooNeg(2,1))/2);

fooPos = GroupFcByRegion(gradCptNetwork>0,shenLabels_LorR,'sum',true);
fooNeg = GroupFcByRegion(gradCptNetwork<0,shenLabels_LorR,'sum',true);
% print results
fprintf('---GradCPT High-Attention---\n')
fprintf('L-L: %d\n',fooPos(1,1)/2);
fprintf('R-R: %d\n',fooPos(2,2)/2);
fprintf('L-R: %d\n',(fooPos(1,2)+fooPos(2,1))/2);

fprintf('---GradCPT Low-Attention---\n')
fprintf('L-L: %d\n',fooNeg(1,1)/2);
fprintf('R-R: %d\n',fooNeg(2,2)/2);
fprintf('L-R: %d\n',(fooNeg(1,2)+fooNeg(2,1))/2);


%% Plot # ROIs in each region
clf; hold on;
for i=1:nReg
    hBar = bar(i,sum(shenLabels_hem==i),'FaceColor',shenColors_hem(i,:));
end
xlim([0 nReg+1]);
ylabel(sprintf('# ROIs in region'))
set(gca,'xtick',1:nReg,'xticklabel',show_symbols(shenLabelNames_hem));
xticklabel_rotate;

%% View Participation of each ROI in +/- Network
networkType = 'Reading';
switch lower(networkType)
    case 'reading'
        nInPos = sum(readingNetwork>0,2);
        nInNeg = sum(readingNetwork<0,2);
    case 'gradcpt'
        nInPos = sum(gradCptNetwork>0,2);
        nInNeg = sum(gradCptNetwork<0,2);
end
nMax = 3;%max([nInPos;nInNeg]);
% GUI_3View(MapColorsOntoAtlas(shenAtlas,[nInPos/nMax,zeros(nRois,1),nInNeg/nMax]));
% Save
BrickToWrite = MapValuesOntoAtlas(shenAtlas,nInPos);
Opt = struct('Prefix',sprintf('%s_nCxns-pos+tlrc',networkType));
WriteBrik(BrickToWrite,shenInfo,Opt);
BrickToWrite = MapValuesOntoAtlas(shenAtlas,nInNeg);
Opt = struct('Prefix',sprintf('%s_nCxns-neg+tlrc',networkType));
WriteBrik(BrickToWrite,shenInfo,Opt);

%% Write Shen Macroscale Regions to AFNI brick
BrickToWrite = MapValuesOntoAtlas(shenAtlas,shenLabels_hem);
Opt = struct('Prefix','ShenMacroscaleRegions+tlrc');
WriteBrik(BrickToWrite,shenInfo,Opt);

%% Produce plots of FC correlations to behavior (as in Baldassarre 2012)
figure(733); clf;
subplot(1,2,1);
% Threshold FC matrix using permutations?
% Plot FC matrix
PlotFcMatrix(mean(FC_fisher,3),[-1 1]*1,shenAtlas,shenLabels_hem,true,shenColors_hem,false);

% Correlate FC matrix with behavior
FC_vec = VectorizeFc(FC_fisher);
[cr_all,cp_all] = corr(FC_vec',fracCorrect);

%% PERM TEST
nPerms = 10000;
cr_all_perms = nan(size(cr_all,1),nPerms);
fprintf('Running %d permutation tests...\n',nPerms)
for i=1:nPerms
    if mod(i,nPerms/10)==0
        fprintf('%d%% done...\n',i/nPerms*100)
    end
    cr_all_perms(:,i) = corr(FC_vec',fracCorrect(randperm(nSubj)));
end
fprintf('Done!\n');
%% Get permutation-based p values
cp_all_permbased = nan(size(cr_all));
for i=1:size(cr_all,1)
    cp_all_permbased(i) = mean(abs(cr_all(i))<abs(cr_all_perms(i,:)));
end
% FDR-correct
cp_all_fdr = mafdr(cp_all_permbased,'bhfdr',true);
% threshold
cr_all_thresh = cr_all;
cr_all_thresh(cp_all_fdr>0.05) = 0;
cr_all_thresh = UnvectorizeFc(cr_all_thresh,0,true);
% Plot FC matrix
subplot(1,2,2);
PlotFcMatrix(cr_all_thresh,[-1 1]*1,shenAtlas,shenLabels_hem,true,shenColors_hem,false);

%% Save results
save ReadingPermTests_allcorr_Fisher.mat cr_all cp_all cp_all_permbased cp_all_fdr cr_all_thresh

%% Plot in 3D
h = PlotShenFcIn3d_Conn(sign(cr_all_thresh));
% prep for image
feval(h,'zoomout'); % zoom out one
feval(h,'background',[1 1 1]); % white background
drawnow;
for iView = 1:numel(viewtypes)
    % switch view
    switch viewtypes{iView}
        case 'left'
            feval(h,'view',[-1 0 0],[],0); % left
        case 'top'
            feval(h,'view',[0,-.01,1],[],0); % superior
        case 'back'
            feval(h,'view',[0,-1,0],[],0); % posterior
    end
    % Save result to image
    feval(h,'print',1); % save image with current view
end

%% Plot regions involved
isInPos = any(cr_all_thresh>0,2);
isInNeg = any(cr_all_thresh<0,2);
GUI_3View(MapColorsOntoAtlas(shenAtlas,cat(2,isInPos,ones(size(isInPos)),isInNeg)));
BrickToWrite = MapValuesOntoAtlas(shenAtlas,(isInNeg&~isInPos) + 2*(isInNeg&isInPos) + 3*(~isInNeg&isInPos));
Opt = struct('Prefix',sprintf('Reading_allcorr_q05_negbothpos+tlrc'));
WriteBrik(BrickToWrite,shenInfo,Opt);

%% Plot regions in Vis/Aud Network
isInPos = any(VisAudNetwork>0,2);
isInNeg = any(VisAudNetwork<0,2);
% GUI_3View(MapColorsOntoAtlas(shenAtlas,cat(2,isInPos,ones(size(isInPos)),isInNeg)));
% BrickToWrite = MapValuesOntoAtlas(shenAtlas,(isInNeg&isInPos) + 2*(isInNeg&~isInPos) + 3*(~isInNeg&isInPos));
% Opt = struct('Prefix',sprintf('VisAud_match15_bothnegpos+tlrc'));
% WriteBrik(BrickToWrite,shenInfo,Opt);
BrickToWrite = MapValuesOntoAtlas(shenAtlas,(isInNeg&~isInPos) + 2*(isInNeg&isInPos) + 3*(~isInNeg&isInPos));
Opt = struct('Prefix',sprintf('VisAud_match15_negbothpos+tlrc'));
WriteBrik(BrickToWrite,shenInfo,Opt);

%% Print # of runs across ALL subjects
nRuns = nan(1,numel(vars.subjects));
for i=1:numel(vars.subjects)
    fprintf('Loading subject %d/%d...\n',i,numel(vars.subjects));
    load(sprintf('%s/Results/SBJ%02d/Distraction-SBJ%02d-Behavior.mat',vars.homedir,vars.subjects(i),vars.subjects(i)));
    nRuns(i) = length(data);
end
fprintf('mean nRuns across %d subjects = %.3f\n',numel(nRuns),mean(nRuns));

%% ================================== %%
%% ==== FOR NEUROIMAGE REVIEWERS ==== %%
%% ================================== %%

%% Produce Figure S4 (mean FC during reading task)
atlasFile = '/Users/jangrawdc/Documents/PRJ03_SustainedAttention/Shen_2013_parcellations/shen_1mm_268_parcellation+tlrc';
[shenAtlas,shenInfo] = BrikLoad(atlasFile);
[shenLabels_hem,shenLabelNames_hem,shenColors_hem] = GetAttnNetLabels(true);
figure(154); clf;
PlotFcMatrix(mean(FC,3),[-1 1],shenAtlas,shenLabels_hem,true,shenColors_hem);
hVert = PlotVerticalLines(find(diff(shenLabels_hem)>0),'k:');
hHoriz = PlotHorizontalLines(find(diff(shenLabels_hem)>0),'k:');

%% Get range & median chars/line
GetVisualsMedianAndRange(); % must be run on local machine!

%% Get range & median of behavior
vars = GetDistractionVariables;
fprintf('=== all subjects (n=%d):\n',numel(vars.subjects));
GetMedianAndRangeOfBehavior(vars.subjects);
fprintf('=== final cohort (n=%d):\n',numel(vars.oksubjects));
GetMedianAndRangeOfBehavior(vars.okSubjects);

%% Use permutation test results to compare predictive abilities
load('ReadingFcAndFracCorrect_19subj_Fisher_2017-05-17.mat');
% set up permutation tests
nPerms = 10000;
nSubj = numel(fracCorrect);
fprintf('getting randomized behavior...\n');
permBeh = nan(nSubj,nPerms);
for i=1:nPerms
    permBeh(:,i) = fracCorrect(randperm(nSubj)');
end
save BehaviorPermutations_2017-08-30 permBeh

%% Run permutations for reading
load('BehaviorPermutations_2017-08-30.mat');
[readperm_pos,readperm_neg,readperm_combo] = deal(nan(nSubj,nPerms));
corr_method = 'corr';
mask_method = 'one';
thresh = 0.01;
tic;
for i=1:nPerms
    if mod(i,100)==0
        fprintf('i=%d/%d (%.1f seconds)...\n',i,nPerms,toc);
    end
    % randomize behavior
    beh = permBeh(:,i);
    % Get reading predictions
    [readperm_pos(:,i), readperm_neg(:,i), readperm_combo(:,i)] = ...
        RunLeave1outBehaviorRegression(FC_fisher,beh,thresh,corr_method,mask_method);
end
fprintf('Done! Took %.1f seconds.\n',toc);
% save results
fprintf('Saving results...\n')
save('ReadingPermPredictions_2017-08-30.mat','readperm_pos','readperm_neg','readperm_combo');
fprintf('Done!\n');

%% Get scores from each metric
load('BehaviorPermutations_2017-08-30.mat');
load('ReadingFcAndFracCorrect_19subj_Fisher_2017-05-17.mat');

% Get static predictions from externally trained networks
score_combo = table();
% - GradCPT
attnNets = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/attn_nets_268.mat');
nets = attnNets.pos_overlap-attnNets.neg_overlap;
[~,~,score_this] = GetFcMaskMatch(FC_fisher,nets>0,nets<0);
score_combo.gradcpt = score_this(:);
% - Vis/Aud Language
load('VisAudNetwork_match15.mat');
nets = VisAudNetwork;
[~,~,score_this] = GetFcMaskMatch(FC_fisher,nets>0,nets<0);
score_combo.visaud = score_this(:);
% - DAN/DMN
load('DanDmnNetwork_match15.mat');
nets = DanDmnNetwork;
[~,~,score_this] = GetFcMaskMatch(FC_fisher,nets>0,nets<0);
score_combo.dandmn = score_this(:);
% Others
otherMetrics = load('ControlMetrics_2017-08-31.mat');
metrics = {'-meanMotion','meanPageDur','saccadeRate','-blinkRate','pupilDilation','-globalFc'};
for i=1:numel(metrics)
    if metrics{i}(1)=='-' % negative correlation expected
        thisMetric = metrics{i}(2:end);
        score_combo.(['minus_' thisMetric]) = -otherMetrics.(thisMetric)(:);
    else
        score_combo.(metrics{i}) = otherMetrics.(metrics{i})(:);
    end
end

% add to table
readScores = load('ReadingNetworkScores_p01_Fisher.mat');
score_combo.reading = readScores.read_combo;
readPerms = load('ReadingPermPredictions_2017-08-30.mat');
score_combo.read_perm = readPerms.readperm_combo;
% save results
save('AllMetricScores_2017-08-31.mat','score_combo');

%% Compare resulting permuted predictions
metrics = score_combo.Properties.VariableNames;
nMetrics = numel(metrics);
zPerm = nan(nMetrics,nMetrics,nPerms);
pPerm = nan(nMetrics,nMetrics,nPerms);
readPerms = load('ReadingPermPredictions_2017-08-30.mat');
for i=1:nPerms
    if mod(i,100)==0
        fprintf('i=%d/%d...\n',i,nPerms);
    end
    % randomize behavior
    beh = permBeh(:,i);
    % get reading predictions from this run
    score_combo.read_perm = readPerms.readperm_combo(:,i);
    % compare predictions from each metric 
    for j=1:nMetrics
        for k=1:nMetrics
            % get z test
            [zPerm(j,k,i),pPerm(j,k,i)] = SteigersZTest(score_combo.(metrics{j}),score_combo.(metrics{k}),beh);
        end
    end
end
fprintf('Done!\n');
% Save perm results
save('SteigerZ_perm_2017-08-31.mat','zPerm','pPerm','metrics');

%% Calculate z scores with True behavior
load('AllMetricScores_2017-08-31.mat'); % score_combo
load('SteigerZ_perm_2017-08-31.mat'); % zPerm,pPerm,metrics
load('ReadingFcAndFracCorrect_19subj_Fisher_2017-05-17.mat','fracCorrect');
nMetrics = numel(metrics);
[zTrue,pTrue, pTrue_perm] = deal(nan(nMetrics-1));
for j=1:nMetrics-1
    for k=1:nMetrics-1
        % get z test
        [zTrue(j,k),pTrue(j,k)] = SteigersZTest(score_combo.(metrics{j}),score_combo.(metrics{k}),fracCorrect);
        if j==nMetrics-1 % reading: compare to read_perm permutation z's
            pTrue_perm(j,k) = mean(zTrue(j,k)<squeeze(zPerm(nMetrics,k,:)));
        elseif k==nMetrics-1 % reading: compare to read_perm permutation z's
            pTrue_perm(j,k) = mean(zTrue(j,k)<squeeze(zPerm(j,nMetrics,:)));
        else
            pTrue_perm(j,k) = mean(zTrue(j,k)<squeeze(zPerm(j,k,:)));
        end
        fprintf('%s>%s: p_perm=%.3g\n',metrics{j},metrics{k},pTrue_perm(j,k));
    end
end

% Plot comparisons to perm resutls
% figure(624); clf;
% for j=1:nMetrics
%     for k=1:nMetrics
%         iPlot = (j-1)*nMetrics+k;
%         subplot(nMetrics,nMetrics,iPlot);
%         hold on;
%         hist(squeeze(zPerm(j,k,:)))
%         PlotVerticalLines(zTrue(j,k),'r--');
%         if j==1
%             title(sprintf('%s\np=%.3g\np_{perm}=%.3g',metrics{k},pTrue(j,k),pTrue_perm(j,k)));
%         else
%             title(sprintf('p=%.3g\n p_{perm}=%.3g',pTrue(j,k),pTrue_perm(j,k)));
%         end
%         if k==1
%             ylabel(metrics{j});
%         end
%     end
% end

% Plot p values as matrix
figure(625); clf;
imagesc(zTrue); hold on;
[jStar,kStar] = find(pTrue_perm>0.95);
plot(jStar,kStar,'c*');
[jStar,kStar] = find(pTrue_perm<0.05);
plot(jStar,kStar,'r*');
set(gca,'xtick',1:nMetrics,'xticklabel',show_symbols(metrics),'ytick',1:nMetrics','yticklabel',show_symbols(metrics));
colorbar;
legend('row outperforms column','column outperforms row');
title('Steiger Z scores comparing across metrics');