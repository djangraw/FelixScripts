function hLines = PlotVerticalLines(values,colorspec,allAsOne)

% Plots vertical lines through the whole plot at the specified x locations.
%
% hLines = PlotVerticalLines(values,colorspec,allAsOne)
%
% INPUTS:
% -values is a vector of x positions at which to plot vertical lines.
% -colorspec is a string indicating the color and linestyle to plot.
% [default: 'k-' for a black solid line].
% -allAsOne is a binary value that indicates whether you'd like to plot
% all lines as a single graphics object [default = false].
%
% OUTPUTS:
% -hLines is an array of handles for the lines, the same size as 'values'.
%
% Created 8/8/11 by DJ.
% Updated 4/20/15 by DJ - added hLines output.

% Handle defualts
if nargin<2 || isempty(colorspec)
    colorspec = 'k-';
end
if nargin<3 || isempty(allAsOne)
    allAsOne = true;
end

% Plot lines
ylimits = get(gca,'YLim');
hLines = gobjects(1,numel(values));
xLines = []; yLines = [];
for i=1:numel(values)
    if ~allAsOne
        if ischar(colorspec)
            hLines(i) = plot([values(i) values(i)],ylimits,colorspec);
        else
            hLines(i) = plot([values(i) values(i)],ylimits,'color',colorspec);
        end
    else
        xLines = [xLines, NaN, values(i), values(i)];
        yLines = [yLines, NaN, ylimits(1), ylimits(2)];
    end
end

if allAsOne
    if ischar(colorspec)
        hLines(i) = plot(xLines,yLines,colorspec);
    else
        hLines(i) = plot(xLines,yLines,'color',colorspec);
    end    
end


