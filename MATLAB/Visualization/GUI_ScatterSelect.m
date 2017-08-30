function varargout = GUI_ScatterSelect(varargin)
% GUI_SCATTERSELECT MATLAB code for GUI_ScatterSelect.fig
%
% h = GUI_ScatterSelect(xdata,ydata,xInfo,yInfo,isSelected)
% 
% INPUTS:
% -xdata is an nxmxp matrix of the x coordinates for each voxel.
% -ydata is an nxmxp matrix of the y coordinates for each voxel. 
% -xInfo is the AFNI info struct for the x coordinates (the RootName field 
% will be used on the xlabel). It will also be used to write any output
% brick to an AFNI .BRIK file.
% -yInfo is the AFNI info struct for the y coordinates (for the y label).
% -isSelected is an nxmxp matrix of boolean values indicating whether each
% voxel should start as selected (optional: empty input = none selected).
%
% OUTPUTS:
% -h is a handle to the GUI figure; to get handles, use handles=guidata(h).
%
% BUTTONS:
% -Select Points will let you click and drag on the plot to draw a lasso
% around groups of points you want to select.
% -Deselect Points does the same thing, but will change any selected points
% to deselected.
% -Undo will revert to the previous set of selections (pressing again will
% redo).
% -Show 1:1 line turns the black diagonal line on or off.
% -the Show Mask button uses GUI_3View to plot a mask of the selected
% voxels interactively.
% -the Save Mask button uses WriteBrick to write a mask of the selected
% voxels to a new AFNI brick (note: it will not overwrite an existing file)
%
% Created 4/3/15 by DJ.
%
%      GUI_SCATTERSELECT, by itself, creates a new GUI_SCATTERSELECT or raises the existing
%      singleton*.
%
%      H = GUI_SCATTERSELECT returns the handle to a new GUI_SCATTERSELECT or the handle to
%      the existing singleton*.
%
%      GUI_SCATTERSELECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_SCATTERSELECT.M with the given input arguments.
%
%      GUI_SCATTERSELECT('Property','Value',...) creates a new GUI_SCATTERSELECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_ScatterSelect_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_ScatterSelect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Edit the above text to modify the response to help GUI_ScatterSelect

% Last Modified by GUIDE v2.5 03-Apr-2015 15:37:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_ScatterSelect_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_ScatterSelect_OutputFcn, ...
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

% ======================== %
% ===== I/O FUNCTIONS ==== %
% ======================== %

% --- Executes just before GUI_ScatterSelect is made visible.
function GUI_ScatterSelect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_ScatterSelect (see VARARGIN)

% Choose default command line output for GUI_ScatterSelect
handles.output = hObject;

% gather inputs
if nargin>4
    handles.xdata = varargin{1};
    handles.ydata = varargin{2};    
else
    error('>=2 inputs must be provided!');
end
if nargin>5 && ~isempty(varargin{3})
    handles.xInfo = varargin{3};
else
    handles.xInfo = struct('RootName','Input 1'); 
end
if nargin>6 && ~isempty(varargin{4})
    handles.yInfo = varargin{4};
else
    handles.yInfo = struct('RootName','Input 2'); 
end
if nargin>7 && ~isempty(varargin{5})
    handles.isSelected = (varargin{5}~=0); % convert to boolean immediately
else
    handles.isSelected = false(size(handles.xdata));
end

% store undo data
handles.wasSelected = handles.isSelected;

% plot data
axes(handles.axes_points); cla; hold on;
handles.hDots(1) = plot(handles.axes_points, 0,0,'b.','buttondownfcn',@StartLasso); % is not selected
handles.hDots(2) = plot(handles.axes_points, 0,0,'r.','buttondownfcn',@StartLasso); % is selected

% Update data
PlotData(handles);
% plot 1:1 line
xLine = get(handles.axes_points,'xlim');
handles.hLine = plot(handles.axes_points, xLine,xLine,'k:');
% Turn line on or off
if get(handles.toggle_showline,'Value')
    set(handles.hLine,'Visible','on');
else
    set(handles.hLine,'Visible','off');
end

% Annotate plot
xlabel(handles.axes_points, handles.xInfo.RootName,'Interpreter','None');
ylabel(handles.axes_points, handles.yInfo.RootName,'Interpreter','None');
legend(handles.axes_points, 'Not Selected','Selected');

% SET CONSTANTS
handles.lassothr = diff(get(gca,'XLim'))/1000;
handles.SELECT = 1; % select-points mode
handles.DESELECT = 2; % deselect-points mode

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes GUI_ScatterSelect wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = GUI_ScatterSelect_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% ======================== %
% ===== SUBFUNCTIONS ===== %
% ======================== %

function PlotData(handles) % [hDots,hLine] = 

% Update status
set(handles.text_npoints,'string',sprintf('%d points selected',sum(handles.isSelected(:)~=0)));
% Update dots
set(handles.hDots(1),'xdata',handles.xdata(~handles.isSelected),'ydata',handles.ydata(~handles.isSelected));
set(handles.hDots(2),'xdata',handles.xdata(handles.isSelected),'ydata',handles.ydata(handles.isSelected));



function StartLasso(hObject,eventdata,handles)
handles = guidata(hObject);

% get current point
foo = get(gca,'CurrentPoint');
handles.xy = foo(1,1:2);
if handles.mode == handles.SELECT % select points
    handles.hLasso = plot(handles.xy(:,1),handles.xy(:,2),'m.-');
