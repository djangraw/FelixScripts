function handles = setTemporalSettings(handles,type)

%set(handles.checkboxTimeWindow,'Enable',type)
set(handles.editTime,'Visible',type)
set(handles.textTime,'Visible',type)
set(handles.pushbuttonTimeUp,'Visible',type)
set(handles.pushbuttonTimeUpFast,'Visible',type)
set(handles.pushbuttonTimeDown,'Visible',type)
set(handles.pushbuttonTimeDownFast,'Visible',type)

set(handles.pushbuttonExportSynch,'Enable',type)
set(handles.checkboxNormalSynch,'Enable',type)
set(handles.pushbuttonPlotSynch,'Enable',type)
set(handles.radionButtonPhaseSynch,'Enable',type)
set(handles.radionButtonSynch,'Enable',type)
set(handles.radionButtonSynchMean,'Enable',type)
set(handles.radionButtonSynchMedian,'Enable',type)
set(handles.radionButtonSynchThres,'Enable',type)
set(handles.pushbuttonAnalysisSynch,'Enable',type)
set(handles.textROI,'Enable',type)

if strcmp(type,'off')
    handles.timeVal = 1;
    handles.win = 0;
    set(handles.sliderTime,'Visible','off','Value',1)    
    intVal = calcInterval(handles.timeVal,handles);
    set(handles.editTime,'String',intVal);    
end