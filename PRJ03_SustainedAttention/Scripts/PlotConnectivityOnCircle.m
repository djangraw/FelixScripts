function [hCircle,hArc] = PlotConnectivityOnCircle(atlas,nClusters,FC,threshold,cluster_names,groupClusters,colors)

% Plot the ROIs, colored according to their cluster, around the unit
% circle. Then plot arcs connecting functionally connected ROIs.
% Clicking on any outside marker will show its ROI, and clicking on an arc
% will show the two ROIs that it connects.
%
% [hCircle,hArc] = PlotConnectivityOnCircle(atlas,nClusters,FC,threshold)
%                = PlotConnectivityOnCircle(atlas,idx,FC,threshold)
%
% INPUTS:
% -atlas is a 3d matrix in which each voxel has a value according to its
% ROI (1:n). Voxels with value 0 are considered outside the brain.
% -nClusters is a scalar indicating the number of clusters that the atlas
% should be grouped into (using ClusterRoisSpatially.m). [default = no
% clustering]. OR... 
% -idx is an n-element vector of the cluster to which each roi belongs.
% [default = 1:n]
% -FC is an nxn matrix of the connectivity between each pair of ROIs.
% -threshold is the cutoff below which FCs will not be plotted.
% -cluster_names is a p-element cell array of strings, where p=nClusters or
%   max(idx), indicating the name of each cluster for the legend.
% -groupClusters is a binary value indicating whether ROIs in the same
% cluster should be plotted together around the circle instead of according
% to their x,y position. [default = true]
% -colors is an nx3 matrix of RGB values [default:
% distinguishable_colors]
%
% OUTPUTS:
% -hCircle is an n-element vector to each ROI as plotted on the circle.
% -hArc is an nxn matrix of handles to each of the plotted arcs.
%
% Created 11/24/15 by DJ.
% Updated 11/30/15 by DJ - allow idx input, default nClusters.
% Updated 12/3/15 by DJ - fixed idx input option, added cluster_names and
%   groupClusters inputs.
% Updated 11/29/16 by DJ - added optional colors input.

% Set defaults
if ~exist('threshold','var') || isempty(threshold)
    threshold = 0;
end
if isempty(nClusters)
    nClusters = max(atlas(:));
    idx = 1:nClusters;
elseif numel(nClusters)==1
    % Get clusters
    idx = ClusterRoisSpatially(atlas,nClusters);
else
    idx = nClusters;
    nClusters = max(idx);    
end
if ~exist('cluster_names','var') || isempty(cluster_names)
    % Name clusters
    cluster_names = cell(1,nClusters);
    for i=1:nClusters
        cluster_names{i} = sprintf('cluster %d',i);
    end
end
if ~exist('groupClusters','var') || isempty(groupClusters)
    groupClusters = true;
end
if ~exist('colors','var')
    colors = [];
end
% Normalize linewidths?
normWidths = false;

% Plot positions
[roiPos_circle, hCircle] = PlotRoisOnCircle(atlas,idx,groupClusters,cluster_names,'-*',colors);

% Put FC on scale where max(abs(FC))-->3 and abs(threshold)-->0
if normWidths
    FCnorm = zeros(size(FC));
    FCnorm(FC>threshold) = (FC(FC>threshold)-threshold)/(max(abs(FC(:)))-threshold)*3;
    FCnorm(FC<-threshold) = (FC(FC<-threshold)+threshold)/(max(abs(FC(:)))-threshold)*3;
else
    FCnorm = FC;
end

% Plot arcs between positions
hArc = nan(size(FC));
for i=1:size(FC,1)
    for j=(i+1):size(FC,2)
        % Find midpoint on the circle to use as center of arc
        cart_mid = mean(roiPos_circle([i j],:),1);
        theta_mid = cart2pol(cart_mid(1),cart_mid(2));
        [x_mid,y_mid] = pol2cart(theta_mid,1.2);
        % Draw the arc        
        if FCnorm(i,j)>0
            hArc(i,j) = DrawArc([x_mid;y_mid], roiPos_circle(i,:)', roiPos_circle(j,:)');
            set(hArc(i,j),'color','r','linewidth', FCnorm(i,j));
            set(hArc(i,j),'ButtonDownFcn',{@ShowRois,i,j})
        elseif FCnorm(i,j)<0
            hArc(i,j) = DrawArc([x_mid;y_mid], roiPos_circle(i,:)', roiPos_circle(j,:)');
            set(hArc(i,j),'color','b','linewidth', -FCnorm(i,j));
            set(hArc(i,j),'ButtonDownFcn',{@ShowRois,i,j})
        end
        
    end
end

set(gca,'xtick',[],'ytick',[])

% ROI plot function
function ShowRois(hObject,eventdata,iRoi,jRoi)     
    
    % Create atlas for vis
    atlasR = atlas;
    for k=1:max(atlas(:))
        atlasR(atlas==k) = idx(k)/(max(idx)*2);
    end
    % Create green overlay  
    atlasG = atlasR;
    atlasG(atlas==iRoi) = 1;
    % Create blue overlay
    atlasB = atlasR;
    atlasB(atlas==jRoi) = 1;   
    % Get position
    roiPos = GetAtlasRoiPositions(atlas);
    % Plot result
    GUI_3View(cat(4,atlasR,atlasG,atlasB),round(roiPos(iRoi,:)));
end

end