% PlotDiceCoefficientsBetweenReadingAndGradcpt.m
%
% Created 5/17/17 by DJ.

atlasFile = '/Users/jangrawdc/Documents/PRJ03_SustainedAttention/Shen_2013_parcellations/shen_1mm_268_parcellation+tlrc';
[shenAtlas,shenInfo] = BrikLoad(atlasFile);

% Declare labels & colors
[shenLabels_hem,shenLabelNames_hem,shenColors_hem] = GetAttnNetLabels(true);

foo = load('ReadingNetwork_p01_Fisher');
readingNetwork = foo.readingNetwork_p01;
foo = load('GradCptNetwork_p01');
gradcptNetwork = foo.gradCptNetwork_p01;

h = PlotAtlasFcIn3d_Conn(atlasFile,readingNetwork);

%% Get overlap

foo = load('Rosenberg2016_crcp_allsubs.mat');
grad_cp = UnvectorizeFc(foo.cp);
grad_cr = UnvectorizeFc(foo.cr);

load('ReadingCpCr_19subj_Fisher_TrainOnAll_2017-05-17.mat');

%% Get overlap
read_cr_vec = VectorizeFc(read_cr);
grad_cr_vec = VectorizeFc(grad_cr);
r_thresh = linspace(0,1,100);
[overlap,total] = deal(nan(size(r_thresh)));
for i=1:numel(r_thresh)
    overlap(i) = sum(abs(read_cr_vec) > r_thresh(i) & abs(grad_cr_vec) > r_thresh(i) & sign(read_cr_vec) == sign(grad_cr_vec));
    total(i) = sum(abs(read_cr_vec) > r_thresh(i)) + sum(abs(grad_cr_vec) > r_thresh(i));       
end
dice = 2*overlap./total;

%% Permutations
nPerms = 10000;
overlap_perm = nan(nPerms,size(overlap,2));
fprintf('Running %d permutations...\n',nPerms);
tic;
for iPerm = 1:nPerms
    read_cr_vec_perm = read_cr_vec(randperm(numel(read_cr_vec)));
    for i=1:numel(r_thresh)
        overlap_perm(iPerm,i) = sum(abs(read_cr_vec_perm) > r_thresh(i) & abs(grad_cr_vec) > r_thresh(i) & sign(read_cr_vec_perm) == sign(grad_cr_vec));    
    end
end
dice_perm = 2*overlap_perm./repmat(total,nPerms,1);
fprintf('Done! Took %d seconds.\n',toc);
save DicePermutations_ReadVsGradCr_AllSubj dice dice_perm r_thresh
%% Clean up
dice_perm_median = median(dice_perm,1);
dice_perm_95 = nan(1,numel(r_thresh));
dice_perm_999 = nan(1,numel(r_thresh));
for i=1:numel(r_thresh)
    dice_perm_95(i) = GetValueAtPercentile(dice_perm(:,i),95);
    dice_perm_999(i) = GetValueAtPercentile(dice_perm(:,i),99.9);
