function [FC_struct_base_thresh,FC_unstruct_base_thresh,FC_struct_unstruct_thresh] = GetFcDiffs_SRTT(FC_struct_fisher,FC_unstruct_fisher,FC_base_fisher,thresh)

if ~exist('thresh','var') || isempty(thresh)
    thresh = 0.01;
end

% Do stats test, threshold, and re-plot
FC_diff_vec = VectorizeFc(FC_struct_fisher - FC_base_fisher);
[~,p_diff_vec] = ttest(FC_diff_vec');
p_diff_vec_fdr = mafdr(p_diff_vec(:),'bhfdr',true);
p_diff_mat_fdr = UnvectorizeFc(p_diff_vec_fdr);
isSig = p_diff_mat_fdr<thresh;
FC_struct_base_thresh = UnvectorizeFc(mean(FC_diff_vec,2)).*isSig;

FC_diff_vec = VectorizeFc(FC_unstruct_fisher - FC_base_fisher);
[~,p_diff_vec] = ttest(FC_diff_vec');
p_diff_vec_fdr = mafdr(p_diff_vec(:),'bhfdr',true);
p_diff_mat_fdr = UnvectorizeFc(p_diff_vec_fdr);
isSig = p_diff_mat_fdr<thresh;
FC_unstruct_base_thresh = UnvectorizeFc(mean(FC_diff_vec,2)).*isSig;

FC_diff_vec = VectorizeFc(FC_struct_fisher - FC_unstruct_fisher);
[~,p_diff_vec] = ttest(FC_diff_vec');
p_diff_vec_fdr = mafdr(p_diff_vec(:),'bhfdr',true);
p_diff_mat_fdr = UnvectorizeFc(p_diff_vec_fdr);
isSig = p_diff_mat_fdr<thresh;
FC_struct_unstruct_thresh = UnvectorizeFc(mean(FC_diff_vec,2)).*isSig;

% Histogram of q values
% qHist = 10.^(-12:.01:0);
% yHist = hist(p_diff_vec_fdr,qHist);
% plot(log10(qHist),cumsum(yHist));
% % ylim([0 0.05]*sum(yHist));
% ylim([0 200]);
% xlabel(sprintf('lgo_{10} q threshold'))
% ylabel('# of edges with q<threshold')
% title(sprintf('SRTT FC (145 subjects)\n Structured - Unstructured blocks'))