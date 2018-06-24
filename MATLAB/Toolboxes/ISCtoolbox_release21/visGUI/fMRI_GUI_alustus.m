function handles = getParams(handles)
%
% fMRI_GUI initialization code.

% This would be nice to get working:
%scrsz = get(0,'ScreenSize');
%set(handles.figure1,'Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2]);

% dataset size and MNI coordinate transformation:
handles.datasize = [91 109 91];
handles.coordinateShift = [-ceil(handles.datasize(1)/2) -ceil(handles.datasize(2)/2) -ceil(handles.datasize(3)/2)];
handles.voxelsize = 2; % mm
set(gcf,'Name','LSA tool 1.0')

% frequency band names:
handles.bandNames{1} = '0 - 0.15 Hz (full band)';
handles.bandNames{2} = '0.07 - 0.15 Hz';
handles.bandNames{3} = '0.04 - 0.07 Hz';
handles.bandNames{4} = '0.02 - 0.04 Hz';
handles.bandNames{5} = '0.01 - 0.02 Hz';
handles.bandNames{6} = '0 - 0.01 Hz';

handles.similarityMeasureNames{1} = 'GISC';
handles.similarityMeasureNames{2} = 'Kendall''s W';
handles.similarityMeasureNames{3} = 'Signed difference';
handles.similarityMeasureNames{4} = 'Mutual information';

handles.sessionNames{1} = 'Session 1';
handles.sessionNames{2} = 'Session 2';


set(handles.popupmenuWavLevel,'String',handles.bandNames)
set(handles.popupmenuSimilarityMeasure,'String',handles.similarityMeasureNames)
set(handles.popupmenuDataset,'String',handles.sessionNames)

% the following are needed when drawing image in separate figure
% (see gui_window_figure.m):
handles.newFigure = 0;
handles.currentView = 0;
handles.figureSet = zeros(1,6);
handles.figureBand = zeros(1,12);
handles.figureSim = zeros(1,8);
handles.figureSet(1) = 1;
handles.figureBand(1) = 1;
handles.figureSim(1) = 1;
handles.colPlot = 1;
handles.rowPlot = 2;
handles.annotationsOn = 0;
handles.annotationsOn = 0;
handles.plotColbar = 0;

%[PublicParams PrivateParams] = initParams;
% load memory map objects:
%load([PublicParams.destinationResults PublicParams.resultsResults]);
%load('D:\Tutkimus\fMRI\matlab codes\GUI\memMap1');
%load('D:\Tutkimus\fMRI\matlab codes\GUI\memMap2');
%load('D:\Tutkimus\fMRI\matlab codes\GUI\memMapPF');
%handles.pathAtlas = 'D:\Tutkimus\fMRI\matlab codes\GUI\atlasData';
%handles.pathAtlas = PublicParams.maskData;
handles.memMap1 = memMap1;
handles.memMap2 = memMap2;
handles.memMapPF = memMapPFdata;
handles.PFtable = PFtable;
handles.freqTable = [1 2 3 4 5 5; 2 1 1 1 1 2];
handles.hp = [];
handles.Segment = 0;
handles.colMapHot64 = colormap(hot(64));
handles.colMapGray64 = colormap(gray(64));
handles.ScaleMinPF = 1;
handles.ScaleMaxPF = 66;
handles.freqCompOn = 0;
handles.Threshold = 0.25;
handles.ThresholdPF = 30;

% load atlas region names:
[txtSub txtCort] = loadLabels;
handles.tableCort = 1:length(txtCort);
labCort = 1:size(txtCort,1); % label cortical regions as 1,2,...,48
for w = 1:length(labCort)
    handles.txtCort{w} = [num2str(labCort(w)) ' ' txtCort{w}];
end
%handles.tableSub = [2 3 4 10 11 12 13 16 17 18 26 41 42 43 49 50 51 52 53 54 58];
handles.tableSub = 49:length(txtSub)+48;

labSub = 49:48+size(txtSub,1); % label sub-cortical regions as 49,50,51,...
for w = 1:length(labSub)
    handles.txtSub{w} = [num2str(labSub(w)) ' ' txtSub{w}];
end

handles.activeAxes = 1;

% init sliders:
set(handles.sliderLayer,'Value',10)
set(handles.sliderLayer,'Max',handles.datasize(3));
set(handles.sliderLayer,'Min',1);
set(handles.editLayer,'String',num2str(get(handles.sliderLayer,'Value')),'Enable','Inactive')


set(handles.sliderAxial,'Value',46)
set(handles.textAxial,'String',['z = ' num2str(handles.voxelsize*(get(handles.sliderAxial,'Value')+handles.coordinateShift(3)))])

set(handles.sliderAxial,'Max',handles.datasize(3));
set(handles.sliderAxial,'Min',1);


set(handles.sliderCoronal,'Value',55)
set(handles.sliderCoronal,'Max',handles.datasize(2));
set(handles.sliderCoronal,'Min',1);
set(handles.textCoronal,'String',['y = ' num2str(handles.voxelsize*(get(handles.sliderCoronal,'Value')+handles.coordinateShift(2)))])

set(handles.sliderSagittal,'Value',46)
set(handles.sliderSagittal,'Max',handles.datasize(1));
set(handles.sliderSagittal,'Min',1);
set(handles.textSagittal,'String',['x = ' num2str(handles.voxelsize*(get(handles.sliderSagittal,'Value')+handles.coordinateShift(1)))])

handles.layerVals(1) = get(handles.sliderAxial,'Value');
handles.layerVals(2) = get(handles.sliderCoronal,'Value');
handles.layerVals(3) = get(handles.sliderSagittal,'Value');

set(handles.sliderTime,'max',24)
set(handles.popupmenuDataset,'Value',1)
set(handles.pushbuttonPlotTimeSeries,'Enable','off')
set(handles.popupmenuOrient,'Value',1)

set(handles.edit1ScaleMin,'String',0)
set(handles.edit1ScaleMax,'String',0.6)
set(handles.checkboxPixVal1,'Value',0)

set(handles.editThreshold,'String',handles.Threshold,'Enable','off')
set(handles.radiobuttonIsolationNoIsolation,'Value',1)

set(handles.radiobuttonOrig,'Visible','off','Enable','off','Value',0,'String',handles.bandNames{1})
set(handles.radiobuttonHigh,'Visible','on','Enable','off','Value',1,'String',handles.bandNames{2})
set(handles.radiobuttonMid,'Visible','on','Enable','off','Value',0,'String',handles.bandNames{3})
set(handles.radiobuttonMidLow,'Visible','on','Enable','off','Value',0,'String',handles.bandNames{4})
set(handles.radiobuttonLow,'Visible','on','Enable','off','Value',0,'String',handles.bandNames{5})
set(handles.radiobuttonVeryLow,'Visible','on','Enable','off','Value',0,'String',handles.bandNames{6})

set(handles.sliderTime,'Visible','off')
set(handles.editTime,'Visible','off')
set(handles.textTime,'Visible','off')

set(handles.checkboxLargeFigure,'Value',0)
set(handles.uipanelAxes,'Visible','on')
set(handles.axes1,'Visible','off')
set(handles.axesAtlas,'Visible','off')
set(handles.sliderLayer,'Visible','off')
set(handles.editLayer,'Visible','off')
set(handles.popupmenuOrient,'Visible','off')
set(handles.uipanel1,'Visible','off')

%set(handles.axesAxial,'Visible','off')
%set(handles.axesCoronal,'Visible','off')
%set(handles.axesSagittal,'Visible','off')
%set(handles.sliderAxial,'Visible','off')
%set(handles.sliderCoronal,'Visible','off')
%set(handles.sliderSagittal,'Visible','off')

axes(handles.axes1);
handles.dataImage = image(zeros(handles.datasize(2),handles.datasize(1)));
set(gca,'YTickLabel',[],'XTickLabel',[],'YTick',[],'XTick',[],'xlimmode',...
    'manual','ylimmode','manual','zlimmode','manual',...
    'climmode','manual','alimmode','manual','Drawmode','fast');axis image
handles.Colbar1 = colorbar('Location','SouthOutside','CLimMode','manual','HandleVisibility','on');

axes(handles.axesAtlas);
handles.atlasImage = image(1);
% handles.ColbarAt = colorbar('Location','SouthOutside','CLimMode','manual','HandleVisibility','off');
set(gca,'YTickLabel',[],'XTickLabel',[],'YTick',[],'XTick',[],'xlimmode',...
    'manual','ylimmode','manual','zlimmode','manual',...
    'climmode','manual','alimmode','manual','Drawmode','fast');
axes(handles.axesAxial);
handles.axialImage = image(zeros(handles.datasize(2),handles.datasize(1)));
set(handles.axialImage,'XData',[1 handles.datasize(1)],'YData',[1 handles.datasize(2)])
% handles.ColbarAt = colorbar('Location','SouthOutside','CLimMode','manual','HandleVisibility','off');
set(gca,'YTickLabel',[],'XTickLabel',[],'YTick',[],'XTick',[],'xlimmode',...
    'manual','ylimmode','manual','zlimmode','manual',...
    'climmode','manual','alimmode','manual','Drawmode','fast');axis image
handles.lineAxialVert = line(1:handles.datasize(1),handles.layerVals(2)*ones(1,handles.datasize(1)),'LineStyle','--','Color','g');
handles.lineAxialHor = line(handles.layerVals(3)*ones(1,handles.datasize(2)),1:handles.datasize(2),'LineStyle','--','Color','g');

axes(handles.axesCoronal);
handles.coronalImage = image(zeros(handles.datasize(3),handles.datasize(1)));
set(handles.coronalImage,'XData',[1 handles.datasize(1)],'YData',[1 handles.datasize(3)])
% handles.ColbarAt = colorbar('Location','SouthOutside','CLimMode','manual','HandleVisibility','off');
set(gca,'YTickLabel',[],'XTickLabel',[],'YTick',[],'XTick',[],'xlimmode',...
    'manual','ylimmode','manual','zlimmode','manual',...
    'climmode','manual','alimmode','manual','Drawmode','fast');axis image
handles.lineCoronalVert = line(1:handles.datasize(1),handles.layerVals(1)*ones(1,handles.datasize(1)),'LineStyle','--','Color','g');
handles.lineCoronalHor = line(handles.layerVals(3)*ones(1,handles.datasize(1)),1:handles.datasize(1),'LineStyle','--','Color','g');

axes(handles.axesSagittal)
handles.sagittalImage = image(zeros(handles.datasize(3),handles.datasize(2)));
set(handles.sagittalImage,'XData',[1 handles.datasize(2)],'YData',[1 handles.datasize(3)])
% handles.ColbarAt = colorbar('Location','SouthOutside','CLimMode','manual','HandleVisibility','off');
set(gca,'YTickLabel',[],'XTickLabel',[],'YTick',[],'XTick',[],'xlimmode',...
    'manual','ylimmode','manual','zlimmode','manual',...
    'climmode','manual','alimmode','manual','Drawmode','fast');axis image
handles.lineSagittalVert = line(1:handles.datasize(2),handles.layerVals(1)*ones(1,handles.datasize(2)),'LineStyle','--','Color','g');
handles.lineSagittalHor = line(handles.layerVals(2)*ones(1,handles.datasize(1)),1:handles.datasize(1),'LineStyle','--','Color','g');

set(handles.text9,'Visible','on')
% set(handles.text19,'Visible','off')
% set(handles.text20,'Visible','off')
set(handles.edit1ScaleMax,'Visible','on')
set(handles.edit1ScaleMin,'Visible','on')

handles.activeAxes = 1;

handles = update_params(handles);
setFigureColorMap(handles);

handles = update_figs(handles);

%set(handles.axialImage,'Visible','on')
%set(handles.coronalImage,'Visible','on')
%set(handles.sagittalImage,'Visible','on')
set(handles.uipanelAxes,'Visible','on')
set(handles.axes1,'Visible','off')
set(handles.axesAtlas,'Visible','off')
set(handles.sliderLayer,'Visible','off')
set(handles.editLayer,'Visible','off')
set(handles.popupmenuOrient,'Visible','off')
set(handles.uipanel1,'Visible','off')
set(handles.dataImage,'Visible','off')
set(handles.atlasImage,'Visible','off')
set(handles.axesAxial,'Visible','on')
set(handles.axesSagittal,'Visible','on')
set(handles.axesCoronal,'Visible','on')


