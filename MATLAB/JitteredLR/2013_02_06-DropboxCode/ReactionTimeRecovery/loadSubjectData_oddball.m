function [ALLEEG,EEG,setlist,reactionTimes] = loadSubjectData_oddball(subject)

% Loads the data for a given subject that is needed to run the program
% run_logisticregression_jittered_EM_saccades.
%
% [ALLEEG,EEG,setlist,reactionTimes] = loadSubjectData_oddball(subject)
%
% INPUTS:
% - subject is a string indicating the common prefix of one subject's data 
%   files, e.g. 'ao_ps_sti' for subject ps on the auditory oddball experiment.
%
% OUTPUTS:
% - ALLEEG and EEG are the standard eeglab data structs.
% - setlist is a 2-element vector indicating the indices of the distractor 
%   and target datasets.
% - saccadeTimes is a struct containing the saccade start and end times in 
%   each target and distractor (each 2x2 combination of these is a
%   different field).
%
% Created 8/15/12 by DJ based on loadSubjectData.m.

% start eeglab and get eeglab variables
eeglab('nogui');
global ALLEEG EEG CURRENTSET;
setlist = zeros(2,1);

% clear ALLEEG
if ~isempty(ALLEEG)
    ALLEEG = pop_delset(ALLEEG,1:length(ALLEEG));
end

if ~exist('saccadeType'); saccadeType = 'start'; end;

% Load distractor and target datasets
EEG = pop_loadset('filepath','../Data/AuditoryOddball_fromLinbi/','filename',[subject, '-std_5 runs.set'],'loadmode','all');
[ALLEEG,EEG,setlist(1)] = eeg_store(ALLEEG,EEG);
EEG = pop_loadset('filepath','../Data/AuditoryOddball_fromLinbi/','filename',[subject,'-odd_5 runs.set'],'loadmode','all');
[ALLEEG,EEG,setlist(2)] = eeg_store(ALLEEG,EEG);

% Load saccadeTimes struct
reactionTimes.standard = [ALLEEG(setlist(1)).event([ALLEEG(setlist(1)).event.type]==200).latency]-[ALLEEG(setlist(1)).event([ALLEEG(setlist(1)).event.type]==50).latency];
reactionTimes.oddball = [ALLEEG(setlist(2)).event([ALLEEG(setlist(2)).event.type]==150).latency]-[ALLEEG(setlist(2)).event([ALLEEG(setlist(2)).event.type]==100).latency];

% TEMP FLIP!
% ALLEEG = ALLEEG([2 1]);