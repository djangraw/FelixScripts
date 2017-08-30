function scaledValues = ScaleToRange(values,range,minmaxValues)

% scaledValues = ScaleToRange(values,range,minmaxValues)
%
% INPUTS:
% -values is an N-D matrix of values you want to rescale.
% -range is a 2-element vector of the min and max values desired in the
% output. [default: [0 1] ]
% -minmaxValues is a 2-element of the min and max values allowed in the
% input (anything above or below this range will be clipped). [default:
% [min(values(:)), max(values(:))] ]
%
% OUTPUT:
% -scaledValues is a matrix of same size as values, but the values have
% been rescaled.
%
% Created 12/16/16 by DJ.

% Declare defaults
if ~exist('range','var') || isempty(range)
    range = [0 1];
end

if ~exist('minmaxValues','var') || isempty(minmaxValues)
    minmaxValues = [min(values(:)),max(values(:))];
end

% Clip
values(values<minmaxValues(1)) = minmaxValues(1);
values(values>minmaxValues(2)) = minmaxValues(2);

% Rescale
scaledValues = (values-minmaxValues(1))*(range(2)-range(1))/(minmaxValues(2)-minmaxValues(1)) + range(1);