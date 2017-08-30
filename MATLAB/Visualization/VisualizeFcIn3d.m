function h = VisualizeFcIn3d(FC,atlas,iNetwork,networkColors,networkNames,orientation,viewFrom)

% h = VisualizeFcIn3d(FC,atlas,iNetwork,networkColors,networkNames,orientation,viewFrom)
%
% Created 10/19/16 by DJ.
% Updated 12/1/16 by DJ.
% Updated 1/10/17 by DJ - added viewFrom input

% declare defaults
if ~exist('iNetwork','var') || isempty(iNetwork)
    iNetwork = ones(max(atlas(:)),1);
end
if ~exist('networkColors','var') || isempty(networkColors)
    networkColors = distinguishable_colors(max(iNetwork),'w');
end
if ~exist('networkNames','var')% || isempty(networkNames)
    networkNames = cell(1,max(iNetwork));
    for i = 1:max(iNetwork)
        networkNames{i} = sprintf('Network %d',i);
    end
end
if ~exist('orientation','var') || isempty(orientation)
    orientation = ['RL';'AP';'IS'];
end
if exist('viewFrom','var') && ~isempty(viewFrom)
    doGuiVersion = false;
else
    doGuiVersion = true;
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

% Set up axis
if doGuiVersion
    clf;
    h.Axis = axes('Position',[0.13 0.3 0.775 0.65]);
else
    h.Axis = gca;
end

% Make legend
hold on;
for i=1:size(networkColors,1)
    plot3(-1,-1,-1,'.','MarkerSize',20,'color',networkColors(i,:));
end
if ~isempty(networkNames)
    legend(networkNames,'Location','EastOutside');
end
% Specify axes
xlabel(sprintf('%s<%s',orientation(1,1),orientation(1,2)));
ylabel(sprintf('%s<%s',orientation(2,1),orientation(2,2)));
zlabel(sprintf('%s<%s',orientation(3,1),orientation(3,2)));

[x,y,z] = sphere;
isLinePlotted = false(nRoi,nRoi);
isBallPlotted = false(1,nRoi);
h.Line = gobjects(nRoi,nRoi);
h.Ball = gobjects(nRoi,1);
fprintf('Plotting...\n');
for i=1:nRoi
    for j=i+1:nRoi
        if FC(i,j)>0  
            h.Line(i,j) = plot3(roiLocs([i j],1), roiLocs([i j],2), roiLocs([i j],3),'r','linewidth',FC(i,j));
            isLinePlotted(i,j) = true;
        elseif FC(i,j)<0
            h.Line(i,j) = plot3(roiLocs([i j],1), roiLocs([i j],2), roiLocs([i j],3),'b','linewidth',-FC(i,j));
            isLinePlotted(i,j) = true;
        end
        if FC(i,j)~=0
            if ~isBallPlotted(i)
                h.Ball(i) = surf(x+roiLocs(i,1),y+roiLocs(i,2),z+roiLocs(i,3),'linestyle','none','facecolor',networkColors(iNetwork(i),:));
                isBallPlotted(i) = true;
            end
            if ~isBallPlotted(j)
                h.Ball(j) = surf(x+roiLocs(j,1),y+roiLocs(j,2),z+roiLocs(j,3),'linestyle','none','facecolor',networkColors(iNetwork(j),:));
                isBallPlotted(j) = true;
            end
        end
    end
end

fprintf('Adding Brain Surface...\n');
h.Surf = VisualizeConvexVolume(atlas>0);

xlim([0 size(atlas,1)])
ylim([0 size(atlas,2)])
zlim([0 size(atlas,3)])
axis equal

if ~doGuiVersion
    switch viewFrom
        case 'top'
            view(h.Axis,[180 90])
        case 'right'
            view(h.Axis,[-90 0])
        case 'back'
            view(h.Axis,[180 0])
    end
else
    

%% Add gui controls

% -------- GUI CONTROL SETUP -------- %
disp('Making GUI controls...')

% max FC slider
minAbsFc = min(abs(FC(:)));
maxAbsFc = max(abs(FC(abs(FC)>0)));
h.MaxFc = uicontrol('Style','slider',...
                'String','Max FC',...
                'Units','normalized','Position',[.35 .2 .3 .05],...
                'Min',minAbsFc,'Max',maxAbsFc,...
                'Value',maxAbsFc,...
                'Callback',@redraw); % max FC slider
% min FC slider
h.MinFc = uicontrol('Style','slider',...
                'String','Min FC',...
                'Units','normalized','Position',[.35 .15 .3 .05],...
                'Min',minAbsFc,'Max',maxAbsFc,...
                'Value',minAbsFc,...
                'Callback',@redraw); % min FC slider

% surface alpha slider
h.SurfAlpha = uicontrol('Style','slider',...
                'String','Surface Alpha',...
                'Units','normalized','Position',[.35 .1 .3 .05],...
                'Min',0,'Max',1,...
                'Value',get(h.Surf,'FaceAlpha'),...
                'Callback',@fadeSurface); % surface alpha slider
% line alpha slider
h.LineWidth = uicontrol('Style','slider',...
                'String','Line Width',...
                'Units','normalized','Position',[.35 .05 .3 .05],...
                'Min',0,'Max',10,...
                'Value',5,...
                'Callback',@redraw); % surface alpha slider
 
% Pushbuttons
h.RightView = uicontrol('Style','pushbutton',...
                'String','Right View',...
                'Units','normalized','Position',[.05 .2 .08 .05],...
                'Value',1,...
                'Callback',@(src,event)view(h.Axis,[-90 0])); % surface alpha slider
