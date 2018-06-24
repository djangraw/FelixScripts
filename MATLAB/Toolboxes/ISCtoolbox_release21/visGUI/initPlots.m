function handles = initPlots(handles)

handles.tagColors = [{[0 0 1]},{[1 0 0]},{[0 1 0]},{[1 1 0]},{[0 1 1]},{[1 0 1]}];
handles.timePlotMarkers = [{'.'},{'.'},{'.'},{'.'},{'.'},{'.'}];
handles.timePlotMarkers{handles.CurrentButton} = 'o';
handles.timePlotLineWidth = [1 1 1 1 1 1];
handles.timePlotLineWidth(handles.CurrentButton) = 2;
handles.timePlotLineStyle = [{'--'},{'--'},{'--'},{'--'},{'--'},{'--'}];
handles.timePlotLineStyle{handles.CurrentButton} = '-';
handles.timePlotNames = handles.H.bandNames;
handles.timePlotColors = [{[64 191 131]./255},{[100 100 155]./255},...
    {[243 122 12]./255},{[255 0 128]./255},{[0 64 0]./255},{[198 255 0]./255}];
handles.tagMarkers = [{'x'},{'.'},{'+'},{'v'},{'o'},{'>'}];
handles.tagLineStyle = [{'-'},{'-'},{'-'},{'-'},{'-'},{'-'}];