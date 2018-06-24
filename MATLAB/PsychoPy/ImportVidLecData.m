function data = ImportVidLecData(filename)

% Created 1/26/15 by DJ. 

if nargin==0
    filename = 'VidLec-1-1-DEMO.log'; % demo
end

params = PsychoPy_ParseParams(filename,'START PARAMETERS','END PARAMETERS');
events = PsychoPy_ParseEvents(filename,[],'START EXPERIMENT');
[quiz.questions,quiz.options,quiz.answers] = PsychoPy_ParseQuestions([params.movieDir params.questionsFilename]);
respKeys = {'1','2','3','4','5'};

% get performance on probes
isProbe = (strncmp('Probe',events.display.name,5));
tProbes = events.display.time(isProbe);
nProbes = numel(tProbes);
[probe.response, probe.RT] = deal(nan(nProbes,1));
for i=1:nProbes    
    iFirstKey = find(events.key.time > tProbes(i) & ismember(events.key.char,respKeys),1);    
    probe.RT(i) = events.key.time(iFirstKey) - tProbes(i);
    probe.response(i) = str2double(events.key.char(iFirstKey));
end
% gt performance on questions
isTrial = (strncmp('Question',events.display.name,8) & ~strcmp('QuestionTime',events.display.name));
tTrials = events.display.time(isTrial);
nTrials = numel(tTrials);
[performance.isCorrect, performance.RT] = deal(nan(nTrials,1));
for i=1:nTrials    
    iFirstKey = find(events.key.time > tTrials(i) & ismember(events.key.char,respKeys),1);    
    performance.RT(i) = events.key.time(iFirstKey) - tTrials(i);
    performance.isCorrect(i) = strcmp(events.key.char(iFirstKey),num2str(quiz.answers(i)));
end

% get wandering catch presses
state.tWanders = events.key.time(strcmp(params.wanderKey,events.key.char));

% prepare output
data.params = params;
data.events = events;
data.performance = performance;
data.state = state;
data.state.probe = probe;
data.quiz = quiz;

% ==== BEGIN PLOTTING ==== %

% Set up plot
clf;
h = zeros(2,2); % plots
MakeFigureTitle(filename);

% --- 1. Plot single-trial performance
starttime = events.block.time(1);
timeontask = tProbes - starttime;
% set up plot
clf;
h(1,1) = subplot(2,1,1); hold on;
ylim([0 6])
bar(timeontask,probe.response);
PlotVerticalLines(state.tWanders-starttime,'m--');
xlabel('time on task (s)')
ylabel('Probe Responses')
set(gca,'ytick',1:5,'yticklabel',{'current task','current stim','other task','MW','sleep'});
legend('probes','MW keypress')

h(2,1) = subplot(2,1,2); hold on;
% starttime = events.display.time(strcmp(events.display.name,'QuestionTime'));
% timeontask = tTrials - starttime;
plot(performance.RT,'.-');
if any(~performance.isCorrect)
    plot(find(~performance.isCorrect),performance.RT(~performance.isCorrect),'ro');
else
    plot(-1,-1,'ro'); % for legend
end
xlim([0 length(performance.RT)])
xlabel('quiz question number')
ylabel('RT (s)');
legend('all trials','errors');






