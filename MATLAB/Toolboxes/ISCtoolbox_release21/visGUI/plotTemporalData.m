function plotTemporalData(handles,Curve)

contents2 = get(handles.listboxAtlasList,'String');
if handles.NormalSynch
    F = ', normalized';
else
    F = '';
end

if handles.NormalSynch
    NormCurve = Curve(:,end);
    Curve(:,end) = [];
end


curveType{1} = 'Mean';
curveType{2} = 'Median';
curveType{3} = 'Number of significant voxels';
if handles.Synch == 1
    mapType = ' Time window ISC, ';
    %    T = (1/handles.Pub.samplingFrequency)*(1:size(Curve,1));
    T = 1:size(Curve,1);
    XLab = 'Time interval';
else
    mapType = ' Inter-subject phase synchronization, ';
    T = (1/handles.Pub.samplingFrequency)*(1:size(Curve,1));
    XLab = 'Time (s)';
end
HH = [{[mapType curveType{handles.ROIcurve}]};{[handles.bandNames{handles.freqBand} ', session ' num2str(handles.dataset) F]}];
figure,plot(T,Curve,'LineWidth',2);title(HH);legend(contents2);xlabel(XLab);xlim([1 T(end)]);grid on;zoom on
%if handles.Synch == 1
%    set(gca,'XTickLabel',handles.intVals)
%end
if handles.NormalSynch
    HH = [{[mapType curveType{handles.ROIcurve}]};{[handles.bandNames{handles.freqBand} ', session ' num2str(handles.dataset) ', whole brain normalization curve']}];
    figure,plot(T,NormCurve,'LineWidth',2);title(HH);legend('Whole brain');xlabel(XLab);xlim([1 T(end)]);grid on;zoom on
end