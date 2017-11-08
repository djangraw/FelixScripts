% CombineNetworkEdgesToPredict_sfn_script.m
%
% Created 11/2/17 by DJ.

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
GradCptNetwork = attnNets.pos_overlap-attnNets.neg_overlap;

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

%% Combine all three
nSubj = size(FC_fisher,3);
allEdgeScore = nan(nSubj,1);
for i=1:nSubj
    allEdges = (read_posMask_all(:,:,i)>0 | GradCptNetwork>0) - (read_negMask_all(:,:,i)>0 | GradCptNetwork<0 | DanDmnNetwork<0);
    [~,~,allEdgeScore(i)] = GetFcMaskMatch(FC_fisher(:,:,i),allEdges>0,allEdges<0);
%     [~,~,allEdgeScore(i)] = GetFcMaskMatch(FC_fisher(:,:,i),read_posMask_all(:,:,i)>0,read_negMask_all(:,:,i)>0);
end

[r_alledge,p_alledge] = corr(allEdgeScore,fracCorrect);
fprintf('Combo: r=%.3f, p=%.3g\n',r_alledge,p_alledge);
[r_read,p_read] = corr(read_combo,fracCorrect);
fprintf('Reading: r=%.3f, p=%.3g\n',r_read,p_read);

%% Plot as bars
allMets = [score_combo.minus_dmn,score_combo.gradcpt,score_combo.reading,allEdgeScore];
metNames = {'-DMN FC','GradCPT FC','Reading FC','Combined Edges FC'};
[r_allmets, p_allmets,rUpper,rLower] = deal(nan(1,size(allMets,2)));
for i=1:size(allMets,2)
    [r_allmets(i), p_allmets(i)] = corr(allMets(:,i),fracCorrect);
    [~,~,rLo,rUp] = corrcoef(allMets(:,i),fracCorrect);
    rUpper(i) = rUp(1,2);
    rLower(i) = rLo(1,2);
end

figure(5623); clf; hold on;
bar(r_allmets(1:3),'facecolor','m');
bar(4,r_allmets(4),'facecolor','g');
errorbar(1:size(allMets,2),r_allmets,r_allmets-rLower,r_allmets-rUpper,'k.');
isStar = p_allmets<0.01;
plot(find(isStar),ones(1,sum(isStar)),'k*')
ylim([-.5 1]);
ylabel('Correlation with Reading Recall');
set(gca,'xtick',1:4,'xticklabel',metNames);


%% Do partial correlation to check if combo score has info beyond reading FC

[r_part,p_part] = partialcorr(score_combo.reading,fracCorrect,score_combo.minus_dmn,'tail','right');        
fprintf('Reading, partial out DMN: r=%.3f, p=%.3g\n',r_part,p_part);

[r_part,p_part] = partialcorr(allEdgeScore,fracCorrect,score_combo.reading,'tail','right');        
fprintf('Combo, partial out Reading: r=%.3f, p=%.3g\n',r_part,p_part);
