function newDeadline = CalculateRtDeadline(filename,filetype,rtThresh,nTrials,doPlot)

% Created 1/26/15 by DJ.

% load
if ischar(filename)
    switch filetype
        case 'BopIt'
            data = ImportBopItData(filename);
        case 'Sart'
            data = ImportSartData(filename);
        case 'AudSart'
            data = ImportAudSartData(filename);
        case 'Tapping'
            data = ImportTappingData(filename);
        case 'Flanker'
            data = ImportFlankerData(filename);
    end
else
    data = filename;
    filename = sprintf('%s-%d-%d-%s.log',filetype,data.params.subject,data.params.session,data.params.date);
end

if ~exist('rtThresh','var')
    rtThresh = data.params.rtThreshAccuracy;
end

if ~exist('nTrials','var')
    nTrials = length(data.RT);
end

if ~exist('doPlot','var')
    doPlot = false;
end

% get RTs & info
RT = data.performance.RT(1:nTrials);    
isCorrect = data.performance.isCorrect(1:nTrials)~=0;
% isCongruent = data.performance.isCongruent(1:nTrials);

% find deadline at which subject gets given percent correct
deadlines = max(RT):-.001:min(RT);
FC = zeros(numel(deadlines)); % fraction correct
FUD = zeros(numel(deadlines)); % fraction under deadline
for i=1:numel(deadlines)
    FC(i) = nanmean(isCorrect(RT<=deadlines(i)));    
    FUD(i) = nanmean(RT<=deadlines(i));
end
% find new deadline
% iDeadline = find(FC<rtThreshAccuracy,1);
iDeadline = find(FUD<rtThresh,1);
if isempty(iDeadline) || iDeadline>length(FC)
    newDeadline = nanmedian(RT);    
    fprintf('No deadline will produce <%g%% correct... choosing median RT = %g sec.\n',rtThresh*100,newDeadline)    
else
    newDeadline = deadlines(iDeadline);
    fprintf('To produce %g%% correct, choose a deadline of %g sec.\n',rtThresh*100,newDeadline)    
end

%% PLOT
if doPlot
    % plot results
    clf; hold on;
    % plot(deadlines,FC*100)
    plot(deadlines,FUD*100)
    xlim([0,max(RT)]);
    ylim([50 100]);
    PlotHorizontalLines(rtThresh*100,'k-.');
    PlotVerticalLines(data.params.rtDeadline,'g:');
    PlotVerticalLines(newDeadline,'k:');
    % annotate
    title(filename,'interpreter','none');
    xlabel('Reaction Time (s)')
    ylabel('% correct')
    legend('% correct with RT < x','desired performance','old deadline','new deadline');
end
