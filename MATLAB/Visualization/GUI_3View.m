function varargout = GUI_3View(varargin)
% GUI_3VIEW MATLAB code for GUI_3View.fig
%
% GUI_3View(brick,iSlice)
% GUI_3View(filename)
% 
% INPUTS:
% -brick is an nxmxp matrix (grayscale) or nxmxpx3 (RGB) matrix of the
% values to be plotted at each voxel.
% -iSlice (optional) is the (i,j,k) coordinate that the GUI should
% start focusing on.
% -filename is a string indicating the AFNI brick to be loaded.
%
% Created 10/2014 by DJ.
% Updated 4/3/15 by DJ - RGB bug fix, comments.
% Updated 11/25/15 by DJ - RGB closes colorbar figure.
% Updated 12/21/15 by DJ - fixed bug when moving mouse offscreen
% Updated 6/9/16 by DJ - commented out axes(hObject) line for compatibility
%   with MATLAB R2016a.
%
%      GUI_3VIEW, by itself, creates a new GUI_3VIEW or raises the existing
%      singleton*.
%
%      H = GUI_3VIEW returns the handle to a new GUI_3VIEW or the handle to
%      the existing singleton*.
%
%      GUI_3VIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_3VIEW.M with the given input arguments.
%
%      GUI_3VIEW('Property','Value',...) creates a new GUI_3VIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_3View_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_3View_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_3View

% Last Modified by GUIDE v2.5 05-Dec-2014 11:59:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_3View_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_3View_OutputFcn, ...
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

% --- Executes just before GUI_3View is made visible.
function GUI_3View_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_3View (see VARARGIN)

% Choose default command line output for GUI_3View
handles.output = hObject;

% initialize
handles.brick_loaded = rand([3,3,3]);
handles.brick = handles.brick_loaded;
handles.activedim = 1;
% handles.slicesize = 1;

handles.axes_sli = subplot(2,2,1);
title(handles.axes_sli,'Slices');
xlabel(handles.axes_sli,'x');
ylabel(handles.axes_sli,'y');
zlabel(handles.axes_sli,'z');
handles.axes_sag = subplot(2,2,3);
title(handles.axes_sag,'Sagittal');
ylabel(handles.axes_sag,'z');
xlabel(handles.axes_sag,'y');
handles.axes_cor = subplot(2,2,4);
title(handles.axes_cor,'Coronal');
ylabel(handles.axes_cor,'z');
xlabel(handles.axes_cor,'x');
handles.axes_axi = subplot(2,2,2);
title(handles.axes_axi,'Axial');
ylabel(handles.axes_axi,'y');
xlabel(handles.axes_axi,'x');
handles.axislist = [handles.axes_sag, handles.axes_cor, handles.axes_axi];
handles.togglelist = [handles.toggle_R, handles.toggle_G, handles.toggle_B];

% load coordinates if provided as input
if nargin>4
    handles.iSlice = varargin{2};
else
    handles.iSlice = [1 1 1];
end
% Update handles structure
guidata(hObject, handles);

% load file/data if provided as input
if nargin>3
    filein = varargin{1};
    if ischar(filein) || isnumeric(filein)
        LoadFile(filein,hObject,handles);
    end
end



% % This sets up the initial plot - only do when we are invisible
% % so window can get raised using GUI_3View.
% if strcmp(get(hObject,'Visible'),'off')
%     imagesc(handles.brick);
%     axis equal
%     colormap gray
% end

% UIWAIT makes GUI_3View wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_3View_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



%======================%
%    SUB-FUNCTIONS
%======================%

% --- Load a given file --- %
function LoadFile(file,hObject,handles)

if ischar(file)
    [err, V, Info, ErrMessage] = BrikLoad(file);
    set(handles.text_file,'String',Info.RootName);
elseif isnumeric(file)
    V = file;
    set(handles.text_file,'String','Matrix Given as Input');
end
if (ndims(V)==4 && size(V,4)==3); % grayscale or RGB
    handles.brick_loaded = V;
    set(handles.togglelist,'Visible','on','Value',1);
