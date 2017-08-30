function PlotScalpMap(R,G,B,clim)

    imgtoplot = cat(3,R,G,B);
    imgtoplot = imgtoplot-min(imgtoplot(:));
    imgtoplot = imgtoplot/max(imgtoplot(:));
    if exist('clim','var')
        imagesc(imgtoplot,clim)
    else
        imagesc(imgtoplot);
    end
end