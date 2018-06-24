function handles = anatomicalPlot(handles)

handles = updateSyncPlotAtlas(handles);
V = find(handles.tags(1,:));
if ~isempty(V)
    if length(V) >= 1
        TP = handles.tags(2,V(1));
    end
    if length(V) >= 2
        TP = [TP handles.tags(2,V(2))]';
    end
end

spM = handles.spMap(1,:) >= handles.H.Threshold;
SegVals = zeros(1,size(spM,2));

if sum(handles.tags(1,:)) >= 2
    spM(2,:) = handles.spMap(2,:) >= handles.H.Threshold;
    SegVals(find(spM(1,:) == 1 & spM(2,:) == 1)) = 4;
    SegVals(find(spM(1,:) == 1 & spM(2,:) == 0)) = 2;
    SegVals(find(spM(1,:) == 0 & spM(2,:) == 1)) = 3;
    SegVals(find(spM(1,:) == 0 & spM(2,:) == 0)) = 1;
else
    SegVals = spM(1,:) + 1;
end

figure
oMap = [0.40 0.5 0.5;
        0 0 1;
        1 0 0;
        0 1 0];
cMap = handles.H.colMap;
cMap(1:size(oMap,1),:) = oMap;
set(gcf,'Colormap',cMap);


dataSeg = handles.H.anatomy;
dataSeg(find(handles.MaskedAt)) = SegVals;
Dat = zeros(size(dataSeg));
Dat(find(handles.MaskedAt)) = 1;


len = 0;
idx = [];
for k = 1:size(dataSeg,handles.H.orient)
    switch handles.H.orient
        case 1
            Wrot(:,:,k) = rot90(squeeze(dataSeg(:,:,k)));
            if sum(sum(Dat(:,:,k))) ~= 0
                len = len + 1;
                idx(len) = k;
            end
        case 2
            Wrot(:,:,k) = rot90(squeeze(dataSeg(:,k,:)));
            if sum(sum(squeeze(Dat(:,k,:)))) ~= 0
                len = len + 1;
                idx(len) = k;
            end
        case 3
            Wrot(:,:,k) = rot90(squeeze(dataSeg(k,:,:)));
            if sum(sum(squeeze(Dat(k,:,:)))) ~= 0
                len = len + 1;
                idx(len) = k;
            end
    end
end
dataSeg = Wrot;
if ~isempty(idx)
    montData = zeros(size(dataSeg,1),size(dataSeg,2));
    montData(:,:,:,1:len) = dataSeg(:,:,idx);
    cMap = get(gcf,'Colormap');
    montage(montData,cMap);
    title(['Spatial Synchronization at Specified Time Instants: ' handles.CurrentRegionName])
    zoom on;
    cb = colorbar;
    if length(V) >= 2
        intV1 = calcInterval(TP(1),handles.H);
        intV2 = calcInterval(TP(2),handles.H);
        set(cb,'Location','SouthOutside','XLim',[0.5 4.5],'XTick',[1 2 3 4],'XTickLabel',...
            [{handles.CurrentRegionName};...
            {['Synch. at ' intV1]};{['Synch. at ' intV2]};...
            {'Simultaneously Synch.'}])
    else
        intV1 = calcInterval(TP(1),handles.H);
        set(cb,'Location','SouthOutside','XLim',[0.5 2.5],'XTick',[1 2],'XTickLabel',...
            [{handles.CurrentRegionName};...
            {['Synch. at ' intV1]}])
    end
end
