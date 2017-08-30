function [sacRate_all,blinkRate_all,sacRate_runs] = GetSaccadeRate(subjects, onlyOkSamples)

% [sacRate_all,blinkRate_all,sacRate_runs] = GetSaccadeRate(subjects)
%
% INPUTS:
% -subjects is an n-element vector of subject numbers.
%
% OUTPUTS:
% -sacRate_all is an n-element vector of the number of saccades/s recorded for
% each subject during the task.
% -sacRate_runs is an n-element cell array containing m-element vectors,
% where m is the number of runs for a subject. nSacc_runs{i}(j) is the
% number of saccades/s in subject i's run j.
%
% Created 1/23/17 by DJ.

if ~exist('onlyOkSamples','var') || isempty(onlyOkSamples)
    onlyOkSamples = false;
end

nSubj = numel(subjects);
[sacRate_runs, blinkRate_runs] = deal(cell(1,nSubj));
[sacRate_all, blinkRate_all] = deal(nan(1,nSubj));

for i=1:nSubj
    fprintf('Loading subject %d/%d...\n',i,nSubj);
    beh = load(sprintf('/data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ%02d/Distraction-SBJ%02d-Behavior.mat',subjects(i),subjects(i)));
    [sacRate_runs{i}, blinkRate_runs{i}] = deal(nan(1,numel(beh.data)));
    for j=1:numel(beh.data)
        [tPageStart,tPageEnd] = GetPageTimes(beh.data(j).events);
        if onlyOkSamples
%             dt = median(diff(beh.data(i).events.samples.time));
            isOk = beh.data(j).events.samples.time>tPageStart(1) & beh.data(j).events.samples.time<tPageEnd(end);
            runLength = (tPageEnd(end)-tPageStart(1))/1000 * ...
                mean(~isnan(beh.data(j).events.samples.position(isOk,1))); % only count times when we had the eye
        else
            runLength = (tPageEnd(end)-tPageStart(1))/1000; % convert to s
        end
        isOk = beh.data(j).events.saccade.time_start>tPageStart(1) & beh.data(j).events.saccade.time_start<tPageEnd(end);
        sacRate_runs{i}(j) = sum(isOk)/runLength;
        isOk = beh.data(j).events.blink.time_start>tPageStart(1) & beh.data(j).events.blink.time_start<tPageEnd(end);
        blinkRate_runs{i}(j) = sum(isOk)/runLength;
    end
    sacRate_all(i) = mean(sacRate_runs{i});
    blinkRate_all(i) = mean(blinkRate_runs{i});
end
fprintf('Done!\n');