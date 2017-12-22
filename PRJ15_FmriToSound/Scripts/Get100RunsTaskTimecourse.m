function [taskTc, tTask] = Get100RunsTaskTimecourse(subject,session,task)

% [taskTc,tTask] = Get100RunsTaskTimecourse(subject,session,task)
%
% Created 12/20/17 by DJ.


text_file = sprintf('SBJ%02d_S%02d_Task%02d_respLog.txt',subject,session,task);
events = Parse100RunsEventsLog(text_file);

tEnd = 320;
dt = 0.5;
tTask = 0:dt:tEnd;

taskTc = zeros(3,numel(tTask));
nBlocks = numel(events.block.time);
tStart = events.key.time(1);
for i=1:nBlocks
    tBlockStart = events.block.time(i)-tStart;
    taskTc(1,tTask>=tBlockStart) = strcmp(events.block.type{i},'Stim');
end
nTrial = numel(events.trial.time);
for i=1:nTrial
    tTrial = events.trial.time(i)-tStart;
    if isnan(str2double(events.trial.char{i})) % number
        taskTc(2,find(tTask>=tTrial,1)) = 1;
    else
        taskTc(2,find(tTask>=tTrial,1)) = 2;
    end
end
nKey = numel(events.key.time);
for i=1:nKey
    tKey = events.key.time(i)-tStart;
    if strcmp(events.key.char{i},'b') % #? Letter? switches by task.
        taskTc(3,find(tTask>=tKey,1)) = 1;
    elseif strcmp(events.key.char{i},'r')
        taskTc(3,find(tTask>=tKey,1)) = 2;
    end
end
    