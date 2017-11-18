% LoadPilotData_script.m
%
% Created 10/25/17 by DJ.
% Updated 11/8/17 by DJ - new pilots

% files = [dir('LetterOrderTask_d2-DJ*.log'); dir('LetterOrderTask_d2-EF*.log')];
% files = [dir('LetterOrderTask_d3-1-*.log')]; % for SBJ01
files = [dir('LetterOrderTask_d4-2-*.log')]; % for SBJ02

filenames = {files(:).name};

clear data;
for i=1:numel(filenames)
    data(i) = ImportLetterOrderData_PsychoPy(filenames{i});
end

%% Plot Behavior
for i=1:numel(data)
    figure(100+i); clf;
    GetLetterOrderReactionTimes(data(i),true);
    MakeFigureTitle(sprintf('RTs: %s',data(i).params.filename));
end
CascadeFigures(100+(1:numel(data)),3);

%% Save timing files
% for i=1:numel(data)
%     SaveLetterOrderTimingFiles(data(i));
% end

% For SBJ DJ&EF
% SaveLetterOrderTimingFiles(data(1:2),'LetterOrder-DJ-r1-r2');
% SaveLetterOrderTimingFiles(data(3:4),'LetterOrder-DJ-r3-r4');
% SaveLetterOrderTimingFiles(data(5:6),'LetterOrder-EF-r1-r2');
% SaveLetterOrderTimingFiles(data(7),'LetterOrder-EF-r3');

% For SBJ01
% SaveLetterOrderTimingFiles(data(1:2),'LetterOrder-1-r1-r2');
% SaveLetterOrderTimingFiles(data(3:4),'LetterOrder-1-r3-r4');

% For SBJ02
SaveLetterOrderTimingFiles(data(1),'LetterOrder-2-r1');
SaveLetterOrderTimingFiles(data(2:4),'LetterOrder-2-r2-r4');
SaveLetterOrderTimingFiles(data(5:6),'LetterOrder-2-r5-r6');
