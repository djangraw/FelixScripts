function PlotTiming(presses,colors)

% PlotTiming(presses,colors)
%
% INPUTS:
% -presses is a 2-column cell array of the keypresses created by
% GetTiming.m.
% -colors is a cell array of plot colors indicating what color each
% row of lines should be.
%
% Created 4/29/15 by DJ.
% Updated 2/6/18 by DJ - comments.

% Declare defaults
if ~exist('colors','var') || isempty(colors)
    colors = {'r','g','b','c','m','y','k'}; % may need more depending on # of keypresses
end

% Plot
hold on;
nRows = size(presses,1);
for i=1:size(presses,1)
    for j=1:size(presses{i,2},1)
        plot(presses{i,2}(j,:), [i i]/(nRows+1),'color',colors{i},'linewidth',2);
    end
end

% Annotate plot
set(gca,'ytick',(1:nRows)/(nRows+1),'yticklabel',presses(:,1),'ydir','reverse');
ylim([0 1]);