else % deselect
    handles.hLasso = plot(handles.xy(:,1),handles.xy(:,2),'c.-');
end
% handles.isDown = true;
set(gcf,'WindowButtonMotionFcn',@TraceLasso)
set(gcf,'WindowButtonUpFcn',@StopLasso);
guidata(hObject,handles);


function TraceLasso(hObject,eventdata)
handles = guidata(hObject);
foo = get(gca,'CurrentPoint');    
if norm(foo(1,1:2)-handles.xy(end,:))>handles.lassothr
    handles.xy = [handles.xy; foo(1,1:2)];    
end    

% Update handles structure
guidata(hObject, handles);
set(handles.hLasso,'XData',handles.xy(:,1),'YData',handles.xy(:,2));
drawnow;

function StopLasso(hObject,eventdata)
handles = guidata(hObject);
% handles.isDown=false;
set(gcf,'WindowButtonMotionFcn',[])
set(gcf,'WindowButtonUpFcn',[]);

handles.xy = [handles.xy; handles.xy(1,:)]; % close polygon
set(handles.hLasso,'XData',handles.xy(:,1),'YData',handles.xy(:,2));
drawnow;
isIn = inpolygon(handles.xdata,handles.ydata,handles.xy(:,1),handles.xy(:,2));
if ~isempty(isIn)
    handles.wasSelected = handles.isSelected;
    if handles.mode == handles.SELECT
        handles.isSelected(isIn) = true;
    else
        handles.isSelected(isIn) = false;
    end
end
% [handles.hDots,handles.hLine] = PlotData(handles);
PlotData(handles);
delete(handles.hLasso);
% Update handles structure
guidata(hObject, handles);



% ======================== %
% ===== UICONTROL FNS ==== %
% ======================== %

% --- Executes on button press in toggle_selectpoints.
function toggle_selectpoints_Callback(hObject, eventdata, handles)
% hObject    handle to toggle_selectpoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of toggle_selectpoints

if get(hObject,'Value')
    set(handles.toggle_deselectpoints,'Value',false);
    set(handles.axes_points,'buttondownfcn',@StartLasso);
    set(handles.hDots,'buttondownfcn',@StartLasso);
    set(handles.hLine,'buttondownfcn',@StartLasso);
else
    set(handles.axes_points,'buttondownfcn',[]);
    set(handles.hDots,'buttondownfcn',[]);
    set(handles.hLine,'buttondownfcn',[]);
end

handles.mode = handles.SELECT;
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in toggle_deselectpoints.
function toggle_deselectpoints_Callback(hObject, eventdata, handles)
% hObject    handle to toggle_deselectpoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of toggle_deselectpoints

if get(hObject,'Value')
    set(handles.toggle_selectpoints,'Value',false);
    set(handles.axes_points,'buttondownfcn',@StartLasso);
    set(handles.hDots,'buttondownfcn',@StartLasso);
    set(handles.hLine,'buttondownfcn',@StartLasso);
else
    set(handles.axes_points,'buttondownfcn',[]);
    set(handles.hDots,'buttondownfcn',[]);
    set(handles.hLine,'buttondownfcn',[]);
end

handles.mode = handles.DESELECT;
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in toggle_showline.
function toggle_showline_Callback(hObject, eventdata, handles)
% hObject    handle to toggle_showline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of toggle_showline

if get(hObject,'Value')
    set(handles.hLine,'Visible','on');
else
    set(handles.hLine,'Visible','off');
end


% --- Executes on button press in button_showmask.
function button_showmask_Callback(hObject, eventdata, handles)
% hObject    handle to button_showmask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% GUI_3View(double(handles.isSelected));

olay = handles.isSelected;
mask = (handles.xdata~=0 | handles.ydata~=0) & ~isnan(handles.xdata) & ~isnan(handles.ydata);
GUI_3View(cat(4,mask/2,(mask+olay)/2,mask/2));

% --- Executes on button press in button_savemask.
function button_savemask_Callback(hObject, eventdata, handles)
% hObject    handle to button_savemask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

filename = uiputfile('*.BRIK','Select AFNI Brik To Write');
if isequal(filename,0) % cancel
    set(handles.text_status,'string','File write canceled.')
else  
    iDot = find(filename=='.',1,'last');
    iPlus = find(filename=='+',1,'last');
    if ~isempty(iPlus)
        Opt.Prefix = filename(1:(iPlus-1));
        Opt.View = filename(iPlus:(iDot-1));
    elseif ~isempty(iDot)
        Opt.Prefix = filename(1:(iDot-1));
    else
        Opt.Prefix = filename;
    end
    [err, ErrMessage, Info] = WriteBrik(handles.isSelected,handles.xInfo,Opt);
    if err==0        
        set(handles.text_status,'string',{'Wrote brik:', filename});
    else
        set(handles.text_status,'string',{'Write error:', ErrMessage});
    end
end


% --- Executes on button press in push_undo.
function push_undo_Callback(hObject, eventdata, handles)
% hObject    handle to push_undo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% swap isSelected and wasSelected.
isS = handles.isSelected;
handles.isSelected = handles.wasSelected;
handles.wasSelected = isS;
% re-plot data
% [handles.hDots,handles.hLine] = PlotData(handles);
PlotData(handles);
if get(handles.toggle_showline,'Value')
    set(handles.hLine,'Visible','on');
else
    set(handles.hLine,'Visible','off');
end

% Update handles structure
guidata(hObject, handles);
