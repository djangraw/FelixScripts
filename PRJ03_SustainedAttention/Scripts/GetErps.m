function [erp,tErp] = GetErps(roi_ts,t,tEvents,tWin)

% Created 1/25/17 by DJ.

% Set up
nEvents = numel(tEvents);
nRois = size(roi_ts,2);
dt = median(diff(t));
tErp = tWin(1):dt:tWin(2);
nT = numel(tErp);
erp = nan(nT,nRois,nEvents);
% Loop
for i=1:nEvents
    isInWin = t>=(tEvents(i)+tWin(1)) & t<=(tEvents(i)+tWin(2));
    erp(:,:,i) = roi_ts(isInWin,:);
end
