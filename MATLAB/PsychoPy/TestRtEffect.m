function TestRtEffect(filenames,filetype)
% filenames = {'BopIt-1-1-Jan_02_1406.log','BopIt-1-2-Jan_06_1647.log','BopIt-1-3-Jan_07_1358.log'};
if ischar(filenames)
    filenames = {filenames}; % for single file
end
if iscell(filenames)
    for i=1:numel(filenames)
        figure(i);
        switch filetype
            case 'BopIt'
                data(i) = ImportBopItData(filenames{i});
            case 'Sart'
                data(i) = ImportSartData(filenames{i});
            case 'AudSart'
                data(i) = ImportAudSartData(filenames{i});
            case 'Tapping'
                data(i) = ImportTappingData(filenames{i});
            case 'Flanker'
                data(i) = ImportFlankerData(filenames{i});
        end
    end
else
    data = filenames;
end

%%
[RtCorrect_cell, RtError_cell, RtPreCorrect_cell, RtPreError_cell] = deal(cell(1,3));
for i=1:numel(data)
    RT = data(i).performance.RT;    
    isCorrect = data(i).performance.isCorrect~=0;
%     if strcmpi(filetype,'Sart')
%         isTarget = data(i).performance.isTarget~=0;
%     else
        isTarget = true(size(isCorrect)); % all trials are fair play
%     end
    if strcmpi(filetype,'Flanker')
        isCongruent = data(i).performance.isCongruent;
        RtCorrect_cell{i} = RT(isCorrect & ~isCongruent);
        RtError_cell{i} = RT(~isCorrect & ~isCongruent);
        RtPreCorrect_cell{i} = RT(isCorrect & isCongruent);
        RtPreError_cell{i} = RT(~isCorrect & isCongruent);
    else
        RtCorrect_cell{i} = RT(isCorrect & isTarget);
        RtError_cell{i} = RT(~isCorrect & isTarget);
        RtPreCorrect_cell{i} = RT(isCorrect & [isCorrect(2:end) & isTarget(2:end); 0]);
        RtPreError_cell{i} = RT(isCorrect & [~isCorrect(2:end) & isTarget(2:end); 0]);
    end
end
%concatenate
RtCorrect = cat(1,RtCorrect_cell{:});
RtError = cat(1,RtError_cell{:});
RtPreCorrect = cat(1,RtPreCorrect_cell{:});
RtPreError = cat(1,RtPreError_cell{:});
%histogram it
maxRT = max([RtCorrect; RtError]);
xHist = 0:.04:maxRT;
pctHist = zeros(4,length(xHist));
pctHist(1,:) = hist(RtCorrect,xHist)/length(RtCorrect)*100;
pctHist(2,:) = hist(RtError,xHist)/length(RtError)*100;
pctHist(3,:) = hist(RtPreCorrect,xHist)/length(RtPreCorrect)*100;
pctHist(4,:) = hist(RtPreError,xHist)/length(RtPreError)*100;
n = [numel(RtCorrect),numel(RtError),numel(RtPreCorrect), numel(RtPreError)];
% plot
figure(numel(data)+1); clf; hold on;
plot(xHist*1000,pctHist);
% plot RT deadline
rtDeadline = nan(1,numel(data));
for i=1:numel(data)    
    if isfield(data(i).params,'rtDeadline')
        rtDeadline(i) = data(i).params.rtDeadline;
    end
    PlotVerticalLines(unique(rtDeadline)*1000,'m:'); % in ms
end
% annotate
if strcmpi(filetype,'Flanker')
    legend(sprintf('Correct Incongruent (n=%d)',n(1)),sprintf('Error Incongruent (n=%d)',n(2)),sprintf('Correct Congruent (n=%d)',n(3)),sprintf('Incorrect Congruent (n=%d)',n(4)),'RT deadline(s)')
else
    legend(sprintf('Correct (n=%d)',n(1)),sprintf('Error (n=%d)',n(2)),sprintf('Pre-Correct (n=%d)',n(3)),sprintf('Pre-Error (n=%d)',n(4)),'RT deadline(s)')
end
xlim([min(xHist), max(xHist)]*1000);
ylabel('% of trials')
xlabel('RT (ms)')
title(sprintf('%d %s sessions',numel(data),filetype))

%% Run stats
if ~strcmpi(filetype,'Sart') && ~strcmpi(filetype,'AudSart') 
    p1 = ranksum(RtCorrect, RtError,'tail','right');
    fprintf('RtCorrect>RtError: p=%.3g\n',p1);
end
if ~isempty(RtPreError)
    p2 = ranksum(RtPreCorrect, RtPreError,'tail','right');
    fprintf('RtPreCorrect>RtPreError: p=%.3g\n',p2);
end