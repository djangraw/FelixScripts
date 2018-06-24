function varargout = JitteredLR_GUI(varargin)
% JITTEREDLR_GUI M-file for JitteredLR_GUI.fig
%      JITTEREDLR_GUI, by itself, creates a new JITTEREDLR_GUI or raises the existing
%      singleton*.
%
%      H = JITTEREDLR_GUI returns the handle to a new JITTEREDLR_GUI or the handle to
%      the existing singleton*.
%
%      JITTEREDLR_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in JITTEREDLR_GUI.M with the given input arguments.
%
%      JITTEREDLR_GUI('Property','Value',...) creates a new JITTEREDLR_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before JitteredLR_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to JitteredLR_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help JitteredLR_GUI

% Last Modified by GUIDE v2.5 19-Dec-2011 13:33:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @JitteredLR_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @JitteredLR_GUI_OutputFcn, ...
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


% --- Executes just before JitteredLR_GUI is made visible.
function JitteredLR_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to JitteredLR_GUI (see VARARGIN)

% Choose default command line output for JitteredLR_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Update copyparams
allresults = dir('results*');
set(handles.popup_copyparams,'string',{'Copy Parameters From File...', allresults(:).name});


% UIWAIT makes JitteredLR_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = JitteredLR_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popup_copyparams.
function popup_copyparams_Callback(hObject, eventdata, handles)
% hObject    handle to popup_copyparams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_copyparams contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_copyparams

contents = cellstr(get(hObject,'String'));
foldername = contents{get(hObject,'Value')};
paramsfile = dir([foldername '/params*']);
if length(paramsfile)~=1
    set(handles.text_status,'string','Error: file not found.')
    return;
end
% load parameters file
load([foldername '/' paramsfile.name]);

% Set Input Settings
set(handles.edit_subject,'string',scope_settings.subject);
set(handles.edit_saccadetype,'string',scope_settings.saccadeType);
set(handles.check_weightprior,'value',pop_settings.weightprior);
set(handles.edit_cvmode,'string',scope_settings.cvmode);
set(handles.edit_jitterrange,'string',num2str(pop_settings.jitterrange));

% Set scope of analysis
set(handles.edit_trainingwindowlength,'string',num2str(scope_settings.trainingwindowlength));
set(handles.edit_trainingwindowinterval,'string',num2str(scope_settings.trainingwindowinterval));
set(handles.edit_trainingwindowrange,'string',num2str(scope_settings.trainingwindowrange));
set(handles.check_parallel,'value',scope_settings.parallel);

% Set pop settings
set(handles.check_usefirstsaccade,'value',pop_settings.useFirstSaccade);
set(handles.check_removebaselineyval,'value',pop_settings.removeBaselineYVal);
set(handles.check_forceonewinner,'value',pop_settings.forceOneWinner);
set(handles.check_usetwoposteriors,'value',pop_settings.useTwoPosteriors);
set(handles.check_conditionprior,'value',pop_settings.conditionPrior);
set(handles.check_denoisedata,'value',pop_settings.deNoiseData);
set(handles.edit_denoiseremove,'string',num2str(pop_settings.deNoiseRemove));
set(handles.edit_convergencethreshold,'string',num2str(pop_settings.convergencethreshold));
if isfield(pop_settings,'null_sigmamultiplier')
    set(handles.edit_sigmamultiplier,'string',num2str(pop_settings.null_sigmamultiplier));
else
    set(handles.edit_sigmamultiplier,'string','1');
end

% Set logist settings
set(handles.edit_eigvalratio,'string',num2str(logist_settings.eigvalratio));
set(handles.edit_lambda,'string',num2str(logist_settings.lambda));
set(handles.check_lambdasearch,'value',logist_settings.lambdasearch);
set(handles.check_regularize,'value',logist_settings.regularize);

set(handles.text_status,'string',['Parameters last loaded from ' foldername])

% --- Executes on button press in button_run.
function button_run_Callback(hObject, eventdata, handles)
% hObject    handle to button_run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Input Settings
subject = get(handles.edit_subject,'string');
saccadeType = get(handles.edit_saccadetype,'string');
weightprior = get(handles.check_weightprior,'value');
cvmode = get(handles.edit_cvmode,'string');
jitterrange = str2num(['[' get(handles.edit_jitterrange,'string') ']']);

% Load data for given subject
[ALLEEG,EEG,setlist,saccadeTimes] = loadSubjectData(subject,saccadeType); % eeg info and saccade info
chansubset = 1:ALLEEG(setlist(1)).nbchan;