h.TopView = uicontrol('Style','pushbutton',...
                'String','Top View',...
                'Units','normalized','Position',[.05 .15 .08 .05],...
                'Value',1,...
                'Callback',@(src,event)view(h.Axis,[180 90])); % surface alpha slider
h.BackView = uicontrol('Style','pushbutton',...
                'String','Back View',...
                'Units','normalized','Position',[.05 .1 .08 .05],...
                'Value',1,...
                'Callback',@(src,event)view(h.Axis,[180 0])); % surface alpha slider

% Toggles
h.ShowPos = uicontrol('Style','togglebutton',...
                'String','Show Pos',...
                'Units','normalized','Position',[.15 .2 .08 .05],...
                'Value',1,...
                'Callback',@redraw); % surface alpha slider
h.ShowNeg = uicontrol('Style','togglebutton',...
                'String','Show Neg',...
                'Units','normalized','Position',[.15 .15 .08 .05],...
                'Value',1,...
                'Callback',@redraw); % surface alpha slider
h.VaryLineWidth = uicontrol('Style','togglebutton',...
                'String','Vary Line Width',...
                'Units','normalized','Position',[.15 .1 .08 .05],...
                'Value',0,...
                'Callback',@redraw); % surface alpha slider
            
            
% Strings
h.MaxFcLabel = uicontrol('Style','text',...
                'String','Max FC',...
                'Units','normalized','Position',[.25 .2 .1 .05],...
                'Callback',@updateFcLims); % max FC slider
h.MinFcLabel = uicontrol('Style','text',...
                'String','Min FC',...
                'Units','normalized','Position',[.25 .15 .1 .05],...
                'Callback',@updateFcLims); % max FC slider
h.SurfAlphaLabel = uicontrol('Style','text',...
                'String','Surface Alpha',...
                'Units','normalized','Position',[.25 .1 .1 .05]); % surface alpha slider
h.LineWidthLabel = uicontrol('Style','text',...
                'String','Line Width',...
                'Units','normalized','Position',[.25 .05 .1 .05]); % surface alpha slider

h.MaxFcString = uicontrol('Style','edit',...
                'String',num2str(maxAbsFc),...
                'Units','normalized','Position',[.75 .2 .1 .05],...
                'Callback',@updateFcLims); % max FC slider
h.MinFcString = uicontrol('Style','edit',...
                'String',num2str(minAbsFc),...
                'Units','normalized','Position',[.75 .15 .1 .05],...
                'Callback',@updateFcLims); % max FC slider
h.SurfAlphaString = uicontrol('Style','edit',...
                'String',num2str(get(h.Surf,'FaceAlpha')),...
                'Units','normalized','Position',[.75 .1 .1 .05],...
                'Callback',@updateSurfAlpha); % surface alpha slider
h.LineWidthString = uicontrol('Style','edit',...
                'String',num2str(get(h.LineWidth,'Value')),...
                'Units','normalized','Position',[.75 .05 .1 .05],...
                'Callback',@updateLineWidth); % surface alpha slider
end
% network checkboxes?

disp('Done!')


% -------- SUBFUNCTIONS -------- %
function redraw(hObject,hAction)
    % Get line width & FC Limits
    lineWidth = get(h.LineWidth,'Value');
    maxFc = get(h.MaxFc,'Value');
    minFc = get(h.MinFc,'Value');
    isInRange = abs(FC)>=minFc & abs(FC)<=maxFc;
    if get(h.ShowPos,'Value')==0
        isInRange(FC>0) = 0;
    end
    if get(h.ShowNeg,'Value')==0
        isInRange(FC<0) = 0;
    end
    if get(h.VaryLineWidth,'Value')==0
        set(h.Line(isInRange & isLinePlotted),'lineWidth',lineWidth);
    else
        lineWidths = ScaleToRange(abs(FC),[0.1 lineWidth],[minFc maxFc]);
        iLines = find(isInRange & isLinePlotted);
        set(h.Line(iLines),{'lineWidth'},num2cell(lineWidths(iLines)));
    end
    % Show only in-range lines
    set(h.Line(isInRange & isLinePlotted),'Visible','On');
    set(h.Line(~isInRange & isLinePlotted),'Visible','Off');
    % Show only in-use nodes
    isBallInRange = any(isInRange,1) | any(isInRange,2)';
    set(h.Ball(isBallInRange & isBallPlotted),'Visible','On');
    set(h.Ball(~isBallInRange & isBallPlotted),'Visible','Off');    
    % Update strings
    set(h.MaxFcString,'String',num2str(maxFc));
    set(h.MinFcString,'String',num2str(minFc));
    set(h.LineWidthString,'String',num2str(lineWidth));
end

function updateFcLims(hObject,hAction)
    maxFc = str2double(get(h.MaxFcString,'String'));
    minFc = str2double(get(h.MinFcString,'String'));
    set(h.MaxFc,'Value',maxFc);
    set(h.MinFc,'Value',minFc);
    redraw();
end

function fadeSurface(hObject,hAction)
    newAlpha = get(h.SurfAlpha,'Value');
    set(h.Surf,'FaceAlpha',newAlpha);
    % Update string
    set(h.SurfAlphaString,'String',num2str(newAlpha));
end

function updateSurfAlpha(hObject,hAction)
    newAlpha = str2double(get(h.SurfAlphaString,'String'));
    set(h.SurfAlpha,'Value',newAlpha);
    fadeSurface();
end

function updateLineWidth(hObject,hAction)
    newWidth = str2double(get(h.LineWidthString,'String'));
    set(h.LineWidth,'Value',newWidth);
    redraw();
end

end

