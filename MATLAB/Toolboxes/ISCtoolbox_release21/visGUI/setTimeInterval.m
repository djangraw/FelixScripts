function handles = setTimeInterval(handles)

handles.intVals = [];
for r = 1:handles.H.Priv.nrTimeIntervals(handles.H.dataset)
    handles.intVals{r} = calcInterval(r,handles.H);
    handles.intVals{r} = handles.intVals{r};
end
it = 1;
while ceil(length(handles.intVals)/(2^(it-1))) > 12
    for r = it:(2^it):length(handles.intVals)
        handles.intVals{r} = [];
    end
    it = it + 1;
end
T = cell(1,sum(handles.tags(1,:)));
set(handles.listboxTags,'Value',1)
handles.currentTag = 1;
for k = 1:size(handles.tags,2)
    if handles.tags(1,k) == 1
        T{k} = handles.tagNames{k};
    end
end
set(handles.listboxTags,'String',T)
intVal = calcInterval(handles.tags(2,handles.currentTag),handles.H);
set(handles.editTag,'String',intVal)
set(handles.sliderTime,'max',handles.H.Priv.nrTimeIntervals(...
    handles.H.dataset),'Value',handles.tags(2,handles.currentTag))