function hFrames = PlotFramesAboveTimes(movieFilename,times,hAxes,frameWidth)

% hFrames = PlotFramesAboveTimes(movieFilename,times,hAxes,frameWidth)
%
% INPUTS:
% - movieFilename is a string, the filename of the movie whose frames you
% want to grab.
% - times is an n-element vector of times (in seconds) in the movie.
% - hAxes is a handle of the axes above which you want to plot the frames.
% - frameWidth is a scalar indicating the width of the frames you want to
%   draw (normalized units, 0-1).
% OUTPUTS:
% - hFrames is an n-element vector of handles for the frames you've drawn.
%
% Created 4/20/15 by DJ.

% handle defaults
if nargin<4 || isempty(frameWidth)
    frameWidth = 0.05;
end

fprintf('Loading movie...\n');
movObj = VideoReader(movieFilename);
% get RGB frames from movie
[frames,true_times] = GetMovieFrames(movObj,times);
frameHeight = frameWidth/size(frames,1)*size(frames,2);

% Draw lines on axes at times we are highlighting
% axes(hAxes);
% PlotVerticalLines(times);

% Get scaling to help find positions of new axes
pos_axes = get(hAxes,'Position');
xlim_axes = get(hAxes,'xlim');
xscale = pos_axes(3)/diff(xlim_axes);
hFrames = [];
hImg = [];
% Place frames and draw them
for i=1:numel(true_times)        
    xpos_line = [pos_axes(1) + (true_times(i)-xlim_axes(1))*xscale];
    hFrames(i) = axes('Position',[xpos_line-frameWidth/2, pos_axes(2)+pos_axes(4), frameWidth, frameHeight]);
    hImg(i) = imagesc(frames(:,:,:,i)/256);
    set(hImg(i),'ButtonDownFcn',{@GetAndPlotMovieClip,movObj,true_times(i),4})
    set(gca,'xtick',[],'ytick',[]);
end
% Set current axes back to original plot
axes(hAxes);
end

function GetAndPlotMovieClip(hObj,hOther, movieFilename, tFrame, tWidth)
    % note current figure
    currentFig = gcf;
    % Get movie
    [mov, frameRate] = GetMovie(movieFilename,tFrame-tWidth/2, tFrame+tWidth/2);
    % Create figure, annotate it, and play movie
    figure(298); 
    MakeFigureTitle(sprintf('%.2f +/- %.2f s',tFrame,tWidth/2),0);
    PlayMovie(mov, frameRate, figure(298), true);
    % move focus back to other figure
    figure(currentFig);
end