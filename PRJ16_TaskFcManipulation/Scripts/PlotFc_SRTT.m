function PlotFc_SRTT(FC_struct,FC_unstruct,FC_base,atlas,clim_diff,thresh)

% PlotFc_SRTT(FC_struct,FC_unstruct,FC_base,atlas,clim_diff,thresh)
%
% Plot the FC matrices for the SRTT task in each of the three block types:
% first separately, then the differences between each pair.
%
% Created 8/11/17 by DJ.
% Updated 8/16/17 by DJ - added thresh input


if ~exist('atlas','var') || isempty(atlas)
    atlas = '/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_1mm_268_parcellation+tlrc.HEAD';
end
if ~exist('clim_diff','var') || isempty(clim_diff)
    clim_diff = [-1 1]*.01;
end
if ~exist('thresh','var') || isempty(thresh)
    thresh = 0.01;
end
if ischar(atlas)
    atlas = BrikLoad(atlas);
end
[shenLabels,shenLabelNames,shenLabelColors] = GetAttnNetLabels(true);


% Fisher Normalize
FC_struct_fisher = atanh(FC_struct);
FC_unstruct_fisher = atanh(FC_unstruct);
FC_base_fisher = atanh(FC_base);

nSubj = size(FC_struct,3);
clim = [-1 1];
doAvgInCluster = false;%'mean';
% Plot
subplot(3,3,1);
PlotFcMatrix(mean(FC_struct_fisher,3),clim,atlas,shenLabels,true,shenLabelColors,doAvgInCluster);
title(sprintf('Mean Fisher-Normed FC in Structured Blocks\n (across %d subj)',nSubj));
subplot(3,3,2);
PlotFcMatrix(mean(FC_unstruct_fisher,3),clim,atlas,shenLabels,true,shenLabelColors,doAvgInCluster);
title(sprintf('Mean Fisher-Normed FC in Unstructured Blocks\n (across %d subj)',nSubj));
subplot(3,3,3);
PlotFcMatrix(mean(FC_base_fisher,3),clim,atlas,shenLabels,true,shenLabelColors,doAvgInCluster);
title(sprintf('Mean Fisher-Normed FC in Baseline Blocks\n (across %d subj)',nSubj));
subplot(3,3,4);
PlotFcMatrix(mean(FC_struct_fisher,3)-mean(FC_base_fisher,3),clim_diff,atlas,shenLabels,true,shenLabelColors,doAvgInCluster);
title(sprintf('Mean Fisher-Normed FC in Structured-Baseline Blocks\n (across %d subj)',nSubj));
subplot(3,3,5);
PlotFcMatrix(mean(FC_unstruct_fisher,3)-mean(FC_base_fisher,3),clim_diff,atlas,shenLabels,true,shenLabelColors,doAvgInCluster);
title(sprintf('Mean Fisher-Normed FC in Unstructured-Baseline Blocks\n (across %d subj)',nSubj));
subplot(3,3,6);
PlotFcMatrix(mean(FC_struct_fisher,3)-mean(FC_unstruct_fisher,3),clim_diff,atlas,shenLabels,true,shenLabelColors,doAvgInCluster);
title(sprintf('Mean Fisher-Normed FC in Structured-Unstructured Blocks\n (across %d subj)',nSubj));

% Do stats test, threshold, and re-plot
FC_diff_vec = VectorizeFc(FC_struct_fisher - FC_base_fisher);
[~,p_diff_vec] = ttest(FC_diff_vec');
p_diff_vec_fdr = mafdr(p_diff_vec(:),'bhfdr',true);
p_diff_mat_fdr = UnvectorizeFc(p_diff_vec_fdr);
isSig = p_diff_mat_fdr<thresh;
subplot(3,3,7);
PlotFcMatrix(UnvectorizeFc(mean(FC_diff_vec,2)).*isSig,clim_diff,atlas,shenLabels,true,shenLabelColors,doAvgInCluster);
title(sprintf('q<%.02g Thresholded Mean Fisher-Normed FC in\n Structured-Baseline Blocks (across %d subj)',thresh, nSubj));

FC_diff_vec = VectorizeFc(FC_unstruct_fisher - FC_base_fisher);
[~,p_diff_vec] = ttest(FC_diff_vec');
p_diff_vec_fdr = mafdr(p_diff_vec(:),'bhfdr',true);
p_diff_mat_fdr = UnvectorizeFc(p_diff_vec_fdr);
isSig = p_diff_mat_fdr<thresh;
subplot(3,3,8);
PlotFcMatrix(UnvectorizeFc(mean(FC_diff_vec,2)).*isSig,clim_diff,atlas,shenLabels,true,shenLabelColors,doAvgInCluster);
title(sprintf('q<%.02g Thresholded Mean Fisher-Normed FC in\n Unstructured-Baseline Blocks (across %d subj)',thresh, nSubj));

FC_diff_vec = VectorizeFc(FC_struct_fisher - FC_unstruct_fisher);
[~,p_diff_vec] = ttest(FC_diff_vec');
p_diff_vec_fdr = mafdr(p_diff_vec(:),'bhfdr',true);
p_diff_mat_fdr = UnvectorizeFc(p_diff_vec_fdr);
isSig = p_diff_mat_fdr<thresh;
subplot(3,3,9);
PlotFcMatrix(UnvectorizeFc(mean(FC_diff_vec,2)).*isSig,clim_diff,atlas,shenLabels,true,shenLabelColors,doAvgInCluster);
title(sprintf('q<%.02g Thresholded Mean Fisher-Normed FC in\n Structured-Unstructured Blocks (across %d subj)',thresh, nSubj));
