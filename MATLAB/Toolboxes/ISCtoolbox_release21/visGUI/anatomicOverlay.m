function W = anatomicOverlay(handles,SegVals,S,dataAt,data)

% This funtion overlays masked data values on anatomical MRI image.

if nargin == 2
    % this code is called only through time-series GUI:
    switch handles.At
        case 1
            load([handles.pathAtlas 'Cort'])
        case 2
            load([handles.pathAtlas 'Sub'])
    end
    dataAt = at(:,:,:,handles.AtlasThreshold);clear at
end

if nargin == 5
    % Overlay just one slice. This code is run in the main GUI window.
    switch handles.orient
        % get orientation defined by user:
        case 3
            W = rot90(squeeze(handles.anatomy(S,:,:)));
        case 2
            W = rot90(squeeze(handles.anatomy(:,S,:)));
        case 
            W = rot90(squeeze(handles.anatomy(:,:,S)));
    end
    % overlay masked values on anatomical slice:
    if handles.MaskingType == 1
        % region based masking:
        W(find(dataAt == handles.CurrentRegion)) = SegVals;
    else
        % threshold based masking:
        if ~handles.freqCompOn
            W(find(data >= handles.Threshold)) = SegVals;
        else
            W(find(data >= handles.ThresholdPF)) = SegVals;
        end
    end
else
    % Overlay masked values on all slices. 
    % This code is run in the temporal analysis GUI window.
    W(find(dataAt == handles.CurrentRegion)) = SegVals;
end
