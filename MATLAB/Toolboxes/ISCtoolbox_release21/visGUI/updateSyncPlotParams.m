function handles = updateSyncPlotParams(handles)

% get current time-interval index 
% (slider not visible if temporal analysis is set off):
handles.H.timeVal = round(get(handles.sliderTime,'Value'));

handles.H.swapBytesOn = get(handles.checkboxSwapBytes,'Value');

handles.normalizationOn = get(handles.checkboxNormalization,'Value');

% get dataset:
handles.H.dataset = get(handles.popupmenuSession,'Value');

% get orientation of the image (axial/coronal/sagittal):
handles.H.orient = get(handles.popupmenuOrient,'Value');
handles.H.AtlasThreshold = get(handles.popupmenuAtlasThreshold,'Value');
handles.H.CurrentRegion = get(handles.listboxAtlas,'Value');
%contents = get(handles.popupmenuThreshold,'String');
%handles.H.Threshold = str2num(contents{get(handles.popupmenuThreshold,'Value')});

handles.H.SimMeasure = get(handles.popupmenuSimilarityMeasure,'Value');
handles.H.freqBand = get(handles.popupmenuFreqBand,'Value');

handles.totalSynchMeasure = get(handles.popupmenuTotalSynchMeasure,'Value');
contents = get(handles.listboxAtlas,'String');
handles.CurrentRegionName = contents{get(handles.listboxAtlas,'Value')};
handles.CurrentRegionName = handles.CurrentRegionName(3:end);

handles.ThresholdVal = get(handles.popupmenuThreshold,'Value');
handles.H.Threshold = handles.H.Priv.th(get(handles.popupmenuThreshold,'Value'));
handles.CurrentButton = get(handles.popupmenuFreqBand,'Value');
for k = 1:handles.H.Priv.maxScale + 2
    handles.CurrentButtonVals(k) = get(handles.(['radiobutton' num2str(k)]),'Value');
end
handles.currentTag = get(handles.listboxTags,'Value');

