function handles = assignWorkspaceData(handles)

if isfield(handles,'sC')
    assignin('base','curves',handles.sC)
end
if isfield(handles,'spMap')
    assignin('base','spMaps',handles.spMap)
end
if isfield(handles,'totalBrainSynch')
    assignin('base','totalBrainSynch',handles.totalBrainSynch)
end
if isfield(handles,'corMat')
    assignin('base','spatialCor',handles.corMat)
end
assignin('base','Tags',handles.sessionTags)