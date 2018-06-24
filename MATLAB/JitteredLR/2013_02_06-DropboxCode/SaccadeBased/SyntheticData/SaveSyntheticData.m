function [ALLEEG, EEG, a] = SaveSyntheticData(subject, fracFirstSaccade, SNR_parallel, SNR_orthogonal)

% Create synthetic data using CreateSyntheticData.m and save it to the
% given subject's EEGLAB datasets.
%
% SaveSyntheticData(subject)
%
% This file should only be called from the 'code' directory on Dropbox.
%
% INPUTS:
% -subject is an integer indicating the subject number.
%
% Created 8/30/11 by DJ
% Updated 9/22/11 by DJ - added fracFirstSaccade, SNR(_parallel) inputs

% Declare defaults
if ~exist('fracFirstSaccade','var')
    fracFirstSaccade = 0.9;
end
if ~exist('SNR','var')
    SNR = 1;
end
if ~exist('SNR_parallel','var')
    SNR_parallel = 10;
end


% Set up
ALLEEG = []; EEG = [];
datapath = sprintf('../Data/3DS-TAG-%d-synth/',subject);
filename1 = sprintf('3DS-TAG-%d-synth-targetappear.set',subject);
filename2 = sprintf('3DS-TAG-%d-synth-distractorappear.set',subject);
saccadeFilename = sprintf('%s3DS-TAG-%d-synth-AllSaccadesToObject',datapath,subject);
halfWidth = 6; % number of samples to each side of t=0 where the signal should extend

% Load datasets
disp('-Loading...')
EEG = pop_loadset(filename1,datapath);
[ALLEEG,EEG,CURRENTSET] = eeg_store(ALLEEG,EEG);
EEG = pop_loadset(filename2,datapath);
[ALLEEG,EEG,CURRENTSET] = eeg_store(ALLEEG,EEG);
saccadeTimes = load(saccadeFilename);

% Create synthetic data
disp('-Synthesizing...')
[a.data1,a.data2,a.weights,a.posteriors1,a.posteriors2] = CreateSyntheticData(saccadeTimes,...
    [0 2]*EEG.srate,EEG.times,EEG.nbchan,fracFirstSaccade,halfWidth,SNR_parallel,SNR_orthogonal);

% Add synthetic data to datasets
ALLEEG(1).data = a.data1;
ALLEEG(2).data = a.data2;

% Add other info to datasets
ALLEEG(1).etc = a;
ALLEEG(2).etc = a;

% Save datasets
disp('-Saving...')
ALLEEG(1) = pop_saveset(ALLEEG(1),'filename',filename1,'filepath',datapath);
ALLEEG(2) = pop_saveset(ALLEEG(2),'filename',filename2,'filepath',datapath);

disp('-Success!')