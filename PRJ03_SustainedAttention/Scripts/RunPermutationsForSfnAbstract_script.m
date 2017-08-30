foo = load('VisAudNetwork_match15');
VisNetwork = foo.VisAudNetwork;
VisNetwork(VisNetwork<0) = 0;

% Get scores
[vis_pos,vis_neg,vis_combo] = GetFcMaskMatch(FC_fisher,VisNetwork>0,VisNetwork<0);
[vis_pos,vis_neg,vis_combo] = deal(vis_pos',vis_neg',vis_combo');

% Correlate with behavior
[p_vis,Rsq_vis,lm_vis] = Run1tailedRegression(fracCorrect*100,vis_combo,true);
r_vis = corr(fracCorrect*100,vis_combo);

% Get Spearman version
[r_vis_spearman,p_vis_spearman] = corr(fracCorrect*100,vis_combo,'type','Spearman','tail','right');

%% Run NeuroSynth Permutations


nPerms = 10000;
[r_beh_vis,p_beh_vis,~,~,~,r_beh_spearman_vis,p_beh_spearman_vis] = RunFcMaskMatchPermutations(FC_fisher,fracCorrect,VisNetwork,nPerms,'behavior');

%% DMN Network


foo = load('DanDmnNetwork_match15');
DmnNetwork = -foo.DanDmnNetwork;
DmnNetwork(DmnNetwork<0) = 0;

% Get scores
[dmn_pos,dmn_neg,dmn_combo] = GetFcMaskMatch(FC_fisher,DmnNetwork>0,DmnNetwork<0);
[dmn_pos,dmn_neg,dmn_combo] = deal(dmn_pos',dmn_neg',dmn_combo');

% Correlate with behavior
[p_dmn,Rsq_dmn,lm_dmn] = Run1tailedRegression(fracCorrect*100,dmn_combo,true);
r_dmn = corr(fracCorrect*100,dmn_combo);

% Get Spearman version
[r_dmn_spearman,p_dmn_spearman] = corr(fracCorrect*100,dmn_combo,'type','Spearman','tail','right');

%% Run NeuroSynth Permutations


nPerms = 10000;
[r_beh_dmn,p_beh_dmn,~,~,~,r_beh_spearman_dmn,p_beh_spearman_dmn] = RunFcMaskMatchPermutations(FC_fisher,fracCorrect,DmnNetwork,nPerms,'behavior');


%% Print results
% load VisAudPermutationTests_Fisher_spearman.mat

fprintf('==========\n');
fprintf('Vis Pearson Correlation: r=%.3g\n',r_vis);
fprintf('Vis Randomized behavior: p<%g\n',(sum(p_beh_vis<p_vis)+1)/size(p_beh_vis,1));
fprintf('==========\n');
fprintf('Vis Spearman Correlation: r=%.3g\n',r_vis_spearman);
fprintf('Vis Randomized behavior: p<%.3g\n',(sum(p_beh_spearman_vis<p_vis_spearman)+1)/size(p_beh_spearman_vis,1));
fprintf('==========\n');
fprintf('==========\n');
fprintf('Dmn Pearson Correlation: r=%.3g\n',r_dmn);
fprintf('Dmn Randomized behavior: p<%g\n',(sum(p_beh_dmn>p_dmn)+1)/size(p_beh_dmn,1));
fprintf('==========\n');
fprintf('Dmn Spearman Correlation: r=%.3g\n',r_dmn_spearman);
fprintf('Dmn Randomized behavior: p<%.3g\n',(sum(p_beh_spearman_dmn>p_dmn_spearman)+1)/size(p_beh_spearman_dmn,1));
fprintf('==========\n');

%% Run Activation Correlation
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
[r_act,p_act] = corr(fracCorrect*100,activityScore,'tail','right');
fprintf('%s activity, thresh %d: r = %.3g, p = %.3g\n',goodLabels{1},thresh,r_act,p_act);

%% Run ACTIVATION permutation tests
nPerms = 10000/8;
corr_method = 'corr';
mask_method = 'one';
thresh = 1;
[p_cell,Rsq_cell,mask_size_cell,mask_size_overlap_cell,r_cell,r_spearman_cell,p_spearman_cell] = deal(cell(1,8));
parfor i=1:8
    tic;
    warning('off','stats:statrobustfit:IterationLimit');
    fprintf('Permutation iteration %d...\n',i);
    for j=1:nPerms
        fracCorrect_perm = fracCorrect(randperm(numel(fracCorrect)));
        activityScore = RunLeaveOneOutRegressionWithActivity(meanInRoi_subj,fracCorrect_perm,thresh);
        [r_cell{i}(j), p_cell{i}(j)] = corr(activityScore,fracCorrect_perm,'tail','right');
    end
    fprintf('Done! took %.1f seconds.\n',toc);
end
% Compile
p = cat(2,p_cell{:})';
% Rsq = cat(2,Rsq_cell{:});
r = cat(2,r_cell{:})';
nPerms = size(p,1);
% Save
% [p,Rsq,mask_size,~,~,~,r] = RunLeave1outPermutations(FC_fisher,fracCorrect,nPerms,corr_method,mask_method,thresh);
% save PermTests_Reading_Fisher_2017-02-22_parfor.mat p Rsq mask_size mask_size_overlap r corr_method mask_method thresh nPerms
save PermTests_Reading_Activation.mat p r corr_method mask_method thresh nPerms

%% Print results
fprintf('==========\n');
fprintf('Activation Pearson Correlation: r=%.3g\n',r_act);
fprintf('Activation Randomized behavior: p<%g\n',(sum(p<p_act)+1)/size(p,1));
fprintf('==========\n');
% fprintf('Dmn Spearman Correlation: r=%.3g\n',r_dmn_spearman);
% fprintf('Dmn Randomized behavior: p<%.3g\n',(sum(p_beh_spearman_dmn>p_dmn_spearman)+1)/size(p_beh_spearman_dmn,1));
% fprintf('==========\n');
