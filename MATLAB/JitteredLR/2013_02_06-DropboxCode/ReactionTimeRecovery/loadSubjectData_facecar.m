function [ALLEEG,EEG,setlist,reactionTimes] = loadSubjectData_facecar(subject)

% Loads the data for a given subject that is needed to run the program
% run_logisticregression_jittered_EM_saccades.
%
% [ALLEEG,EEG,setlist,reactionTimes] = loadSubjectData_facecar(subject)
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
% Updated 9/18/12 by DJ - added eeg_checkset, replaced pop_delset with []
% Updated 9/27/12 by DJ - SWITCHED FACES AND CARS!!!

% start eeglab and get eeglab variables
eeglab('nogui');
global ALLEEG EEG CURRENTSET;
setlist = zeros(2,1);

% clear ALLEEG
if ~isempty(ALLEEG)
    ALLEEG = [];
%     ALLEEG = pop_delset(ALLEEG,1:length(ALLEEG));
end

% Load distractor and target datasets
EEG = pop_loadset('filepath','../Data/FaceCar_fromJason/','filename',['facecar_', subject, '_C_45_correct.set'],'loadmode','all');
EEG = eeg_checkset(EEG);
[ALLEEG,EEG,setlist(1)] = eeg_store(ALLEEG,EEG);
EEG = pop_loadset('filepath','../Data/FaceCar_fromJason/','filename',['facecar_', subject, '_F_45_correct.set'],'loadmode','all');
EEG = eeg_checkset(EEG);
[ALLEEG,EEG,setlist(2)] = eeg_store(ALLEEG,EEG);

% Load saccadeTimes struct
reactionTimes.car = getRT(ALLEEG(setlist(1)),'RT');
reactionTimes.face = getRT(ALLEEG(setlist(2)),'RT');


