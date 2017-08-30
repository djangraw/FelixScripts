function [hAxes, hPlot] = DisplaySlices(dataBrick, dim, iSlices, whSubplots,clim,allOnOne)

% [hAxes, hPlot] = DisplaySlices(dataBrick, dim, iSlices, whSubplots,clim,allOnOne)
% 
% Created 12/22/15 by DJ.
% Updated 4/5/16 by DJ - added hPlot outputs
% Updated 6/2/16 by DJ - fixed all <0 bug, added allOnOne bug

nSubplots = numel(iSlices);
if ~exist('whSubplots','var') || isempty(whSubplots)   
    whSubplots = [ceil(sqrt(nSubplots)), ceil(nSubplots/ceil(sqrt(nSubplots)))];
end
if ~exist('clim','var') || isempty(clim)   
    clim = [GetValueAtPercentile(dataBrick(~isnan(dataBrick) & dataBrick~=0),2), GetValueAtPercentile(dataBrick(~isnan(dataBrick) & dataBrick~=0),98)];
end
if ~exist('allOnOne','var') || isempty(allOnOne)   
    allOnOne = false;
end


% extract slices and labels
if dim==1
    slices = permute(dataBrick(iSlices,:,:,:),[3 2 1 4]);
    xlbl = 'y';
    ylbl = 'z';
elseif dim==2    
    slices = permute(dataBrick(:,iSlices,:,:),[3 1 2 4]);
    xlbl = 'x';
    ylbl = 'z';
elseif dim==3
    slices = permute(dataBrick(:,:,iSlices,:),[2 1 3 4]);    
    xlbl = 'x';
    ylbl = 'y';
end
dimLabels = {'Sagittal','Coronal','Axial'};

% plot
if allOnOne
    % construct
    hSlice = size(slices,1);
    wSlice = size(slices,2);
    allSlices = zeros(hSlice*whSubplots(1), wSlice*whSubplots(2),size(slices,4));
    for i=1:nSubplots
        iRow = ceil((nSubplots-i+1)/whSubplots(2));
        iCol = mod(i-1,whSubplots(2))+1;
        iPlot = (iRow-1)*hSlice + (1:hSlice);
        jPlot = (iCol-1)*wSlice + (1:wSlice);
        allSlices(iPlot,jPlot,:) = squeeze(slices(:,:,i,:));
    end
    % plot
    cla;
    hPlot = imagesc(allSlices);
    hold on;
    % Add lines
    hHori = PlotHorizontalLines(hSlice*(0:whSubplots(2))+.5,'g');
    hVert = PlotVerticalLines(wSlice*(0:whSubplots(2))+.5,'g');
    hAxes = [hHori,hVert];
    % annotate plot
    set(gca,'ydir','normal','clim',clim);
    xlabel(xlbl);
    ylabel(ylbl);   
    set(gca,'xtick',[],'ytick',[]);
    title(sprintf('%s slices',dimLabels{dim}));
    axis square
    colorbar;
else
    clf;
    for i=1:nSubplots
        hAxes(i) = subplot(whSubplots(1),whSubplots(2),i);
        hPlot(i) = imagesc(squeeze(slices(:,:,i,:)));
        % annotate plot
        set(gca,'ydir','normal','clim',clim);
        xlabel(xlbl);
        ylabel(ylbl);   
        title(sprintf('%s slice %d',dimLabels{dim},iSlices(i)));
        axis square
    end
    % make colorbar
    hAxes(nSubplots+1) = axes('Position',[90 10 5 80]/100,'clim',clim,'visible','off');
    colorbar;
end

