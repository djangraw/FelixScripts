function templateMatch = PlotFcTemplateTimecourse(subject,atlasType,fcTemplates,winLength,templateNames,doPlot)

% templateMatch = PlotFcTemplateTimecourse(subject,atlasType,fcTemplates,winLength,templateNames,doPlot)
%
% Created 10/21/16 by DJ.

% Declare defaults
nTemplates = size(fcTemplates,3);
if ~exist('templateNames','var') || isempty(templateNames)
    templateNames = cell(nTemplates,1);
    for i=1:nTemplates
        templateNames{i} = sprintf('FC template #%d',i);
    end
end
if ~exist('doPlot','var') || isempty(doPlot)
    doPlot = true;
end
templateNames = templateNames(:); % make a column vector

%% Declare constants
homedir = '/data/jangrawdc/PRJ03_SustainedAttention/Results';
TR = 2;
nFirstRemoved = 3;
if subject==9
    nTR = 246;
else
    nTR = 252;
end
hrfOffset = 6;
alignment = 'start';

% Set up
cd(homedir);
subjStr = sprintf('SBJ%02d',subject);
fprintf('Getting FC for subject %d...\n',subject)
cd(subjStr)
foo = dir('AfniProc*');
cd(foo(1).name);
% get atlas
switch atlasType
    case 'Shen'
        atlasFilename = '/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_2mm_268_parcellation.nii.gz';
        filename = sprintf('shen268_withSegTc_%s_ROI_TS.1D',subjStr);
        [atlasLabels,labelNames,colors] = GetAttnNetLabels(false);
end
atlas = BrikLoad(atlasFilename);

% Load BOLD data
[err,M,Info,Com] = Read_1D(filename);
% Crop data
isCensored = all(M==0,2);
isZeroCol = all(M==0,1); % ROIs without enough voxels
fprintf('Removing %d censored samples and %d (near-)empty ROIs\n',sum(isCensored),sum(isZeroCol))
M_crop = M;
M_crop(isCensored,:) = NaN;
M_crop(:,isZeroCol) = NaN;
nT = size(M_crop,1);

% get FC template matches
nTemplates = size(fcTemplates,3);
nWin = nT - winLength + 1;
templateMatch = nan(nTemplates,nWin);
for i=1:nTemplates
    templateMatch(i,:) = GetFcTemplateMatch(M_crop',fcTemplates(:,:,i),winLength,true,'mult');
end
% t = (1:size(M_crop,1))*TR + nFirstRemoved*TR - hrfOffset;
tFC = (1:nWin)*TR;

%% load behavior data
if doPlot
    beh = load(sprintf('../Distraction-%d-QuickRun.mat',subject));
    % [pageStartTimes,pageEndTimes,eventSessions,eventTypes] = GetEventBoldSessionTimes(beh.data);
    [iTcEventSample,iFcEventSample,eventNames] = GetEventSamples(beh.data, winLength, TR, nFirstRemoved, nTR, hrfOffset, alignment);
    eventCats = unique(eventNames);
    % eventColors = distinguishable_colors(numel(eventCats));
    eventColors = [1 0 0; 1 .75 0; 0 1 0];

    % Plot results
    figure(62); clf;
    subplot(211); hold on;
    plot(tFC,templateMatch');

    % Plot events
    for k=1:numel(eventCats)
        isThisType = strcmp(eventNames',eventCats{k});
        isOkEvent = ~isnan(iFcEventSample) & iFcEventSample<nWin;
        PlotVerticalLines(tFC(iFcEventSample(isThisType & isOkEvent)),eventColors(k,:),true);
    end
    PlotVerticalLines(tFC((nTR-nFirstRemoved):(nTR-nFirstRemoved):end),'k--',true);
    xlabel(sprintf('time (with %ds offset)',hrfOffset));
    ylabel('component activity');
    title(sprintf('SBJ%02d, %.1f sec window',subject, winLength*TR));
    legend([templateNames; eventCats; {'Session'}]);

    for i=1:nTemplates
        subplot(2,nTemplates,nTemplates+i);
        PlotFcMatrix(fcTemplates(:,:,i),[0 1],atlas,atlasLabels,true,colors,false);
        title(templateNames{i});
    end
end