else
    handles.brick_loaded = nanmean(V,4);
    set(handles.togglelist,'Visible','off');
end
% make sure slice is in volume
handles.iSlice = min(handles.iSlice,[size(V,1),size(V,2),size(V,3)]);
% handles.iSlice = [1 1 1];
% handles.slicesize = Info.DELTA;

% All channels are on
handles.brick = handles.brick_loaded;

RedrawAllSlices(handles,hObject);

% set axis dimensions so each pixel is of equal size
for iDim = 1:3    
    axis(handles.axislist(iDim),'equal');
end

% Update axes
axis(handles.axislist(1),[1, size(handles.brick,2), 1, size(handles.brick,3)]);
axis(handles.axislist(2),[1, size(handles.brick,1), 1, size(handles.brick,3)]);
axis(handles.axislist(3),[1, size(handles.brick,1), 1, size(handles.brick,2)]);
set(handles.axislist,'ydir','normal');

% get color limits
if size(handles.brick,4)<3
    clim = [min(handles.brick(:)), max(handles.brick(:))];
    set(handles.axislist,'clim',clim);
    colormap gray
    % make a colorbar figure
    figure(999); clf; axes('clim',clim,'visible','off'); colormap gray; colorbar;
else
    % close the colorbar figure
    if ishandle(999)
        close(999);
    end
end

% Update handles structure
guidata(hObject, handles);

% colormap(handles.axes_sli,'jet');


% --- Redraw one slice of the image. --- %
function RedrawSlice(brick,activedim,iSlice,hAxis)
cla(hAxis); 
hold(hAxis,'on');
set(hAxis,'ydir','reverse');
% axis equal
sizebrick = size(brick);
iSlice = min(sizebrick(1:3),iSlice);
iSlice = max([1 1 1],iSlice);
switch activedim
    case 1 % sagittal
        foo = permute(squeeze(brick(iSlice(1),:,:,:)),[2 1 3]);
        hImg = imagesc(foo,'Parent',hAxis);
%         axis(hAxis,[1, size(brick,2), 1, size(brick,3)]);
        hLine1 = plot(hAxis,[iSlice(2), iSlice(2)],get(hAxis,'ylim'),'g');
        hLine2 = plot(hAxis,get(hAxis,'xlim'),[iSlice(3), iSlice(3)],'g');
    case 2 % coronal
        foo = permute(squeeze(brick(:,iSlice(2),:,:)),[2 1 3]);
        hImg = imagesc(foo,'Parent',hAxis);
%         axis(hAxis,[1, size(brick,1), 1, size(brick,3)]);
        hLine1 = plot(hAxis,[iSlice(1), iSlice(1)],get(hAxis,'ylim'),'g');
        hLine2 = plot(hAxis,get(hAxis,'xlim'),[iSlice(3), iSlice(3)],'g');
    case 3 % axial
        foo = permute(squeeze(brick(:,:,iSlice(3),:)),[2 1 3]);
        hImg = imagesc(foo,'Parent',hAxis);
%         axis(hAxis,[1, size(brick,1), 1, size(brick,2)]);
        hLine1 = plot(hAxis,[iSlice(1), iSlice(1)],get(hAxis,'ylim'),'g');
        hLine2 = plot(hAxis,get(hAxis,'xlim'),[iSlice(2), iSlice(2)],'g');
end
hold off;

set(hAxis,'ydir','normal');
set(hImg,'ButtonDownFcn',@MoveCrosshair);
set(hLine1,'ButtonDownFcn',@MoveCrosshair);
set(hLine2,'ButtonDownFcn',@MoveCrosshair);
set(gcf,'WindowButtonUpFcn',@StopMovingCrosshair);

% colormap gray
% colorbar;


