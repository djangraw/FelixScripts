function handles = setPanels(handles)

if ( handles.colPlot == 1 && handles.rowPlot == 2 ) || ...
        ( handles.colPlot == 2 && handles.rowPlot == 1 )
    set(handles.uipanelSet,'Visible','off')
else
     set(handles.uipanelSet,'Visible','on')
end
if ( handles.colPlot == 1 && handles.rowPlot == 3 ) || ...
        ( handles.colPlot == 3 && handles.rowPlot == 1 )
    set(handles.uipanelSim,'Visible','off')
else
    set(handles.uipanelSim,'Visible','on')
end
    
if ( handles.colPlot == 3 && handles.rowPlot == 2 ) || ...
        ( handles.colPlot == 2 && handles.rowPlot == 3 )
    set(handles.uipanelBand,'Visible','off')
else
    set(handles.uipanelBand,'Visible','on')
end