end
%% plot results
figure(62); clf;
subplot(121);
plot(r_thresh,[dice;dice_perm_median; dice_perm_95; dice_perm_999]');
legend('true','mean of random perms','95th percentile','99.9th percentile')
xlabel('r threshold');
ylabel('Sorensen-Dice coefficient')

subplot(122);
plot(r_thresh,dice-dice_perm_median);
xlabel('r threshold');
ylabel('Sorensen-Dice coefficient - median of permutations')



%% === SAME WITH P VALUE THRESHOLDS === %
%% Get overlap
p_thresh = linspace(0,1,100);
read_cp_vec = VectorizeFc(read_cp);
grad_cp_vec = VectorizeFc(grad_cp);
r_thresh = linspace(0,1,100);
[overlap,total] = deal(nan(size(r_thresh)));
for i=1:numel(p_thresh)
    overlap(i) = sum(read_cp_vec < p_thresh(i) & grad_cp_vec < p_thresh(i) & sign(read_cr_vec) == sign(grad_cr_vec));
    total(i) = sum(read_cp_vec < p_thresh(i)) + sum(grad_cp_vec < p_thresh(i));       
end
dice_p = 2*overlap./total;

%% Permutations
nPerms = 10000;
overlap_perm = nan(nPerms,size(overlap,2));
fprintf('Running %d permutations...\n',nPerms);
tic;
for iPerm = 1:nPerms
    permind = randperm(numel(read_cr_vec));
    read_cr_vec_perm = read_cr_vec(permind);
    read_cp_vec_perm = read_cp_vec(permind);
    for i=1:numel(p_thresh)
        overlap_perm(iPerm,i) = sum(read_cp_vec_perm < p_thresh(i) & grad_cp_vec < p_thresh(i) & sign(read_cr_vec_perm) == sign(grad_cr_vec));
    end
end
dice_perm_p = 2*overlap_perm./repmat(total,nPerms,1);
fprintf('Done! Took %d seconds.\n',toc);
save DicePermutations_ReadVsGradCp_AllSubj dice_p dice_perm_p p_thresh
%% Clean up
dice_perm_median = median(dice_perm_p,1);
overlap_perm_median = median(overlap_perm,1);
[dice_perm_95, dice_perm_999, overlap_perm_95, overlap_perm_999] = deal(nan(1,numel(p_thresh)));
for i=1:numel(p_thresh)
    dice_perm_95(i) = GetValueAtPercentile(dice_perm_p(:,i),95);
    dice_perm_999(i) = GetValueAtPercentile(dice_perm_p(:,i),99.9);
    overlap_perm_95(i) = GetValueAtPercentile(overlap_perm(:,i),95);
    overlap_perm_999(i) = GetValueAtPercentile(overlap_perm(:,i),99.9);
end
%% plot results
figure(63); clf;
set(gcf,'Position',[260 488 1207 847]);
subplot(221);
plot(r_thresh,[dice_p;dice_perm_median; dice_perm_95; dice_perm_999]');
legend('true','median of random perms','95th percentile','99.9th percentile','Location','SouthEast')
xlabel('p threshold');
ylabel('Sorensen-Dice coefficient')

subplot(222);
plot(p_thresh,dice_p - dice_perm_median);
xlabel('p threshold');
ylabel('Sorensen-Dice coefficient - median of permutations')

subplot(223);
plot(r_thresh,[overlap;overlap_perm_median; overlap_perm_95; overlap_perm_999]');
legend('true','median of random perms','95th percentile','99.9th percentile','Location','SouthEast')
xlabel('p threshold');
ylabel('# overlapping edges')

subplot(224);
plot(p_thresh,overlap - overlap_perm_median);
xlabel('p threshold');
ylabel('# overlapping edges - median of permutations')



%% === SAME WITH DAN & DMN === %%
% load
load DanDmnNetwork_match15 % DanDmnNetwork
dandmn_vec = VectorizeFc(DanDmnNetwork);
% Get overlap
p_thresh = linspace(0,1,100);
read_cp_vec = VectorizeFc(read_cp);
grad_cp_vec = VectorizeFc(grad_cp);
r_thresh = linspace(0,1,100);
[overlap_read,overlap_read_opp,total_read,overlap_grad,overlap_grad_opp,total_grad] = deal(nan(size(p_thresh)));
for i=1:numel(p_thresh)
    overlap_read(i) = sum(read_cp_vec < p_thresh(i) & dandmn_vec~=0 & sign(read_cr_vec) == sign(dandmn_vec));
    overlap_read_opp(i) = sum(read_cp_vec < p_thresh(i) & dandmn_vec~=0 & sign(read_cr_vec) ~= sign(dandmn_vec));
%     total_read(i) = sum(read_cp_vec < p_thresh(i)) + sum(dandmn_vec~=0);
    total_read(i) = 2*sum(dandmn_vec~=0);
    overlap_grad(i) = sum(grad_cp_vec < p_thresh(i) & dandmn_vec~=0 & sign(grad_cr_vec) == sign(dandmn_vec));
    overlap_grad_opp(i) = sum(grad_cp_vec < p_thresh(i) & dandmn_vec~=0 & sign(grad_cr_vec) ~= sign(dandmn_vec));
%     total_grad(i) = sum(grad_cp_vec < p_thresh(i)) + sum(dandmn_vec~=0);       
    total_grad(i) = 2*sum(dandmn_vec~=0);       
end
dice_read_p = 2*overlap_read./total_read;
dice_grad_p = 2*overlap_grad./total_grad;
dice_read_opp_p = 2*overlap_read_opp./total_read;
dice_grad_opp_p = 2*overlap_grad_opp./total_grad;

%% plot results
figure(64); clf;
subplot(121);
plot(r_thresh,[dice_read_p;dice_grad_p]');%dice_perm_median; dice_perm_95; dice_perm_999]');
legend('Reading','GradCPT')
xlabel('p threshold');
% ylabel('Sorensen-Dice coefficient with DAN-DMN network')
ylabel('Fraction of DAN-DMN edges agreeing with network')

subplot(122);
plot(r_thresh,[dice_read_opp_p;dice_grad_opp_p]');%dice_perm_median; dice_perm_95; dice_perm_999]');
legend('Reading','GradCPT')
xlabel('p threshold');
% ylabel('Sorensen-Dice coefficient with DMN-DAN network')
ylabel('Fraction of DMN-DAN edges agreeing with network')

% subplot(122);
% plot(p_thresh,[dice_read_p - dice_perm_median; dice_grad_p - dice_perm_median]');
% legend('reading','gradcpt')
% xlabel('p threshold');
% ylabel('Sorensen-Dice coefficient with DAN/DMN network - median of permutations')