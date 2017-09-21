function [rollingPc, rollingRt] = PlotSrttTrialByTrialBeh(trialBehTable)

% [rollingPc, rollingRt] = PlotSrttTrialByTrialBeh(trialBehTable)
%
% Created 9/20/17 by DJ.

% % Make Gaussian Smoothing Kernel h
% N = 1;
% sigma = 10;
% ind = -floor(N/2) : floor(N/2);
% 
% % Create Gaussian Mask
% kernel = exp(-(ind.^2) / (2*sigma*sigma));
% kernel(ind<0) = 0; % convert to half-gaussian (causal)
% 
% % Normalize so that total area (sum of all weights) is 1
% kernel = kernel / sum(kernel(:));


% Set up
subjects = unique(trialBehTable.Subject);
nSubj = numel(subjects);
% figure(523); clf;
nRows = ceil(sqrt(nSubj));
nCols = ceil(nSubj/nRows);
[rollingPc, rollingRt] = deal(cell(1,nSubj));
for i=1:nSubj
    isThisSubj = trialBehTable.Subject == subjects(i);
    
    behThis = trialBehTable(isThisSubj,:);
    
    rtThis = behThis.Target_RT;
    rtThis(rtThis==0) = NaN;
%     isNoResp = (isnan(rtThis));
%     isError = (behThis.Target_ACC==0 & ~isnan(rtThis));
    isCorrect = (behThis.Target_ACC==1);
    rollingPc{i} = isCorrect;
    rollingRt{i} = rtThis;
%     rollingPc{i} = conv(isCorrect,kernel,'same')*100;
%     rollingRt{i} = conv(rtThis,kernel,'same');
%     nTrials = size(behThis,1);
    % Plot corrects, errors, and no-responses
%     subplot(nRows,nCols,i); cla; hold on;
%     [~,h1,h2] = plotyy(1:nTrials,rtThis,1:nTrials,rollingPc{i});
%     set(h1,'marker','.');
%     plot(find(isError),behThis.Target_RT(isError),'rx')
%     plot(find(isNoResp),zeros(1,sum(isNoResp)),'m.');
%     PlotVerticalLines(find(diff(behThis.Cond)~=0)+0.5,'k--');
end


