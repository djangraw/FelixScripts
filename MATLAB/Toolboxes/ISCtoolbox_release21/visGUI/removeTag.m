function handles = removeTag(handles,hObject)

minNrOfTags = 0;
maxNrOfTags = 6;
Val = get(handles.listboxTags,'Value');
contents = get(handles.listboxTags,'String');
if length(contents) == 1
    contents = '';
    set(handles.listboxTags,'Value',1)
    set(handles.listboxTags,'String',contents)
    handles.tags = [zeros(1,maxNrOfTags);ones(1,maxNrOfTags)];
else
    for k = 1:length(contents)-1
        cont{k} = contents{k};
    end
    contents = cont;
    handles.tags(:,Val:end-1) = handles.tags(:,Val+1:end);
    handles.tags(:,end) = [0;1];
    set(handles.listboxTags,'Value',1)
    set(handles.listboxTags,'String',contents)
end

if length(contents) == minNrOfTags
    set(hObject,'Enable','off')
    set(handles.sliderTime,'Enable','off')

end
if length(contents) < maxNrOfTags
    set(handles.pushbuttonAdd,'Enable','on')
end

handles.currentTag = get(handles.listboxTags,'Value');

timeValtmp = handles.H.timeVal;
intVal = calcInterval(handles.tags(2,handles.currentTag),handles.H);
set(handles.editTag,'String',intVal)
set(handles.sliderTime,'Value',handles.tags(2,handles.currentTag))

handles.TagContents = get(handles.listboxTags,'String');

if sum(handles.tags(1,:)) == 0
    set(handles.pushbuttonSegment,'Enable','off')
else
    set(handles.pushbuttonSegment,'Enable','on')
end
