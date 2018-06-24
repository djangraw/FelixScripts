function data = ImportSingingData(filename)

% Import data from SingingTask.py log.
%
% Created 3/17/17 by DJ. 

if nargin==0
    filename = 'Singing-1-1-TEST.log'; % demo
end

% parse info
params = PsychoPy_ParseParams(filename,'START PARAMETERS','END PARAMETERS');
events = PsychoPy_ParseEvents(filename,{'key','display'},'START EXPERIMENT');

% get trial timing info
trialTypes = {'Exercise','Speak','Sing'};
tTrialStart = cell(1,numel(trialTypes));
for i=1:numel(trialTypes)
    trialStartMsg = sprintf('%s(1/',trialTypes{i});
    isTrialStart = strncmp(events.display.name,trialStartMsg,length(trialStartMsg));
    tTrialStart{i} = events.display.time(isTrialStart);
end
tTrialStart_all = sort(cat(1,tTrialStart{:}),'ascend');
ITI = diff(tTrialStart_all);

% Plot ITI histogram
figure(723); clf; hold on;
hist(ITI);
PlotVerticalLines(params.trialTime+params.msgTime + params.restTime,'r--');
xlabel('ITI (sec)')
ylabel('# trials')
legend('histogram','specified in params')

% make data struct
data.params = params;
data.events = events;
