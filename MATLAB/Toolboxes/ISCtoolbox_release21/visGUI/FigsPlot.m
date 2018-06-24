function handles = FigsPlot(handles)


    MM = max(handles.sC(:));
    if MM == 0
        MM = 1;
    end
    mm = min(handles.sC(:));
    if mm >= MM
        mm = 0;
    end
    if isempty(mm)
        mm = 0;
    end
    if isempty(MM)
        MM = 1;
    end


%%%%%%%%%%%%%%% update time-axes:

if handles.updateTemporalPlot

    axes(handles.axesTime)

    % update lines:
    for r = 1:length(handles.timeAxesChildren)
%        set(handles.timeAxesChildrenTags(r),'XData',1:handles.H.Priv.nrTimeIntervals(handles.H.dataset),...
%            'YData',zeros(1,handles.H.Priv.nrTimeIntervals(handles.H.dataset)))
        %if strcmp(handles.timePlotNames(handles.CurrentButton(handles.dataset))...
        %,get(handles.timeAxesChildren(r),'Tag'))
        set(handles.timeAxesChildren(r),'LineWidth',...
            handles.timePlotLineWidth(r),'Color',handles.timePlotColors{r},...
            'Marker',handles.timePlotMarkers{r},'MarkerSize',6,...
            'LineStyle',handles.timePlotLineStyle{r},'Tag',handles.timePlotNames{r})
        if handles.CurrentButtonVals(r) == 1
            set(handles.timeAxesChildren(r),'Visible','on','YData',...
                handles.sC(r,:),'XData',1:handles.H.Priv.nrTimeIntervals(handles.H.dataset))%,'HandleVisibility','on')
        else
            set(handles.timeAxesChildren(r),'Visible','off','YData',...
                handles.sC(r,:),'XData',1:handles.H.Priv.nrTimeIntervals(handles.H.dataset))%,'HandleVisibility','off')
        end
    end

    % properties:
    set(gca,'XTickLabel',handles.intVals,'XTick',1:handles.H.Priv.nrTimeIntervals(handles.H.dataset),'FontSize',10);
    T = title([{['Session ' num2str(handles.H.dataset) ': ' ...
        handles.CurrentRegionName]};...
        {['Temporal intersubject synchronization']};{' '}]);
    %set(T,'FontSize',12);
    zoom on;xlabel('Time interval');ylim([mm MM])
    switch handles.totalSynchMeasure;
        case 1
            ylabel('Amount of voxels');
        case 2
            ylabel('Mean Synchronization');
        case 3
            ylabel('Median Synchronization');
    end

end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% update spatial axes & tags:
if handles.updateSpatialPlot

    axes(handles.axesTime)
    ylim([mm MM])
    for r = 1:size(handles.tags,2)
        if handles.tags(1,r)
            set(handles.timeAxesChildrenTags(r),'YData',...
                linspace(mm,MM,handles.H.Priv.nrTimeIntervals(handles.H.dataset)),'XData',...
                handles.tags(2,r)...
                *ones(1,handles.H.Priv.nrTimeIntervals(handles.H.dataset)),'Visible','on')
            set(handles.timeAxesTagText{r},'Position',...
                [handles.tags(2,r),MM],'Visible','on')
        else
            set(handles.timeAxesChildrenTags(r),'Visible','off')
            set(handles.timeAxesTagText{r},'Visible','off')
        end
    end

    axes(handles.axesSpatial);zoom on
    for r = 1:size(handles.tags,2)
        if handles.tags(1,r)
            set(handles.spatialAxesChildren(r),'YData',...
                handles.spMap(r,:),'XData',1:size(handles.spMap,2),'HandleVisibility','on','Visible','on')
        else
            set(handles.spatialAxesChildren(r),'Visible','off','YData',1,'XData',1)
        end
    end

    % set threshold line:
    set(handles.spatialAxesThres,'XData',1:size(handles.spMap,2),'YData',...
        handles.Threshold*(ones(1,size(handles.spMap,2))))

    % set spatial-axes properties:
    ylabel('Inter-subject synchronization');xlim([0 size(handles.spMap,2)]);xlabel('voxel index')
    contents = get(handles.popupmenuFreqBand,'String');
    Band = contents{handles.H.freqBand};
    T = title([{['Spatial intersubject synchronization during the selected time intervals for ' Band ' frequency band']};{' '}]);
end

handles.updateTemporalPlot = 0;
handles.updateSpatialPlot = 0;

warning on