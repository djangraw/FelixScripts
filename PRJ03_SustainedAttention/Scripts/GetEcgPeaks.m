function [tPeaks] = GetEcgPeaks(rawEcg,Fs)

% Created 7/15/16 by DJ. 

% Handle inputs
if ~exist('Fs','var') || isempty(Fs)
    Fs = 50;
end
if ~exist('doPlot','var') || isempty(doPlot)
    doPlot = false;
end
% Get time vector
t = (1:length(rawEcg))/Fs;

% Get wavelet transform of ECG
% See http://www.mathworks.com/examples/wavelet/mw/wavelet-ex77408607-r-wave-detection-in-the-ecg
wt = modwt(rawEcg,5);
wtrec = zeros(size(wt));
wtrec(4:5,:) = wt(4:5,:);
y = imodwt(wtrec,'sym4');

% Get peaks
[~,tPeaks] = findpeaks(y,t,'MinPeakHeight',std(y),...
    'MinPeakDistance',0.150);

% Plot results
if doPlot
    nRows = 5;
    for i=1:nRows
        subplot(nRows,1,i);
        cla; hold on;
        plot(t,rawEcg);
        PlotVerticalLines(tPeaks);
        xlim([0 100] + (i-1)*100);
        xlabel('time (s)')
        ylabel('ECG trace');
    end
end
