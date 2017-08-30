function [HR, HRrest] = GetHeartRateDuringSinging(data)

% Created 5/23/17 by DJ.

conditions = data(1).params.trialTypes;
fs = 1/median(diff(data(1).physio.time));

nRuns = numel(data);
HR = nan(2,nRuns,numel(conditions));
HRrest = nan(7,nRuns);
for i=1:nRuns
    % Get peaks of HR trace
    [~,locs] = findpeaks(data(i).physio.pulseox.data,'MinPeakWidth',0.05*fs,'MinPeakDistance',0.4*fs);
    tPeaks = data(i).physio.time(locs);
    for j=1:numel(conditions)
        % Get times of blocks of this condition
        isInCond = strcmp(data(i).events.display.name,conditions{j});
        isBlockStart = diff(isInCond)>0;
        isBlockEnd = diff(isInCond)<0;        
        tStart = data(i).events.display.time(isBlockStart);
        tEnd = data(i).events.display.time(isBlockEnd);
        nBlocks = sum(isBlockStart);               
        % Get median HR in each block
        for k=1:nBlocks
            isInBlock = tPeaks>tStart(k) & tPeaks<tEnd(k);
            HR(k,i,j) = 1/median(diff(tPeaks(isInBlock)))*60; % convert to bpm
        end
    end
    % Get times of rest blocks
    isInCond = strcmp(data(i).events.display.name,'Fixation');
    isBlockStart = diff(isInCond)>0;
    isBlockEnd = diff(isInCond)<0;        
    tStart = data(i).events.display.time(isBlockStart);
    tEnd = data(i).events.display.time(isBlockEnd);
    nBlocks = sum(isBlockStart);               
    % Get median HR in each block
    for k=1:nBlocks
        isInBlock = tPeaks>tStart(k) & tPeaks<tEnd(k);
        HRrest(k,i) = 1/median(diff(tPeaks(isInBlock)))*60; % convert to bpm
    end
end