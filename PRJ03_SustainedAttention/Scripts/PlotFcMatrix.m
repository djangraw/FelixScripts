function [FC_ordered,order,idx_ordered,FC_grouped,hRect] = PlotFcMatrix(FC,clim,atlas,nClusters,showBottomTri,clusterColors,doAvgInCluster)

% [FC_ordered,order,idx_ordered,FC_grouped] = PlotFcMatrix(FC,clim,atlas,nClusters,showBottomTri,clusterColors,doAvgInCluster)
%
% INPUTS: 
% -FC is an nxn matrix indicating the functional connectivity
% between n ROIs.
% -clim is a 2-element vector indicating the [min, max] values that should
% be used for coloring the plot.
% -atlas is an mxpxq matrix containing values of 0:n. This indicates a 3d
% spatial volume that shows where the n ROIs are located in the brain.
% -nClusters is a scalar indicating how many ROI groups should be found in
% each hemisphere. ROIs will be clustered spatially with
% ClustersRoiSpatially.m. 0 --> no clustering ([default]). n-element vector
% --> nClusters(i) indicates the cluster that ROI i belongs to.
% -showBottomTri shows the bottom half of the triangle in addition to the
% top half [default = false].
% -clusterColors is an nClusters x 3 matrix indicating the RGB values for
% the rectangles drawn around the clusters.
% -doAvgInCluster will show the mean within each cluster
%
% OUTPUTS: 
% -FC_ordered is an nxn matrix with the ROIs reordered as shown in the
% plot.
% -order is the reordering index (i.e., FC_ordered = FC(order,order)).
% -idx_ordered is the cluster that each ROI belongs to in FC_ordered.
% -FC_grouped is an nClusters x nClusters matrix indicating the mean or
% summed connectivity of each cluster pair.
% -hRect is a set of handles for the rectangles showing each cluster.
%
% Created 12/23/15 by DJ.
% Updated 3/24/16 by DJ - display clusters in colors matching their squares
% Updated 6/9/16 by DJ - comments
% Updated 9/28/16 by DJ - added showBottomTri and clusterColors inputs.
% Updated 1/2/17 by DJ - added FC_grouped output.
% Updated 1/10/17 by DJ - added hRect output.

if ~exist('nClusters','var') || isempty(nClusters) || isequal(nClusters,0)
    showClusters = false;
elseif numel(nClusters)==1 
    idx = ClusterRoisSpatially(atlas,nClusters);
    showClusters = true;
else
    idx = nClusters;
    nClusters = numel(unique(idx));
    showClusters = true;
end
if ~exist('clim','var') 
    clim = [];
end
if ~exist('showBottomTri','var') || isempty(showBottomTri)
    showBottomTri = false;
end
if ~exist('doAvgInCluster','var') || isempty(doAvgInCluster)
    doAvgInCluster = false;
end
% Accept either true/false or string input for doAvgInCluster
if ischar(doAvgInCluster)
    avgMethod = doAvgInCluster;
    doAvgInCluster = true;
else
    avgMethod = 'mean';
end

% make symmetric if it's not
% if ~issymmetric(FC)
%     FC = UnvectorizeFc(VectorizeFc(FC),0);
% end

% reorder FC matrix
if showClusters
    [idx_ordered,order] = sort(idx,'ascend');
    FC_ordered = FC(order,order);
else
    FC_ordered = FC;
    order = 1:size(FC,1);
    idx_ordered = ones(size(order));
end

% group by cluster
if doAvgInCluster
    clusters = unique(idx_ordered);
    FC_grouped = nan(numel(clusters));
    atlas0 = atlas;
    for i=1:numel(clusters)
        for j=i:numel(clusters)
            switch avgMethod
                case 'mean'
                    FC_grouped(i,j) = nanmean(nanmean(FC_ordered(idx_ordered==clusters(i),idx_ordered==clusters(j)))); 
                    FC_grouped(j,i) = nanmean(nanmean(FC_ordered(idx_ordered==clusters(i),idx_ordered==clusters(j)))); 
                case 'sum'
                    FC_grouped(i,j) = nansum(nansum(FC_ordered(idx_ordered==clusters(i),idx_ordered==clusters(j)))); 
                    FC_grouped(j,i) = nansum(nansum(FC_ordered(idx_ordered==clusters(i),idx_ordered==clusters(j)))); 
            end
        end
        atlas(ismember(atlas0,find(idx==clusters(i)))) = i;
    end    
    clear atlas0
    idx = clusters;
    idx_ordered = clusters;
    order = 1:numel(clusters);
else
    FC_grouped = FC_ordered;
end

FC_plot = FC_grouped;
if ~showBottomTri
    uppertri = triu(ones(size(FC_plot,1)),1);
    FC_plot(~uppertri) = 0;
