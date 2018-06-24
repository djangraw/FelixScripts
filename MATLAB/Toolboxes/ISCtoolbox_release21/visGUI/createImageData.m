function T = createImageData(handles)

T.img = handles.SegIm;
T.anatomy = handles.anatomy;
T.colMap = get(gcf,'Colormap');
if handles.allFreq
    T.band = ' ';
%    T.colMap = handles.colMapAllBands;
elseif handles.freqCompOn
    %T.colMap = handles.colMapHotCold;
    str = get(handles.popupmenuFreqBand,'String');
    str2 = get(handles.popupmenuFreqBandComp,'String');
    T.band{1} = str{get(handles.popupmenuFreqBand,'Value')};
    T.band{2} = str2{get(handles.popupmenuFreqBandComp,'Value')};
    T.band{3} = [T.band{1} ' > ' T.band{2}];
    T.band{4} = [T.band{1} ' < ' T.band{2}];
elseif handles.sessionCompOn
    
else
%   T.colMap = handles.colMap;
    str = get(handles.popupmenuFreqBand,'String');
    T.band = str{get(handles.popupmenuFreqBand,'Value')};
end

str = get(handles.popupmenuSession,'String');
T.session = str{get(handles.popupmenuSession,'Value')};
%T.atlas = handles.dataAt;
T.atlas = handles.atlas;
T.colBar1 = handles.Colbar1;
T.colBar2 = handles.Colbar2;
%T.colbarMax = str2num(get(handles.edit1ScaleMax,'String'));
T.th = handles.Threshold;
%T.thA = handles.Threshold;
