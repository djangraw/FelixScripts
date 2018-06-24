function handles = update_figs(handles)
% This function updates brain maps in GUI main axes

% load new 3D volume of data from disk only if there is a change in GUI parameters:
handles.repeatLoadingImages = 1;
if handles.changeInCurrentAxes
    while( handles.repeatLoadingImages > 0 );
        handles = loadNewImage(handles);
        if handles.repeatLoadingImages == -1
            return
        end
    end
end
handles.changeInCurrentAxes = 0;

% get 2D image slice and rotate map 90 degrees for better viewing:
if handles.currentView % update single orientation and atlas:
    switch handles.orient
        case 1
            dataA = rot90(squeeze(handles.atlas(:,:,handles.layerVal)));
            dataM = rot90(squeeze(handles.SegIm(:,:,handles.layerVal)));
            if ~handles.newFigure
                axes(handles.axes1);
                set(handles.dataImage,'CData',dataM);
                axes(handles.axesAtlas);
                set(handles.atlasImage,'CData',dataA);
            end
        case 2
            dataA = rot90(squeeze(handles.atlas(:,handles.layerVal,:)));
            dataM = rot90(squeeze(handles.SegIm(:,handles.layerVal,:)));
            if ~handles.newFigure
                axes(handles.axes1);
                set(handles.dataImage,'CData',dataM);
                axes(handles.axesAtlas);
                set(handles.atlasImage,'CData',dataA);
            end
        case 3
            dataA = rot90(squeeze(handles.atlas(handles.layerVal,:,:)));
            dataM = rot90(squeeze(handles.SegIm(handles.layerVal,:,:)));
            if ~handles.newFigure
                axes(handles.axes1);
                set(handles.dataImage,'CData',dataM);
                axes(handles.axesAtlas);
                set(handles.atlasImage,'CData',dataA);
            end
    end
else % update all orientations:
    
    dataM1 = rot90(squeeze(handles.SegIm(handles.layerVals(1),:,:)));
    dataM2 = rot90(squeeze(handles.SegIm(:,handles.layerVals(2),:)));
    dataM3 = rot90(squeeze(handles.SegIm(:,:,handles.layerVals(3))));

    if handles.showAtlas
        if handles.Perim            
            Perim1 = rot90(squeeze(handles.atlasPerimSag(handles.layerVals(1),:,:)));
            Perim2 = rot90(squeeze(handles.atlasPerimCor(:,handles.layerVals(2),:)));
            Perim3 = rot90(squeeze(handles.atlasPerimAx(:,:,handles.layerVals(3))));
            if handles.allFreq
                dataM1(Perim1) = 10;
                dataM2(Perim2) = 10;
                dataM3(Perim3) = 10;
            else
                dataM1(Perim1) = size(get(gcf,'Colormap'),1)-1;
                dataM2(Perim2) = size(get(gcf,'Colormap'),1)-1;
                dataM3(Perim3) = size(get(gcf,'Colormap'),1)-1;
            end
        else
            if ( handles.Masking == 1 && handles.MaskingType == 1 ) == 0
                At3 = rot90(squeeze(handles.atlas(:,:,handles.layerVals(3))));
                At2 = rot90(squeeze(handles.atlas(:,handles.layerVals(2),:)));
                At1 = rot90(squeeze(handles.atlas(handles.layerVals(1),:,:)));
                
                if handles.allFreq
                    dataM1(At1==1) = 10;
                    dataM2(At2==1) = 10;
                    dataM3(At3==1) = 10;
                else
                    dataM1(At1==1) = size(get(gcf,'Colormap'),1)-1;
                    dataM2(At2==1) = size(get(gcf,'Colormap'),1)-1;
                    dataM3(At3==1) = size(get(gcf,'Colormap'),1)-1;
                end
            end
        end
        
    end
    
    if ~handles.newFigure
        axes(handles.axesAxial);
        set(handles.axialImage,'CData',dataM3);
        set(handles.lineAxialVert,'XData',handles.layerVals(1)*ones(1,handles.datasize(handles.dataset,2)),'YData',1:handles.datasize(handles.dataset,2))
        set(handles.lineCoronalHor,'XData',1:handles.datasize(handles.dataset,1),'YData',(handles.datasize(handles.dataset,3)-handles.layerVals(3))*ones(1,handles.datasize(handles.dataset,1)));
        set(handles.lineCoronalVert,'XData',handles.layerVals(1)*ones(1,handles.datasize(handles.dataset,1)),'YData',1:handles.datasize(handles.dataset,1));
        set(handles.lineSagittalHor,'XData',1:handles.datasize(handles.dataset,2),'YData',(handles.datasize(handles.dataset,3)-handles.layerVals(3))*ones(1,handles.datasize(handles.dataset,2)));
        axes(handles.axesCoronal);
        set(handles.coronalImage,'CData',dataM2);
        set(handles.lineAxialHor,'XData',1:handles.datasize(handles.dataset,1),'YData',(handles.datasize(handles.dataset,2)-handles.layerVals(2))*ones(1,handles.datasize(handles.dataset,1)));
        set(handles.lineSagittalVert,'XData',(handles.layerVals(2))*ones(1,handles.datasize(handles.dataset,1)),'YData',1:handles.datasize(handles.dataset,1));        
        axes(handles.axesSagittal);
        set(handles.sagittalImage,'CData',dataM1);
    end
end
drawnow

if handles.newFigure ~= 0 && ~handles.currentView
    handles.CurrentData{1}(:,:,1,handles.newFigure) = dataM1;
    handles.CurrentData{2}(:,:,1,handles.newFigure) = dataM2;
    handles.CurrentData{3}(:,:,1,handles.newFigure) = dataM3;
elseif handles.newFigure ~= 0 && handles.currentView
    handles.CurrentData{1}(:,:,1,handles.newFigure) = dataM;
else
    handles.CurrentData = [];
end


