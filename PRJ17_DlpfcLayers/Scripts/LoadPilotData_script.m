% LoadPilotData_script.m
% Created 10/25/17 by DJ.

files = [dir('LetterOrderTask_d2-DJ*.log'); dir('LetterOrderTask_d2-EF*.log')];
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
CascadeFigures(100+(1:numel(data)),4);

%% Save timing files
% for i=1:numel(data)
%     SaveLetterOrderTimingFiles(data(i));
% end

SaveLetterOrderTimingFiles(data(1:2),'LetterOrder-DJ-r1-r2');
SaveLetterOrderTimingFiles(data(3:4),'LetterOrder-DJ-r3-r4');
SaveLetterOrderTimingFiles(data(5:6),'LetterOrder-EF-r1-r2');
SaveLetterOrderTimingFiles(data(7),'LetterOrder-EF-r3');
