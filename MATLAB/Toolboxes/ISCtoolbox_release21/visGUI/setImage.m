function handles = setImage(dataM,dataA,handles,imType);

if strcmp(imType,'data') % set similarity map
   % TITL = 'Inter-Subject Synchronization';
    if ~handles.currentView
        axes(handles.axesAtlas);
        switch handles.iter
            case 1
                axes(handles.axesAxial);
                set(handles.axialImage,'CData',dataM);
                set(handles.lineAxialVert,'XData',1:handles.datasize(1),'YData',-1*(2*handles.coordinateShift(2)+handles.layerVals(2))*ones(1,handles.datasize(1)))
                set(handles.lineAxialHor,'XData',handles.layerVals(3)*ones(1,handles.datasize(2)),'YData',1:handles.datasize(2))
            case 2
                axes(handles.axesCoronal);
                set(handles.coronalImage,'CData',dataM);
                set(handles.lineCoronalVert,'XData',1:handles.datasize(1),'YData',-1*(2*handles.coordinateShift(1)+handles.layerVals(1))*ones(1,handles.datasize(1)))
                set(handles.lineCoronalHor,'XData',handles.layerVals(3)*ones(1,handles.datasize(1)),'YData',1:handles.datasize(1))
            case 3
                axes(handles.axesSagittal);
                set(handles.sagittalImage,'CData',dataM);
                set(handles.lineSagittalVert,'XData',1:handles.datasize(2),'YData',-1*(2*handles.coordinateShift(1)+handles.layerVals(1))*ones(1,handles.datasize(2)))
                set(handles.lineSagittalHor,'XData',handles.layerVals(2)*ones(1,handles.datasize(1)),'YData',1:handles.datasize(1))
        end
    else
        axes(handles.axes1);
        % create image handle:
        set(handles.dataImage,'CData',dataM);
        %title(TITL)
    end

    drawnow
    handles = setColorbarScale(handles);
    handles.CurrentData = dataM;
    
else % set atlas map
    axes(handles.axesAtlas);cla;%zoom on;
    W = anatomicOverlayAtlas(handles,handles.layerVal,dataA);
    handles.atlasImage = image(W);
    set(gca,'YTickLabel',[],'XTickLabel',[],'YTick',[],'XTick',[]);
    handles.ColbarAt = colorbar('peer',handles.axesAtlas,'Location',...
        'SouthOutside','CLimMode','manual','HandleVisibility','on');
    % set colorbar limits for atlas:
    if handles.At == 1
        XL = [131-0.5 131+47+0.5];
        XT = XL(1)+1.5:2:XL(2);
        XTL = (XL(1)-130)+1.5:2:(XL(2)-130);
        imTitle = 'Harvard-Oxford Cortical Atlas';
    else
        XL = [131+48-0.5 131+48+20+0.5];
        XT = XL(1)+0.5:XL(2);
        XTL = (XL(1)-130)+0.5:(XL(2)-130);
        imTitle = 'Harvard-Oxford Sub-Cortical Atlas';
    end
    set(handles.ColbarAt,'XLim',XL,'XTick',XT,'XTickLabel',num2str(XTL'),'FontSize',9);
    title(imTitle)
end