% --- Redraw All Slices of the image. --- %
function RedrawAllSlices(handles,hObject)
% draw 3d slices
slice(handles.axes_sli,permute(nanmean(handles.brick,4),[2 1 3]),handles.iSlice(1),handles.iSlice(2),handles.iSlice(3));
xlabel(handles.axes_sli,'x');
ylabel(handles.axes_sli,'y');
zlabel(handles.axes_sli,'z');
% correct slice
sizebrick = size(handles.brick);
handles.iSlice = min(sizebrick(1:3),handles.iSlice);
handles.iSlice = max([1 1 1],handles.iSlice);

% Redraw slices
for iDim = 1:3
    % redraw
    RedrawSlice(handles.brick, iDim, handles.iSlice,handles.axislist(iDim));
end

% update coordinates text
set(handles.text_xyz,'string',sprintf('(x,y,z) = (%d,%d,%d)',handles.iSlice));
% update intensity text
if size(handles.brick,4)==3
    set(handles.text_intensity,'string',sprintf('(R,G,B) = (%.2f,%.2f,%.2f)',handles.brick(handles.iSlice(1),handles.iSlice(2),handles.iSlice(3),:)));
else
    set(handles.text_intensity,'string',sprintf('intensity = %.2f',handles.brick(handles.iSlice(1),handles.iSlice(2),handles.iSlice(3))));
end

% try
%     axes(hObject); % go back to object you were on before this ran
% end

% --- Move the crosshairs in a given axis. --- %
function MoveCrosshair(objHandle,eventData)

set(gcf,'WindowButtonMotionFcn',@DragCrosshair);
DragCrosshair(objHandle,eventData);


% --- Continue moving the crosshairs in a given axis. --- %
function DragCrosshair(objHandle,eventData)
hObject = gca;%get(objHandle,'Parent');
coords = get(hObject,'CurrentPoint');
coords = coords(1,1:2);
iSlice_new = round(coords);

handles = guidata(hObject);%guihandles(get(hAxis,'Parent'));
activedim = find(handles.axislist==hObject);
handles.iSlice(setdiff(1:3,activedim)) = iSlice_new;
% Update handles structure
guidata(hObject, handles);

RedrawAllSlices(handles,hObject);

% --- Stop crosshair form moving when you move the mouse. --- %
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
if ~isequal(file,0)
    LoadFile(file,hObject,handles);
end

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
%   TOGGLE FUNCTIONS
%======================%

% --- Executes on button press in toggle_R.
function toggle_R_Callback(hObject, eventdata, handles)
% hObject    handle to toggle_R (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of toggle_R

% Adjust brick
if get(hObject,'Value')~=0
    handles.brick(:,:,:,1) = handles.brick_loaded(:,:,:,1);
else
    handles.brick(:,:,:,1) = 0;
end
% Update handles structure
guidata(hObject, handles);

% Redraw slices
RedrawAllSlices(handles,hObject);

% --- Executes on button press in toggle_G.
function toggle_G_Callback(hObject, eventdata, handles)
% hObject    handle to toggle_G (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of toggle_G

% Adjust brick
if get(hObject,'Value')~=0
    handles.brick(:,:,:,2) = handles.brick_loaded(:,:,:,2);
else
    handles.brick(:,:,:,2) = 0;
end
% Update handles structure
guidata(hObject, handles);

% Redraw slices
RedrawAllSlices(handles,hObject);


% --- Executes on button press in toggle_B.
function toggle_B_Callback(hObject, eventdata, handles)
% hObject    handle to toggle_B (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of toggle_B

% Adjust brick
if get(hObject,'Value')~=0
    handles.brick(:,:,:,3) = handles.brick_loaded(:,:,:,3);
else
    handles.brick(:,:,:,3) = 0;
end
% Update handles structure
guidata(hObject, handles);

% Redraw slices
RedrawAllSlices(handles,hObject);

%======================%
%   UNUSED FUNCTIONS
%======================%

function text_intensity_Callback(hObject, eventdata, handles)
% hObject    handle to text_intensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text_intensity as text
%        str2double(get(hObject,'String')) returns contents of text_intensity as a double


% --- Executes during object creation, after setting all properties.
function text_intensity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_intensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


