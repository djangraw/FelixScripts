function handles = quickUpdateSpatialMaps(handles)

load([handles.H.Pub.dataDestination 'memMaps'])

D = memMaps.resultMap.win.([...
    handles.H.Priv.prefixFreqBand num2str(handles.H.freqBand-1)...
    ]).([handles.H.Priv.prefixSession num2str(handles.H.dataset)...
    ]).(handles.H.Priv.simM{handles.H.SimMeasure+2}).Data(handles.tags(2,handles.currentTag)).xyz;
clear memMaps

%    if handles.H.swapBytesOn
D = swapbytes(D);
%    end

handles.spMap(handles.currentTag,:) = D(find(handles.MaskedAt));

MM = max(handles.sC(:));
if MM == 0
    MM = 1;
end
mm = min(handles.sC(:));
if mm >= MM
    mm = 0;
end
if isempty(mm)
    mm = 0;
end
if isempty(MM)
    MM = 1;
end

set(handles.spatialAxesChildren(handles.currentTag),'YData',...
    handles.spMap(handles.currentTag,:),'XData',1:size(handles.spMap,2),...
    'HandleVisibility','on','Visible','on')

set(handles.timeAxesChildrenTags(handles.currentTag),'XData',...
    handles.tags(2,handles.currentTag)*ones(1,handles.H.Priv.nrTimeIntervals(handles.H.dataset)),...
    'YData',linspace(mm,MM,handles.H.Priv.nrTimeIntervals(handles.H.dataset)),'HandleVisibility','on','Visible','on')

set(handles.timeAxesTagText{handles.currentTag},'Position',...
    [handles.tags(2,handles.currentTag),max(handles.sC(:))],'Visible','on')

% set threshold line:
set(handles.spatialAxesThres,'XData',1:size(handles.spMap,2),'YData',...
    handles.Threshold*(ones(1,size(handles.spMap,2))))

handles = setCorrelations(handles);
