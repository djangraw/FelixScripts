function handles = updateSyncPlotAtlas(handles)

switch handles.H.AtlasThreshold
    case 1
        ind = 1;
    case 2
        ind = 3;
    case 3
        ind = 5;
end
handles.H.At = get(handles.popupmenuAtlas,'Value');

if handles.H.At == 2
    ind = ind + 1;
end

dataAt = load_nii(handles.H.Priv.brainAtlases{ind});
dataAt = dataAt.img;
handles.MaskedAt = dataAt == handles.H.labels{handles.H.At}(handles.H.CurrentRegion);
