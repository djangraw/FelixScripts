function ImageRgb(R,G,B,clim)

% ImageRgb(R,G,B,clim)
%
% INPUTS:
% -R,G,B are 2d matrices of equal size, to be used as the red, green, and
% blue channels of the image.
% -clim is a 2-element vector indicating the min and max color limits.
% (default: let imagesc scale the colorbars accordingly.)
%
% OUTPUTS:
% -none.
%
% Created 11/25/14 by DJ.

    imgtoplot = cat(3,R,G,B);
    % normalize
%     imgtoplot = imgtoplot-min(imgtoplot(:));
%     imgtoplot = imgtoplot/max(imgtoplot(:));
    if exist('clim','var')
        imagesc(imgtoplot,clim)
    else
        imagesc(imgtoplot);
    end
end