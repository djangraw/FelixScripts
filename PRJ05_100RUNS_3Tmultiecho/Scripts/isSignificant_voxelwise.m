function [isSig,results_Q] = isSignificant_voxelwise(results_Z,mask,correctionMethod)

% [isSig,results_Q] = isSignificant_voxelwise(results_Z,mask,correctionMethod)
%
% INPUTS:
% - results_Z is an mxnxp matrix of z scores.
% - mask is an mxnxp matrix of binary values.
% - correctionMethod is a string ('fdr, 'bonf', or 'none')
%
% OUTPUTS:
% - isSig is an mxnxp matrix of binary values.
% - results_Q is an mxnxp matrix.
%
% Created 4/7/15 by DJ.

threshold = 0.05;


% Find significant voxels
results_P = 1-normcdf(results_Z);
isInMask = mask~=0;


switch correctionMethod
    case 'fdr'
        q = mafdr(results_P(isInMask),'bhfdr','true');
        results_Q = 0.5*ones(size(results_P));
        results_Q(isInMask) = q;
        isSig = results_Q < threshold;
    case 'bonf'
        q = results_P(isInMask);
        results_Q = 0.5*ones(size(results_P));
        results_Q(isInMask) = q;
        isSig = results_Q < (threshold/sum(isInMask));
    case 'none'
        q = results_P(isInMask);
        results_Q = 0.5*ones(size(results_P));
        results_Q(isInMaks) = q;
        isSig = results_Q < threshold;
end
