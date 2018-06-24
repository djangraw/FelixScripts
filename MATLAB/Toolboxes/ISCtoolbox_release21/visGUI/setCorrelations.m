function handles = setCorrelations(handles)

if sum(handles.tags(1,:)) > 0
    handles.corMat = corr(handles.spMap(1:sum(handles.tags(1,:)),:)');
    set(handles.textSpatialCorr,'String',num2str(round(100*handles.corMat)/100))
    set(handles.textTemporalCorr,'String',num2str(round(100*handles.corMat)/100))
else
    set(handles.textSpatialCorr,'String',' ')
    set(handles.textTemporalCorr,'String',' ')
end
