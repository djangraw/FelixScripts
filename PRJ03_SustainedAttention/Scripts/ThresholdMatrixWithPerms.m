function [p,h] = ThresholdMatrixWithPerms(FC,FC_perm)

% [p,h] = ThresholdMatrixWithPerms(FC,FC_perm)
%
% Created 1/2/16 by DJ.

thresh = 0.05;

p = nan(size(FC));
for i=1:size(FC,1)
    for j=1:size(FC,2)
        p(i,j) = mean(abs(FC_perm)<abs(FC));
    end
end

h = p<thresh;