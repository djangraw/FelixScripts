function cm = GetCenterOfMass(brick,thresh)

% cm = GetCenterOfMass(brick)
%
% Created 12/28/17 by DJ.

% Declare defaults
if ~exist('thresh','var') || isempty(thresh)
    thresh = 0;
end
% Get mask
mask = brick>thresh;
[cols, rows, pages] = meshgrid(1:size(brick, 2), 1:size(brick, 1), 1:size(brick, 3));
% Get center point
rowcenter = sum(rows(mask) .* brick(mask)) / sum(brick(mask));
colcenter = sum(cols(mask) .* brick(mask)) / sum(brick(mask));
pagcenter = sum(pages(mask) .* brick(mask)) / sum(brick(mask));
% compile center of mass vector
cm = [rowcenter,colcenter,pagcenter];
