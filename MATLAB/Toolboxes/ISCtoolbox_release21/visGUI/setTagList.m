function handles = setTagList(handles,hObject)

brOld = handles.H.CurrentRegion;
if handles.H.At == 2
    brOld = brOld + length(handles.H.txtCort);
end
handles.sessionTags{brOld,handles.H.dataset}{1} = handles.tags;
handles.sessionTags{brOld,handles.H.dataset}{2} = handles.corMat;

handles.H.CurrentRegion = get(hObject,'Value');
brNew = handles.H.CurrentRegion;
if handles.H.At == 2
    brNew = brNew + length(handles.H.txtCort);
end
handles.tags = handles.sessionTags{brNew,handles.H.dataset}{1};
