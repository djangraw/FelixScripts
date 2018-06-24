function [handles,errFlag] = getParams(handles)

% This would be nice to get working:
%scrsz = get(0,'ScreenSize');
%set(handles.figure1,'Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2]);

[Pub,Priv,errFlag] = checkAndLoadParamFile(handles);
if errFlag
    disp('Incorrect Parameter File! Cannot open visu-GUI.')
    return
end

Pub.datasize = Priv.dataSize;

[handles,errFlag] = readParams(Pub,Priv,handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Pub,Priv,errFlag] = checkAndLoadParamFile(handles)

Pub = [];
Priv = [];
errFlag = 0;

% load parameters:
if isfield(handles,'ParamStructInput')
    Params = handles.ParamStructInput;
else
    load(handles.paramFile)
end
% check validity of the struct:
if exist('Params') ~= 1
    errFlag = 1;
    return
end
if ~isstruct(Params)
    errFlag = 1;
    return
end

%if in case of old Params file from older versions of ISCtoolbox
Params = testParamsMat(Params)

if ( ~isfield(Params,'PublicParams') || ~isfield(Params,'PrivateParams') ) 
    errFlag = 1;
    return
end
Pub = Params.PublicParams;
Priv = Params.PrivateParams;

% check fields:
if ( ~isfield(Pub,'maskPath') || ...
    ~isfield(Pub,'atlasPath') || ...
    ~isfield(Pub,'dataDestination') || ...    
    ~isfield(Pub,'ssiOn') || ...
    ~isfield(Pub,'nmiOn') || ...
    ~isfield(Pub,'corOn') || ...
    ~isfield(Pub,'kenOn') || ...
    ~isfield(Pub,'subjectSource') || ...
    ~isfield(Pub,'calcPhase') || ...
    ~isfield(Pub,'removeMemmaps') || ...
    ~isfield(Pub,'removeFiltermaps') || ...
    ~isfield(Pub,'sessionCompOn') || ...
    ~isfield(Pub,'freqCompOn') || ...
    ~isfield(Pub,'winOn') || ...
    ~isfield(Pub,'fileFormat') || ...
    ~isfield(Pub,'samplingFrequency') || ...
    ~isfield(Pub,'nrFreqBands') || ...
    ~isfield(Pub,'windowSize') || ...
    ~isfield(Pub,'windowStep') )
%    disp('first set')
    errFlag = 1;
    return
end

if ( ~isfield(Priv,'prefixSession') || ...
    ~isfield(Priv,'prefixFreqBand') || ...
    ~isfield(Priv,'subjectDestination') || ...
    ~isfield(Priv,'subjectFiltDestination') || ... 
    ~isfield(Priv,'resultsDestination') || ...
    ~isfield(Priv,'prefixResults') || ...
    ~isfield(Priv,'prefixSubject') || ...
    ~isfield(Priv,'prefixSubjectFilt') || ... 
    ~isfield(Priv,'prefixSyncResults') || ...
    ~isfield(Priv,'maxScale') || ...    
    ~isfield(Priv,'simM') || ...
    ~isfield(Priv,'nrSubjects') || ...
    ~isfield(Priv,'nrSessions') || ...
    ~isfield(Priv,'transformType') || ...
    ~isfield(Priv,'resultMapName') || ...
    ~isfield(Priv,'origMapName') || ...
    ~isfield(Priv,'filtMapName') || ...
    ~isfield(Priv,'synchMapName') || ...
    ~isfield(Priv,'dataSize') || ...
    ~isfield(Priv,'nrTimeIntervals') || ...
    ~isfield(Priv,'startInds') || ... 
    ~isfield(Priv,'th') )
%    disp('second set')
    errFlag = 1;
    return
end

function [handles,errFlag] = readParams(Pub,Priv,handles);
% initialize handles.structure parameters

errFlag = 0;

handles.Pub = Pub;
handles.Priv = Priv;

handles.dataset = 1;
handles.datasize = Priv.dataSize;
if isfield(Priv,'voxelSize') == 0
   Priv.voxelSize = 1;
   warning('No standard template defined, visualization not supported!!')
   errFlag = 1;
   return
end
handles.voxelsize = Priv.voxelSize;
if handles.voxelsize == 2
    handles.coordinateShift = [92 -128 -74];
    handles.coordinateProd = [-2 2 2];
else
    handles.coordinateShift = [92 -128 -74];
    handles.coordinateProd = [-1 1 1];
%    handles.coordinateShift = [-ceil(handles.datasize(1)/2) ...
%    -ceil(handles.datasize(2)/2) -ceil(handles.datasize(3)/2)];
%handles.coordinateProd = [-ceil(handles.datasize(1)/2) ...
%    -ceil(handles.datasize(2)/2) -ceil(handles.datasize(3)/2)];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set popupmenu field names:
maxf = round(100*( Pub.samplingFrequency / 2 ))/100;
minf = round(100*(maxf/2))/100;
handles.bandNames{1} = ['full band'];
for k = 2:Priv.maxScale + 1
    handles.bandNames{k} = [num2str(minf) '-' num2str(maxf) ' Hz'];    
    minf = round(100*(minf/2))/100;
    maxf = round(100*(maxf/2))/100;
end
if Pub.nrFreqBands > 1
	handles.bandNames{k+1} = ['0-' num2str(maxf) ' Hz'];
end
for k = 2:length(handles.bandNames)
    handles.subbandNames{k-1} = handles.bandNames{k};
end

k = 1;
if Pub.corOn
    handles.similarityMeasureNames{k} = 'ISC';
    k = k + 1;
end
if Pub.kenOn
    handles.similarityMeasureNames{k} = 'Kendall''s W';
    k = k + 1;
end
if Pub.ssiOn
    handles.similarityMeasureNames{k} = 'Signed difference';
    k = k + 1;
end
if Pub.nmiOn
    handles.similarityMeasureNames{k} = 'Mutual information';
    k = k + 1;
end

for k = 1:Priv.nrSessions
    handles.sessionNames{k} = ['Session ' num2str(k)];
end

set(handles.popupmenuFreqBand,'String',handles.bandNames)
set(handles.popupmenuSimilarityMeasure,'String',handles.similarityMeasureNames)
set(handles.popupmenuSession,'String',handles.sessionNames)
set(handles.popupmenuSessionComp,'String',handles.sessionNames)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init parameters for gui_window_figure.m:
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
handles.swapBytesOn = 0;
handles.changeInCurrentAxes = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init main GUI parameters:
handles.hp = [];
handles.Segment = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handles.subjPairs = ((handles.Priv.nrSubjects)^2-(handles.Priv.nrSubjects))/2;
handles.freqComps = ((Priv.maxScale+2)^2-(Priv.maxScale+2))/2;
handles.sessionComps = (Priv.nrSessions)*(Priv.nrSessions-1)/2;

% colorbar scaling:
handles.ScaleMin1 = 0;
handles.ScaleMax1 = 1;

% session comparison parameters:
handles.sessionCompOn = 0;
%handles.sessionComp = NaN;
handles.dataset2 = 1;
handles.sessionCompTable = zeros(Priv.nrSessions);
% create frequency comparison table:
iter = 1;
for rr = 1:Priv.nrSessions
    for cc = 1:Priv.nrSessions
        if rr == cc
            handles.sessionCompTable(rr,cc) = NaN;
        end
        if cc > rr
            handles.sessionCompTable(rr,cc) = iter;
            iter = iter + 1;
        end
    end
end

if handles.dataset <= handles.dataset2
    handles.sessionComp = handles.sessionCompTable(handles.dataset,handles.dataset2);
else
    handles.sessionComp = handles.sessionCompTable(handles.dataset2,handles.dataset);
end

set(handles.popupmenuSession,'Value',handles.dataset)
set(handles.popupmenuSessionComp,'Value',handles.dataset2)

% frequency comparison parameters:
handles.freqCompOn = 0;
%handles.freqComp = NaN;
handles.allFreq = 0;
handles.freqBand = 1;
handles.freqBand2 = 1;
handles.freqBandCompTable = zeros(Priv.maxScale+2);
% create frequency comparison table:
iter = 1;
for rr = 1:Priv.maxScale+2
    for cc = 1:Priv.maxScale+2
        if rr == cc
            handles.freqBandCompTable(rr,cc) = NaN;
        end
        if cc > rr
            handles.freqBandCompTable(rr,cc) = iter;
            iter = iter + 1;
        end
    end
end

if handles.freqBand <= handles.freqBand2
    handles.freqComp = handles.freqBandCompTable(handles.freqBand,handles.freqBand2);
else
    handles.freqComp = handles.freqBandCompTable(handles.freqBand2,handles.freqBand);
end

set(handles.popupmenuFreqBand,'Value',handles.freqBand)
set(handles.popupmenuFreqBandComp,'Value',handles.freqBand2)


% set initial ZPF test (2=pairwise,1=sum test):
handles.ZPFtest = 1;
% set initial significance level (1=0.05,2=0.01,3=0.001):
handles.alpha = 3;
% set initial correction method:
handles.correction = 2;
% set initial ISC-map type(1=mean,2=Fisher,3=std,4=Q25,5=Q50,6=Q75):
handles.mapType = 1;

% show positive correlations
handles.direction = 1;

% time-window analysis is not default:
handles.timeWinAnalysis = 0;


handles.maxSc = 100;
handles.colMapSize = 64;

% save platform information:
[aa,bb,cc] = computer;
handles.endian = cc;

% memory map usage mode (1=always load pointers from disk (fast), 
% 2=keep in handles-struct (this slows down the GUI!))
handles.loadMemMaps = 1;

handles.correctionMethods{1} = {  'none'; 'FDR (indep/dep)'; ...
    'FDR (no assump.)'; 'bonferroni' };
handles.correctionMethods{2} = { 'none' };
handles.correctionMethods{3} = { 'FWER' };

handles.Threshold = 0.20;
handles.At = 1;
handles.activeAxes = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialize sliders:
handles.xMNI = 0;
handles.yMNI = 0;
handles.zMNI = 0;

set(handles.sliderLayer,'Value',floor(handles.datasize(handles.dataset,3)/2),...
'Max',handles.datasize(handles.dataset,3),'Min',1,'SliderStep',[1/(handles.datasize(handles.dataset,3)-1) 10/(handles.datasize(handles.dataset,3)-1)]);
set(handles.editLayer,'String',...
num2str(get(handles.sliderLayer,'Value')),'Enable','Inactive')

set(handles.sliderAxial,'Value',-1*handles.coordinateShift(3)/handles.coordinateProd(3),...
'Max',handles.datasize(handles.dataset,3),'Min',1)
handles.layerVals(3) = get(handles.sliderAxial,'Value');
set(handles.textAxial,'String',['z (MNI mm) = ' num2str(handles.zMNI)])
set(handles.textAxialMatlab,'String',['z (Matlab) = ' num2str(handles.layerVals(3))])

set(handles.sliderCoronal,'Value',-1*handles.coordinateShift(2)/handles.coordinateProd(2),...
'Max',handles.datasize(handles.dataset,2),'Min',1,'SliderStep',[1/(handles.datasize(handles.dataset,2)-1) 10/(handles.datasize(handles.dataset,2)-1)])
handles.layerVals(2) = get(handles.sliderCoronal,'Value');
set(handles.textCoronal,'String',['y (MNI mm) = ' num2str(handles.yMNI)])
set(handles.textCoronalMatlab,'String',['y (Matlab) = ' num2str(handles.layerVals(2))])

set(handles.sliderSagittal,'Value',-1*handles.coordinateShift(1)/handles.coordinateProd(1),...
    'Max',handles.datasize(handles.dataset,1),'Min',1,'SliderStep',[1/(handles.datasize(handles.dataset,1)-1) 10/(handles.datasize(handles.dataset,1)-1)])
handles.layerVals(1) = get(handles.sliderSagittal,'Value');
set(handles.textSagittal,'String',['x (MNI mm) = ' num2str(handles.xMNI)])
set(handles.textSagittalMatlab,'String',['x (Matlab) = ' num2str(handles.layerVals(1))])

if Pub.winOn == 1
    nrTIs = handles.Priv.nrTimeIntervals(1);
    set(handles.sliderTime,'Value',1,'max',nrTIs,'SliderStep',[1/nrTIs 10/nrTIs])
    set(handles.pushbuttonAnalysisSynch,'Enable','on')
else
    set(handles.sliderTime,'Value',1,'max',1)
    set(handles.pushbuttonAnalysisSynch,'Enable','off')
end

% if Pub.calcPhase == 1
%     set(handles.checkboxTimeWindow,'Value',0)
% end

set(handles.checkboxTimeWindow,'Value',0)
set(handles.popupmenuSession,'Value',1)
%set(handles.popupmenuSessionComp,'Value',1)

set(handles.popupmenuOrient,'String',[{'axial'},{'coronal'},{'sagittal'}])
set(handles.popupmenuOrient,'Value',1)

set(handles.edit1ScaleMin,'String',0)
set(handles.edit1ScaleMax,'String',1)
set(handles.checkboxPixVal1,'Value',0)

set(handles.editThreshold,'String',handles.Priv.th(round(length(handles.Priv.th)/3)),'Enable','off')
set(handles.radiobuttonAutomaticTh,'Value',1)
set(handles.radiobuttonManualTh,'Value',0)
set(handles.radiobuttonAtlasTh,'Value',0)
set(handles.checkboxTh,'Value',1)
handles.manual = 0;


set(handles.popupmenuSessionComp,'Enable','off')
if Priv.nrSessions > 1 && Pub.sessionCompOn
    set(handles.checkboxSessionCompOn,'Enable','on')
    set(handles.checkboxSessionCompOn,'Value',0)
else
    set(handles.checkboxSessionCompOn,'Enable','off')    
    set(handles.checkboxSessionCompOn,'Value',0)
end

% set threshold view based on selected parameters:
handles = setThresholdView(handles);

set(handles.popupmenuOrient,'String',[{'axial'},{'coronal'},{'sagittal'}],'Value',1)

if Pub.nrFreqBands > 1
    set(handles.popupmenuFreqBandComp,'Enable','off','String',handles.bandNames)
else
    set(handles.popupmenuFreqBandComp,'Visible','off')    
end

% hide time-interval view:
set(handles.sliderTime,'Visible','off')
set(handles.editTime,'Visible','off')
set(handles.textTime,'Visible','off')

set(handles.textROI,'Enable','off')
set(handles.sliderTime,'Visible','off','Value',1)
set(handles.editTime,'Visible','off')
set(handles.textTime,'Visible','off')
set(handles.pushbuttonExportSynch,'Enable','off')
set(handles.pushbuttonPlotSynch,'Enable','off')
set(handles.radionButtonPhaseSynch,'Enable','off')
set(handles.radionButtonSynch,'Enable','off')
set(handles.checkboxNormalSynch,'Enable','off')
set(handles.radionButtonSynchMean,'Enable','off')
set(handles.radionButtonSynchMedian,'Enable','off')
set(handles.radionButtonSynchThres,'Enable','off')
set(handles.pushbuttonAnalysisSynch,'Enable','off')

if Pub.calcStats == 0
    set(handles.popupmenuMapType,'Value',1,'String',{'mean'})
end


set(handles.checkboxSwapBytes,'Value',0)

set(handles.uipanelAxes,'Visible','on')
set(handles.axes1,'Visible','off')
set(handles.axesAtlas,'Visible','off')
set(handles.sliderLayer,'Visible','off')
set(handles.editLayer,'Visible','off')
set(handles.popupmenuOrient,'Visible','off')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load anatomical floating-point template image, scale, quantize and shift values:


handles.rangeAnatomy = 64;
I = load_nii([handles.Pub.maskPath 'MNI152_T1_' num2str(handles.voxelsize) 'mm_brain.nii']);
%I = load_nii([handles.Pub.maskPath]);
W = single(I.img);
W = W-min(min(min(nonzeros(W))));
W = W./max(max(max(W)));
W = round((handles.rangeAnatomy-1)*W);
W(W < 0) = 0;
W(W > handles.rangeAnatomy) = handles.rangeAnatomy;
% shift values such that they mach gray-scale part of the colormap:
W = W + handles.colMapSize + 1;% 67; % 67, ..., 131
handles.anatomy = W; %uint8(W);

handles.atlas = zeros(size(handles.anatomy));

% handles.dataAt = load_nii(handles.Priv.brainAtlases{1});
% handles.dataAt = handles.dataAt.img;
% % add constant term for atlas to fit image with the colormap;
% handles.dataAt(find(handles.dataAt)) = handles.dataAt(find(handles.dataAt)) + handles.colMapSize + handles.rangeAnatomy + 1;

% set(handles.popupmenuAtlas,'String',[{'Cortical'},{'Subcortical'}])
% set(handles.popupmenuAtlasThreshold,'String',[{'0%'},{'25%'},{'50%'}])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create colormaps:
%handles.colMapHot64 = colormap(hot(64));
%handles.colMapGray64 = colormap(gray(64));
%c1 = colormap(spring(18));
%c2 = colormap(winter(18));
%c3 = colormap(summer(18));
%c4 = colormap(bone(15));
%handles.colMapAtlasVal = [c1;c2;c3;c4];

handles.CurrentRegion = 1;
handles.showAtlas = 1;
handles.atlasIndexList = zeros(69,2);
handles.rangeAtlas = 69;
handles.colMapAtlasVal = colormap(winter(handles.rangeAtlas));
rv = randperm(handles.rangeAtlas);
handles.colMapAtlasVal(1:handles.rangeAtlas,:) = handles.colMapAtlasVal(rv,:);
% set colormap of the GUI:
handles = setFigureColorMap(handles);

set(gcf,'Colormap',handles.colMapHotCold)

% check whether image processing toolbox is installed:
A = ver;
for k = 1:length(A)
    s(k)=strcmp(A(k).Name,'Image Processing Toolbox');
end
if sum(s) == 1
    handles.imProcToolbox = 1;
     handles.Perim = 0;
    set(handles.checkboxAtlasRegionType,'Value',1,'Enable','on')
else
    handles.imProcToolbox = 0;
     handles.Perim = 0;
    set(handles.checkboxAtlasRegionType,'Value',1,'Enable','off')
end

% load atlas image:
handles.AtlasThreshold = 3;
% handles = loadAtlasData(handles);

handles = loadAtlasData(handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% initialize GUI axis and images:
handles.Colbar1min = 0;
handles.Colbar1max = 64;
handles.Colbar2min = 128;
handles.Colbar2max = 193;

% Large brain image:
axes(handles.axes1);
handles.dataImage = image(zeros(handles.datasize(handles.dataset,2),handles.datasize(handles.dataset,1)));
set(gca,'YTickLabel',[],'XTickLabel',[],'YTick',[],'XTick',[],'xlimmode',...
    'manual','ylimmode','manual','zlimmode','manual',...
    'climmode','manual','alimmode','manual','Drawmode','fast');axis image
handles.Colbar1 = colorbar( 'Location','SouthOutside','CLimMode','manual',...
    'HandleVisibility','on','XLim',[handles.Colbar1min handles.Colbar1max],'XTick',handles.Colbar1min:10:handles.Colbar1max,...
    'XTickLabel',round(100*(handles.Colbar1min:10:handles.Colbar1max)/handles.Colbar1max)/100 ,'Position',[0.155 0.09 0.25 0.03]);
set(handles.axes1,'Visible','off')

% Large atlas image:
axes(handles.axesAtlas);
handles.atlasImage = image(zeros(handles.datasize(handles.dataset,2),handles.datasize(handles.dataset,1)));
set(gca,'YTickLabel',[],'XTickLabel',[],'YTick',[],'XTick',[],'xlimmode',...
    'manual','ylimmode','manual','zlimmode','manual',...
    'climmode','manual','alimmode','manual','Drawmode','fast');axis image
handles.Colbar2 = colorbar( 'Location','SouthOutside','CLimMode','manual',...
    'HandleVisibility','on','XLim',[handles.Colbar2min handles.Colbar2max],'XTick',handles.Colbar2min:10:handles.Colbar2max,...
    'XTickLabel',round(100*(handles.Colbar1min:10:handles.Colbar1max)/handles.Colbar1max)/100,'Position',[0.155+0.3 0.09 0.25 0.03] );
set(handles.axesAtlas,'Visible','off')
%set(handles.Colbar1,'Position',[0.155 0.09 0.25 0.03])


% Three smaller brain images (main view):
axes(handles.axesAxial);
handles.axialImage = image(zeros(handles.datasize(handles.dataset,2),handles.datasize(handles.dataset,1)));
set(handles.axialImage,'XData',[1 handles.datasize(handles.dataset,1)],'YData',[1 handles.datasize(handles.dataset,2)])
set(gca,'YTickLabel',[],'XTickLabel',[],'YTick',[],'XTick',[],'xlimmode',...
    'manual','ylimmode','manual','zlimmode','manual',...
    'climmode','manual','alimmode','manual','Drawmode','fast');axis image
handles.lineAxialHor = line(1:handles.datasize(handles.dataset,1),(handles.datasize(handles.dataset,2)-handles.layerVals(2))*ones(1,handles.datasize(handles.dataset,1)),'LineStyle','--','Color','g');
handles.lineAxialVert = line(handles.layerVals(1)*ones(1,handles.datasize(handles.dataset,2)),1:handles.datasize(handles.dataset,2),'LineStyle','--','Color','g');

axes(handles.axesCoronal);
handles.coronalImage = image(zeros(handles.datasize(handles.dataset,3),handles.datasize(handles.dataset,1)));
set(handles.coronalImage,'XData',[1 handles.datasize(handles.dataset,1)],'YData',[1 handles.datasize(handles.dataset,3)])
set(gca,'YTickLabel',[],'XTickLabel',[],'YTick',[],'XTick',[],'xlimmode',...
    'manual','ylimmode','manual','zlimmode','manual',...
    'climmode','manual','alimmode','manual','Drawmode','fast');axis image
handles.lineCoronalHor = line(1:handles.datasize(handles.dataset,1),(handles.datasize(handles.dataset,3)-handles.layerVals(3))*ones(1,handles.datasize(handles.dataset,1)),'LineStyle','--','Color','g');
handles.lineCoronalVert = line(handles.layerVals(1)*ones(1,handles.datasize(handles.dataset,1)),1:handles.datasize(handles.dataset,1),'LineStyle','--','Color','g');
axes(handles.axesSagittal)
handles.sagittalImage = image(zeros(handles.datasize(handles.dataset,3),handles.datasize(handles.dataset,2)));
set(handles.sagittalImage,'XData',[1 handles.datasize(handles.dataset,2)],'YData',[1 handles.datasize(handles.dataset,3)])
set(gca,'YTickLabel',[],'XTickLabel',[],'YTick',[],'XTick',[],'xlimmode',...
    'manual','ylimmode','manual','zlimmode','manual',...
    'climmode','manual','alimmode','manual','Drawmode','fast');axis image
handles.lineSagittalHor = line(1:handles.datasize(handles.dataset,2),(handles.datasize(handles.dataset,3)-handles.layerVals(3))*ones(1,handles.datasize(handles.dataset,2)),'LineStyle','--','Color','g');
handles.lineSagittalVert = line((handles.layerVals(2))*ones(1,handles.datasize(handles.dataset,1)),1:handles.datasize(handles.dataset,1),'LineStyle','--','Color','g');


% set initial image view:
set(handles.uipanelAxes,'Visible','on')
set(handles.uipanelOrientation,'Visible','off')
set(handles.sliderLayer,'Visible','off')
set(handles.editLayer,'Visible','off')
set(handles.popupmenuOrient,'Visible','off')
set(handles.dataImage,'Visible','off')
set(handles.atlasImage,'Visible','off')
set(handles.axesAxial,'Visible','on')
set(handles.axesSagittal,'Visible','on')
set(handles.axesCoronal,'Visible','on')
set(handles.popupmenuAtlasThreshold,'Visible','on')
set(handles.edit1ScaleMax,'Visible','off')
set(handles.edit1ScaleMin,'Visible','off')

handles.activeAxes = 1;
set(handles.listboxAtlasList,'String',{});

set(handles.radionButtonSynchThres,'Value',0)
set(handles.checkboxNormalSynch,'Value',0)
set(handles.radionButtonSynchMedian,'Value',0)
set(handles.radionButtonSynchMean,'Value',1)
if handles.Pub.winOn && ~handles.Pub.calcPhase 
    set(handles.radionButtonSynch,'Value',1)
    set(handles.radionButtonPhaseSynch,'Value',0)
    handles.Synch = 1;
    set(handles.pushbuttonAnalysisSynch,'Enable','off')
end
if ~handles.Pub.winOn && handles.Pub.calcPhase 
    set(handles.radionButtonSynch,'Value',0)
    set(handles.radionButtonPhaseSynch,'Value',1)
    handles.Synch = 0;
end
if ~handles.Pub.winOn && ~handles.Pub.calcPhase 
    set(handles.radionButtonSynch,'Value',1)
    set(handles.radionButtonPhaseSynch,'Value',0)
    handles.Synch = 1;
end
if handles.Pub.winOn && handles.Pub.calcPhase 
    set(handles.radionButtonSynch,'Value',1)
    set(handles.radionButtonPhaseSynch,'Value',0)
    set(handles.pushbuttonAnalysisSynch,'Enable','off')
    handles.Synch = 1;
end
if handles.Pub.useTemplate == 0
    set(handles.popupmenuAtlas,'Enable','off')
    set(handles.pushbuttonAddRemoveRegion,'Enable','off')
    set(handles.pushbuttonUpdateRegions,'Enable','off')
end

handles.NormalSynch = 0;
handles.plottedRegions = [];
handles.ROIcurve = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set atlas listbox:
handles = setAtlasList(handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if Pub.winOn
    % set initial time-interval for time-interval box:
    intVal = calcInterval(1,handles);
    set(handles.editTime,'String',intVal);
else
    set(handles.editTime,'String','--');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update parameters and images:
handles = update_params(handles);
handles = update_figs(handles);

