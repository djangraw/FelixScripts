function varargout = plotTimeSeries_GUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plotTimeSeries_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @plotTimeSeries_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before plotTimeSeries_GUI is made visible.
function plotTimeSeries_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plotTimeSeries_GUI (see VARARGIN)

handles = plotTimeSeriesInit(handles,varargin{1});
% Choose default command line output for plotTimeSeries_GUI
handles.output = handles;
guidata(hObject, handles);

%set(handles.figure1,'WindowStyle','modal')
% UIWAIT makes plotTimeSeries_GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = plotTimeSeries_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles)
    guidata(hObject, handles);
    varargout{1} = handles;
    delete(handles.figure1)
else
    varargout{1} = handles;
end

% --- Executes on button press in pushbuttonAdd.
function pushbuttonAdd_Callback(hObject, eventdata, handles)

handles = addTag(handles,hObject);
handles = quickUpdateSpatialMaps(handles);
guidata(hObject, handles);

% --- Executes on slider movement.
function sliderTime_Callback(hObject, eventdata, handles)
% hObject    handle to sliderTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = sliderSet(handles,hObject);
handles = quickUpdateSpatialMaps(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function sliderTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in pushbuttonRemove.
function pushbuttonRemove_Callback(hObject, eventdata, handles)

handles = removeTag(handles,hObject);
handles.updateSpatialPlot = 1;
handles = updateSpatialMaps(handles);
handles = FigsPlot(handles);
guidata(hObject, handles);

% --- Executes on selection change in listboxTags.
function listboxTags_Callback(hObject, eventdata, handles)
% hObject    handle to listboxTags (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listboxTags contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxTags
handles.currentTag = get(hObject,'Value');
intVal = calcInterval(handles.tags(2,handles.currentTag),handles.H);
set(handles.editTag,'String',intVal)
set(handles.sliderTime,'Value',handles.tags(2,handles.currentTag))
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listboxTags_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popupmenuThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ThresholdVal = get(handles.popupmenuThreshold,'Value');
handles = getThreshold(handles);
handles = updateTemporalCurves(handles);
handles = updateSpatialMaps(handles);
handles.updateTemporalPlot = 1;
handles.updateSpatialPlot = 1;
handles = FigsPlot(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuThreshold_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupmenuFreqBand.
function popupmenuFreqBand_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuFreqBand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.CurrentButton = get(hObject,'Value');
handles.H.freqBand = get(hObject,'Value');
handles = initRadiobuttons(handles,0);
handles.updateTemporalPlot = 1;
handles = updateSpatialMaps(handles);
handles.updateSpatialPlot = 1;
handles = FigsPlot(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuFreqBand_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupmenuSimilarityMeasure.
function popupmenuSimilarityMeasure_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSimilarityMeasure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function popupmenuSimilarityMeasure_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupmenuTotalSynchMeasure.
function popupmenuTotalSynchMeasure_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuTotalSynchMeasure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.totalSynchMeasure = get(hObject,'Value');
if handles.totalSynchMeasure == 1
    set(handles.popupmenuThreshold,'Visible','on')
    set(handles.checkboxManual,'Visible','on')
    set(handles.textThreshold,'Visible','on')
else
    set(handles.popupmenuThreshold,'Visible','off')
    set(handles.checkboxManual,'Visible','off')
    set(handles.textThreshold,'Visible','off')
end    
handles = updateTemporalCurves(handles);
handles = updateSpatialMaps(handles);
handles.updateTemporalPlot = 1;
handles.updateSpatialPlot = 1;
handles = FigsPlot(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuTotalSynchMeasure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuTotalSynchMeasure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupmenuSession.
function popupmenuSession_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuSession (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = setTagListSession(handles,hObject);

handles = setTimeInterval(handles);
handles = updateTemporalCurves(handles);
handles = updateSpatialMaps(handles);
handles.updateTemporalPlot = 1;
handles.updateSpatialPlot = 1;
handles = FigsPlot(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuSession_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbuttonSegment.
function pushbuttonSegment_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSegment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = anatomicalPlot(handles);

% --- Executes on selection change in popupmenuAtlas.
function popupmenuAtlas_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuAtlas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.H.At = get(hObject,'Value');

if get(hObject,'Value') == 1
    set(handles.listboxAtlas,'Value',1)
    set(handles.listboxAtlas,'String',handles.H.txtCort)
    set(handles.listboxAtlas,'Value',1)
else
    set(handles.listboxAtlas,'Value',1)
    set(handles.listboxAtlas,'String',handles.H.txtSub)
    set(handles.listboxAtlas,'Value',1)
end

handles = updateSyncPlotAtlas(handles);
handles = updateTemporalCurves(handles);
handles = updateSpatialMaps(handles);
handles.updateTemporalPlot = 1;
handles.updateSpatialPlot = 1;
handles = FigsPlot(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuAtlas_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuAtlas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupmenuAtlasThreshold.
function popupmenuAtlasThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuAtlasThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.H.AtlasThreshold = get(hObject,'Value');
handles = updateSyncPlotAtlas(handles);
handles = updateTemporalCurves(handles);
handles = updateSpatialMaps(handles);
handles.updateTemporalPlot = 1;
handles.updateSpatialPlot = 1;
handles = FigsPlot(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuAtlasThreshold_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in listboxAtlas.
function listboxAtlas_Callback(hObject, eventdata, handles)
% hObject    handle to listboxAtlas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = setTagList(handles,hObject);

contents = get(handles.listboxAtlas,'String');
handles.CurrentRegionName = contents{get(handles.listboxAtlas,'Value')};
handles.CurrentRegionName = handles.CurrentRegionName(3:end);

handles = setTimeInterval(handles);
handles = updateSyncPlotAtlas(handles);
handles = updateTemporalCurves(handles);
handles = updateSpatialMaps(handles);
handles.updateTemporalPlot = 1;
handles.updateSpatialPlot = 1;
handles = FigsPlot(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listboxAtlas_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkboxSwapBytes.
function checkboxSwapBytes_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSwapBytes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.H.swapBytesOn = get(hObject,'Value');
handles = updateTemporalCurves(handles);
handles = updateSpatialMaps(handles);
handles.updateTemporalPlot = 1;
handles.updateSpatialPlot = 1;
handles = FigsPlot(handles);
guidata(hObject, handles);

% --- Executes on selection change in popupmenuOrient.
function popupmenuOrient_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuOrient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.H.orient = get(hObject,'Value');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuOrient_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkboxNormalization.
function checkboxNormalization_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxNormalization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.normalizationOn = get(hObject,'Value');
handles = updateTemporalCurves(handles);
handles = updateSpatialMaps(handles);
handles.updateTemporalPlot = 1;
handles.updateSpatialPlot = 1;
handles = FigsPlot(handles);
guidata(hObject, handles);

% --- Executes on button press in checkboxManual.
function checkboxManual_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxManual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.manualTh = get(hObject,'Value');
%set(handles.popupmenuThreshold,'Enable','on')
handles.ThresholdVal = 1;
if handles.manualTh
    set(handles.popupmenuTotalSynchMeasure,'Enable','on')
    set(handles.popupmenuThreshold,'Value',1,'String',handles.stringManualTh)
else
    set(handles.popupmenuTotalSynchMeasure,'Value',1,'Enable','off')
    handles.totalSynchMeasure = 1;
    set(handles.popupmenuThreshold,'Value',1,'String',handles.stringFDR)
end
handles = getThreshold(handles);
%handles = updateSyncPlotParams(handles);
handles = updateTemporalCurves(handles);
handles = updateSpatialMaps(handles);
handles.updateTemporalPlot = 1;
handles.updateSpatialPlot = 1;
handles = FigsPlot(handles);
guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% radiobuttons and empty callbacks:

function editTag_Callback(hObject, eventdata, handles)
function editTag_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function radiobutton1_Callback(hObject, eventdata, handles)
handles = setButton(handles,hObject,1,handles.textColor1);
guidata(hObject, handles);
function radiobutton2_Callback(hObject, eventdata, handles)
handles = setButton(handles,hObject,2,handles.textColor2);
guidata(hObject, handles);
function radiobutton3_Callback(hObject, eventdata, handles)
handles = setButton(handles,hObject,3,handles.textColor3);
guidata(hObject, handles);
function radiobutton4_Callback(hObject, eventdata, handles)
handles = setButton(handles,hObject,4,handles.textColor4);
guidata(hObject, handles);
function radiobutton5_Callback(hObject, eventdata, handles)
handles = setButton(handles,hObject,5,handles.textColor5);
guidata(hObject, handles);
function radiobutton6_Callback(hObject, eventdata, handles)
handles = setButton(handles,hObject,6,handles.textColor6);
guidata(hObject, handles);
function radiobutton7_Callback(hObject, eventdata, handles)
handles = setButton(handles,hObject,7,handles.textColor7);
guidata(hObject, handles);
function radiobutton8_Callback(hObject, eventdata, handles)
handles = setButton(handles,hObject,8,handles.textColor8);
guidata(hObject, handles);
function radiobutton9_Callback(hObject, eventdata, handles)
handles = setButton(handles,hObject,9,handles.textColor9);
guidata(hObject, handles);
function radiobutton10_Callback(hObject, eventdata, handles)
handles = setButton(handles,hObject,10,handles.textColor10);
guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
% hObject    handle to menuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menuFileExport_Callback(hObject, eventdata, handles)
% hObject    handle to menuFileExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
5
handles = assignWorkspaceData(handles);

% --------------------------------------------------------------------
function menuFileReturn_Callback(hObject, eventdata, handles)
% hObject    handle to menuFileReturn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
user_response = confCloseModal('Title','Confirm Close');
switch lower(user_response)
    case 'no'
        % take no action
    case 'yes'
        handles.output = handles;
        % Update handles structure
        guidata(hObject, handles)
        uiresume(handles.figure1)
%        delete(handles.figure1)
end
