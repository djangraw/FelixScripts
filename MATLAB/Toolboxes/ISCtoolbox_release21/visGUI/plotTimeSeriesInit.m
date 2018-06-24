function handles = plotTimeSeriesInit(handles,H)

set(gcf,'CloseRequestFcn','LSAclosereq')
set(gcf,'Name','Temporal analysis tool')
% get handles data from fMRI_GUI:
handles.H = H;

handles.curveTypes{1} = 'active voxels';
handles.curveTypes{2} = 'mean';
handles.curveTypes{3} = 'median';

handles.thresVec = length(handles.H.Priv.th)+(1:2:2*(handles.H.Priv.maxScale+2));
handles.ThresholdVal = 1;
handles.manualTh = 0;
handles.corMat = [];


handles.stringFDR = {'p < 0.05, FDR (indep/dep)';'p < 0.005, FDR (indep/dep)'};
handles.stringManualTh = num2str((handles.H.Priv.th'));
set(handles.popupmenuThreshold,'String',handles.stringFDR)
set(handles.checkboxManual,'Value',handles.manualTh)

% set object fields:
set(handles.popupmenuFreqBand,'String',handles.H.bandNames)
set(handles.popupmenuSimilarityMeasure,'String',handles.H.similarityMeasureNames)
handles.totalSynchMeasure = 1;
set(handles.popupmenuTotalSynchMeasure,'String',handles.curveTypes)

set(handles.popupmenuSession,'String',handles.H.sessionNames)
set(handles.checkboxSwapBytes,'Value',handles.H.swapBytesOn)
set(handles.popupmenuAtlas,'String',[{'Cortical'},{'Subcortical'}])
set(handles.popupmenuAtlasThreshold,'String',[{'0%'},{'25%'},{'50%'}])
set(handles.listboxAtlas,'String',handles.H.txtCort)
set(handles.popupmenuOrient,'String',[{'axial'},{'coronal'},{'sagittal'}],'Value',1)

for k = 1:handles.H.Priv.maxScale + 2
    set(handles.(['radiobutton' num2str(k)]),'String',handles.H.bandNames{k},'Visible','on')
    set(handles.(['textColor' num2str(k)]),'String',' ','Visible','on')
end
for k = (handles.H.Priv.maxScale + 2 + 1):10
    set(handles.(['radiobutton' num2str(k)]),'String',' ','Visible','off')
    set(handles.(['textColor' num2str(k)]),'String',' ','Visible','off')
end

handles.CurrentButton = 1;
handles.CurrentButtonVals = [1 zeros(1,handles.H.Priv.maxScale + 1)];
handles.tags = [zeros(1,handles.H.Priv.maxScale + 2); ones(1,handles.H.Priv.maxScale + 2)];
handles.currentTag = 1;
handles.TagContents = {'Tag 1'};
handles.normalizationOn = 1;

handles.updateTemporalPlot = 1;
handles.updateSpatialPlot = 1;



set(handles.checkboxNormalization,'Value',handles.normalizationOn)

handles = initRadiobuttons(handles,0);
set(gcf,'Colormap',handles.H.colMap)

handles.H.CurrentRegion = 1;

if handles.totalSynchMeasure == 1
    set(handles.popupmenuThreshold,'Enable','on')
else
    set(handles.popupmenuThreshold,'Enable','off')
end
set(handles.sliderTime,'max',handles.H.Priv.nrTimeIntervals(1))

handles.intVals = [];
for r = 1:handles.H.Priv.nrTimeIntervals(1)
    handles.intVals{r} = calcInterval(r,handles.H);
    handles.intVals{r} = handles.intVals{r};
end
it = 1;
while ceil(length(handles.intVals)/(2^(it-1))) > 12
    for r = it:(2^it):length(handles.intVals)
        handles.intVals{r} = [];
    end
    it = it + 1;
end

handles.H.CurrentRegion = 1;
handles.H.At = 1;
handles.H.AtlasThreshold = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init temporal-axes:

% initialize temporal curves:
handles = updateTemporalCurves(handles);

axes(handles.axesTime);

% create curve objects using plot:
hold on
for r = 1:handles.H.Priv.maxScale + 2
    handles.timePlotNamesLegend{r} = handles.timePlotNames{handles.H.Priv.maxScale+2-r};
    handles.tagNames{r} = ['Tag' num2str(r)];
    plot(1:handles.H.Priv.nrTimeIntervals(1),handles.sC(r,:),'Visible','off','LineWidth',...
        handles.timePlotLineWidth(r),'Color',handles.timePlotColors{r},...
        'Marker',handles.timePlotMarkers{r},'MarkerSize',6,...
        'LineStyle',handles.timePlotLineStyle{r},'Tag',handles.timePlotNames{r});
end
hold off
% obtain children (=curve) objects and reverse order:
handles.timeAxesChildren = flipud(get(gca,'Children'));
set(gca,'Children',handles.timeAxesChildren)

% set default curve (=full band) visible:
set(handles.timeAxesChildren(1),'Visible','on')

% init Tags:

% create tag objects using plot:
hold on
for r = 1:handles.H.Priv.maxScale + 2
    plot(ones(1,handles.H.Priv.nrTimeIntervals(1)),1:handles.H.Priv.nrTimeIntervals(1));
end
hold off
% obtain all children objects of the axes (tags + time curves):
W = get(gca,'Children');
% pick tags only:
handles.timeAxesChildrenTags = W(1:handles.H.Priv.maxScale + 2);

for r = 1:handles.H.Priv.maxScale + 2
    set(handles.timeAxesChildrenTags(r),'Visible','off','LineWidth',2,'LineStyle',...
        handles.tagLineStyle{r},'Color',handles.tagColors{r},...
        'Tag',handles.tagNames{r},'HandleVisibility','off');
end
for r = 1:handles.H.Priv.maxScale + 2
    handles.timeAxesTagText{r} = text('String',handles.tagNames{r},...
        'BackgroundColor',handles.tagColors{r},'HorizontalAlignment','center',...
        'VerticalAlignment','middle','Position',[1 1],'Visible','off','HandleVisibility','off');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init spatial axes:

% initialize spatial maps:
handles = updateSyncPlotAtlas(handles);

axes(handles.axesSpatial);

hold on
for r = 1:handles.H.Priv.maxScale + 2
    plot(1:10,1:10);
end
hold off

handles.spatialAxesChildren = get(gca,'Children');
for r = 1:handles.H.Priv.maxScale + 2
    set(handles.spatialAxesChildren(r),'Visible','off','LineWidth',1,'LineStyle',...
        handles.tagLineStyle{r},'Color',handles.tagColors{r},...
        'Tag',handles.tagNames{r},'HandleVisibility','on');
end

handles.spatialLegend = legend(handles.tagNames);
for r = 1:handles.H.Priv.maxScale + 2
    handles.spatialLegendIndex(r,1) = 18-(r-1)*3;
    handles.spatialLegendIndex(r,2) = 17-(r-1)*3;
end
handles.spatialAxesThres = line(1:100,ones(1,100));
set(handles.spatialAxesThres,'HandleVisibility','off','LineStyle','--','Color',[0 0 0],'LineWidth',2)


handles = updateSyncPlotParams(handles);

if sum(handles.tags(1,:)) == 0
    set(handles.pushbuttonSegment,'Enable','off')
else
    set(handles.pushbuttonSegment,'Enable','on')
end

handles.updateSpatialPlot = 0;
handles.updateTemporalPlot = 1;
handles = getThreshold(handles);
%handles = FigsPlot(handles);

set(handles.textSpatialCorr,'Position',[155 2.5 60 7],'String',' ')
set(handles.textTemporalCorr,'Position',[210 2.5 60 7],'String',' ')
set(handles.textSpatialCorStr,'Position',[155 10 22 1.154],'String','Spatial correlation')
set(handles.textTemporalCorStr,'Position',[210 10 22 1.154],'String','Temporal correlation')

for s = 1:length(handles.H.txtCort)+length(handles.H.txtSub)
    for k = 1:handles.H.Priv.nrSessions
        handles.sessionTags{s,k}{1} = [zeros(1,size(handles.tags,2));ones(1,size(handles.tags,2))];
        handles.sessionTags{s,k}{2} = [];
        handles.sessionTags{s,k}{3} = [];
    end
end

