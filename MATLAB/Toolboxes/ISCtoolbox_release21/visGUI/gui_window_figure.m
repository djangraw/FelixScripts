function varargout = gui_window_figure(varargin)
% GUI_WINDOW_FIGURE M-file for gui_window_figure.fig
%      GUI_WINDOW_FIGURE, by itself, creates a new GUI_WINDOW_FIGURE or raises the existing
%      singleton*.
%
%      H = GUI_WINDOW_FIGURE returns the handle to a new GUI_WINDOW_FIGURE or the handle to
%      the existing singleton*.
%
%      GUI_WINDOW_FIGURE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_WINDOW_FIGURE.M with the given input arguments.
%
%      GUI_WINDOW_FIGURE('Property','Value',...) creates a new GUI_WINDOW_FIGURE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_window_figure_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_window_figure_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_window_figure

% Last Modified by GUIDE v2.5 07-Apr-2009 00:58:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_window_figure_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_window_figure_OutputFcn, ...
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

% --- Executes just before gui_window_figure is made visible.
function gui_window_figure_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_window_figure (see VARARGIN)

handles.maxNrFreqBands = 12;
handles.maxNrSimMeasures = 8;
handles.maxNrSessions = 6;


set(handles.uipanelSet,'Visible','on')
set(handles.uipanelSim,'Visible','on')
set(handles.uipanelBand,'Visible','on')

set(handles.radiobuttonFreq1,'Visible','off','Parent',handles.uipanelBand)
set(handles.radiobuttonFreq2,'Visible','off','Parent',handles.uipanelBand)
set(handles.radiobuttonFreq3,'Visible','off','Parent',handles.uipanelBand)
set(handles.radiobuttonFreq4,'Visible','off','Parent',handles.uipanelBand)
set(handles.radiobuttonFreq5,'Visible','off','Parent',handles.uipanelBand)
set(handles.radiobuttonFreq6,'Visible','off','Parent',handles.uipanelBand)
set(handles.radiobuttonFreq7,'Visible','off','Parent',handles.uipanelBand)
set(handles.radiobuttonFreq8,'Visible','off','Parent',handles.uipanelBand)
set(handles.radiobuttonFreq9,'Visible','off','Parent',handles.uipanelBand)
set(handles.radiobuttonFreq10,'Visible','off','Parent',handles.uipanelBand)
set(handles.radiobuttonFreq11,'Visible','off','Parent',handles.uipanelBand)
set(handles.radiobuttonFreq12,'Visible','off','Parent',handles.uipanelBand)

set(handles.radiobuttonSim1,'Visible','off','Parent',handles.uipanelSim)
set(handles.radiobuttonSim2,'Visible','off','Parent',handles.uipanelSim)
set(handles.radiobuttonSim3,'Visible','off','Parent',handles.uipanelSim)
set(handles.radiobuttonSim4,'Visible','off','Parent',handles.uipanelSim)
set(handles.radiobuttonSim5,'Visible','off','Parent',handles.uipanelSim)
set(handles.radiobuttonSim6,'Visible','off','Parent',handles.uipanelSim)
set(handles.radiobuttonSim7,'Visible','off','Parent',handles.uipanelSim)
set(handles.radiobuttonSim8,'Visible','off','Parent',handles.uipanelSim)

set(handles.radiobuttonSet1,'Parent',handles.uipanelSet,'Position',[1.5 6.5 22.8000 1.1538],'Visible','off')
set(handles.radiobuttonSet2,'Parent',handles.uipanelSet,'Position',[1.5 5 22.8000 1.1538],'Visible','off')
set(handles.radiobuttonSet3,'Parent',handles.uipanelSet,'Position',[1.5 3.5 22.8000 1.1538],'Visible','off')
set(handles.radiobuttonSet4,'Parent',handles.uipanelSet,'Position',[1.5 2 22.8000 1.1538],'Visible','off')
set(handles.radiobuttonSet5,'Parent',handles.uipanelSet,'Position',[1.5 0.5 22.8000 1.1538],'Visible','off')
set(handles.radiobuttonSet6,'Parent',handles.uipanelSet,'Position',[1.5 -1 22.8000 1.1538],'Visible','off')

