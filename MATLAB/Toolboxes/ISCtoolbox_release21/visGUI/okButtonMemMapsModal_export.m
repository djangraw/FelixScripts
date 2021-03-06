function varargout = okButtonMemMapsModal_export(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',          mfilename, ...
                   'gui_Singleton',     gui_Singleton, ...
                   'gui_OpeningFcn',    @modaldlg_OpeningFcn, ...
                   'gui_OutputFcn',     @modaldlg_OutputFcn, ...
                   'gui_LayoutFcn',  @okButtonMemMapsModal_export_LayoutFcn, ...
                   'gui_Callback',      []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    varargout{1:nargout} = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before modaldlg is made visible.
function modaldlg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to modaldlg (see VARARGIN)

% Choose default command line output for modaldlg
handles.output = 'Yes';

% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
if(nargin > 3)
    for index = 1:2:(nargin-3),
        switch lower(varargin{index})
        case 'title'
            set(hObject, 'Name', varargin{index+1});
        case 'string'
            set(handles.string, 'String', varargin{index+1});
        otherwise
            error('Invalid input arguments');
        end
    end
end

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
FigWidth=215;FigHeight=88;
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','points');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','points');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'position', FigPos);

% Show a question icon from dialogicons.mat - variables questIconData
% and questIconMap
load dialogicons.mat

IconData=errorIconData;
errorIconMap(256,:)=get(handles.figure1,'color');
IconCMap=errorIconMap;

axes(handles.axes1);
Img=image(IconData);
set(handles.figure1, 'Colormap', IconCMap);

set(gca, ...
    'Visible', 'off', ...
    'YDir'   ,'reverse'       , ...
    'XLim'   ,get(Img,'XData'), ...
    'YLim'   ,get(Img,'YData')  ...
    );
    
% UIWAIT makes modaldlg wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = modaldlg_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = [];

% The figure can be deleted now
delete(handles.figure1);

% --- Executes on button press in yes_button.
function yes_button_Callback(hObject, eventdata, handles)
% hObject    handle to yes_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.figure1);
else
    % The GUI is no longer waiting, just close it
    delete(handles.figure1);
end

% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" - do uiresume if we get it
if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.figure1);
end    


% --- Creates and returns a handle to the GUI figure. 
function h1 = okButtonMemMapsModal_export_LayoutFcn(policy)
% policy - create a new figure or use a singleton. 'new' or 'reuse'.

persistent hsingleton;
if strcmpi(policy, 'reuse') & ishandle(hsingleton)
    h1 = hsingleton;
    return;
end
load okButtonMemMapsModal_export.mat


appdata = [];
appdata.GUIDEOptions = struct(...
    'active_h', [], ...
    'taginfo', struct(...
    'figure', [], ...
    'pushbutton', [], ...
    'axes', [], ...
    'text', 7), ...
    'override', [], ...
    'release', 13, ...
    'resize', 'none', ...
    'accessibility', 'callback', ...
    'mfile', [], ...
    'callbacks', [], ...
    'singleton', [], ...
    'syscolorfig', [], ...
    'lastSavedFile', 'D:\Tutkimus\HBM2009\codes\GUI\okButtonMemMapsModal_export.m', ...
    'blocking', 0);
appdata.UsedByGUIData_m = struct(...
    'figure1', [], ...
    'text1', 224.002197265625, ...
    'axes1', [], ...
    'pushbutton2', 217.002319335938, ...
    'pushbutton1', [], ...
    'output', []);
appdata.tagListener = [];
appdata.lastValidTag = 'figure1';
appdata.GUIDELayoutEditor = [];

