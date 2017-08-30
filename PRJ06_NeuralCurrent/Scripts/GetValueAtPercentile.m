function valAtPerc = GetValueAtPercentile(values,percentile)

% Returns the value that a certain percent of given values are below.
%
% valAtPerc = GetValueAtPercentile(values,percentile)
%
% INPUTS:
% - values is a matrix (interpreted as a vector) of the value collection.
% - percentile is a value between 0 and 100 indicating the percentile
%
% OUTPUTS:
% - valAtPerc is the value that percentile% of values are below.
%
% Created 10/1/15 by DJ.

sorted = sort(values(:),'ascend');
valAtPerc = interp1((1:numel(sorted))/numel(sorted),sorted,percentile/100,'linear');
