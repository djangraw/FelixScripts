% GetFcTemplateMatch_script.m
%
% Created 5/2/16 by DJ.

% Set up
subject = 'SBJ27';
filename = sprintf('shen268_%s_ROI_TS.1D',subject);
winLength = 10; % in TRs
TR = 2; % in seconds

% Load data
fprintf('Loading data...\n')
attnNets = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/attn_nets_268.mat');
[err,M,Info,Com] = Read_1D(filename);

if size(M,2) ~= size(attnNets.pos_overlap,1)
    error('Size of M and attnNets.pos_overlap do not match!')
end

%%
fprintf('Getting match timecourses...\n')
% Get match timecourse
posMatch = GetFcTemplateMatch(M',attnNets.pos_overlap,winLength);
negMatch = GetFcTemplateMatch(M',attnNets.neg_overlap,winLength);

% Plot results
fprintf('Plotting match timecourses...\n')
t = (1:numel(posMatch))*TR;
plot(t,[posMatch,negMatch]);
xlabel('time (s)');
ylabel('match strength (correlation coeff)')
title(subject)
legend('positive attention','negative attention');

%% Add arousal template match and plot
% (run GetSpatialTemplateMatch_script.m first)
% Smooth arousal template
templateMatch_smooth = conv(templateMatch,ones(1,winLength),'valid');
% Plot results
fprintf('Plotting match timecourses...\n')
t = (1:numel(posMatch))*TR;
plot(t,[templateMatch_smooth', posMatch-negMatch]);
xlabel('time (s)');
ylabel('match strength (correlation coeff)')
title(subject)
legend('arousal','positive - negative attention');

%% Get FC template match across subjects and compare to percent correct
subjects = 9:28;
attnNets = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/attn_nets_268.mat');
TR = 2; % in seconds
[posMatch_subj,negMatch_subj,acc_read,acc_ign,acc_att] = deal(nan(1,numel(subjects)));
for i=1:numel(subjects)
    subject = subjects(i);
    % go into AfniProc folder
    cd('/data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ%02d',subject)
    D = dir('AfniProc*');
    cd(D(1).name);
    % get Shen atlas timecourses
    filename = sprintf('shen268_SBJ%02d_ROI_TS.1D',subject);

    % Load data
    fprintf('Loading data...\n')
    [err,M,Info,Com] = Read_1D(filename);
    cd ..
    behavior = load(sprintf('Distraction-%d-QuickRun',subject);

    if size(M,2) ~= size(attnNets.pos_overlap,1)
        error('Size of M and attnNets.pos_overlap do not match!')
    end
    winLength = size(M,1); % whole session
    posMatch_subj(i) = GetFcTemplateMatch(M',attnNets.pos_overlap,winLength);
    negMatch_subj(i) = GetFcTemplateMatch(M',attnNets.neg_overlap,winLength);
    
    % Get percent correct on questions
    isRead = strcmp(behavior.question.type,'reading');
    isIgn = strcmp(behavior.question.type,'ignoreSound');
    isAtt = strcmp(behavior.question.type,'attendSound');
    acc_read(i) = mean(behavior.question.isCorrect(isRead));
    acc_ign(i) = mean(behavior.question.isCorrect(isIgn));
    acc_att(i) = mean(behavior.question.isCorrect(isAtt));

end
