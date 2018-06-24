function handles = updateSpatialMaps(handles)

load([handles.H.Pub.dataDestination 'memMaps'])

ROI_inds = find(handles.MaskedAt);
handles.spMap = zeros(size(handles.tags(2,:),2),length(ROI_inds));
for k = 1:size(handles.tags(2,:),2)
    if handles.tags(1,k)
        D = memMaps.resultMap.win.([...
            handles.H.Priv.prefixFreqBand num2str(handles.H.freqBand-1)...
            ]).([handles.H.Priv.prefixSession num2str(handles.H.dataset)...
            ]).(handles.H.Priv.simM{handles.H.SimMeasure+2}).Data(handles.tags(2,k)).xyz;
%    if handles.H.swapBytesOn
        D = swapbytes(D);
%    end
handles.spMap(k,:) = D(ROI_inds);
        
    end
end
%    if handles.H.swapBytesOn
%handles.spMap(k,:) = swapbytes(handles.spMap(k,:));
%    end

handles = setCorrelations(handles);

clear memMaps
