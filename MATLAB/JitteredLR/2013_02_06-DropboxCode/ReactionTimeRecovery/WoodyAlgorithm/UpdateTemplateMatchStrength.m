function matchStrength = UpdateTemplateMatchStrength(data,template)

% Created 11/27/12 by DJ.

% Set up
[~,nT,ntrials] = size(data);
windowSize = size(template,2);

% Main loop
% matchStrength = nan(ntrials, nT-windowSize);
% dataMag = nan(ntrials, nT-windowSize);
% for i=1:ntrials
%     ms = xcorr2(data(:,:,i),template);
%     for j=1:nT-windowSize
%         dataMag(i,j) = sum(dot(data(:,j-1+(1:windowSize),i),data(:,j-1+(1:windowSize),i)));
%     end
%     matchStrength(i,:) = ms(ceil(size(ms,1)/2),windowSize:end-windowSize);
% end
% 
% % Normalize
% matchStrength = matchStrength./sqrt(dataMag*sum(dot(template,template)));


% Alternative: normalized cross-correlation
matchStrength = nan(ntrials, nT-windowSize);
for i=1:ntrials
    ms = normxcorr2(template,data(:,:,i));
    matchStrength(i,:) = ms(ceil(size(ms,1)/2),windowSize:end-windowSize);
end

% Normalize to make all above 0 and each trial sum to 1
% matchStrength = exp(matchStrength);
matchStrength(matchStrength<0) = 0;
matchStrength(sum(matchStrength,2)==0, :) = eps;
matchStrength = matchStrength./repmat(sum(matchStrength,2),1,size(matchStrength,2));