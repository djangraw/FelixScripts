function handles = setThresholdView(handles)


% always force manual thresholding these maps:
if handles.mapType > 2 && ~handles.freqCompOn && ~handles.sessionCompOn
    if get(handles.radiobuttonAutomaticTh,'Value')
        set(handles.radiobuttonManualTh,'Value',1)
    end
    set(handles.radiobuttonAutomaticTh,'Value',0,'Visible','off')
    handles.manual = 1;
else
    set(handles.radiobuttonAutomaticTh,'Visible','on')
end

if get(handles.checkboxTh,'Value') % thresholding set on
    handles.Masking = 1;
    set(handles.radiobuttonAtlasTh,'Visible','on')
    set(handles.radiobuttonManualTh,'Visible','on')
    if get(handles.radiobuttonManualTh,'Value') % manual thresholding set on
        set(handles.editThreshold,'Visible','on','Enable','on')
        set(handles.popupmenuCorrectionMap,'Visible','off')
        set(handles.popupmenuAlphaMap,'Visible','off')
        set(handles.textAlphaLevel,'Visible','off')
        set(handles.textCorrectionMethod,'Visible','off')
        set(handles.textThreshold,'Visible','on')
        handles.MaskingType = 2;
        handles.manual = 1;
    end
    if get(handles.radiobuttonAutomaticTh,'Value') % automatic thresholding set on
        set(handles.editThreshold,'Visible','on','Enable','off')
        if handles.mapType < 3 || handles.freqCompOn || handles.sessionCompOn
            set(handles.popupmenuCorrectionMap,'Visible','on')
            set(handles.popupmenuAlphaMap,'Visible','on')
            set(handles.textAlphaLevel,'Visible','on')
            set(handles.textCorrectionMethod,'Visible','on')
        else
            set(handles.popupmenuCorrectionMap,'Visible','off')
            set(handles.popupmenuAlphaMap,'Visible','off')
            set(handles.textAlphaLevel,'Visible','off')
            set(handles.textCorrectionMethod,'Visible','off')
        end
        set(handles.textThreshold,'Visible','on')
        handles.MaskingType = 2;
        handles.manual = 0;
    end
    if get(handles.radiobuttonAtlasTh,'Value') % atlas-based thresholding set on
        set(handles.editThreshold,'Visible','off')
        set(handles.popupmenuCorrectionMap,'Visible','off')
        set(handles.textAlphaLevel,'Visible','off')
        set(handles.textThreshold,'Visible','off')
        set(handles.textCorrectionMethod,'Visible','off')
        set(handles.popupmenuAlphaMap,'Visible','off')
        handles.MaskingType = 1;
    end
else % no thresholding selected
    handles.Masking = 0;
    set(handles.radiobuttonAutomaticTh,'Visible','off')
    set(handles.radiobuttonAtlasTh,'Visible','off')
    set(handles.radiobuttonManualTh,'Visible','off')
    set(handles.editThreshold,'Visible','off')
    set(handles.popupmenuCorrectionMap,'Visible','off')
    set(handles.popupmenuAlphaMap,'Visible','off')
    set(handles.textAlphaLevel,'Visible','off')
    set(handles.textThreshold,'Visible','off')
    set(handles.textCorrectionMethod,'Visible','off')
end

handles.changeInCurrentAxes = 1;