% extract saccade times according to indicated input
switch saccadeType
    case {'start','toObject_start','allToObject_start'}
        saccadeTimes1 = saccadeTimes.distractor_saccades_start; 
        saccadeTimes2 = saccadeTimes.target_saccades_start;        
    case {'end','toObject_end','allToObject_end'}
        saccadeTimes1 = saccadeTimes.distractor_saccades_end;
        saccadeTimes2 = saccadeTimes.target_saccades_end;    
end

% Declare scope of analysis
scope_settings.subject = subject;
scope_settings.saccadeType = saccadeType;
scope_settings.trainingwindowlength = str2double(get(handles.edit_trainingwindowlength,'string'));
scope_settings.trainingwindowinterval = str2double(get(handles.edit_trainingwindowinterval,'string'));
scope_settings.trainingwindowrange = str2num(get(handles.edit_trainingwindowrange,'string'));
scope_settings.parallel = get(handles.check_parallel,'value');
scope_settings.cvmode = cvmode;

% Declare parameters of pop_logisticregressions_jittered_EM
pop_settings.convergencethreshold = str2double(get(handles.edit_convergencethreshold,'string')); % subspace between spatial weights at which algorithm converges
pop_settings.jitterrange = jitterrange; % In samples please!
pop_settings.weightprior = weightprior; % re-weight prior according to prevalence of each label
pop_settings.useFirstSaccade = get(handles.check_usefirstsaccade,'value'); % 1st iteration prior is first saccade on each trial
pop_settings.removeBaselineYVal = get(handles.check_removebaselineyval,'value'); % Subtract average y value before computing posteriors
pop_settings.forceOneWinner = get(handles.check_forceonewinner,'value'); % make all posteriors 0 except max (i.e. find 'best saccade' in each trial)
pop_settings.useTwoPosteriors = get(handles.check_usetwoposteriors,'value'); % calculate posteriors separately for truth=0,1, use both for Az calculation
pop_settings.conditionPrior = get(handles.check_conditionprior,'value'); % calculate likelihood such that large values of y (in either direction) are rewarded
pop_settings.deNoiseData = get(handles.check_denoisedata,'value'); % only keep approved components (see pop code for selection) in dataset
pop_settings.deNoiseRemove = str2num(get(handles.edit_denoiseremove,'string')); % remove these components
pop_settings.null_sigmamultiplier = str2num(get(handles.edit_sigmamultiplier,'string')); % factor to expand "null y" distribution

% Declare parameters of logist_weighted
logist_settings.eigvalratio = str2double(get(handles.edit_eigvalratio,'string'));
logist_settings.lambda = str2double(get(handles.edit_lambda,'string'));
logist_settings.lambdasearch = get(handles.check_lambdasearch,'value');
logist_settings.regularize = get(handles.check_regularize,'value');


% Define output directory that encodes info about this run
outDirName = ['./results_',subject,'_',saccadeType,'Saccades'];
if weightprior == 1
    outDirName = [outDirName,'_weightprior'];
else
    outDirName = [outDirName,'_noweightprior'];
end
outDirName = [outDirName,'_',cvmode];
outDirName = [outDirName,'_jrange_',num2str(pop_settings.jitterrange(1)),'_to_',num2str(pop_settings.jitterrange(2))];
outDirName = [outDirName,'/'];

% run algorithm with given data & parameters
run_logisticregression_jittered_EM_saccades(outDirName,...
											ALLEEG,...
											setlist,...
											chansubset,...
											saccadeTimes1,...
											saccadeTimes2,...
											scope_settings,...
                                            pop_settings,...
                                            logist_settings);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%   UNUSED FUNCTIONS   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object creation, after setting all properties.
function popup_copyparams_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_copyparams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_trainingwindowlength_Callback(hObject, eventdata, handles)
% hObject    handle to edit_trainingwindowlength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_trainingwindowlength as text
%        str2double(get(hObject,'String')) returns contents of edit_trainingwindowlength as a double


% --- Executes during object creation, after setting all properties.
function edit_trainingwindowlength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_trainingwindowlength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_trainingwindowinterval_Callback(hObject, eventdata, handles)
% hObject    handle to edit_trainingwindowinterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_trainingwindowinterval as text
%        str2double(get(hObject,'String')) returns contents of edit_trainingwindowinterval as a double


% --- Executes during object creation, after setting all properties.
function edit_trainingwindowinterval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_trainingwindowinterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_trainingwindowrange_Callback(hObject, eventdata, handles)
% hObject    handle to edit_trainingwindowrange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_trainingwindowrange as text
%        str2double(get(hObject,'String')) returns contents of edit_trainingwindowrange as a double


