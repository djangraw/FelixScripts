function plot_JLR_Az(foldername,cvmode)

% Plot Jittered LR Az results over time on the current axes.
%
% plot_JLR_Az(foldername,cvmode)
%
% INPUTS:
% - foldername is a string indicating where the JLR results are saved.
% - cvmode is a string indicating the cross-validation mode (results should 
% have been saved as 'params_<cvmode>' and 'results_<cvmode>').
%
% Created 11/21/11 by DJ.
% Updated 8/16/12 by DJ - plot dots, if statement, show_symbols
% Updated 2/6/13 by DJ - comments.

% load
disp('loading...')
par = load([foldername '/params_' cvmode]);
res = load([foldername '/results_' cvmode]);

% set up
disp('plotting...')
t = par.ALLEEG(par.setlist(1)).times(res.trainingwindowoffset);
Az = res.Azloo;

% Plot on current axes
cla; hold on
plot(t,Az,'.-');
if numel(t)>1
    xlim([t(1), t(end)])
else
    xlim([t-50, t+50])
end
plot(get(gca,'XLim'),[0.5 0.5],'k--');
plot(get(gca,'XLim'),[0.75 0.75],'k:');
ylim([0.3 1]); % set limits
plot([0 0],get(gca,'YLim'),'k-');
% Annotate plot
title(sprintf('%s\nvs. %s',show_symbols(par.ALLEEG(par.setlist(1)).setname),show_symbols(par.ALLEEG(par.setlist(2)).setname)));
xlabel('time (s)');
ylabel([cvmode ' Az']);
disp('Success!');