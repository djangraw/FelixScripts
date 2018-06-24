function handles = setFigureColorMap(handles)

% init colormap:
colMap = zeros(handles.colMapSize+handles.rangeAnatomy+handles.rangeAtlas+2+9+3,3);

% set gray-scale values in the middle of the map (anatomical colors):
colMap((handles.colMapSize+1):(handles.colMapSize+handles.rangeAnatomy)...
    ,:) = colormap(gray(handles.rangeAnatomy)); % anatomical values

% set winter colors in the end of the map (atlas colors):
colMap((handles.colMapSize+handles.rangeAnatomy+1):end-2-9-3,:) = ...
    handles.colMapAtlasVal; % atlas values

colLines = colormap(lines(handles.colMapSize));

% set red-yellow range in the beginning of the colormap (synchronization colors)
oMap = colormap(hot(handles.colMapSize));
colMap(1:handles.colMapSize,:) = oMap;

% add red to denote currently selected brain region:
colMap(end-2,:) = [1 0 0];
%colMap(end-1,:) = colLines(2,:);
colMap(end-1,:) = [0 1 0];

colMap(192:199,:) = [1 0 0;0 0.75 0;0 0 1;1 1 0;0 1 1;1 0 1; 0.8 0 0.4; 0.4 0 0.8];
colMap(200:207,:) = 0.5*[1 0 0;0 0.75 0;0 0 1;1 1 0;0 1 1;1 0 1; 0.8 0 0.4; 0.4 0 0.8];
colMap(208:210,:) = 0.25*[1 0 0;0 1 0;0 0 1];
colMap(210,:) = [0 0.9 0];
%colMap(192:207,:) = colormap(lines(16));
%colMap(208,:) = [1 0 0];
%colMap(209,:) = [0 1 0];
%colMap(210,:) = [0 0 1];

handles.colMapHotCold = colMap;
handles.colMapHotCold((handles.colMapSize+handles.rangeAnatomy+1 ...
):(2*handles.colMapSize+handles.rangeAnatomy),:) = colormap(cool(handles.colMapSize));

% set created colormap:
set(gcf,'Colormap',colMap);
handles.colMap = colMap;

handles.colMapAllBands = handles.colMap;
vals = [255 128 0; 0 255 0; 255 255 0]/255;
%handles.colMapAllBands(1:10,:) = [colLines(1:7,:) ;vals]; 
%handles.colMapAllBands(1:6,:) = [255 0 255;0 255 255;255 255 0;0 0 255;0 255 0;255 0 255]/255; 
handles.colMapAllBands(1:6,:) = [255 0 255;0 255 255;191 191 0;0 0 255;0 128 0;255 0 255]/255; 

handles.colMapAllBands(10,:) = [255 0 0]/255;

%handles.colMapAllBands(1:handles.colMapSize,:) = colLines;

