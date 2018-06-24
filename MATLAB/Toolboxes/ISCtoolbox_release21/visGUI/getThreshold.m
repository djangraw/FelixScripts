function handles = getThreshold(handles)

if handles.manualTh
    handles.Threshold = handles.H.Priv.th(handles.ThresholdVal);
else
    load([handles.H.Priv.statsDestination 'Th' ...
        handles.H.Priv.prefixFreqBand num2str(handles.H.freqBand-1) ...
        'Session' num2str(handles.H.dataset) 'win1.mat'],'Th')
    Th(Th==0)=NaN;
    handles.Threshold = Th(2);
    if handles.ThresholdVal == 2
        handles.Threshold = Th(6);
    end
end