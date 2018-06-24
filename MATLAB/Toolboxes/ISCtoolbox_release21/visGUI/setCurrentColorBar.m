function handles = setCurrentColorBar(handles)

if handles.allFreq
    set(handles.Colbar1,'XLim',[0.5 handles.Priv.maxScale+1+0.5]);
    set(handles.Colbar1,'XTick',1:handles.Priv.maxScale+1,'XTickLabel',handles.subbandNames)
    set(handles.edit1ScaleMin,'String','----','Enable','off')
    set(handles.edit1ScaleMax,'String','----','Enable','off')
    set(handles.editThreshold,'String',num2str(round(handles.Threshold*100)/100))
else
    set(handles.Colbar1,'XLim',[0 handles.colMapSize],'XTick',0:25:handles.colMapSize);
    if handles.freqCompOn || handles.sessionCompOn
        if ~isnan(handles.TH)
            if handles.ScaleMax1 > 100 && handles.ScaleMax1 < 1000
                step = 50;
                MM = 100*floor(handles.ScaleMax1/100);
            else
                step = 10;
                MM = 10*floor(handles.ScaleMax1/10);
            end
            if MM + step < handles.ScaleMax1
                MM = MM + step;
            end
            hval = MM*handles.colMapSize/handles.ScaleMax1;
            Xvec1 = round(linspace(1,round(hval),1+MM/step));
            Xvec2 = Xvec1 + handles.colMapSize+handles.rangeAnatomy;
            Xvec = [Xvec1 Xvec2];
            set(handles.Colbar1,'Visible','on','XTick',Xvec,'XTickLabel',[0:step:MM 0:step:MM])
            set(handles.Colbar1,'XLim',[handles.TH 192.5],'Position',[0.1546 0.0684 0.66 0.0671])
            set(handles.edit1ScaleMin,'String',num2str(round(handles.ScaleMin1)),'Enable','on')
            set(handles.edit1ScaleMax,'String',num2str(round(handles.ScaleMax1)),'Enable','on')
        else
            set(handles.Colbar1,'Visible','off')
        end
    else
        set(handles.Colbar1,'XTickLabel',(round(10*linspace(...
            handles.ScaleMin1,handles.ScaleMax1,length(get(handles.Colbar1,'XTick'))))/10))
        set(handles.edit1ScaleMin,'String',num2str(round(handles.ScaleMin1*100)/100),'Enable','on')
        set(handles.edit1ScaleMax,'String',num2str(round(handles.ScaleMax1*100)/100),'Enable','on')
       % set(handles.editThreshold,'String',num2str(round(handles.Threshold*100)/100))
    end
end

%set(handles.Colbar1,'Position',[0.155 0.09 0.25 0.03])

%        get(handles.Colbar1,'XTickLabel')
%        get(handles.Colbar1,'XTick')
%handles.colMapSize+handles.rangeAnatomy+1):(2*handles.colMapSize+handles.rangeAnatomy)






%    else
%        if handles.mapType == 3
%            set(handles.Colbar1,'XTickLabel',round(100*handles.maxSc*[0:0.1:1])/100)
%        else
%            set(handles.Colbar1,'XTickLabel',round(10*handles.maxSc*[0:0.1:1])/10)
%        end
%        set(handles.edit1ScaleMin,'String',num2str(round(handles.maxSc*handles.ScaleMin1*100)/100))
%        set(handles.edit1ScaleMax,'String',num2str(round(handles.maxSc*handles.ScaleMax1*100)/100))
%        set(handles.editThreshold,'String',num2str(round(handles.maxSc*handles.Threshold*100)/100))
%    end
%else
%    switch handles.ZPFtest
%        case 1
%            set(handles.Colbar1,'XTickLabel',round(handles.subjPairs*[0:0.1:1]))
%            set(handles.edit1ScaleMin,'String',num2str(floor(handles.subjPairs*handles.ScaleMin1)))
%            set(handles.edit1ScaleMax,'String',num2str(floor(handles.subjPairs*handles.ScaleMax1)))
%            set(handles.editThreshold,'String',num2str(floor(handles.subjPairs*handles.Threshold)))
%        case 2
%            set(handles.Colbar1,'XTickLabel',round(10*handles.maxSc*linspace(handles.ScaleMin1,handles.ScaleMax1,11)/10))
%            set(handles.Colbar1,'XTickLabel',round(10*handles.maxSc*[0:0.1:handles.ScaleMax1])/10)
%            set(handles.edit1ScaleMin,'String',num2str(round(handles.maxSc*handles.ScaleMin1*100)/100))
%            set(handles.edit1ScaleMax,'String',num2str(round(handles.maxSc*handles.ScaleMax1*100)/100))
%            set(handles.editThreshold,'String',num2str(round(handles.maxSc*handles.Threshold*100)/100))
%    end
%end
%set(handles.Colbar1,'XLim',[round(handles.ScaleMin1*handles.colMapSize) round(handles.ScaleMax1*64)])