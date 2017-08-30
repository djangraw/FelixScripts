function PlotMovieFrames(movieFilename,times)

% Created 4/20/15 by DJ.

[frames,true_times] = GetMovieFrames(movieFilename,times);

nPlots = numel(times);
nRows = ceil(sqrt(nPlots));
nCols = ceil(nPlots/nRows);
for i=1:numel(times)
    subplot(nRows,nCols,i);
    imagesc(frames(:,:,:,i)/256);
    title(sprintf('t=%.2f',true_times(i)));
    set(gca,'xtick',[],'ytick',[]);
end
    