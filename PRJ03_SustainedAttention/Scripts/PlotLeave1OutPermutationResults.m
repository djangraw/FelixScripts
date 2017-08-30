% PlotLeave1OutPermutationResults.m
%
% Created 1/4/17 by DJ.

% First run part of:
% ComparePredictions_GradcptDandmnReading
% to get FC, fracCorrect

% Run permutation tests
% [p,Rsq,mask_size,cp_perms,cr_perms,behav_perms] = RunLeave1outPermutations(FC,fracCorrect,1000,'corr','cpcr',0);
% save PermTests_CpCr_20subj-noGSR_2017-01-04.mat cp_perms cr_perms behav_perms subjects
% or Load permutation tests
% load('PermTests_CpCr_20subj-noGSR_2017-01-04.mat');
% Threshold and combine across subjects

threshold = 0.01;
isBelowThresh = squeeze(all(cp_perms<threshold,3));
isPos = squeeze(all(cr_perms>0,3));
nPerms = size(cp_perms,4);
isBelowThresh_vec = VectorizeFc(isBelowThresh);
isPos_vec = VectorizeFc(isPos);

%% Get various bits of info
% 1. # in pos & neg networks
networkSize(:,1) = sum(isBelowThresh_vec & isPos_vec,1)';
networkSize(:,2) = sum(isBelowThresh_vec & ~isPos_vec,1)';

figure(161); clf;
[n,xHist] = hist(networkSize,1:max(networkSize(:)));
pctHist = cumsum(n)./repmat(sum(n),length(n),1)*100;
plot(xHist,pctHist);
xlabel('# edges in network')
ylabel('% permutations with at most this many edges')
legend('pos','neg');

%% 2. edge-wise (min across LOSO iters) predictive ability

min_cr_perms = min(abs(cr_perms),[],3).*sign(cr_perms(:,:,1,:));
isOkEdge = all(cr_perms>0,3) | all(cr_perms<0,3);
min_cr_perms(~isOkEdge) = 0;
min_cr_perms = squeeze(min_cr_perms);
% Get p values
% Load if necessary
% foo = load('ReadingCpCr_20subj-noGSR_2017-01-04');
% read_cr = foo.cr_all;
min_cr_read = min(abs(read_cr),[],3).*sign(read_cr(:,:,1));
isOkEdge = all(read_cr>0,3) | all(read_cr<0,3);
min_cr_read(~isOkEdge) = 0;
% Vectorize
mincrread_vec = VectorizeFc(min_cr_read);
mincrperms_vec = VectorizeFc(min_cr_perms);
nEdge = size(mincrread_vec,1);

p_read = mean(repmat(mincrread_vec,1,nPerms)<mincrperms_vec,2);
p_read_posfdr = mafdr(1-p_read);
p_read_negfdr = mafdr(p_read);
fprintf('%d/%d = %.3g + p<0.025\n',sum(p_read_posfdr<0.025),nEdge,mean(p_read_posfdr<0.025)),
fprintf('%d/%d = %.3g - p<0.025\n',sum(p_read_negfdr<0.025),nEdge,mean(p_read_negfdr<0.025));
%%
figure(162); clf;
[n,xHist] = hist([p_read_posfdr, p_read_negfdr],0:.001:1);
pctHist = cumsum(n)./repmat(sum(n),length(n),1)*100;
plot(xHist,pctHist);
xlabel('p_{fdr}')
ylabel('% permutation edges below this p value')
legend('pos','neg');


%% Get GradCPT Network
fprintf('Loading attention network matrices...\n')
[shenAtlas,shenInfo] = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_2mm_268_parcellation.nii.gz');
[shenLabels,shenLabelNames,shenColors] = GetAttnNetLabels(true);

%% # edges in each cluster pair (at p<.01 threshold) by chance
thresh = 0.01;
max_cp_perms = max(abs(cp_perms),[],3);
isOkEdge = all(cr_perms>0,3) | all(cr_perms<0,3);
max_cp_perms(~isOkEdge) = 1;
max_cp_perms = squeeze(max_cp_perms);
maxcpperms_vec = VectorizeFc(max_cp_perms);
isInNetwk = UnvectorizeFc(maxcpperms_vec<thresh,0,true);

%% Get sum within each region pair
nGroups = numel(unique(shenLabels));
sumInNetwk = nan(nGroups,nGroups,nPerms);
for i=1:nPerms
    sumInNetwk(:,:,i) = GroupFcByRegion(isInNetwk,shenLabels,'sum');
end
%% Get 99th percentile across regions
sumInNetwk_99p = nan(nGroups);
for i=1:nGroups
    for j=1:nGroups
        sumInNetwk_99p(i,j) = GetValueAtPercentile(sumInNetwk(i,j,:),99);
    end
end
%% Plot
figure(163); clf;
PlotFcMatrix(sumInNetwk_99p,[0 1]*4,[],(1:nGroups)',true,shenColors,'sum');
title('99th percentile of # edges per region pair');