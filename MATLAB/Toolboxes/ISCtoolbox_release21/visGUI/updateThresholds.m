function handles = updateThresholds(handles,mapType)

switch mapType
    case 'ISCmap'
        if handles.manual
            if max(handles.dataT(:)) <= handles.Threshold
                handles.Threshold = 0;
            end
        else
            switch handles.alpha
                case 1 % 0.05
                    inds = 1;
                case 2 % 0.01
                    inds = 5;
                case 3 % 0.001
                    inds = 9;
            end
            load([handles.Priv.statsDestination 'Thband' num2str(handles.freqBand-1) 'Session' num2str(handles.dataset) 'win' num2str(handles.win)])
            Th(Th==0) = NaN;
            handles.Threshold = Th(inds+handles.correction-1);
        end
    case 'ISCtmap'
        if handles.manual
            if max(handles.dataT(:)) <= handles.Threshold
                handles.Threshold = 0;
            end
        else
            switch handles.alpha
                case 1
                    inds = 1;
                case 2
                    inds = 5;
                case 3
                    inds = 9;
            end
            load([handles.Priv.statsDestination 'ThTband' num2str(handles.freqBand-1) ...
                'Session' num2str(handles.dataset) 'win' num2str(handles.win)])
            %load([handles.Priv.statsDestination 'ThFisband' num2str(handles.freqBand-1) ...
            %    'Session' num2str(handles.dataset) 'win' num2str(handles.win)])
            Th(Th==0) = NaN;
            handles.Threshold = Th(inds+handles.correction-1);%/handles.maxSc;
        end
    case 'otherISCmap'
        if max(handles.dataT(:)) <= handles.Threshold
            handles.Threshold = 0;
        end
    case 'sessionComp'
        if isnan(handles.sessionComp)
            handles.Threshold = handles.maxSc+0.01;
        else
        if handles.manual
            if max(handles.dataT(:)) <= handles.Threshold
                handles.Threshold = 0;
            end
        else
            load([handles.Priv.PFsessionDestination 'Th' ...
                handles.Priv.prefixPF 'Band' ...
                num2str(handles.freqBand-1) 'sessComp' ...
                num2str(handles.sessionComp) 'win' num2str(handles.win)])
            Th(Th==0) = NaN;
            handles.Threshold(1) = Th(handles.alpha);%/handles.maxSc;
        end
        end
    case 'freqComp'
        if isnan(handles.freqComp) || handles.freqBand == handles.freqBand2
            handles.Threshold = handles.maxSc+0.01;
        else
        if handles.manual
            if max(handles.dataT(:)) <= handles.Threshold
                handles.Threshold = 0;
            end
        else
            load([handles.Priv.PFDestination 'Th' ...
                handles.Priv.prefixPF 'Session' ...
                num2str(handles.dataset) 'freqComp' ...
                num2str(handles.freqComp) 'win' num2str(handles.win)])
            Th(Th==0) = NaN;
            handles.Threshold(1) = Th(handles.alpha);%/handles.maxSc;
        end
        end
    case 'phaseMap'
        if handles.manual
            if max(handles.dataT(:)) <= handles.Threshold
                handles.Threshold = 0;
            end
        else
            switch handles.alpha
                case 1 % 0.05
                    inds = 1;
                case 2 % 0.01
                    inds = 5;
                case 3 % 0.001
                    inds = 9;
            end
            
            load([handles.Priv.statsDestination 'ThPhase' ...
                handles.Priv.prefixFreqBand num2str(handles.freqBand-1) ...
                handles.Priv.prefixSession num2str(handles.dataset)])
            Th(Th==0) = NaN;
     %      handles.Threshold(1) = Th(handles.alpha);%/handles.maxSc;
            handles.Threshold = Th(inds+handles.correction-1);%/handles.maxSc;        
        end
    case 'allFreq'
        if handles.manual
            if max(handles.dataT(:)) <= handles.Threshold
                handles.Threshold = 0;
            end
        else
            switch handles.alpha
                case 1 % 0.05
                    inds = 1;
                case 2 % 0.01
                    inds = 5;
                case 3 % 0.001
                    inds = 9;
            end
            load([handles.Priv.statsDestination 'Thband' num2str(handles.freqBand-1) 'Session' num2str(handles.dataset) 'win' num2str(handles.win)])
            Th(Th==0) = NaN;
            handles.Threshold = Th(inds+handles.correction-1);
        end
    otherwise
        handles.Threshold = 0.01;
end

set(handles.editThreshold,'String',num2str(handles.Threshold))

%handles = setCurrentColorBar(handles);

