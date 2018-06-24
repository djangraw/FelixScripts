function [ALLEEG,EEG,setlist,saccadeTimes] = loadSubjectData(subject,saccadeType)

% Loads the data for a given subject that is needed to run the program
% run_logisticregression_jittered_EM_saccades.
%
% [ALLEEG,EEG,setlist,saccadeTimes] = loadSubjectData(subject)
%
% INPUTS:
% - subject is a string indicating the common prefix of one subject's data 
%   files, e.g. '3DS-TAG-2' for subject 2 on the 3DSearch/TAG experiment.
%
% OUTPUTS:
% - ALLEEG and EEG are the standard eeglab data structs.
% - setlist is a 2-element vector indicating the indices of the distractor 
%   and target datasets.
% - saccadeTimes is a struct containing the saccade start and end times in 
%   each target and distractor (each 2x2 combination of these is a
%   different field).
%
% Created 6/11 by BC.
% Updated 8/3/11 by DJ - comments.
% Updated 8/26/11 by DJ - added allToObject options for saccadeType

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
EEG = pop_loadset('filepath',['../Data/',subject],'filename',[subject,'-distractorappear.set'],'loadmode','all');
[ALLEEG,EEG,setlist(1)] = eeg_store(ALLEEG,EEG);
EEG = pop_loadset('filepath',['../Data/',subject],'filename',[subject,'-targetappear.set'],'loadmode','all');
[ALLEEG,EEG,setlist(2)] = eeg_store(ALLEEG,EEG);

% Load saccadeTimes struct
if strcmp(saccadeType,'start') || strcmp(saccadeType,'end')
    saccadeTimes = load(['../Data/',subject,'/',subject,'-SaccadeTimes.mat']);
elseif strcmp(saccadeType,'toObject_start') || strcmp(saccadeType,'toObject_end')
    saccadeTimes = load(['../Data/',subject,'/',subject,'-SaccadeToObject.mat']);
elseif strcmp(saccadeType,'allToObject_start') || strcmp(saccadeType,'allToObject_end')
    saccadeTimes = load(['../Data/',subject,'/',subject,'-AllSaccadesToObject.mat']);
else
    warning('Unknown saccade type - saccadeTimes will be blank');
    saccadeTimes = [];
end

