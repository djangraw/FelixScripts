function [iEvent_combo] = ConvertBoldSessionTimeToComboTime(eventTimes,eventSessions,TR,nFirstTRsRemoved,nTRsPerSession,doRound)

% [iEvent_combo] = ConvertBoldSessionTimeToComboTime(eventTimes,eventSessions,TR,nTRsPerSession,nFirstTRsRemoved,doRound)
%
% INPUTS: 
% -eventTimes is an N-element vector in which eventTimes(i) is the time (in
% seconds relative to the first trigger event) of each event. 
% -eventSessions is an N-element vector of the session in which each of
% these events occurred.
% -TR is a scalar indicating the duration of each fMRI acquisition in
% seconds.
% -nFirstTRsRemoved is a scalar indicating how many TRs were removed from
% the beginning of the session during preprocessing.
% -nTRsPerSession is a scalar indicating how many TRs are found in each
% session (AFTER removing the first TRs). 
% -doRound is a boolean value indicating whether the times should be
% rounded to the nearest index or left as decimals.
%
% OUTPUTS:
% -iEvent_combo is an N-element vector of the index of the data point in
% the combo BOLD file that corresponds to the time when the input events
% occurred. 
%
% Created 3/11-14/16 by DJ.

% Declare defaults
if ~exist('doRound','var') || isempty(doRound)
    doRound = true;
end

% times within session
nSessions = max(eventSessions);
tTR_session = ((1:nTRsPerSession)+nFirstTRsRemoved-1)*TR;

% set up interp method
if doRound
    interpMethod = 'nearest';
else
    interpMethod = 'linear';
end

% get indices of events
iEvent_combo = nan(size(eventTimes));
for i=1:nSessions
    % Get offset for this session
    sessionOffset = (i-1)*nTRsPerSession; % indices in this session are sessionOffset + (1:nTRsPerSession)
    % Find times of event within session
    isEventInSession = (eventSessions==i);     
    iTrWithinSession = interp1(tTR_session,1:numel(tTR_session),eventTimes(isEventInSession),interpMethod,NaN); % anything before first or after last TR will be NaN.
    % translate to index of event within combo file
    iEvent_combo(isEventInSession) = iTrWithinSession + sessionOffset;
end
