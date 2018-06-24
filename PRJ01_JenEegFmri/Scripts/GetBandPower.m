function [bandPower, tTR, bpf] = GetBandPower(EEG,filtercutoffs,eventname)

% Created 1/9/15 by DJ.
% Updated 1/13/15.

if ~exist('eventname','var')
    eventname = 'R128';
end

% create filter
% apply filter
[EEG,~,bpf.b,bpf.a] = pop_iirfilt_returnfilter(EEG, filtercutoffs(1), filtercutoffs(2));

% get TR times
isTRevent = strcmp(eventname,{EEG.event.type});
tTR = [EEG.event(isTRevent).latency]/EEG.srate;
nTR = length(tTR);
% get average power in each TR
bandPower = zeros(EEG.nbchan,nTR-1);
time_s = EEG.times/1000;
for i=1:nTR-1
    if i<nTR
        isInWin = time_s>tTR(i) & time_s<=tTR(i+1);
    else
        isInWin = time_s>tTR(i);
    end
    bandPower(:,i) = sqrt(mean(EEG.data(:,isInWin).^2,2));
end
% crop to only full TRs
tTR = tTR(1:end-1);

