function valOnAtlas = MapValuesOntoAtlas(atlas,values,indices)

% valOnAtlas = MapValuesOntoAtlas(atlas,values,indices)
% 
% INPUTS:
% -atlas is an XxYxZ matrix in which each ROI is marked by a certain index.
% -values is an n-element vector of values you'd like to assign to certin
% ROIs.
% -indices is an n-element vector of the indices you'd like to map the
% values to (that is: valOnAtlas(atlas==indices(i)) = values(i)). 
% [default = 1:n]
%
% OUTPUTS:
% -valOnAtlas is an XxYxZ matrix in which the ROI indices are replaced by
% the given values. Any index not assigned a value will be set to 0.
%
% Created 12/22/15 by DJ.

if ~exist('indices','var') || isempty(indices)
    indices = 1:numel(values);
end

valOnAtlas = nan(size(atlas));
for i=1:numel(indices)
    valOnAtlas(atlas==indices(i)) = values(i);
end