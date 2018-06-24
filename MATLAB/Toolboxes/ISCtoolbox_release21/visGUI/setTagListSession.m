function handles = setTagListSession(handles,hObject)

brainReg = handles.H.CurrentRegion;
if handles.H.At == 2
    brainReg = brainReg + length(handles.H.txtCort);
end
handles.sessionTags{brainReg,handles.H.dataset}{1} = handles.tags;
handles.sessionTags{brainReg,handles.H.dataset}{2} = handles.corMat;
 
handles.H.dataset = get(hObject,'Value');
handles.tags = handles.sessionTags{brainReg,handles.H.dataset}{1};
