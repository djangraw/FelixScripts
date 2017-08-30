% SaveNetworkMasks.m
% 
% Created 1/10/17 by DJ.


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
[shenAtlas,shenInfo] = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_2mm_268_parcellation.nii.gz');
attnNets = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/attn_nets_268.mat');
[shenLabels,shenLabelNames,shenColors] = GetAttnNetLabels(false);
[shenLabels_hem,shenLabelNames_hem,shenColors_hem] = GetAttnNetLabels(true);
invorder = reshape([11:20;1:10],20,1);
order = nan(size(invorder));
for i=1:numel(invorder), order(i) = find(invorder==i); end
shenLabels_hem = order(shenLabels_hem);
shenLabelNames_hem = shenLabelNames_hem(invorder);
shenColors_hem = shenColors_hem(invorder,:);
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

[dandmn_pos,dandmn_neg,dandmn_combo] = GetFcMaskMatch(FC,DanDmnNetwork>0,DanDmnNetwork<0);

%% Get masks
read_posMask = all(read_posMask_all>0,3);
read_negMask = all(read_negMask_all>0,3);
gradcpt_posMask = attnNets.pos_overlap;
gradcpt_negMask = attnNets.neg_overlap;
dandmn_posMask = DanDmnNetwork>0;
dandmn_negMask = DanDmnNetwork<0;

%% Save results
cd /data/jangrawdc/PRJ03_SustainedAttention/Results
save Distraction-Rosenberg_AllMasks read_posMask read_negMask gradcpt_posMask gradcpt_negMask dandmn_posMask dandmn_negMask