end

% plot FC
cla; hold on;
hImg = imagesc(FC_plot);
set(hImg,'ButtonDownFcn',@ShowFcRow);
% add cluster rectangles
if showClusters
    iClusters = unique(idx_ordered);
    nClusters = numel(iClusters);
    if ~exist('clusterColors','var') || isempty(clusterColors)
        clusterColors = distinguishable_colors(nClusters);
    end
    if size(idx_ordered,1)==1
        idx_ordered = idx_ordered';
    end
    iClusterEdge = [0; find(diff(idx_ordered)>0); numel(idx_ordered)];
%     hGridVert = PlotVerticalLines(iClusterEdge+.5,'k');
%     hGridHori = PlotHorizontalLines(iClusterEdge+5.,'k');
    for i=1:nClusters        
        hRect(i) = rectangle('position',[iClusterEdge(i)+.5, iClusterEdge(i)+.5, iClusterEdge(i+1)-iClusterEdge(i),iClusterEdge(i+1)-iClusterEdge(i)],...
            'edgecolor',clusterColors(i,:),'linewidth',2);
        set(hRect(i),'ButtonDownFcn',{@ShowCluster,i});    
    end
%     set([hGridVert,hGridHori],'ButtonDownFcn',@ShowFcRow);    
end
% annotate plot
if ~isempty(clim)
    set(gca,'ydir','reverse','clim',clim)
else
    set(gca,'ydir','reverse');
end
xlim([0.5 size(FC_grouped,1)+0.5]);
ylim([0.5 size(FC_grouped,2)+0.5]);
if doAvgInCluster
    xlabel('Cluster');
    ylabel('Cluster');
else
    xlabel('ROI');
    ylabel('ROI');
end
axis square
colorbar;   

% ROI plot function
function ShowCluster(hObject,eventdata,iCluster)     
    
%     % Create atlas for vis
    atlasIdx = MapValuesOntoAtlas(atlas,idx);
%     atlasR = atlasIdx/(nanmax(idx)*2);
%     % Create green overlay  
%     atlasG = atlasR;
%     atlasG(atlasIdx==iCluster) = 1;
%     % Create blue overlay
%     atlasB = atlasR;    
    % Get RGB atlas
    atlasRGB = MapColorsOntoAtlas(atlasIdx,clusterColors);
    % Get position
    roiPos = GetAtlasRoiPositions(atlasIdx);
    % Plot result
%     GUI_3View(cat(4,atlasR,atlasG,atlasB),round(roiPos(iCluster,:)));
    GUI_3View(atlasRGB,round(roiPos(iCluster,:)));
end

% ROI plot function
function ShowFcRow(hObject,eventdata)     
    
    % get row
    hObject = gca;%get(objHandle,'Parent');
    coords = get(hObject,'CurrentPoint');
    coords = coords(1,1:2);
    iRow = round(coords(2));
    iRow = max(0,min(iRow,size(FC_grouped,1)));
    % get reordered atlas
    invOrder = zeros(size(order));
    for k=1:numel(order)
        invOrder(k) = find(order==k);
    end
    atlas_ordered = MapValuesOntoAtlas(atlas,invOrder);
    % Plot in GUI_3View
    % get overlay
    overlay = FC_grouped(iRow,:);
    overlay(overlay<clim(1)) = clim(1); % clip at color limits
    overlay(overlay>clim(2)) = clim(2); % clip at color limits
    overlay = overlay/max(abs(clim));
    % Create atlas for vis
    atlasScaled = atlas_ordered/(nanmax(atlas_ordered(:))*2);
    % Create red overlay    
    atlasR = MapValuesOntoAtlas(atlas_ordered,overlay.*(overlay>0));
    % create green overlay
    atlasG = atlasScaled;
    atlasG(atlas_ordered==iRow) = 1;
    % Create blue overlay
    atlasB = MapValuesOntoAtlas(atlas_ordered,-overlay.*(overlay<0));
    % Get position
    roiPos = GetAtlasRoiPositions(atlas_ordered);
    % Plot result
    GUI_3View(cat(4,atlasR,atlasG,atlasB),round(roiPos(iRow,:)));
    
    % Plot with VisualizeFcIn3d.m
%     figure(909); clf;
%     FC_row = zeros(size(FC_grouped));
%     FC_row(iRow,:) = FC_grouped(iRow,:);
%     FC_row(:,iRow) = FC_grouped(:,iRow);    
%     VisualizeFcIn3d(FC_row,atlas_ordered,idx_ordered,clusterColors);
%     fprintf('displaying connectivity with ROI %d (%d in atlas)\n',iRow,order(iRow));
end
end