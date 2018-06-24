function handles = setAtlasList(handles)


if isfield(handles,'RegionNames')
    handles = rmfield(handles,'RegionNames');
end

% get region names:
load txtCort
load txtSub
regN = [txtCort;txtSub];

% save total number of cortical brain regions:
handles.nrCorticalRegions = size(txtCort,1);

% save original region labels:
A = load_nii(handles.Priv.brainAtlases{1});
A = A.img;
labels = nonzeros(unique(A));
A = load_nii(handles.Priv.brainAtlases{2});
A = A.img;
handles.regionLabelsOrig = [labels; uint8(nonzeros(unique(A)))];

% save region names with region label (1,2,...,69):
for w = 1:length(handles.regionLabelsOrig)
    handles.RegionNames{w} = [num2str(w) ' ' regN{w}];
end

%set names to atlas list:
set(handles.popupmenuAtlas,'Value',1)
set(handles.popupmenuAtlas,'String',handles.RegionNames)