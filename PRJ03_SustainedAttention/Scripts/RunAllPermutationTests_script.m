% RunAllPermutationTests_script.m
%
% Created 2/21/17 by DJ.

%% Load
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
fprintf('Loading attention network matrices...\n')
[shenAtlas,shenInfo] = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/EPIres_shen_1mm_268_parcellation+tlrc.BRIK');
attnNets = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/attn_nets_268.mat');
[shenLabels,shenLabelNames,shenColors] = GetAttnNetLabels(false);
[shenLabels_hem,shenLabelNames_hem,shenColors_hem] = GetAttnNetLabels('region-hem');

% Get cpcr
gradcpt_struct = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/Rosenberg2016_weights.mat');
gradcpt_cp = UnvectorizeFc(cat(2,gradcpt_struct.cp{:}));
gradcpt_cr = UnvectorizeFc(cat(2,gradcpt_struct.cr{:}));

% Get scores
[gradcpt_pos,gradcpt_neg,gradcpt_combo] = GetFcMaskMatch(FC_fisher,attnNets.pos_overlap,attnNets.neg_overlap);
[gradcpt_pos,gradcpt_neg,gradcpt_combo] = deal(gradcpt_pos',gradcpt_neg',gradcpt_combo');

% Correlate with behavior
[p_gradcpt,Rsq_gradcpt,lm_gradcpt] = Run1tailedRegression(fracCorrect*100,gradcpt_combo,true);
r_gradcpt = corr(fracCorrect*100,gradcpt_combo);

% Get Spearman version
[r_gradcpt_spearman,p_gradcpt_spearman] = corr(fracCorrect*100,gradcpt_combo,'type','Spearman','tail','right');

%% Run permutations
nPerms = 10000;
[r_beh,p_beh,~,~,score_combo,r_beh_spearman,p_beh_spearman] = RunFcMaskMatchPermutations(FC_fisher,fracCorrect,attnNets.pos_overlap-attnNets.neg_overlap,nPerms,'behavior');

% Save results
% save GradCptPermutationTests_Fisher.mat r_edges r_beh p_edges p_beh
save GradCptPermutationTests_Fisher_spearman.mat r_edges r_beh p_edges p_beh r_edges_spearman p_edges_spearman r_beh_spearman p_beh_spearman

%% Print results
load GradCptPermutationTests_Fisher_spearman.mat

fprintf('==========\n');
fprintf('GradCPT Pearson Correlation: r=%.3g\n',r_gradcpt);
fprintf('GradCPT Randomized edges: p<%g\n',(sum(p_edges<p_gradcpt)+1)/size(p_edges,1));
fprintf('GradCPT Randomized behavior: p<%g\n',(sum(p_beh<p_gradcpt)+1)/size(p_edges,1));
fprintf('==========\n');
fprintf('GradCPT Spearman Correlation: r=%.3g\n',r_gradcpt_spearman);
fprintf('GradCPT Randomized edges: p<%g\n',(sum(p_edges_spearman<p_gradcpt_spearman)+1)/size(p_edges_spearman,1));
fprintf('GradCPT Randomized behavior: p<%g\n',(sum(p_beh_spearman<p_gradcpt_spearman)+1)/size(p_beh_spearman,1));
fprintf('==========\n');


%% Get NeuroSynth network
posFilename = [homedir '/Results/NeuroSynth/NeuroSynth_v4-topics-100_15_reading_words_language_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc'];
negFilename = [homedir '/Results/NeuroSynth/NeuroSynth_v4-topics-100_86_speech_auditory_sounds_pFgA_z_FDR_0.01_EpiRes_MNI+tlrc'];
atlasFilename = [homedir '/Results/Shen_2013_atlas/MNI_EPIres_shen_1mm_268_parcellation+tlrc'];
posMaskThreshold = 0;
negMaskThreshold = 0;
posMatchThreshold = 0.15;
negMatchThreshold = 0.15;
VisAudNetwork = GetNeurosynthNetworks(posFilename,negFilename,atlasFilename,posMaskThreshold,negMaskThreshold,posMatchThreshold,negMatchThreshold);

% Get scores
[visaud_pos,visaud_neg,visaud_combo] = GetFcMaskMatch(FC_fisher,VisAudNetwork>0,VisAudNetwork<0);
[visaud_pos,visaud_neg,visaud_combo] = deal(visaud_pos',visaud_neg',visaud_combo');

% Correlate with behavior
[p_visaud,Rsq_visaud,lm_visaud] = Run1tailedRegression(fracCorrect*100,visaud_combo,true);
r_visaud = corr(fracCorrect*100,visaud_combo);

% Get Spearman version
[r_visaud_spearman,p_visaud_spearman] = corr(fracCorrect*100,visaud_combo,'type','Spearman','tail','right');

%% Run NeuroSynth Permutations


nPerms = 10000;
% [r_edges,p_edges] = RunFcMaskMatchPermutations(FC_fisher,fracCorrect,VisAudNetwork,nPerms,'edges');
% [r_beh,p_beh] = RunFcMaskMatchPermutations(FC_fisher,fracCorrect,VisAudNetwork,nPerms,'behavior');
[r_edges,p_edges,~,~,~,r_edges_spearman,p_edges_spearman] = RunFcMaskMatchPermutations(FC_fisher,fracCorrect,VisAudNetwork,nPerms,'edges');
[r_beh,p_beh,~,~,~,r_beh_spearman,p_beh_spearman] = RunFcMaskMatchPermutations(FC_fisher,fracCorrect,VisAudNetwork,nPerms,'behavior');
% Save results
% save VisAudPermutationTests_Fisher.mat r_edges r_beh p_edges p_beh
save VisAudPermutationTests_Fisher_spearman.mat r_edges r_beh p_edges p_beh r_edges_spearman p_edges_spearman r_beh_spearman p_beh_spearman

%% Print results
load VisAudPermutationTests_Fisher_spearman.mat

fprintf('==========\n');
fprintf('VisAud Pearson Correlation: r=%.3g\n',r_visaud);
fprintf('VisAud Randomized edges: p<%g\n',(sum(p_edges<p_visaud)+1)/size(p_edges,1));
fprintf('VisAud Randomized behavior: p<%g\n',(sum(p_beh<p_visaud)+1)/size(p_edges,1));
fprintf('==========\n');
fprintf('VisAud Spearman Correlation: r=%.3g\n',r_visaud_spearman);
fprintf('VisAud Randomized edges: p<%.3g\n',(sum(p_edges_spearman<p_visaud_spearman)+1)/size(p_edges_spearman,1));
fprintf('VisAud Randomized behavior: p<%.3g\n',(sum(p_beh_spearman<p_visaud_spearman)+1)/size(p_beh_spearman,1));
fprintf('==========\n');

%% DAN/DMN Network
load('DanDmnNetwork_match15.mat'); %DanDmnNetwork

% Get scores
[dandmn_pos,dandmn_neg,dandmn_combo] = GetFcMaskMatch(FC_fisher,DanDmnNetwork>0,DanDmnNetwork<0);
[dandmn_pos,dandmn_neg,dandmn_combo] = deal(dandmn_pos',dandmn_neg',dandmn_combo');
% Get correlations
[r_dandmn, p_dandmn] = corr(fracCorrect*100,dandmn_combo,'tail','right');
% Get Spearman version
[r_dandmn_spearman,p_dandmn_spearman] = corr(fracCorrect*100,dandmn_combo,'type','Spearman','tail','right');

% Run permutations
[r_edges,p_edges,~,~,~,r_edges_spearman,p_edges_spearman] = RunFcMaskMatchPermutations(FC_fisher,fracCorrect,DanDmnNetwork,nPerms,'edges');
[r_beh,p_beh,~,~,~,r_beh_spearman,p_beh_spearman] = RunFcMaskMatchPermutations(FC_fisher,fracCorrect,DanDmnNetwork,nPerms,'behavior');
% Save results
save DanDmnPermutationTests_Fisher_spearman.mat r_edges r_beh p_edges p_beh r_edges_spearman p_edges_spearman r_beh_spearman p_beh_spearman

%% Print results
load DanDmnPermutationTests_Fisher_spearman.mat

fprintf('==========\n');
fprintf('DanDmn Pearson Correlation: r=%.3g\n',r_dandmn);
fprintf('DanDmn Randomized edges: p<%g\n',(sum(p_edges<p_dandmn)+1)/size(p_edges,1));
fprintf('DanDmn Randomized behavior: p<%g\n',(sum(p_beh<p_dandmn)+1)/size(p_edges,1));
fprintf('==========\n');
fprintf('DanDmn Spearman Correlation: r=%.3g\n',r_dandmn_spearman);
fprintf('DanDmn Randomized edges: p<%.3g\n',(sum(p_edges_spearman<p_dandmn_spearman)+1)/size(p_edges_spearman,1));
fprintf('DanDmn Randomized behavior: p<%.3g\n',(sum(p_beh_spearman<p_dandmn_spearman)+1)/size(p_beh_spearman,1));
fprintf('==========\n');

%% Get Reading Network and predictions
thresh = 0.01;
corr_method = 'robustfit';
mask_method = 'one';
% Get reading network scores via LOSO
[read_pos, read_neg, read_combo,read_posMask_all,read_negMask_all] = RunLeave1outBehaviorRegression(FC_fisher,fracCorrect,thresh,corr_method,mask_method);
% Get correlation with behavior
[p_read,Rsq_read,lm_read] = Run1tailedRegression(fracCorrect*100,read_combo,true);
r_read = corr(fracCorrect*100,read_combo);

% Get Spearman version
[r_read_spearman,p_read_spearman] = corr(fracCorrect*100,read_combo,'type','Spearman','tail','right');

%% Run permutation tests
nPerms = 10000/8;
corr_method = 'corr';
mask_method = 'one';
thresh = 0.01;
[p_cell,Rsq_cell,mask_size_cell,mask_size_overlap_cell,r_cell,r_spearman_cell,p_spearman_cell] = deal(cell(1,8));
parfor i=1:8
    tic;
    fprintf('Permutation iteration %d...\n',i);
%     [p_cell{i},Rsq_cell{i},mask_size_cell{i},mask_size_overlap_cell{i},~,~,r_cell{i}] = RunLeave1outPermutations(FC_fisher,fracCorrect,nPerms,corr_method,mask_method,thresh);
    [p_cell{i},Rsq_cell{i},mask_size_cell{i},mask_size_overlap_cell{i},~,~,r_cell{i},r_spearman_cell{i},p_spearman_cell{i}] = RunLeave1outPermutations(FC_fisher,fracCorrect,nPerms,corr_method,mask_method,thresh);
    fprintf('Done! took %.1f seconds.\n',toc);
end
% Compile
p = cat(2,p_cell{:});
Rsq = cat(2,Rsq_cell{:});
mask_size = cat(3,mask_size_cell{:});
mask_size_overlap = cat(2,mask_size_overlap_cell{:});
r = cat(2,r_cell{:});
r_spearman = cat(2,r_spearman_cell{:});
p_spearman = cat(2,p_spearman_cell{:});
nPerms = size(p,2);
% Save
% [p,Rsq,mask_size,~,~,~,r] = RunLeave1outPermutations(FC_fisher,fracCorrect,nPerms,corr_method,mask_method,thresh);
% save PermTests_Reading_Fisher_2017-02-22_parfor.mat p Rsq mask_size mask_size_overlap r corr_method mask_method thresh nPerms
save PermTests_Reading_Fisher_spearman.mat p Rsq mask_size mask_size_overlap r r_spearman p_spearman corr_method mask_method thresh nPerms

%% Load/print permutation test results
foo = load('PermTests_Reading_Fisher_spearman.mat');
% load GradCptPermutationTests.mat

% fprintf('GradCPT Randomized edges: p<%g\n',(sum(p_edges<p_gradcpt)+1)/nPerms);
fprintf('Reading Randomized behavior: p<%g\n',(sum(foo.p(end,:)<p_read)+1)/size(foo.p,2));
