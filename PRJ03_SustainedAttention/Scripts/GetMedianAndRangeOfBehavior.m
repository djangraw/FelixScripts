function GetMedianAndRangeOfBehavior(subjects)

% GetMedianAndRangeOfBehavior(subjects)
%
% Created 8/29/17 by DJ.

% Set up
vars = GetDistractionVariables;
homedir = vars.homedir;
nSubj = numel(subjects);
[nRuns,tRead] = deal(nan(1,nSubj));
tRead_run = cell(1,nSubj);
% Load & calculate
fprintf('===Loading data for %d subjects...\n',nSubj);
for i=1:nSubj
    % load behavior data
    beh = load(sprintf('%s/Results/SBJ%02d/Distraction-SBJ%02d-Behavior.mat',homedir,subjects(i),subjects(i)));
    % Get nRuns
    nRuns(i) = numel(beh.data);
    tRead_run{i} = nan(1,nRuns(i));
    for j=1:nRuns(i)
        iStart = find(strncmp(beh.data(j).events.display.name,'Page',4),1);
        iStop = find(strcmp(beh.data(j).events.display.name,'TakeABreak'),1);
        tRead_run{i}(j) = (beh.data(j).events.display.time(iStop)-beh.data(j).events.display.time(iStart))/1000; % convert to sec
    end
    tRead(i) = median(tRead_run{i});
end
fprintf('===Done!\n');
fprintf('===Results:\n');
% Calculate median and range
medRuns = median(nRuns);
rangeRuns = [min(nRuns), max(nRuns)];
medTime = median(tRead);
rangeTime = [min([tRead_run{:}]), max([tRead_run{:}])];
fprintf('# Runs: %g-%g, median %g\n',rangeRuns,medRuns); 
fprintf('time/run (s): %g-%g, median %g\n',rangeTime,medTime); 
fprintf('time/run (m): %g-%g, median %g\n',rangeTime/60,medTime/60); 