H = varargin{1};
handles.bandNames = H.bandNames;
handles.similarityMeasureNames = H.similarityMeasureNames;
handles.sessionNames = H.sessionNames;
handles.figureSet = H.figureSet;
handles.figureSim = H.figureSim;
handles.figureBand = H.figureBand;
handles.plotColbar = H.plotColbar;
handles.annotationsOn = H.annotationsOn;
handles.rowPlot = H.rowPlot;
handles.colPlot = H.colPlot;

set(handles.checkboxPlotColorbar,'Value',handles.plotColbar)
set(handles.checkboxPlotAnnotations,'Value',handles.annotationsOn)
set(handles.popupmenuRows,'Value',handles.rowPlot);
set(handles.popupmenuColumns,'Value',handles.colPlot);
handles = setPanels(handles);

%handles.freqCompOn = H.freqCompOn;
%handles.freqBand = H.freqBand;

if ~H.freqCompOn
    for k = 1:length(handles.similarityMeasureNames)
        set(handles.(['radiobuttonSim' num2str(k)]),'Visible','on','String',...
            handles.similarityMeasureNames{k},'Value',handles.figureSim(k))
    end
    if length(handles.similarityMeasureNames)+1 <= handles.maxNrSimMeasures
        for k = (length(handles.similarityMeasureNames)+1):handles.maxNrSimMeasures
            set(handles.(['radiobuttonSim' num2str(k)]),'Visible','off')
        end
    end
else
    handles.figureBand(H.freqBand) = 0;
end

for k = 1:length(handles.sessionNames)
    set(handles.(['radiobuttonSet' num2str(k)]),'Visible','on','String',...
        handles.sessionNames{k},'Value',handles.figureSet(k))
end
if length(handles.sessionNames)+1 <= handles.maxNrSessions
    for k = (length(handles.sessionNames)+1):handles.maxNrSessions
        set(handles.(['radiobuttonSet' num2str(k)]),'Visible','off')
    end
end
for k = 1:length(handles.bandNames)
    set(handles.(['radiobuttonFreq' num2str(k)]),'Visible','on','String',...
        handles.bandNames{k},'Value',handles.figureBand(k))
end
if length(handles.bandNames)+1 <= handles.maxNrFreqBands
    for k = (length(handles.bandNames)+1):handles.maxNrFreqBands
        set(handles.(['radiobuttonFreq' num2str(k)]),'Visible','off')
    end
end

if H.freqCompOn
    set(handles.uipanelSim,'Visible','off')
    %    set(handles.(['radiobuttonFreq' num2str(H.freqBand)]),'Visible','off')
else
    set(handles.uipanelSim,'Visible','on')
end

% Choose default command line output for gui_window_figure
handles.output = handles;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_window_figure wait for user response (see UIRESUME)
set(handles.figure1,'WindowStyle','modal')

uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = gui_window_figure_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

delete(handles.figure1)

% --- Executes on button press in pushbuttonCreateFig.
function pushbuttonCreateFig_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCreateFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% return current handles in output:
handles.newFigure = 1;
handles.output = handles; 
guidata(hObject, handles);
uiresume(handles.figure1)

% --- Executes on button press in pushbuttonCancel.
function pushbuttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% return initial handles in output:
handles = handles.output;
handles.newFigure = 0;
handles.output = handles;
guidata(hObject, handles);
uiresume(handles.figure1);

% --- Executes on button press in radiobuttonFreq2.
function radiobuttonFreq2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonFreq2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonFreq2
handles.figureBand(2) = get(hObject,'Value');
guidata(hObject, handles);

% --- Executes on button press in radiobuttonFreq3.
function radiobuttonFreq3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonFreq3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonFreq3
handles.figureBand(3) = get(hObject,'Value');
guidata(hObject, handles);

