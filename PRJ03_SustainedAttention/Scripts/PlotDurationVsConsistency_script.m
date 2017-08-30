% PlotDurationVsConsistency_script.m
%
% Created 6/6/17 by DJ.

subjects = [9:11 13:19 22 24:25 28 30:33 36];

afniProcFolder = 'AfniProc_MultiEcho_2016-09-22'; % 9-22 = MNI
tsFilePrefix = 'shen268_withSegTc'; % 'withSegTc' means with BPFs
% runComboMethod = 'avgRead'; % average of run-wise FC, limited to reading samples
lengths = 45:45:405;
part2_start = 406;
doPlot = false;
TR = 2;

%% Get FC
[FC,FC_part2,roiTcCropped] = GetFc_VaryLength(subjects,afniProcFolder,tsFilePrefix,lengths,part2_start);
FC_fisher = atanh(FC);
FC_part2_fisher = atanh(FC_part2);
for k=1:size(FC_fisher,4)
    FC_fisher(:,:,:,k) = UnvectorizeFc(VectorizeFc(FC_fisher(:,:,:,k)),0,true);
    FC_part2_fisher(:,:,:,k) = UnvectorizeFc(VectorizeFc(FC_part2_fisher(:,:,:,k)),0,true);
end
%% Get long-run FC
FC_long = GetFc_AllSubjects(subjects,afniProcFolder,tsFilePrefix,'catRuns');
FC_long_fisher = atanh(FC_long);
FC_long_fisher = UnvectorizeFc(VectorizeFc(FC_long_fisher),0,true);

%% Get performance
[fracCorrect, RT] = GetFracCorrect_AllSubjects(subjects);

%% Plot session lengths
nTr = nan(1,numel(subjects));
for i=1:numel(subjects)
    nTr(i) = size(roiTcCropped{i},1);
end
figure(152);
set(gcf,'Position',[1000 1059 391 276]);
hist(nTr*2/60)
xlabel('Session length after censoring (min)');
ylabel('# subjects');


%% Measure pairwise stability
[FcCorr_2part, FcCorr_long] = deal(nan(numel(subjects),numel(lengths)));
for i=1:numel(subjects)
    for j=1:numel(lengths)
        FcCorr_2part(i,j) = corr(VectorizeFc(FC_fisher(:,:,i,j)),VectorizeFc(FC_part2_fisher(:,:,i,j)));
        FcCorr_long(i,j) = corr(VectorizeFc(FC_fisher(:,:,i,j)),VectorizeFc(FC_long_fisher(:,:,i)));
    end
end
nEdges = size(VectorizeFc(FC_fisher(:,:,1,1)),1);
[FcIcc_2part, FcIcc_long] = deal(nan(nEdges,numel(lengths)));
Fc_long_vec = VectorizeFc(FC_long_fisher(:,:,:));
normByN = 1; % 0: var will norm by N-1
for j=1:numel(lengths)
    fprintf('length %d/%d...\n',j,numel(lengths));
    Fc1_vec = VectorizeFc(FC_fisher(:,:,:,j));
    Fc2_vec = VectorizeFc(FC_part2_fisher(:,:,:,j));    
    for i=1:size(Fc1_vec,1)
        MSb = mean(var([Fc1_vec(i,:); Fc2_vec(i,:)],normByN,2)); % between-subject variance
        MSw = mean(var([Fc1_vec(i,:); Fc2_vec(i,:)],normByN,1)); % within-subject variance

        FcIcc_2part(i,j) = (MSb-MSw)/(MSb+MSw);
        MSb = mean(var([Fc1_vec(i,:); Fc_long_vec(i,:)],normByN,2)); % between-subject variance
        MSw = mean(var([Fc1_vec(i,:); Fc_long_vec(i,:)],normByN,1)); % within-subject variance
        FcIcc_long(i,j) = (MSb-MSw)/(MSb+MSw);
    end
end
fprintf('Done!\n');


%% Plot stability metrics
figure(62); clf; 
subplot(2,2,1); hold on;
bar(lengths*TR/60, mean(FcCorr_2part));
errorbar(lengths*TR/60, mean(FcCorr_2part,1),std(FcCorr_2part),'k.');
xlabel('scan length (min)');
ylabel('1st-vs-2nd half correlation of FC');
ylim([0 1])
set(gca,'xtick',lengths*TR/60);
grid on
subplot(2,2,2); hold on;
bar(lengths*TR/60, mean(FcCorr_long));
errorbar(lengths*TR/60, mean(FcCorr_long,1),std(FcCorr_long),'k.');
xlabel('scan length (min)');
ylabel('Correlation with full dataset FC');
grid on
ylim([0 1])
set(gca,'xtick',lengths*TR/60);

subplot(2,2,3); hold on;
bar(lengths*TR/60, mean(FcIcc_2part));
errorbar(lengths*TR/60, mean(FcIcc_2part,1),std(FcIcc_2part),'k.');
xlabel('scan length (min)');
ylabel('ICC (1st-vs-2nd half)');
ylim([0 1])
set(gca,'xtick',lengths*TR/60);
grid on
subplot(2,2,4); hold on;
bar(lengths*TR/60, mean(FcIcc_long));
errorbar(lengths*TR/60, mean(FcIcc_long,1),std(FcIcc_long),'k.');
xlabel('scan length (min)');
ylabel('ICC (with full dataset)');
ylim([0 1])
set(gca,'xtick',lengths*TR/60);
grid on

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

%% Get Reading Network and predictions
thresh = 0.01;
corr_method = 'robustfit';
mask_method = 'one';
[read_pos, read_neg, read_combo,read_posMask_all,read_negMask_all] = RunLeave1outBehaviorRegression(FC_fisher,fracCorrect,thresh,corr_method,mask_method);
fprintf('Done!\n');
% save ReadingNetworkScores_p01_Fisher read_pos read_neg read_combo subjects