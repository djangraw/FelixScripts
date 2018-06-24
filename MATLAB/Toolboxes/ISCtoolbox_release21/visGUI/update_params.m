function handles = update_params(handles);

handles.changeInCurrentAxes = 1;


% get current image slice:
handles.layerVal = round(get(handles.sliderLayer,'Value'));
handles.layerVals(3) = round(get(handles.sliderAxial,'Value'));
handles.layerVals(2) = round(get(handles.sliderCoronal,'Value'));
handles.layerVals(1) = round(get(handles.sliderSagittal,'Value'));

% temporal analysis on/off (2-min time-interval, 30s time step):
handles.win = get(handles.checkboxTimeWindow,'Value');
% get current time-interval index 
% (slider not visible if temporal analysis is set off):
handles.timeVal = round(get(handles.sliderTime,'Value'));
% get dataset:
handles.dataset = get(handles.popupmenuSession,'Value');
% get orientation of the image (axial/coronal/sagittal):
handles.orient = get(handles.popupmenuOrient,'Value');

handles.alpha = get(handles.popupmenuAlphaMap,'Value');
%handles.ZPFalpha = get(handles.popupmenuAlphaZPF,'Value');
handles.ZPFtest = get(handles.popupmenuZPF,'Value');
handles.correction = get(handles.popupmenuCorrectionMap,'Value');
handles.freqBand2 = get(handles.popupmenuFreqBandComp,'Value');

% get colorbar scales depending on the view:
%handles.freqCompOn = get(handles.radiobuttonFreqCompOn,'Value');

%if ~handles.freqCompOn % standard similarity map (similarity value range)
%handles.ScaleMin1 = str2num(get(handles.edit1ScaleMin,'String'));
%handles.ScaleMax1 = str2num(get(handles.edit1ScaleMax,'String'));
%handles.Threshold = str2num(get(handles.editThreshold,'String'));
%else % frequency comparison similarity map (number of subject pairs)
%    handles.ScaleMinPF = str2num(get(handles.edit1ScaleMin,'String'));
%    handles.ScaleMaxPF = str2num(get(handles.edit1ScaleMax,'String'));
%    handles.ThresholdPF = str2num(get(handles.editThreshold,'String'));
%end


handles.SimMeasure = get(handles.popupmenuSimilarityMeasure,'Value');
handles.mapType = get(handles.popupmenuMapType,'Value');

handles.freqBand = get(handles.popupmenuFreqBand,'Value');

if handles.freqBand <= handles.freqBand2
    handles.freqComp = handles.freqBandCompTable(handles.freqBand,handles.freqBand2);
else
    handles.freqComp = handles.freqBandCompTable(handles.freqBand2,handles.freqBand);
end

handles.PixVal1 = get(handles.checkboxPixVal1,'Value');

handles.AtlasThreshold = get(handles.popupmenuAtlasThreshold,'Value');
%handles.CurrentRegion = get(handles.listboxAtlas,'Value');

