function [pd_all,pd_runs] = GetSubjectPupilDilation(subjects,delay)

% [pd_all,pd_runs] = GetSubjectPupilDilation(subjects,delay)
%
% INPUTS:
% -subjects is an n-element vector of subject numbers.
% -delay is a scalar indicating the time, in seconds, that you expect the
% pupillary response to be delayed relative to the stimulus.
%
% OUTPUTS:
% -pd_all is an n-element vector of the pupil dilation for each subject
% during the task (text - fixation), mean across all pages & runs.
% -pd_runs is an n-element cell array containing m-element vectors,
% where m is the number of runs for a subject. pd_runs{i}(j) is the
% mean pupil dilation in subject i's run j.
%
% Created 1/24/17 by DJ.

if ~exist('delay','var') || isempty(delay)
    delay = 0;
end

nSubj = numel(subjects);
[pd_runs] = deal(cell(1,nSubj));
[pd_all] = deal(nan(1,nSubj));

for i=1:nSubj
    fprintf('Loading subject %d/%d...\n',i,nSubj);
    beh = load(sprintf('/data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ%02d/Distraction-SBJ%02d-Behavior.mat',subjects(i),subjects(i)));
    [pd_runs{i}] = deal(nan(1,numel(beh.data)));
    for j=1:numel(beh.data)
        PD = sqrt(sum(beh.data(j).events.samples.PD.^2,2));
        t = beh.data(j).events.samples.time;
        [tPageStart,tPageEnd] = GetPageTimes(beh.data(j).events);
        isInPage = false(size(t));
        for k=1:numel(tPageEnd)
            isInPage(t>(tPageStart(k)+delay) & t<(tPageEnd(k)+delay)) = true;
        end
        isInRun = t>(tPageStart(1)+delay) & t<(tPageEnd(end)+delay);
        pd_runs{i}(j) = nanmean(PD(isInPage & isInRun)) - nanmean(PD(~isInPage & isInRun));
    end
    pd_all(i) = mean(pd_runs{i});
end
fprintf('Done!\n');