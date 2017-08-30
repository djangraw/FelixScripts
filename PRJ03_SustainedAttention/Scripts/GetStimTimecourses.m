function [stimTimecourse,stimTypes] = GetStimTimecourses(data,TR,nFirstTRsRemoved,nTRsPerSession)

% [stimTimecourse,stimTypes] = GetStimTimecourses(data,TR,nFirstTRsRemoved,nTRsPerSession)
%
% INPUTS:
% - data is an N-element vector of distraction task data structs with
% fields events.soundstart and events.display.
% -TR is a scalar indicating the duration of each fMRI acquisition in
% seconds.
% -nFirstTRsRemoved is a scalar indicating how many TRs were removed from
% the beginning of the session during preprocessing.
% -nTRsPerSession is a scalar indicating how many TRs are found in each
% session (AFTER removing the first TRs). 
%
% OUTPUTS:
% -stimTimecourse is an M x nTRsPerSession*N matrix, where M is the number
% of unique event types.
% -stimTypes is am M-element cell array of strings indicating the M unique
% event types.
%
% Created 10/6/16 by DJ based on WritePageTimesToAfniFiles.m.

% Declare defaults
if ~exist('TR','var') || isempty(TR)
    TR = 2;
end
if ~exist('nFirstTRsRemoved','var') || isempty(nFirstTRsRemoved)
    nFirstTRsRemoved = 3;
end
if ~exist('nTRsPerSession','var') || isempty(nTRsPerSession)
    nTRsPerSession = 246;
end
doRound = true;

fprintf('Getting page start & end times...\n')
[pageStartTimes,pageEndTimes,eventSessions,eventTypes] = GetEventBoldSessionTimes(data);
% Split white noise trials into those in attend/ignore blocks
isNoise = strcmp(eventTypes,'whiteNoise');
for i=1:numel(data)
    iInSession = find(eventSessions==i);
    iFirstHalf = iInSession(1:15);    
    iSecondHalf = iInSession(16:end);
    if strncmpi(data(i).params.promptType,'AttendReadingFirst',length('AttendReadingFirst'))
        eventTypes(iFirstHalf(isNoise(iFirstHalf))) = repmat({'ignoredNoise'},sum(isNoise(iFirstHalf)),1);
        eventTypes(iSecondHalf(isNoise(iSecondHalf))) = repmat({'attendedNoise'},sum(isNoise(iSecondHalf)),1);
    else
        eventTypes(iFirstHalf(isNoise(iFirstHalf))) = repmat({'attendedNoise'},sum(isNoise(iFirstHalf)),1);
        eventTypes(iSecondHalf(isNoise(iSecondHalf))) = repmat({'ignoredNoise'},sum(isNoise(iSecondHalf)),1);
    end
end
% get indices of start times
fprintf('Converting to TR indices...\n')
iPageStart_combo = ConvertBoldSessionTimeToComboTime(pageStartTimes,eventSessions,TR,nFirstTRsRemoved,nTRsPerSession,doRound);
% get indices of fixation events
iPageEnd_combo = ConvertBoldSessionTimeToComboTime(pageEndTimes,eventSessions,TR,nFirstTRsRemoved,nTRsPerSession,doRound);
% Get event types
stimTypes = unique(eventTypes);
nStimTypes = numel(stimTypes);

% Produce Timecourses
stimTimecourse = zeros(nStimTypes, nTRsPerSession*numel(data));
for i=1:nStimTypes
    iThis = find(strcmp(eventTypes,stimTypes{i}));
    for j=1:numel(iThis)
        stimTimecourse(i,iPageStart_combo(iThis(j)):iPageEnd_combo(iThis(j))) = 1;
    end
end
    