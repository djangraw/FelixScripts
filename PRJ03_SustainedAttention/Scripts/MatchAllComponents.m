function [iBest,match] = MatchAllComponents(comps1,comps2)

% [iBest,match] = MatchAllComponents(comps1,comps2)
%
% Created 7/29/16 by DJ.

nComps1 = size(comps1,4);
nComps2 = size(comps2,4);
iBest = nan(nComps1,1);
match = nan(nComps1,nComps2);

for i=1:nComps1
    fprintf('Matching comp %d/%d...\n',i,nComps1);
    [iBest(i),match(i,:)] = FindBestComponentMatch(comps2,comps1(:,:,:,i));
end