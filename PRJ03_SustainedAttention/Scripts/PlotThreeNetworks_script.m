% PlotThreeNetworks_script.m
%
% Created 2/17/17 by DJ.

%% Get NeuroSynth Network
% posFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth/NeuroSynth_dorsalattention_pAgF_z_FDR_0.01_EpiRes_MNI+tlrc';
% negFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth/NeuroSynth_defaultmode_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc';
% posFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth/NeuroSynth_v4-topics-100_87_sentences_language_comprehension_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc';
% posFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth/NeuroSynth_visualword_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc';
posFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth/NeuroSynth_reading_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc';
negFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/NeuroSynth/NeuroSynth_speechperception_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc';
atlasFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/MNI_EPIres_shen_1mm_268_parcellation+tlrc';
posMaskThreshold = 0;
negMaskThreshold = 0;
posMatchThreshold = 0.23;%0.15;
negMatchThreshold = 0.06;%0.15;
readingSpeechNetwork = GetNeurosynthNetworks(posFilename,negFilename,atlasFilename,posMaskThreshold,negMaskThreshold,posMatchThreshold,negMatchThreshold);

%% Get predictions
[readspeech_pos,readspeech_neg,readspeech_combo] = GetFcMaskMatch(FC,readingSpeechNetwork>0,readingSpeechNetwork<0);
[readspeech_pos,readspeech_neg,readspeech_combo] = deal(readspeech_pos',readspeech_neg',readspeech_combo');

%% FIGURE 2: 
% Compare predictions across tasks

% Set up
figure(277); clf;
set(gcf,'Position',[159         122        1660        1165]);
% set(gcf,'Position',[159         122        1660        435]);
networks = {'gradcpt','readspeech','read'};
networkNames = {'gradCPT','Reading/Speech','Reading'};
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
        r = sqrt(lm.Rsquared.Ordinary);
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

%%
read_comboMask = all(read_posMask_all>0,3)-all(read_negMask_all>0,3);
clim = [75 30 18];

figure(278); clf;
set(gcf,'Position',[62 722 1731 613]);
subplot(131);
[~,~,~,~,hRect] = PlotFcMatrix(attnNets.pos_overlap-attnNets.neg_overlap,[-1 1]*clim(1),shenAtlas,shenLabels_hem,true,shenColors_hem,'sum');
title('GradCpt Networks')
delete(hRect);
subplot(132);
[~,~,~,~,hRect] = PlotFcMatrix(readingSpeechNetwork,[-1 1]*clim(2),shenAtlas,shenLabels_hem,true,shenColors_hem,'sum');
title('Read/Speech Networks')
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