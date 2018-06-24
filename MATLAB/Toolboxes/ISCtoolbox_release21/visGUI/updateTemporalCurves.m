function handles = updateTemporalCurves(handles)

warning off

switch handles.totalSynchMeasure
    case 1
        if handles.manualTh
            % manual threshold
            c = handles.ThresholdVal;
            c = repmat(c,1,handles.H.Priv.maxScale+2);
        else % thresholding based on p-values
            c = handles.thresVec;
            if handles.ThresholdVal == 2
                c = c + 1;
            end
        end
    case 2
        c = length(handles.H.Priv.th) + 2*(handles.H.Priv.maxScale+2) + 1;
        c = repmat(c,1,handles.H.Priv.maxScale+2);
    case 3
        c = length(handles.H.Priv.th) + 2*(handles.H.Priv.maxScale+2) + 2;
        c = repmat(c,1,handles.H.Priv.maxScale+2);
end

% select cortical/subcortical atlas:
if handles.H.At == 1
    CR = handles.H.CurrentRegion;
else
    CR = handles.H.CurrentRegion + 49;
end

handles.sC = zeros(handles.H.Priv.maxScale+2,handles.H.Priv.nrTimeIntervals(handles.H.dataset));
handles.totalBrainSynch = zeros(handles.H.Priv.maxScale+2,handles.H.Priv.nrTimeIntervals(handles.H.dataset));

load([handles.H.Pub.dataDestination 'memMaps'])

for k = 1:handles.H.Priv.maxScale + 2
    handles.sC(k,:) = memMaps.synchMap.([handles.H.Priv.prefixSession...
        num2str(handles.H.dataset)]).([handles.H.Priv.prefixFreqBand...
        num2str(k-1)]).Data(CR).tcsa(:,c(k),3,handles.H.AtlasThreshold);
    if ~strcmp(handles.H.Priv.computerInfo.endian,handles.H.endian)
        handles.sC(k,:) = swapbytes(sC(k,:));
    end
    if handles.normalizationOn
        handles.totalBrainSynch(k,:) = memMaps.synchMap.([handles.H.Priv.prefixSession...
            num2str(handles.H.dataset)]).([handles.H.Priv.prefixFreqBand...
            num2str(k-1)]).Data(end).tcsa(:,c(k),3,handles.H.AtlasThreshold);
        if ~strcmp(handles.H.Priv.computerInfo.endian,handles.H.endian)
            handles.totalBrainSynch(k,:) = swapbytes(handles.totalBrainSynch(k,:));
        end
        handles.sC(k,:) = handles.sC(k,:)./handles.totalBrainSynch(k,:);
    end
end
if handles.H.swapBytesOn
    handles.sC = swapbytes(handles.sC);
end
warning on
clear memMaps