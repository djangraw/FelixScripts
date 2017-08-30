function [tPeaks] = GetRespPeaks(rawResp,Fs,doPlot)

% Created 7/15/16 by DJ. 

% Handle inputs
if ~exist('Fs','var') || isempty(Fs)
    Fs = 50;
end
if ~exist('doPlot','var') || isempty(doPlot)
    doPlot = false;
end
% Get time vector
t = (1:length(rawResp))/Fs;

% Demean and get peaks
[~,tPeaks] = findpeaks(rawResp-mean(rawResp),t,...'MinPeakHeight',std(rawResp),...
    'MinPeakDistance',1.0,'MinPeakProminence',std(rawResp)/10);

% Plot results
if doPlot
    nRows = 5;
    for i=1:nRows
        subplot(nRows,1,i);
        cla; hold on;
        plot(t,rawResp);
        PlotVerticalLines(tPeaks);
        xlim([0 100] + (i-1)*100);
        xlabel('time (s)')
        ylabel('respiration trace');
    end
end