h1 = figure(...
'Units','points',...
'PaperUnits',get(0,'defaultfigurePaperUnits'),...
'CloseRequestFcn','okButtonMemMapsModal_export(''figure1_CloseRequestFcn'',gcf,[],guidata(gcf))',...
'Color',[0.941176470588235 0.941176470588235 0.941176470588235],...
'Colormap',[0 0 0;0.125 0 0;0.125 0 0.125;0.2890625 0 0;0.2890625 0 0.125;0.125 0.125 0;0.4140625 0 0;0.125 0.125 0.125;0.2890625 0.125 0;0.578125 0 0;0.2890625 0.125 0.125;0.4140625 0.125 0;0.703125 0 0;0.4140625 0.125 0.125;0.578125 0.125 0;0.578125 0.125 0.125;0.2890625 0.2890625 0.125;0.703125 0.125 0;0.2890625 0.2890625 0.2890625;0.4140625 0.2890625 0;0.703125 0.125 0.125;0.4140625 0.2890625 0.125;0.4140625 0.2890625 0.2890625;0.8671875 0.125 0;0.4140625 0.2890625 0.4140625;0.578125 0.2890625 0;0.8671875 0.125 0.125;0.578125 0.2890625 0.125;0.578125 0.2890625 0.2890625;0.703125 0.2890625 0;0.703125 0.2890625 0.125;0.4140625 0.4140625 0.2890625;0.703125 0.2890625 0.2890625;0.4140625 0.4140625 0.4140625;0.578125 0.4140625 0.125;0.8671875 0.2890625 0.125;0.578125 0.4140625 0.2890625;0.703125 0.4140625 0;0.8671875 0.2890625 0.2890625;0.578125 0.4140625 0.4140625;0.703125 0.4140625 0.125;0.703125 0.4140625 0.2890625;0.8671875 0.4140625 0;0.8671875 0.4140625 0.125;0.8671875 0.4140625 0.2890625;0.578125 0.578125 0.2890625;0.99609375 0.4140625 0.125;0.578125 0.578125 0.4140625;0.703125 0.578125 0.125;0.99609375 0.4140625 0.2890625;0.578125 0.578125 0.578125;0.703125 0.578125 0.2890625;0.99609375 0.4140625 0.4140625;0.703125 0.578125 0.4140625;0.8671875 0.578125 0;0.8671875 0.578125 0.125;0.703125 0.578125 0.578125;0.8671875 0.578125 0.2890625;0.99609375 0.578125 0;0.8671875 0.578125 0.4140625;0.99609375 0.578125 0.125;0.703125 0.703125 0.2890625;0.99609375 0.578125 0.2890625;0.99609375 0.578125 0.4140625;0.703125 0.703125 0.578125;0.703125 0.703125 0.703125;0.8671875 0.703125 0.2890625;0.8671875 0.703125 0.4140625;0.99609375 0.703125 0.125;0.8671875 0.703125 0.578125;0.8671875 0.703125 0.703125;0.99609375 0.703125 0.4140625;0.99609375 0.703125 0.578125;0.8671875 0.8671875 0.703125;0.8671875 0.8671875 0.8671875;0.99609375 0.8671875 0.578125;0.99609375 0.8671875 0.703125;0.99609375 0.8671875 0.8671875;0.99609375 0.99609375 0.703125;0.99609375 0.99609375 0.8671875;0.99609375 0.99609375 0.99609375],...
'IntegerHandle','off',...
'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
'KeyPressFcn','okButtonMemMapsModal_export(''figure1_KeyPressFcn'',gcbo,[],guidata(gcbo))',...
'MenuBar','none',...
'Name','okButtonMemMapsModal',...
'NumberTitle','off',...
'PaperPosition',get(0,'defaultfigurePaperPosition'),...
'PaperSize',[20.98404194812 29.67743169791],...
'PaperType',get(0,'defaultfigurePaperType'),...
'Position',[389.25 671.5 207.75 102],...
'Renderer',get(0,'defaultfigureRenderer'),...
'RendererMode','manual',...
'Resize','off',...
'WindowStyle','modal',...
'HandleVisibility','callback',...
'Tag','figure1',...
'UserData',[],...
'Behavior',get(0,'defaultfigureBehavior'),...
'Visible','off',...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.tagListener = [];
appdata.lastValidTag = 'yes_button';

h2 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Callback','okButtonMemMapsModal_export(''yes_button_Callback'',gcbo,[],guidata(gcbo))',...
'FontWeight','bold',...
'ListboxTop',0,...
'Position',[19.4 0.307692307692308 13.2 1.76923076923077],...
'String','OK',...
'Tag','yes_button',...
'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.tagListener = [];
appdata.lastValidTag = 'axes1';

h3 = axes(...
'Parent',h1,...
'Units','characters',...
'Position',[2.8 4.84615384615385 10 3.84615384615385],...
'Box','on',...
'CameraPosition',[160.5 100.5 9.16025403784439],...
'CameraPositionMode',get(0,'defaultaxesCameraPositionMode'),...
'Color',get(0,'defaultaxesColor'),...
'ColorOrder',get(0,'defaultaxesColorOrder'),...
'Layer','top',...
'LooseInset',[7.462 0.99 5.453 0.675],...
'XColor',get(0,'defaultaxesXColor'),...
'XLim',[0.5 320.5],...
'XLimMode','manual',...
'YColor',get(0,'defaultaxesYColor'),...
'YDir','reverse',...
'YLim',[0.5 200.5],...
'YLimMode','manual',...
'ZColor',get(0,'defaultaxesZColor'),...
'Tag','axes1',...
'Behavior',get(0,'defaultaxesBehavior'),...
'Visible','off',...
'CreateFcn', {@local_CreateFcn, '', appdata} );

h4 = get(h3,'title');

set(h4,...
'Parent',h3,...
'Units','data',...
'FontUnits','points',...
'BackgroundColor','none',...
'Color',[0 0 0],...
'EdgeColor','none',...
'EraseMode','normal',...
'DVIMode','auto',...
'FontAngle','normal',...
'FontName','Helvetica',...
'FontSize',10,...
'FontWeight','normal',...
'HorizontalAlignment','center',...
'LineStyle','-',...
'LineWidth',0.5,...
'Margin',[],...
'Position',[157.3 -25.5000000000001 1.00005459937205],...
'Rotation',0,...
'String','',...
'Interpreter','tex',...
'VerticalAlignment','bottom',...
'ButtonDownFcn',[],...
'CreateFcn', {@local_CreateFcn, [], ''} ,...
'DeleteFcn',[],...
'BusyAction','queue',...
'HandleVisibility','off',...
'HelpTopicKey','',...
'HitTest','on',...
'Interruptible','on',...
'SelectionHighlight','on',...
'Serializable','on',...
'Tag','',...
'UserData',[],...
'Behavior',struct(),...
'Visible','off',...
'XLimInclude','on',...
'YLimInclude','on',...
'ZLimInclude','on',...
'CLimInclude','on',...
'ALimInclude','on',...
'Clipping','off');

h5 = get(h3,'xlabel');

set(h5,...
'Parent',h3,...
'Units','data',...
'FontUnits','points',...
'BackgroundColor','none',...
'Color',[0 0 0],...
'EdgeColor','none',...
'EraseMode','normal',...
'DVIMode','auto',...
'FontAngle','normal',...
'FontName','Helvetica',...
'FontSize',10,...
'FontWeight','normal',...
'HorizontalAlignment','center',...
'LineStyle','-',...
'LineWidth',0.5,...
'Margin',[],...
'Position',[157.3 294.5 1.00005459937205],...
'Rotation',0,...
'String','',...
'Interpreter','tex',...
'VerticalAlignment','cap',...
'ButtonDownFcn',[],...
'CreateFcn', {@local_CreateFcn, [], ''} ,...
'DeleteFcn',[],...
'BusyAction','queue',...
'HandleVisibility','off',...
'HelpTopicKey','',...
'HitTest','on',...
'Interruptible','on',...
'SelectionHighlight','on',...
'Serializable','on',...
'Tag','',...
'UserData',[],...
'Behavior',struct(),...
'Visible','off',...
'XLimInclude','on',...
'YLimInclude','on',...
'ZLimInclude','on',...
'CLimInclude','on',...
'ALimInclude','on',...
'Clipping','off');

h6 = get(h3,'ylabel');

set(h6,...
'Parent',h3,...
'Units','data',...
'FontUnits','points',...
'BackgroundColor','none',...
'Color',[0 0 0],...
'EdgeColor','none',...
'EraseMode','normal',...
'DVIMode','auto',...
'FontAngle','normal',...
'FontName','Helvetica',...
'FontSize',10,...
'FontWeight','normal',...
'HorizontalAlignment','center',...
'LineStyle','-',...
'LineWidth',0.5,...
'Margin',[],...
'Position',[-201.1 106.5 1.00005459937205],...
'Rotation',90,...
'String','',...
'Interpreter','tex',...
'VerticalAlignment','bottom',...
'ButtonDownFcn',[],...
'CreateFcn', {@local_CreateFcn, [], ''} ,...
'DeleteFcn',[],...
'BusyAction','queue',...
'HandleVisibility','off',...
'HelpTopicKey','',...
'HitTest','on',...
'Interruptible','on',...
'SelectionHighlight','on',...
'Serializable','on',...
'Tag','',...
'UserData',[],...
'Behavior',struct(),...
'Visible','off',...
'XLimInclude','on',...
'YLimInclude','on',...
'ZLimInclude','on',...
'CLimInclude','on',...
'ALimInclude','on',...
'Clipping','off');

h7 = get(h3,'zlabel');

set(h7,...
'Parent',h3,...
'Units','data',...
'FontUnits','points',...
'BackgroundColor','none',...
'Color',[0 0 0],...
'EdgeColor','none',...
'EraseMode','normal',...
'DVIMode','auto',...
'FontAngle','normal',...
'FontName','Helvetica',...
'FontSize',10,...
'FontWeight','normal',...
'HorizontalAlignment','right',...
'LineStyle','-',...
'LineWidth',0.5,...
'Margin',[],...
'Position',[-92.3 -85.5000000000001 1.00005459937205],...
'Rotation',0,...
'String','',...
'Interpreter','tex',...
'VerticalAlignment','middle',...
'ButtonDownFcn',[],...
'CreateFcn', {@local_CreateFcn, [], ''} ,...
'DeleteFcn',[],...
'BusyAction','queue',...
'HandleVisibility','off',...
'HelpTopicKey','',...
'HitTest','on',...
'Interruptible','on',...
'SelectionHighlight','on',...
'Serializable','on',...
'Tag','',...
'UserData',[],...
'Behavior',struct(),...
'Visible','off',...
'XLimInclude','on',...
'YLimInclude','on',...
'ZLimInclude','on',...
'CLimInclude','on',...
'ALimInclude','on',...
'Clipping','off');

h8 = image(...
'Parent',h3,...
'CData',mat{1},...
'XData',[1 320],...
'YData',[1 200],...
'Behavior',get(0,'defaultimageBehavior'));

appdata = [];
appdata.lastValidTag = 'text2';

h9 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'Position',[21.6 4.51282051282051 10.6 1.15384615384615],...
'String',{  'Static Text' },...
'Style','text',...
'Tag','text2',...
'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.tagListener = [];
appdata.lastValidTag = 'text5';

h10 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Position',[16 6.76923076923077 38.2 1.15384615384615],...
'String','Could not access data from the disk.',...
'Style','text',...
'Tag','text5',...
'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );

appdata = [];
appdata.tagListener = [];
appdata.lastValidTag = 'text6';

h11 = uicontrol(...
'Parent',h1,...
'Units','characters',...
'HorizontalAlignment','left',...
'ListboxTop',0,...
'Max',[],...
'Position',[3 2.30769230769231 50.4 2.30769230769231],...
'String',{  'Possible causes: data does not exist or memory '; 'pointers contain invalid data addresses.' },...
'Style','text',...
'Tag','text6',...
'Behavior',get(0,'defaultuicontrolBehavior'),...
'CreateFcn', {@local_CreateFcn, '', appdata} );


hsingleton = h1;


% --- Set application data first then calling the CreateFcn. 
function local_CreateFcn(hObject, eventdata, createfcn, appdata)

if ~isempty(appdata)
   names = fieldnames(appdata);
   for i=1:length(names)
       name = char(names(i));
       setappdata(hObject, name, getfield(appdata,name));
   end
end

if ~isempty(createfcn)
   eval(createfcn);
end


% --- Handles default GUIDE GUI creation and callback dispatch
function varargout = gui_mainfcn(gui_State, varargin)


%   GUI_MAINFCN provides these command line APIs for dealing with GUIs
%
%      OKBUTTONMEMMAPSMODAL_EXPORT, by itself, creates a new OKBUTTONMEMMAPSMODAL_EXPORT or raises the existing
%      singleton*.
%
%      H = OKBUTTONMEMMAPSMODAL_EXPORT returns the handle to a new OKBUTTONMEMMAPSMODAL_EXPORT or the handle to
%      the existing singleton*.
%
%      OKBUTTONMEMMAPSMODAL_EXPORT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OKBUTTONMEMMAPSMODAL_EXPORT.M with the given input arguments.
%
%      OKBUTTONMEMMAPSMODAL_EXPORT('Property','Value',...) creates a new OKBUTTONMEMMAPSMODAL_EXPORT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before untitled_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to untitled_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.4.6.10.2.1 $ $Date: 2005/01/14 21:54:21 $

gui_StateFields =  {'gui_Name'
                    'gui_Singleton'
                    'gui_OpeningFcn'
                    'gui_OutputFcn'
                    'gui_LayoutFcn'
                    'gui_Callback'};
gui_Mfile = '';
for i=1:length(gui_StateFields)
    if ~isfield(gui_State, gui_StateFields{i})
        error('Could not find field %s in the gui_State struct in GUI M-file %s', gui_StateFields{i}, gui_Mfile);        
    elseif isequal(gui_StateFields{i}, 'gui_Name')
        gui_Mfile = [gui_State.(gui_StateFields{i}), '.m'];
    end
end

numargin = length(varargin);

if numargin == 0
    % OKBUTTONMEMMAPSMODAL_EXPORT
    % create the GUI
    gui_Create = 1;
elseif isequal(ishandle(varargin{1}), 1) && ispc && iscom(varargin{1}) && isequal(varargin{1},gcbo)
    % OKBUTTONMEMMAPSMODAL_EXPORT(ACTIVEX,...)    
    vin{1} = gui_State.gui_Name;
    vin{2} = [get(varargin{1}.Peer, 'Tag'), '_', varargin{end}];
    vin{3} = varargin{1};
    vin{4} = varargin{end-1};
    vin{5} = guidata(varargin{1}.Peer);
    feval(vin{:});
    return;
elseif ischar(varargin{1}) && numargin>1 && isequal(ishandle(varargin{2}), 1)
    % OKBUTTONMEMMAPSMODAL_EXPORT('CALLBACK',hObject,eventData,handles,...)
    gui_Create = 0;
else
    % OKBUTTONMEMMAPSMODAL_EXPORT(...)
    % create the GUI and hand varargin to the openingfcn
    gui_Create = 1;
end

if gui_Create == 0
    varargin{1} = gui_State.gui_Callback;
    if nargout
        [varargout{1:nargout}] = feval(varargin{:});
    else
        feval(varargin{:});
    end
else
    if gui_State.gui_Singleton
        gui_SingletonOpt = 'reuse';
    else
        gui_SingletonOpt = 'new';
    end
    
    % Open fig file with stored settings.  Note: This executes all component
    % specific CreateFunctions with an empty HANDLES structure.
    
    % Do feval on layout code in m-file if it exists
    if ~isempty(gui_State.gui_LayoutFcn)
        gui_hFigure = feval(gui_State.gui_LayoutFcn, gui_SingletonOpt);
        % openfig (called by local_openfig below) does this for guis without
        % the LayoutFcn. Be sure to do it here so guis show up on screen.
        movegui(gui_hFigure,'onscreen')
    else
        gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt);            
        % If the figure has InGUIInitialization it was not completely created
        % on the last pass.  Delete this handle and try again.
        if isappdata(gui_hFigure, 'InGUIInitialization')
            delete(gui_hFigure);
            gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt);            
        end
    end
    
    % Set flag to indicate starting GUI initialization
    setappdata(gui_hFigure,'InGUIInitialization',1);

    % Fetch GUIDE Application options
    gui_Options = getappdata(gui_hFigure,'GUIDEOptions');
    
    if ~isappdata(gui_hFigure,'GUIOnScreen')
        % Adjust background color
        if gui_Options.syscolorfig 
            set(gui_hFigure,'Color', get(0,'DefaultUicontrolBackgroundColor'));
        end

        % Generate HANDLES structure and store with GUIDATA. If there is
        % user set GUI data already, keep that also.
        data = guidata(gui_hFigure);
        handles = guihandles(gui_hFigure);
        if ~isempty(handles)
            if isempty(data)
                data = handles;
            else
                names = fieldnames(handles);
                for k=1:length(names)
                    data.(char(names(k)))=handles.(char(names(k)));
                end
            end
        end
        guidata(gui_hFigure, data);
    end
    
    % If user specified 'Visible','off' in p/v pairs, don't make the figure
    % visible.
    gui_MakeVisible = 1;
    for ind=1:2:length(varargin)
        if length(varargin) == ind
            break;
        end
        len1 = min(length('visible'),length(varargin{ind}));
        len2 = min(length('off'),length(varargin{ind+1}));
        if ischar(varargin{ind}) && ischar(varargin{ind+1}) && ...
                strncmpi(varargin{ind},'visible',len1) && len2 > 1
            if strncmpi(varargin{ind+1},'off',len2)
                gui_MakeVisible = 0;
            elseif strncmpi(varargin{ind+1},'on',len2)
                gui_MakeVisible = 1;
            end
        end
    end
    
    % Check for figure param value pairs
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end
        try set(gui_hFigure, varargin{index}, varargin{index+1}), catch break, end
    end

    % If handle visibility is set to 'callback', turn it on until finished
    % with OpeningFcn
    gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
    if strcmp(gui_HandleVisibility, 'callback')
        set(gui_hFigure,'HandleVisibility', 'on');
    end
    
    feval(gui_State.gui_OpeningFcn, gui_hFigure, [], guidata(gui_hFigure), varargin{:});
    
    if ishandle(gui_hFigure)
        % Update handle visibility
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);
        
        % Make figure visible
        if gui_MakeVisible
            set(gui_hFigure, 'Visible', 'on')
            if gui_Options.singleton 
                setappdata(gui_hFigure,'GUIOnScreen', 1);
            end
        end

        % Done with GUI initialization
        rmappdata(gui_hFigure,'InGUIInitialization');
    end
    
    % If handle visibility is set to 'callback', turn it on until finished with
    % OutputFcn
    if ishandle(gui_hFigure)
        gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
        if strcmp(gui_HandleVisibility, 'callback')
            set(gui_hFigure,'HandleVisibility', 'on');
        end
        gui_Handles = guidata(gui_hFigure);
    else
        gui_Handles = [];
    end
    
    if nargout
        [varargout{1:nargout}] = feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    else
        feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    end
    
    if ishandle(gui_hFigure)
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);
    end
end    

function gui_hFigure = local_openfig(name, singleton)

% this application data is used to indicate the running mode of a GUIDE
% GUI to distinguish it from the design mode of the GUI in GUIDE.
setappdata(0,'OpenGuiWhenRunning',1);

% openfig with three arguments was new from R13. Try to call that first, if
% failed, try the old openfig.
try 
    gui_hFigure = openfig(name, singleton, 'auto');
catch
    % OPENFIG did not accept 3rd input argument until R13,
    % toggle default figure visible to prevent the figure
    % from showing up too soon.
    gui_OldDefaultVisible = get(0,'defaultFigureVisible');
    set(0,'defaultFigureVisible','off');
    gui_hFigure = openfig(name, singleton);
    set(0,'defaultFigureVisible',gui_OldDefaultVisible);
end
rmappdata(0,'OpenGuiWhenRunning');

