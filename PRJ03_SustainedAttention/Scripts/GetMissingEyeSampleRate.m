function [missingSampleRate, missingSampleRate_runs] = GetMissingEyeSampleRate(subjects)

% missingSampleRate = GetMissingEyeSampleRate(subjects)
%
% INPUTS:
% -subjects is an n-element vector of subject numbers.
%
% OUTPUTS:
% -missingSampleRate is an n-element vector of the number of eye samples
% that were missing for each subject during the task.
% -missingSampleRate_runs is an n-element cell array containing m-element vectors,
% where m is the number of runs for a subject. nSacc_runs{i}(j) is the
% number of missing samples/s in subject i's run j.
%
% Created 4/4/17 by DJ based on GetSaccadeRate.m

% Set up
nSubj = numel(subjects);
[missingSampleRate_runs] = deal(cell(1,nSubj));
[missingSampleRate] = deal(nan(1,nSubj));

for i=1:nSubj
    fprintf('Loading subject %d/%d...\n',i,nSubj);
    beh = load(sprintf('/data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ%02d/Distraction-SBJ%02d-Behavior.mat',subjects(i),subjects(i)));
    [missingSampleRate_runs{i}] = deal(nan(1,numel(beh.data)));
    for j=1:numel(beh.data)
        [tPageStart,tPageEnd] = GetPageTimes(beh.data(j).events);
        isOk = beh.data(j).events.samples.time>tPageStart(1) & beh.data(j).events.samples.time<tPageEnd(end);
        missingSampleRate_runs{i}(j) = mean(isnan(beh.data(j).events.samples.position(isOk,1))); % only count times when we had the eye
        
    end
    missingSampleRate(i) = mean(missingSampleRate_runs{i});
end
fprintf('Done!\n');