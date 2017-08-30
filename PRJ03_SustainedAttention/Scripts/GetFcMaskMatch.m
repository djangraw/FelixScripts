function [pred_pos,pred_neg,pred_combo] = GetFcMaskMatch(FC,posMask,negMask)

% [pred_pos,pred_neg,pred_glm] = GetFcMaskMatch(FC,posMask,negMask)
%
% INPUTS:
% -FC is an mxmxn matrix where m is the number of ROIs and n is the number
% of subjects.
% -pos/negMask are each an mxm binary matrix indicating which ROI pairs are
% in the positive or negative prediction mask. Only the upper triangular
% part of these masks will be used, as indicated in VectorizeFc.
%
% OUTPUTS:
% -pred_pos/neg/combo are an nx1 vector of match scores based on the 'mean'
% metric (mean FC in the ROI pairs of each mask).
%
% Created 1/3/16 by DJ.
% Updated 5/11/17 by DJ - removed *2 scaling factor for combo scores

% Vectorize
test_vecs = VectorizeFc(FC);
pos_mask_overlap_vec = VectorizeFc(posMask);
neg_mask_overlap_vec = VectorizeFc(negMask);
% Get match and normalize
pred_pos = (pos_mask_overlap_vec'*test_vecs)/sum(pos_mask_overlap_vec);
pred_neg = (neg_mask_overlap_vec'*test_vecs)/sum(neg_mask_overlap_vec);
pred_combo = ((pos_mask_overlap_vec-neg_mask_overlap_vec)'*test_vecs)/sum(pos_mask_overlap_vec+neg_mask_overlap_vec);
% pred_combo = ((pos_mask_overlap_vec-neg_mask_overlap_vec)'*test_vecs)/sum(pos_mask_overlap_vec+neg_mask_overlap_vec)*2;
