function [FC_grouped,groups] = GroupFcByRegion(FC,atlasLabels,groupMethod,makeSymmetric)

% [FC_grouped,groups] = GroupFcByRegion(FC,atlasLabels,groupMethod,makeSymmetric)
% 
% INPUTS:
% -FC is an mxm symmetric matrix of FC values.
% -atlasLabels is an m-element vector of integers indicating which region
% each ROI belongs to.
% -groupMethod is a string indicating how to combine (either 'mean' or
% 'sum' [default]).
% -makeSymmetric is a binary value indicating whether the matrix should be
% made symmetric before being grouped. [default: true]
%
% OUTPUTS:
% -FC_grouped is a pxp symmetric matrix of the .
% -groups is a p-element vector
%
% Created 1/4/17 by DJ.
% Created 1/25/17 by DJ - enforce symmetric matrix

% Declare defaults
if ~exist('groupMethod','var') || isempty(groupMethod)
    groupMethod = 'sum';
end
if ~exist('makeSymmetric','var') || isempty(makeSymmetric)
    makeSymmetric = true;
end

% make symmetric
if makeSymmetric
    fprintf('Making FC Matrix Symmetric...\n')
    FC = UnvectorizeFc(VectorizeFc(FC),0,true);
end

% group by cluster
groups = unique(atlasLabels);
FC_grouped = nan(numel(groups));
for i=1:numel(groups)
    for j=1:numel(groups)
        switch groupMethod
            case 'mean'
                FC_grouped(i,j) = nanmean(nanmean(FC(atlasLabels==groups(i),atlasLabels==groups(j)))); 
                FC_grouped(j,i) = nanmean(nanmean(FC(atlasLabels==groups(i),atlasLabels==groups(j)))); 
            case 'sum'
                FC_grouped(i,j) = nansum(nansum(FC(atlasLabels==groups(i),atlasLabels==groups(j)))); 
                FC_grouped(j,i) = nansum(nansum(FC(atlasLabels==groups(i),atlasLabels==groups(j)))); 
            otherwise
                error('groupMethod %d not recognized!',groupMethod)
        end
    end
end    