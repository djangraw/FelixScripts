function [hLines,hFrames] = PlotPeakFrames(hAxis,hTimecourse,nTop,movieFilename)

% [hLines,hFrames] = PlotPeakFrames(hAxis,hTimecourse,nTop,movieFilename)
%
% INPUTS:
% - hAxis is the hande to an axis
% - hTimecourse is the handle of the line whose peaks you want to highlight
% with movie frames.
%
% OUTPUTS:
% - hLines is an nTop-element vector of handles to the new vertical lines
% in hAxis.
% - hFrames is an nTop-element vector of handles to the new axes in which
% the movie frames are drawn.
%
% Created 4/21/15 by DJ.

% open('TestSphereTimecourse.fig');
if nargin<1 || isempty(hAxis)
    hAxis = subplot(3,1,1);
end
if nargin<2 || isempty(hTimecourse)
    hPlots = get(hAxis,'children');
    hTimecourse = hPlots(strcmp('Mean',{hPlots.DisplayName}));
end
if nargin<3 || isempty(nTop)
    nTop = 5;
end
if nargin<4 || isempty(movieFilename)
    movieFilename = 'Big_Buck_Bunny_420s_360p.mp4';
end

hrfDelay = 5; % subtract this to compensate for HRF lag
frameSize = 0.05;
%%
t = get(hTimecourse,'xdata');
avg = get(hTimecourse,'ydata');
%%
% [topAvg,iTop] = sort(abs(avg),'descend');
[topAvg,iTop] = sort(avg,'descend');
% get peaks only
topTimes = [];
for i=1:numel(iTop)
    if ~any(abs(iTop(1:i-1) - iTop(i))==1) && t(iTop(i))>hrfDelay
        topTimes = [topTimes, t(iTop(i))];
    end
    if length(topTimes)==nTop
        break
    end
end
% topTimes = t(iTop([1 2 3 5 7 10]));

%%
hLines = PlotVerticalLines(topTimes,'k');
hFrames = PlotFramesAboveTimes(movieFilename,topTimes-hrfDelay,hAxis,frameSize);