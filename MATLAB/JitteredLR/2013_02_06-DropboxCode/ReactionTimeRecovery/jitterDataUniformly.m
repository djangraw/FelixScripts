function [EEG,jitter] = jitterDataUniformly(EEG,jitterrange)

% Re-epochs the data around fake events that are jittered by a predictable
% amount.
%
% [EEG,jitter] = jitterDataUniformly(EEG,jitterrange)
%
% INPUTS:
% -EEG is an eeglab dataset with events at time zero of every epoch.
% -jitterrange is a 2-element vector indicating the min and max time (in
% ms) of the jitter you want to add.
%
% OUTPUTS:
% -EEG is the input set re-epoched around these fake events (type 999).
% -jitter is an EEG.trials-element vector in which jitter(i) is the jitter
% (in ms) that has been added to trial i.
% 
% Created 8/15/12 by DJ.

% Find uniform jitter
jitter = linspace(jitterrange(1),jitterrange(2),EEG.trials);

% Add events at these latencies
events = [repmat(999,1,EEG.trials); jitter]';
assignin('base','events',events);
% EEG = pop_importepoch(EEG,'events',{'A','B'},'typefield','A','latencyfields',{'B'},'clearevents','off');
for i=1:EEG.trials
    iZeroEvent = EEG.epoch(i).event(find([EEG.epoch(i).eventlatency{:}]==0,1));
    EEG.event(end+1) = EEG.event(iZeroEvent);
    EEG.event(end).latency = EEG.event(iZeroEvent).latency + jitter(i)/1000*EEG.srate;
    EEG.event(end).type = 999;
end

EEG = pop_editeventvals( EEG, 'sort', { 'latency', 0} );
EEG = eeg_checkset(EEG,'eventconsistency');

% Epoch around these events
tMin = (EEG.times(1)-jitter(1))/1000;
tMax = (EEG.times(end)-jitter(end))/1000;
EEG = pop_epoch(EEG,{999},[tMin, tMax]);
