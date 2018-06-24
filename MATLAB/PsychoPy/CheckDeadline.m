function [rtDeadlines,PC,pctFastEnough] = CheckDeadline(filenames,filetype)

% load data
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

% get deadlines and PC
[PC,pctFastEnough,rtDeadlines] = deal(nan(1,numel(data)));

for i=1:numel(data)
    PC(i) = nanmean(data(i).performance.isCorrect)*100;
    pctFastEnough(i) = nanmean(data(i).performance.RT<=data(i).params.rtDeadline)*100;
    rtDeadlines(i) = data(i).params.rtDeadline;
end
% sort
[rtDeadlines,iOrder] = sort(rtDeadlines,'ascend');
PC = PC(iOrder);
pctFastEnough = pctFastEnough(iOrder);

% plot results
figure(99); cla;
plot(rtDeadlines,[PC;pctFastEnough]','.-');
xlabel('RT deadline (s)');
ylabel('% of trials');
legend('% correct','% RTs under deadline');
