function Curve = updateTemporalData(handles)

load([handles.Pub.dataDestination 'memMaps'])
contents2 = get(handles.listboxAtlasList,'String');

for k = 1:length(contents2)
    if handles.Synch == 1
        if handles.ROIcurve == 1
            S = 1;
        elseif handles.ROIcurve == 2
            S = 0;
        else
            switch handles.alpha
                case 1 % 0.05
                    inds = 1;
                case 2 % 0.01
                    inds = 5;
                case 3 % 0.001
                    inds = 9;
            end
            S = inds+handles.correction-1;
            S = 14 - S;
        end
        
        Curve(:,k) =  memMaps.synchMap.([handles.Priv.prefixSession...
            num2str(handles.dataset)]).([handles.Priv.prefixFreqBand num2str(handles.freqBand-1)]).Data(...
            handles.plottedRegions(k)).tcsa(:,end-S,3,handles.AtlasThreshold);
        if handles.NormalSynch
            % Global ISC curve over all brain voxels:
            NormalCurve(:,k) =  memMaps.synchMap.([handles.Priv.prefixSession...
                num2str(handles.dataset)]).([handles.Priv.prefixFreqBand...
                num2str(handles.freqBand-1)]).Data(end).tcsa(:,end-S,3,...
                handles.AtlasThreshold);            
            NC = NormalCurve(:,k);
        end
    else
        Curve(:,k) = memMaps.phaseSynchMap.([handles.Priv.prefixSession...
            num2str(handles.dataset)]).([handles.Priv.prefixFreqBand num2str(handles.freqBand-1)]).Data(...
            handles.plottedRegions(k)).tca(:,handles.ROIcurve,handles.AtlasThreshold);
        if handles.NormalSynch
            NormalCurve(:,k) =  memMaps.phaseSynchMap.([handles.Priv.prefixSession...
                num2str(handles.dataset)]).([handles.Priv.prefixFreqBand ...
                num2str(handles.freqBand-1)]).Data(end).tca(:,handles.ROIcurve,...
                handles.AtlasThreshold);
                NC = NormalCurve(:,k);
        end
    end
end

L = length(contents2);

for k = 1:L
    clear memMaps
    if ~strcmp(handles.Priv.computerInfo.endian,handles.endian)
        Curve(:,k) = swapbytes(Curve(:,k));
        if handles.NormalSynch
            NormalCurve(:,k) = swapbytes(NormalCurve(:,k));
        end
    end
    if handles.swapBytesOn
        Curve(:,k) = swapbytes(Curve(:,k));
        if handles.NormalSynch
            NormalCurve(:,k) = swapbytes(NormalCurve(:,k));
        end
    end
end

if handles.NormalSynch
    Curve = Curve./NormalCurve;
    F = ', normalized';
else
    F = '';
end

if handles.NormalSynch
    Curve = [Curve NC];
end


