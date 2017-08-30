function [roiPos_circle,h] = PlotRoisOnCircle(atlas,idx,groupClusters,clusterNames,marker,colors)

% Plot the ROIs, colored according to their cluster, around the unit
% circle. Clicking on any marker will show its ROI in GUI_3View.
%
% [roiPos_circle,h] = PlotRoisOnCircle(atlas,idx,groupClusters,clusterNames,marker,colors)
%
% INPUTS:
% -atlas is a 3d matrix in which each voxel has a value according to its
% ROI (1:n). Voxels with value 0 are considered outside the brain.
% -idx is an n-element vector of the cluster to which each roi belongs.
% [default = 1:n]
% -groupClusters is a binary value indicating whether ROIs in the same
% cluster should be plotted together around the circle instead of according
% to their x,y position. [default = true]
% -marker is a string indicating the marker you'd like to use to plot the
% positions (see 'help plot' for options). [default = '-']
% -colors is an nx3 matrix of RGB values [default:
% distinguishable_colors]
%
% OUTPUTS:
% -roiPos_circle is an nx2 matrix where each row is the (x,y) position of
% that ROI on the circle.
% -h is an m-element vector of handles to each of the plotted clusters,
% where m=max(idx).
%
% Created 11/24/15 by DJ.
% Updated 11/29/16 by DJ - added optional colors input.

% Handle defaults
if ~exist('idx','var') || isempty(idx)
    idx = 1:max(atlas(:));
end
if ~exist('groupClusters','var') || isempty(groupClusters)
    groupClusters = true;
end
if ~exist('clusterNames','var') || isempty(clusterNames)
    clusterNames = [];
end
if ~exist('marker','var') || isempty(marker)
    marker = '-';
end
if ~exist('colors','var') 
    colors = [];
end
% Get ROI postions
roiPos = GetAtlasRoiPositions(atlas);
nROIs = size(roiPos,1);

% get atlas center
ctr = size(atlas)/2;

% Find angle    
if groupClusters
    nClusters = max(idx);
    nROIsR = sum(idx <= nClusters/2);
    nROIsL = sum(idx > nClusters/2);
    thetaEven = [linspace(-pi/2,pi/2,nROIsR), linspace(3*pi/2,pi/2,nROIsL)];
    theta = zeros(nROIs,1);
    for i=1:nClusters
        theta(idx==i) = thetaEven((1:sum(idx==i))+sum(idx<i));
    end
else
    theta = zeros(nROIs,1);
    for i=1:nROIs
        theta(i) = atan2((roiPos(i,2)-ctr(2)),(roiPos(i,1)-ctr(1)));
    end

end

% get cartesian coords
xPlot = cos(theta);
yPlot = sin(theta);

% Plot, colored with cluster
nClusters = numel(unique(idx));
if isempty(colors)
    colors = distinguishable_colors(nClusters,'w');
end
cla; hold on;
for i=1:nClusters
    if any(idx==i)
        h(i) = plot(xPlot(idx==i),yPlot(idx==i),marker,'color',colors(i,:),'linewidth',3);
        set(h(i),'ButtonDownFcn',{@ShowRoi,i});
    end
end


% Annnotate
if isempty(clusterNames)
    clusterNames = cell(1,nClusters);
    for i=1:nClusters
        clusterNames{i} = sprintf('Cluster %d',i);
    end
end
legend(clusterNames);
% create output
roiPos_circle = [xPlot,yPlot];

% ROI plot function
function ShowRoi(hObject,eventdata,iCluster)
    % Get nearest ROI
    cp = get(gca,'CurrentPoint'); % get the point(s) (x,y) where the person just clicked
    x = cp(1,1);
    y = cp(1,2);
    dist=bsxfun(@hypot,xPlot-x,yPlot-y);
    iRoi = find(dist==min(dist));    
    
    % Create atlas for vis
    atlasR = atlas;
    for j=1:nROIs
        atlasR(atlas==j) = idx(j)/(nClusters*2);
    end
    % Create blue overlay
    atlasB = atlasR;
    atlasB(atlasR==iCluster/(nClusters*2)) = 1;
    % Create green overlay   
    atlasG = atlasR;
    atlasG(atlas==iRoi) = 1;
    % Plot result
    GUI_3View(cat(4,atlasR,atlasG,atlasB),round(roiPos(iRoi,:)));
end

end