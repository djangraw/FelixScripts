function [rawAcc, rawRt] = GetSrttTrialByTrialBeh(trialBehTable)

% [rawAcc,rawRt] = GetSrttTrialByTrialBeh(trialBehTable)
%
% Created 9/20/17 by DJ.

% Set up
subjects = unique(trialBehTable.Subject);
nSubj = numel(subjects);
[rawAcc, rawRt] = deal(cell(1,nSubj));
for i=1:nSubj
    isThisSubj = trialBehTable.Subject == subjects(i);
    % get behavior for this subject
    behThis = trialBehTable(isThisSubj,:);
    % Extract RT, censor no-response trials
    rtThis = behThis.Target_RT;
    rtThis(rtThis==0) = NaN;
    % Add to cells
    rawAcc{i} = (behThis.Target_ACC==1);
    rawRt{i} = rtThis;
end


