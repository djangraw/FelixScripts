function varargout = GUI_PlotScan(varargin)
% GUI_PLOTSCAN MATLAB code for GUI_PlotScan.fig
%      GUI_PLOTSCAN, by itself, creates a new GUI_PLOTSCAN or raises the existing
%      singleton*.
%
%      H = GUI_PLOTSCAN returns the handle to a new GUI_PLOTSCAN or the handle to
%      the existing singleton*.
%
%      GUI_PLOTSCAN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_PLOTSCAN.M with the given input arguments.
%
%      GUI_PLOTSCAN('Property','Value',...) creates a new GUI_PLOTSCAN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_PlotScan_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_PlotScan_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Edit the above text to modify the response to help GUI_PlotScan
%
% Last Modified by GUIDE v2.5 28-Oct-2014 10:35:20
% Updated 11/9/15 by DJ - fixed first-time-loading bug.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_PlotScan_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_PlotScan_OutputFcn, ...
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

% --- Executes just before GUI_PlotScan is made visible.
function GUI_PlotScan_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_PlotScan (see VARARGIN)

% Choose default command line output for GUI_PlotScan
handles.output = hObject;

% initialize
handles.brick = rand([3,3,3]);
handles.iSlice = [2 2 2];
handles.activedim = 1;
handles.slicesize = 1;

% set up axes
axes(handles.axes1);
hold on;

% Update handles structure
guidata(hObject, handles);

% % This sets up the initial plot - only do when we are invisible
% % so window can get raised using GUI_PlotScan.
% if strcmp(get(hObject,'Visible'),'off')
%     imagesc(handles.brick);
%     axis equal
%     colormap gray
% end

% UIWAIT makes GUI_PlotScan wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_PlotScan_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%======================%
%  BUTTON FUNCTIONS
%======================%

% --- Executes on button press in button_update.
function button_update_Callback(hObject, eventdata, handles)
% hObject    handle to button_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
cla;
hold on;

activedim = get(handles.popup_orientation, 'Value');
RedrawSlice(handles.brick, activedim, handles.iSlice)
set(handles.text_xyz,'string',sprintf('(x,y,z) = (%d,%d,%d)',handles.iSlice));

% set slider values
slidermax = size(handles.brick,activedim);
set(handles.slider_iSlice,'max',slidermax,'value',slidermax-handles.iSlice(activedim)+1,'SliderStep',[1/slidermax, 10/slidermax]);
dims = 'xyz';
set(handles.text_iSlice,'string',sprintf('%s=%d',dims(activedim),handles.iSlice(activedim)));

handles.activedim = activedim;
% Update handles structure
guidata(hObject, handles);

% --- Executes on slider movement.
function slider_iSlice_Callback(hObject, eventdata, handles)
% hObject    handle to slider_iSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

iSliceRev = round(get(hObject,'value')); % slider is reversed (1 at top)
set(hObject,'value',iSliceRev);
handles.iSlice(handles.activedim) = size(handles.brick,handles.activedim)-iSliceRev+1;

% Redraw slice
RedrawSlice(handles.brick, handles.activedim, handles.iSlice)
set(handles.text_xyz,'string',sprintf('(x,y,z) = (%d,%d,%d)',handles.iSlice));

dims = 'xyz';
set(handles.text_iSlice,'string',sprintf('%s=%d',dims(handles.activedim),handles.iSlice(handles.activedim)));

% Update handles structure
guidata(hObject, handles);


%======================%
%    SUB-FUNCTIONS
%======================%
function RedrawSlice(brick,activedim,iSlice)
cla;
set(gca,'ydir','reverse');
axis equal
iSlice = min(size(brick),iSlice);
switch activedim
    case 1 % sagittal
        hImg = imagesc(squeeze(brick(iSlice(1),:,:))');
        axis([1, size(brick,2), 1, size(brick,3)]);
        hLine1 = plot([iSlice(2), iSlice(2)],get(gca,'ylim'),'g');
        hLine2 = plot(get(gca,'xlim'),[iSlice(3), iSlice(3)],'g');
    case 2 % coronal
        hImg = imagesc(squeeze(brick(:,iSlice(2),:))');
        axis([1, size(brick,1), 1, size(brick,3)]);
        hLine1 = plot([iSlice(1), iSlice(1)],get(gca,'ylim'),'g');
        hLine2 = plot(get(gca,'xlim'),[iSlice(3), iSlice(3)],'g');
    case 3 % axial
        hImg = imagesc(brick(:,:,iSlice(3))');
        axis([1, size(brick,1), 1, size(brick,2)]);
        hLine1 = plot([iSlice(1), iSlice(1)],get(gca,'ylim'),'g');
        hLine2 = plot(get(gca,'xlim'),[iSlice(2), iSlice(2)],'g');
end

set(hImg,'ButtonDownFcn',@MoveCrosshair);
set(hLine1,'ButtonDownFcn',@MoveCrosshair);
set(hLine2,'ButtonDownFcn',@MoveCrosshair);
set(gcf,'WindowButtonUpFcn',@StopMovingCrosshair);

colormap gray
colorbar;

function MoveCrosshair(objHandle,eventData)

set(gcf,'WindowButtonMotionFcn',@DragCrosshair);
DragCrosshair(objHandle,eventData);


function DragCrosshair(objHandle,eventData)
hObject = gca;
coords = get(hObject,'CurrentPoint');
coords = coords(1,1:2);
iSlice_new = round(coords);

handles = guidata(hObject);%guihandles(get(hAxis,'Parent'));
handles.iSlice(setdiff(1:3,handles.activedim)) = iSlice_new;
% Update handles structure
guidata(hObject, handles);
% Redraw slice
RedrawSlice(handles.brick, handles.activedim, handles.iSlice);
set(handles.text_xyz,'string',sprintf('(x,y,z) = (%d,%d,%d)',handles.iSlice));


function StopMovingCrosshair(objHandle,eventData)

set(gcf,'WindowButtonMotionFcn','');

%======================%
%    MENU FUNCTIONS
%======================%
% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.BRIK');
if ~isequal(file, 0)
    [err, V, Info, ErrMessage] = BrikLoad (file);
end
if ndims(V)==3
    handles.brick = V;
else
    handles.brick = mean(V,4);
end
handles.iSlice = [1 1 1];
handles.slicesize = Info.DELTA;

% set slider values
activedim = handles.activedim;
slidermax = size(handles.brick,activedim);
set(handles.slider_iSlice,'max',slidermax,'value',slidermax-handles.iSlice(activedim)+1,'SliderStep',[1/slidermax, 10/slidermax]);
dims = 'xyz';
set(handles.text_iSlice,'string',sprintf('%s=%d',dims(activedim),handles.iSlice(activedim)));


% Update handles structure
guidata(hObject, handles);
% Redraw slice
RedrawSlice(handles.brick, handles.activedim, handles.iSlice);
set(handles.text_xyz,'string',sprintf('(x,y,z) = (%d,%d,%d)',handles.iSlice));

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)




%======================%
%   UNUSED FUNCTIONS
%======================%
% --- Executes on selection change in popup_orientation.
function popup_orientation_Callback(hObject, eventdata, handles)
% hObject    handle to popup_orientation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_orientation contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_orientation


% --- Executes during object creation, after setting all properties.
function popup_orientation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_orientation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function slider_iSlice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_iSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
