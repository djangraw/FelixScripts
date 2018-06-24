function handles = sliderSet(handles,hObject);

handles.timeSliderVal = handles.tags(2,handles.currentTag);
t = get(hObject,'Value');
if ( t - handles.timeSliderVal ) > 0 && ( t - handles.timeSliderVal ) < 1
    handles.timeSliderVal = ceil(t);
elseif ( t - handles.timeSliderVal ) < 0 && ( t - handles.timeSliderVal ) > -1
    handles.timeSliderVal = floor(t);
else
    handles.timeSliderVal = round(t);
end
set(hObject,'Value',handles.timeSliderVal)
intVal = calcInterval(handles.timeSliderVal,handles.H);
set(handles.editTag,'String',intVal)
handles.tags(2,handles.currentTag) = handles.timeSliderVal;
