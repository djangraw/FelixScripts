function RT = getRT(EEG,responseevent)

% Created 8/16/12 by DJ.
% Updated 8/21/12 by DJ.

RT = nan(1,EEG.trials);
if ischar(responseevent)
    for i=1:EEG.trials
        isResponse = strcmp(EEG.epoch(i).eventtype,responseevent);
        RT(i) = EEG.epoch(i).eventlatency{isResponse};
    end
else
    for i=1:EEG.trials
        isResponse = [EEG.epoch(i).eventtype{:}]==responseevent;
        RT(i) = EEG.epoch(i).eventlatency{isResponse};
    end
end    