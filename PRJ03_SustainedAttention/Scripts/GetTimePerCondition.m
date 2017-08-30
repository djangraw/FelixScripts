function [timePerCondition_all,timePerCondition_runs, conditions] = GetTimePerCondition(subjects)

% [timePerCondition_all,timePerCondition_runs, conditions] = GetTimePerCondition(subjects)
%
% INPUTS:
% -subjects is an n-element vector of subject numbers.
%
% OUTPUTS:
% -timePerCondition_all is an nxm matrix in which element (i,k) is the
% seconds spent in condition k by subject i.
% -timePerCondition_runs is an n-element cell array containing pxm matrices
% where p is the number of runs for a subject. nSacc_runs{i}(j,k) is the
% number of saccades/s in subject i's run j, condition k.
%
% Created 4/6/17 by DJ.

nSubj = numel(subjects);
beh = load(sprintf('/data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ%02d/Distraction-SBJ%02d-Behavior.mat',subjects(1),subjects(1)));
conditions = unique(beh.data(1).events.soundstart.name);
conditions(strcmp(conditions,'switchSound')) = [];
nCond = numel(conditions);
[timePerCondition_runs] = deal(cell(1,nSubj));
[timePerCondition_all] = deal(nan(nSubj,nCond));

for i=1:nSubj
    fprintf('Loading subject %d/%d...\n',i,nSubj);
    beh = load(sprintf('/data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ%02d/Distraction-SBJ%02d-Behavior.mat',subjects(i),subjects(i)));
    [timePerCondition_runs{i}] = deal(nan(numel(beh.data),nCond));
    for j=1:numel(beh.data)
        [tPageStart,tPageEnd] = GetPageTimes(beh.data(j).events);
        pageDur = tPageEnd-tPageStart;
        [~,iCond] = ismember(beh.data(j).events.soundstart.name,conditions);
        iCond(iCond==0) = []; % remove switchSound to make same length as page list
        for k=1:nCond
            timePerCondition_runs{i}(j,k) = sum(pageDur(iCond==k));
        end
    end
    timePerCondition_all(i,:) = sum(timePerCondition_runs{i},1);
end
fprintf('Done!\n');