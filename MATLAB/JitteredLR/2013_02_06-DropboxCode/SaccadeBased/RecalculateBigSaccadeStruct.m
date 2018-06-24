% subject = 2; sessions = 41:48;
% subject = 14; sessions = 1:8;
% subject = 15; sessions = 4:11;
% subject = 16; sessions = 1:8;
% subject = 19; sessions = 2:11;
subject = 6; sessions = 1:8;
substring = sprintf('SQ-%d',subject);
prefix = 'sq';

%% Get Behavioral data
for i=1:numel(sessions)
    load(sprintf('%s-%d-%d.mat',prefix,subject,sessions(i)));
    y(i) = x;
end

%% Load EEG stuff
ALLEEG = [];
EEG = pop_loadset(sprintf('%s-targetappear.set',substring),substring);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG);
EEG = pop_loadset(sprintf('%s-distractorappear.set',substring),substring);
[ALLEEG EEG] = eeg_store(ALLEEG, EEG);

%% Get BigSaccade structdbquit
BigSaccade = GetBigSaccadeStruct(ALLEEG,y);
save(sprintf('%s/%s-BigSaccade',substring,substring),'BigSaccade');