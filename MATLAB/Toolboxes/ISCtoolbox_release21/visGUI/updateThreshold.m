function handles = updateThreshold(handles)

if handles.freqCompOn == 0
    if handles.mapType == 1 && ~handles.manual
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
    if handles.mapType == 2 && ~handles.manual % t-test
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
        %switch handles.alpha
        %handles.Threshold = ;
%       handles.Threshold = 
%       nrSubjectPairs = 
        
    end
else % ZPF test
    if handles.ZPFtest == 1 && ~handles.manual && handles.MaskingType~=1 % sum ZPF
        handles.Threshold = handles.Priv.nrSubjects*(handles.Priv.nrSubjects-1)/2/2;
    end
    if handles.ZPFtest == 2 && ~handles.manual && handles.MaskingType~=1 % sum ZPF
        if ~isnan(handles.freqComp)
            load([handles.Priv.PFDestination 'Th' ...
                handles.Priv.prefixPF 'Session' ...
                num2str(handles.dataset) 'freqComp' ...
                num2str(handles.freqComp) 'win' num2str(handles.win)])
            Th(Th==0) = NaN;
            handles.Threshold(1) = Th(handles.alpha);%/handles.maxSc;
        end
    end
end
handles = setColorMapScale(handles);
%handles = setCurrentColorBar(handles);

