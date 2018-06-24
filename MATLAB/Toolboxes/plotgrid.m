function h = plotgrid(ax, xyz, varargin)
% function h = plotgrid(ax, xyz, varargin)
% Plot the 4D position array xyz(nx,ny,nz,3) in a grid-like plot
%
% INPUTS:
% -ax is the handle of the axis you want to plot in.
% -xyz is 
%
% OUTPUTS:
% -h is the handle of the grid you have plotted.
%
% Downloaded 12/3/14 from http://www.mathworks.com/matlabcentral/newsreader/view_thread/311932.

if isempty(ax)
    ax = gca();
end

hold(ax, 'on');
h = [];
for dim=1:3
    p = 1:4;
    p([1 dim]) = [dim 1];
    a = permute(xyz, p);
    m = size(a,1);
    a = reshape(a, m, [], 3);
    if m > 1
        hd = plot3(ax, a(:,:,1), a(:,:,2), a(:,:,3), '.-', varargin{:});
    else
        hd = plot3(ax, a(:,:,1), a(:,:,2), a(:,:,3), '.', varargin{:});
    end
    h = [h; hd];
end
hold(ax, 'off');

end % plotgrid
