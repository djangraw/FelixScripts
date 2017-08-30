function h = VisualizeFcIn2d(FC,atlas,iNetwork,networkColors,networkNames,orientation, view)

% h = VisualizeFcIn2d(FC,atlas,iNetwork,networkColors,networkNames,orientation, view)
%
% Created 1/10/17
% Updated 7/11/17 - turned legend autoupdate off to avoid very long legend

% declare defaults
if ~exist('iNetwork','var') || isempty(iNetwork)
    iNetwork = ones(max(atlas(:)),1);
end
if ~exist('networkColors','var') || isempty(networkColors)
    networkColors = distinguishable_colors(max(iNetwork),'w');
end
if ~exist('networkNames','var') %|| isempty(networkNames)
    networkNames = cell(1,max(iNetwork));
    for i = 1:max(iNetwork)
        networkNames{i} = sprintf('Network %d',i);
    end
end
if ~exist('orientation','var') || isempty(orientation)
    orientation = ['RL';'AP';'IS'];
end
if ~exist('view','var') || isempty(view)
    view='left';
end

% Flip atlas orientation if it's abnormal
for i=1:3
    if ismember(orientation(i,1),{'L','P','S'})
        atlas = flip(atlas,i);
        orientation(i,:) = fliplr(orientation(i,:));
    end
end

fprintf('Setting up...\n');
% Get Atlas ROI locs
roiLocs = GetAtlasRoiPositions(atlas);
nRoi = size(roiLocs,1);

switch view
    case 'top'
        roiLocs_2D = roiLocs(:,[1 2]);
        atlas_2D = squeeze(any(atlas>0,3));
        orientation_2d = orientation([1 2],:);
        set(gca,'XDir','reverse','YDir','reverse');
    case 'back'
        roiLocs_2D = roiLocs(:,[1 3]);
        atlas_2D = squeeze(any(atlas>0,2));
        orientation_2d = orientation([1 3],:);
        set(gca,'XDir','reverse','YDir','normal');
    case 'right'
        roiLocs_2D = roiLocs(:,[2 3]);
        atlas_2D = squeeze(any(atlas>0,1));
        orientation_2d = orientation([2 3],:);
        set(gca,'XDir','reverse','YDir','normal');
    case 'left'
        roiLocs_2D = roiLocs(:,[2 3]);
        atlas_2D = squeeze(any(atlas>0,1));
        orientation_2d = orientation([2 3],:);
        set(gca,'XDir','normal','YDir','normal');
end

% For each non-zero edge, plot barbell
cla; hold on;
h.Axis = gca;
for i=1:size(networkColors,1)
    plot(-1,-1,'.','MarkerSize',20,'color',networkColors(i,:));
end
if ~isempty(networkNames)
    legend(networkNames,'Location','EastOutside','AutoUpdate','off');
end

% Specify axes
xlabel(sprintf('%s<%s',orientation_2d(1,1),orientation_2d(1,2)));
ylabel(sprintf('%s<%s',orientation_2d(2,1),orientation_2d(2,2)));
% zlabel(sprintf('%s<%s',orientation(3,1),orientation(3,2)));

% Plot brain outline
fprintf('Adding Brain Surface...\n');
i = find(atlas_2D>0);
[X,Y] = ind2sub(size(atlas_2D),i);
k = boundary([X,Y],.75);
h.Surf = patch(X(k),Y(k),[1 1 1]*.85,'edgecolor','k','linewidth',2);


% [x,y,z] = sphere;
isLinePlotted = false(nRoi,nRoi);
isBallPlotted = false(1,nRoi);
h.Line = gobjects(nRoi,nRoi);
h.Ball = gobjects(nRoi,1);
fprintf('Plotting...\n');
for i=1:nRoi
    for j=i+1:nRoi
        if FC(i,j)>0  
            h.Line(i,j) = plot(roiLocs_2D([i j],1), roiLocs_2D([i j],2),'r','linewidth',FC(i,j));
            isLinePlotted(i,j) = true;
        elseif FC(i,j)<0
            h.Line(i,j) = plot(roiLocs_2D([i j],1), roiLocs_2D([i j],2),'b','linewidth',-FC(i,j));
            isLinePlotted(i,j) = true;
        end
        if FC(i,j)~=0
            if ~isBallPlotted(i)
                h.Ball(i) = plot(roiLocs_2D(i,1),roiLocs_2D(i,2),'.','markersize',20,'color',networkColors(iNetwork(i),:));
                isBallPlotted(i) = true;
            end
            if ~isBallPlotted(j)
                h.Ball(j) = plot(roiLocs_2D(j,1),roiLocs_2D(j,2),'.','markersize',20,'color',networkColors(iNetwork(j),:));
                isBallPlotted(j) = true;
            end
        end
    end
end

xlim([0 size(atlas_2D,1)])
ylim([0 size(atlas_2D,2)])
axis equal
