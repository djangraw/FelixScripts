function [isInOverlap,Info] = GetMaskOverlap(varargin)

% isInOverlap = GetMaskOverlap(varargin)
%
% Created 4/11/19 by DJ.

Info = cell(nargin,1);
for i=1:nargin
    % Load file
    if ischar(varargin{i})
        [V,Info{i}] = BrikLoad(varargin{i});
    else
        V = varargin{i};
    end
    % Get overlap
    if i==1
        isInOverlap = (V>0);
    else
        isInOverlap = isInOverlap .* (V>0);
    end
end
