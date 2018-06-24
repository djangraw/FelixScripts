function handles = update_timefig(handles,varargin)

if nargin == 1
    threshUpdate = 0;
    waitbarText = ['Loading dataset ' num2str(handles.dataset) ': ' handles.CurrentRegionName(3:end)];
end
if nargin == 2
    if varargin{1} == 1
        threshUpdate = 1;
        waitbarText = ['Updating synchronization values...'];
    end
end

handles.waitBar = waitbar(0,waitbarText,'WindowStyle','modal');
handles.waitBarIter = 1;

    tmphandles = handles;
    % update graph data of current brain region:
    for m = 1:3
        handles.SimMeasure = m;
        for k = 1:6
            waitbar(handles.waitBarIter/(2*6))
            handles.waitBarIter = handles.waitBarIter + 1;
            handles.wavLevel = handles.freqTable(1,k);
            handles.coefType = handles.freqTable(2,k);
            handles.CurrentButton(handles.dataset) = k;
            % generate curves:
            handles = FigsUpdate(handles,threshUpdate);
        end
    end
    % return current values:
    handles.coefType = tmphandles.coefType;
    handles.wavLevel = tmphandles.wavLevel;
    handles.wavLevel = tmphandles.wavLevel;
    handles.CurrentButton(handles.dataset) = tmphandles.CurrentButton(handles.dataset);
    handles.SimMeasure = tmphandles.SimMeasure;
    handles = FigsPlot(handles);
    close(handles.waitBar)

% this subfunction generates synchronization curves:
function handles = FigsUpdate(handles,threshUpdate)

emptyData = isnan(handles.CurrentPlotData{handles.dataset}...
    (handles.CurrentButton(handles.dataset),1,handles.SimMeasure,1));
% load data only if necessary:
if ( emptyData || threshUpdate )
    % load atlas data:
    switch handles.At
        case 1
            load([handles.pathAtlas 'Cort'])
        case 2
            load([handles.pathAtlas 'Sub'])
    end
    dataAt = at(:,:,:,handles.AtlasThreshold);clear at
    
    % get memory map of the brain map data:
    Map = decideMemMap(handles);
    % calculate number of synchronized voxels/brain region/time point:
    voxSum = zeros(1,size(Map.Data,1));
    if emptyData
        handles.voxTot = sum(sum(sum(dataAt == handles.CurrentRegion)));
        dataMap = zeros(size(Map.Data,1),handles.voxTot);
        N = length(get(handles.popupmenuTotalSynchMeasure,'String'));
        for m = 1:N
            for s = 1:size(Map.Data,1)
                tsdata = single(Map.data(s).XYZ);
                if m == 2
                    % calculate spatial maps:
                    dataMap(s,:) = tsdata(find(dataAt == handles.CurrentRegion))';
                end
                switch m
                    case 1
                        voxSum(s) = sum(sum(sum((tsdata.*(dataAt == handles.CurrentRegion)) > handles.Threshold(handles.dataset))));
                    case 2
                        voxSum(s) = mean(dataMap(s,:));
                    case 3
                        voxSum(s) = median(dataMap(s,:));
                end
            end
            handles.CurrentPlotData{handles.dataset}(handles.CurrentButton(handles.dataset),:,handles.SimMeasure,m) = voxSum;
        end
        handles.CurrentPlotDataMap{handles.dataset}(:,:,handles.CurrentButton(handles.dataset),handles.SimMeasure) = dataMap;
    end
    if threshUpdate
        for s = 1:size(Map.Data,1)
            tsdata = single(Map.data(s).XYZ);
            voxSum(s) = sum(sum(sum((tsdata.*(dataAt == handles.CurrentRegion)) > handles.Threshold(handles.dataset))));
            dataMap(s,:) = tsdata(find(dataAt == handles.CurrentRegion))';
        end
        handles.CurrentPlotData{handles.dataset}(handles.CurrentButton(handles.dataset),:,handles.SimMeasure,1) = voxSum;    
    end
end