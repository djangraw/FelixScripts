% TestMultiWindowJlr_script.m

addpath('~/Dropbox/JitteredLogisticRegression/code/');
addpath('~/Dropbox/JitteredLogisticRegression/code/ReactionTimeRecovery/');

%% Load data
disp('Loading...')
ALLDATA = load('response_locked_data');
ALLPRIOR = load('jitterprior_pcatemplate');
ALLSETTINGS = load('pop_and_logist_settings');
disp('Done!')

%% Run Multi-Window JLR
iSubj = 1;

ALLEEG = ALLDATA.datastructs{iSubj};
pop_settings = ALLSETTINGS.pop_settings;
logist_settings = ALLSETTINGS.logist_settings;
jitterPrior = ALLPRIOR.jitterPrior{iSubj};

twlength = 50;
iMin = find(ALLEEG(1).times>=-500,1);
iMax = find(ALLEEG(1).times>=-50,1);
twoffset  = iMin:twlength:iMax;
D = ALLEEG(1).nbchan; 
P = length(twoffset);

% RUN TEST!
SetUpMultiWindowJlr_v1p0(ALLEEG,twlength,twoffset,zeros(D+1,P)+eps,jitterPrior,pop_settings,logist_settings);