% --- Executes during object creation, after setting all properties.
function edit_trainingwindowrange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_trainingwindowrange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_parallel.
function check_parallel_Callback(hObject, eventdata, handles)
% hObject    handle to check_parallel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_parallel



function edit_subject_Callback(hObject, eventdata, handles)
% hObject    handle to edit_subject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_subject as text
%        str2double(get(hObject,'String')) returns contents of edit_subject as a double


% --- Executes during object creation, after setting all properties.
function edit_subject_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_subject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_saccadetype_Callback(hObject, eventdata, handles)
% hObject    handle to edit_saccadetype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_saccadetype as text
%        str2double(get(hObject,'String')) returns contents of edit_saccadetype as a double


% --- Executes during object creation, after setting all properties.
function edit_saccadetype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_saccadetype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_weightprior.
function check_weightprior_Callback(hObject, eventdata, handles)
% hObject    handle to check_weightprior (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_weightprior



function edit_cvmode_Callback(hObject, eventdata, handles)
% hObject    handle to edit_cvmode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_cvmode as text
%        str2double(get(hObject,'String')) returns contents of edit_cvmode as a double


% --- Executes during object creation, after setting all properties.
function edit_cvmode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_cvmode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_jitterrange_Callback(hObject, eventdata, handles)
% hObject    handle to edit_jitterrange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_jitterrange as text
%        str2double(get(hObject,'String')) returns contents of edit_jitterrange as a double


% --- Executes during object creation, after setting all properties.
function edit_jitterrange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_jitterrange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_convergencethreshold_Callback(hObject, eventdata, handles)
% hObject    handle to edit_convergencethreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_convergencethreshold as text
%        str2double(get(hObject,'String')) returns contents of edit_convergencethreshold as a double


% --- Executes during object creation, after setting all properties.
function edit_convergencethreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_convergencethreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_usefirstsaccade.
function check_usefirstsaccade_Callback(hObject, eventdata, handles)
% hObject    handle to check_usefirstsaccade (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_usefirstsaccade


% --- Executes on button press in check_removebaselineyval.
function check_removebaselineyval_Callback(hObject, eventdata, handles)
% hObject    handle to check_removebaselineyval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_removebaselineyval


% --- Executes on button press in check_forceonewinner.
function check_forceonewinner_Callback(hObject, eventdata, handles)
% hObject    handle to check_forceonewinner (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_forceonewinner


% --- Executes on button press in check_usetwoposteriors.
function check_usetwoposteriors_Callback(hObject, eventdata, handles)
% hObject    handle to check_usetwoposteriors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_usetwoposteriors


% --- Executes on button press in check_denoisedata.
function check_denoisedata_Callback(hObject, eventdata, handles)
% hObject    handle to check_denoisedata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_denoisedata



function edit_denoiseremove_Callback(hObject, eventdata, handles)
% hObject    handle to edit_denoiseremove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_denoiseremove as text
%        str2double(get(hObject,'String')) returns contents of edit_denoiseremove as a double


% --- Executes during object creation, after setting all properties.
function edit_denoiseremove_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_denoiseremove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_regularize.
function check_regularize_Callback(hObject, eventdata, handles)
% hObject    handle to check_regularize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_regularize


% --- Executes on button press in check_lambdasearch.
function check_lambdasearch_Callback(hObject, eventdata, handles)
% hObject    handle to check_lambdasearch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_lambdasearch



function edit_lambda_Callback(hObject, eventdata, handles)
% hObject    handle to edit_lambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_lambda as text
%        str2double(get(hObject,'String')) returns contents of edit_lambda as a double


% --- Executes during object creation, after setting all properties.
function edit_lambda_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_lambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_eigvalratio_Callback(hObject, eventdata, handles)
% hObject    handle to edit_eigvalratio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_eigvalratio as text
%        str2double(get(hObject,'String')) returns contents of edit_eigvalratio as a double


% --- Executes during object creation, after setting all properties.
function edit_eigvalratio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_eigvalratio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_conditionprior.
function check_conditionprior_Callback(hObject, eventdata, handles)
% hObject    handle to check_conditionprior (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_conditionprior



function edit_sigmamultiplier_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sigmamultiplier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sigmamultiplier as text
%        str2double(get(hObject,'String')) returns contents of edit_sigmamultiplier as a double


% --- Executes during object creation, after setting all properties.
function edit_sigmamultiplier_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sigmamultiplier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
