function handles = addTag(handles,hObject)

maxNrOfTags = 6;
minNrOfTags = 0;

contents = get(handles.listboxTags,'String');
if length(contents) < maxNrOfTags
   contents{end+1} = handles.tagNames{length(contents)+1};
   set(handles.listboxTags,'String',contents)
   set(handles.listboxTags,'Value',length(contents))
end

if length(contents) == maxNrOfTags
    set(hObject,'Enable','off')
end
if length(contents) > minNrOfTags
    set(handles.pushbuttonRemove,'Enable','on')
    set(handles.sliderTime,'Enable','on')
end

handles.tags(1,length(contents)) = 1;
handles.tags(2,length(contents)) = 1;
handles.currentTag = get(handles.listboxTags,'Value');
intVal = calcInterval(handles.tags(2,handles.currentTag),handles.H);
set(handles.editTag,'String',intVal)
set(handles.sliderTime,'Value',handles.tags(2,handles.currentTag))
handles.TagContents = get(handles.listboxTags,'String');

if sum(handles.tags(1,:)) == 0
    set(handles.pushbuttonSegment,'Enable','off')
else
    set(handles.pushbuttonSegment,'Enable','on')
end
