%% load data from a subject
files = dir('Flanker-2*.log');
filenames = {files.name}; 
clear data
for iFile = 1:numel(filenames)
    data(iFile) = ImportFlankerData(filenames{iFile});
end
%% plot deadlines at they would be computed with fewer trials
figure(1); clf;
fracUnder = 0.9;
clear h
for iFile = 1:numel(filenames)
    deadlines = zeros(1,100); 
    for i=1:100
        deadlines(i) = CalculateRtDeadline(data(iFile),'Flanker',fracUnder,i);
    end
    
    h(iFile) = subplot(2,2,iFile);
    plot(deadlines);
    xlabel('# trials included');
    ylabel(sprintf('%dth-percentile RT (s)',fracUnder*100));    
    title(filenames{iFile},'interpreter','none');
end
linkaxes(h);


%% Get new RT deadline

% filename = 'AudSart-2-4-Jan_26_1741.log';
% data = ImportAudSartData(filename);
% RTsorted = sort(data.performance.RT(~data.performance.isTarget),'ascend');

filename = 'Flanker-2-5-Jan_26_1525.log';
data = ImportFlankerData(filename);
RTsorted = sort(data.performance.RT,'ascend');
fracUnder = 0.9;
newThreshold = interp1((1:length(RTsorted))/length(RTsorted), RTsorted, fracUnder);
fprintf('%g %% of trials have RTs under %g ms.\n',fracUnder*100,newThreshold*1000);