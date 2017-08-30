function PlotTiming(presses)

% Created 4/29/15 by DJ.

hold on;
colors = {'r','g','b','c','m','y','k'};
nRows = size(presses,1);
for i=1:size(presses,1)
    for j=1:size(presses{i,2},1)
        plot(presses{i,2}(j,:), [i i]/(nRows+1),'color',colors{i},'linewidth',2);
    end
end

set(gca,'ytick',(1:nRows)/(nRows+1),'yticklabel',presses(:,1),'ydir','reverse');
ylim([0 1]);
