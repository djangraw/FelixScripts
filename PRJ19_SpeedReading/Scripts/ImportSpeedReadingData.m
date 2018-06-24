function data = ImportSpeedReadingData(logFilename)

% Created 6/4/18 by DJ.

params = PsychoPy_ParseParams(logFilename,'---START PARAMETERS---','---END PARAMETERS---');
events = PsychoPy_ParseEvents(logFilename,{'display','soundset','soundstart','key','trial'},'WaitingForScanner');%'---START EXPERIMENT---');

% make data struct
data.params = params;
data.events = events;

% plot wpm rates
isFrame = strncmp(data.events.display.name,'frame',5);
cla; hold on;
IFI = diff(data.events.display.time(isFrame));
fpm = 60./IFI;
plot(fpm,'.-')

% plot intended wpm rates
fpm_ideal = linspace(data.params.minFPM,data.params.maxFPM,str2num(data.params.nFrames{1}));
plot(fpm_ideal,'.-');

% plot available wpm rates
fpm_available = 3600./(1:60);
PlotHorizontalLines(fpm_available,'k:');
legend('actual','ideal','available');
xlabel('frame');
ylabel('frames per minute')
title(logFilename,'Interpreter','None');