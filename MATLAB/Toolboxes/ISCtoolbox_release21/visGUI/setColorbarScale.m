function handles = setColorbarScale(handles);
% set colorbar scale:

if handles.freqCompOn
    mi(1) = handles.ScaleMinPF;
    Ma(1) = handles.ScaleMaxPF;
    XL = [mi Ma];
    XTL = (mi(1)-1):5:(Ma(1)-1);
    XT = mi(1):5:Ma(1);
else
    mi(1) = handles.ScaleMin1;
    Ma(1) = handles.ScaleMax1;
    XL = [1+ceil(64*mi(1)) ceil(64*Ma(1))];
    XTL = mi(1):0.1:Ma(1);
    XT = 1+64*(mi(1):0.1:Ma(1));
end
set(handles.Colbar1,'XLim',XL,'XTick',XT,'XTickLabel',num2str(XTL'));