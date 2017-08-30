function [iBest,matchLevel] = FindBestComponentMatch(components,template)

% [iBest,matchLevel] = FindBestComponentMatch(components,template)
% 
% Find the component that best matches a template.
% 
% INPUTS:
% -components is an NxMxPxQ matrix indicating Q different spatial components.
% -template is an NxMxP matrix indicating the template you'd like to match to.
%
% OUTPUTS:
% -iBest is the index of the component best matching the template.
% -matchLevel is a 1xQ matrix indicating the level to which each component
% matches the template.
%
% Created 7/27/16 by DJ.
% Updated 7/28/16 by DJ - changed best match to max(abs(matchLevel))

% evaluate match
matchLevel = nan(1,size(components,4));
for i=1:size(components,4)
    thisComp = components(:,:,:,i);
    matchLevel(i) = corr(thisComp(:),template(:));
end
% find best match
[~,iBest] = max(abs(matchLevel));