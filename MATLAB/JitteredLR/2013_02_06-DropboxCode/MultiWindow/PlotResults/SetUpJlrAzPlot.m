function [hTop,hBot] = SetUpJlrAzPlot(tStim, tResp)

% Created 12/6/12 by DJ.

% Make axes
hTop = gca; cla; hold on;
set(hTop,'XColor','b','YColor','b',...
   'XAxisLocation','top');
hBot = axes('Position',get(hTop,'Position'),...           
    'XColor','r','YColor','k',...
   'Color','none'); hold on;

% Set up axis limits
set(hBot,'ylim',[0.3 1]);
set(hTop,'ylim',[0.3 1]);
set(hTop,'xlim',[tStim(1) tStim(end)]);
set(hBot,'xlim',[tResp(1) tResp(end)]);
% Plot lines of interest
plot(hTop,[0 0],get(gca,'ylim'),'b--')
% plot(hBot,[0 0],get(gca,'ylim'),'r--')
plot(hTop,get(hTop,'xlim'),[0.5 0.5],'k--');
plot(hTop,get(hTop,'xlim'),[0.75 0.75],'k:');
% Annotate axes
xlabel(hBot,'time of response-locked window center (ms)');
xlabel(hTop,'time of stimulus-locked window center (ms)');
ylabel('Testing Az values');      
% title('Cars (c=0) vs. Faces (c=1)')

