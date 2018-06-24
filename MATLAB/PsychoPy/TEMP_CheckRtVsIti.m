% TEMP_CheckRtVsIti.m
%
% See if RT and ITI are related in a given task/subject.
%
% Created 1/27/15 by DJ.

%% load data from a subject
files = dir('Flanker-2*.log');
filenames = {files.name}; 
clear data
for iFile = 1:numel(filenames)
    data(iFile) = ImportFlankerData(filenames{iFile});
end

%%
N = numel(data);
[RT, TOT, ITI, isC] = deal(cell(1,N)); % rxn time, time-on-task, inter-trial interval (BEFORE)
for i=1:N
    isC{i} = data(i).performance.isCongruent;
    RT{i} = data(i).performance.RT;
    TOT{i} = data(i).events.display.time(ismember(data(i).events.display.name,{'LeftTarget','RightTarget'}));
    ITI{i} = [nan; diff(TOT{i})]; % before current trial
end
isC = cat(1,isC{:})>0;
RT = cat(1,RT{:});
TOT = cat(1,TOT{:});
ITI = cat(1,ITI{:});
% remove nans
isGood = ~isnan(ITI);
isC = isC(isGood);
RT = RT(isGood);
TOT = TOT(isGood);
ITI = ITI(isGood);

%% Get regressions
[coeffC, sC] = polyfit(ITI(isC),RT(isC),1);
[coeffI, sI] = polyfit(ITI(~isC),RT(~isC),1);

%% plot results

clf;
cla; hold on;
scatter(ITI(isC),RT(isC),'b.');
scatter(ITI(~isC),RT(~isC),'r.');
xLine = get(gca,'xlim');
plot(xLine,xLine*coeffC(1)+coeffC(2),'b-');
plot(xLine,xLine*coeffI(1)+coeffI(2),'r-');
xlabel('ITI (s)')
ylabel('RT (s)');
title(sprintf('Flanker-2, %d files',N));
legend('coherent','incoherent');