% --- Executes on button press in radiobuttonFreq4.
function radiobuttonFreq4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonFreq4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonFreq4
handles.figureBand(4) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in radiobuttonFreq5.
function radiobuttonFreq5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonFreq5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonFreq5
handles.figureBand(5) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in radiobuttonFreq1.
function radiobuttonFreq1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonFreq1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonFreq1
handles.figureBand(1) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in radiobuttonFreq6.
function radiobuttonFreq6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonFreq6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonFreq6
handles.figureBand(6) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in radiobuttonSim1.
function radiobuttonSim1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonSim1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonSim1
handles.figureSim(1) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in radiobuttonSim2.
function radiobuttonSim2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonSim2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonSim2
handles.figureSim(2) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in radiobuttonSim3.
function radiobuttonSim3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonSim3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonSim3
handles.figureSim(3) = get(hObject,'Value');
guidata(hObject, handles);

% --- Executes on button press in checkbox1.
function checkboxPlotColorbar_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.plotColbar = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in radiobuttonSet1.
function radiobuttonSet1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonSet1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonSet1
handles.figureSet(1) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in radiobuttonSet2.
function radiobuttonSet2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonSet2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonSet2
handles.figureSet(2) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on selection change in popupmenuRows.
function popupmenuRows_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuRows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuRows contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuRows

val = get(hObject,'Value');
if val ~= handles.colPlot
    handles.rowPlot = get(hObject,'Value');
else
    set(hObject,'Value',handles.rowPlot);
end

handles = setPanels(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuRows_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuRows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenuColumns.
function popupmenuColumns_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenuColumns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenuColumns contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenuColumns

val = get(hObject,'Value');
if val ~= handles.rowPlot
    handles.colPlot = get(hObject,'Value');
else
    set(hObject,'Value',handles.colPlot);
end

handles = setPanels(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenuColumns_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuColumns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in radiobuttonFreq7.
function radiobuttonFreq7_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonFreq7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonFreq7
handles.figureBand(7) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in radiobuttonFreq8.
function radiobuttonFreq8_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonFreq8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonFreq8
handles.figureBand(8) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in radiobuttonFreq9.
function radiobuttonFreq9_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonFreq9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonFreq9
handles.figureBand(9) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in radiobuttonFreq10.
function radiobuttonFreq10_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonFreq10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonFreq10
handles.figureBand(10) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in radiobuttonFreq11.
function radiobuttonFreq11_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonFreq11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonFreq11
handles.figureBand(11) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in radiobuttonFreq12.
function radiobuttonFreq12_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonFreq12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonFreq12
handles.figureBand(12) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in radiobuttonSim4.
function radiobuttonSim4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonSim4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonSim4
handles.figureSim(4) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in radiobuttonSim5.
function radiobuttonSim5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonSim5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonSim5
handles.figureSim(5) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in radiobuttonSim6.
function radiobuttonSim6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonSim6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonSim6
handles.figureSim(6) = get(hObject,'Value');
guidata(hObject, handles);

% --- Executes on button press in radiobuttonSim7.
function radiobuttonSim7_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonSim7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonSim7
handles.figureSim(7) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in radiobuttonSim8.
function radiobuttonSim8_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonSim8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonSim8
handles.figureSim(8) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in radiobuttonSet3.
function radiobuttonSet3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonSet3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonSet3
handles.figureSet(3) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in radiobuttonSet4.
function radiobuttonSet4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonSet4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonSet4
handles.figureSet(4) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in radiobuttonSet5.
function radiobuttonSet5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonSet5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonSet5
handles.figureSet(5) = get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in radiobuttonSet6.
function radiobuttonSet6_Callback(hObject, eventdata, handles)
% hObject    handle to radiobuttonSet6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobuttonSet6

handles.figureSet(6) = get(hObject,'Value');
guidata(hObject, handles);



% --- Executes on button press in checkboxPlotAnnotations.
function checkboxPlotAnnotations_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxPlotAnnotations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkboxPlotAnnotations
handles.annotationsOn = get(hObject,'Value');
guidata(hObject, handles);


