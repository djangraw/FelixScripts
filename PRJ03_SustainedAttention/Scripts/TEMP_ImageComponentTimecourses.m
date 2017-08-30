% TEMP_ImageComponentTimecourses.m
%
% Created ~12/18/16 by DJ.

subjects = [9:11,13:19,22,24:25,28,30:34,36];
fcWinLength = 10;
doPlot = false;%true;%
TR = 2;
nFirstRemoved = 3;
hrfOffset = 6; % in seconds

subject = 9;
cd(sprintf('/data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ%02d/AfniProc_MultiEcho_2016-09-22',subject));
beh = load(sprintf('../Distraction-SBJ%02d-Behavior.mat',subject));
nRuns = numel(beh);
nRows = ceil(sqrt(nRuns));
nCols = ceil(nRuns/nRows);
for i=1:nRuns

    % find accepted & ignored components
    okComps = ReadAcceptedComps(subject,i);

    % Get timecourses 
    ts = Read_1D(sprintf('TED.SBJ%02d.r%02d/meica_mix.1D',subject,i));
    t = (1:size(ts,1))*TR + nFirstRemoved*TR - hrfOffset;

    % Crop to accepted components and get FC
    ts_ok = ts(:,okComps);
    FC_ok = VectorizeFc(GetFcMatrices(ts_ok','sw',fcWinLength));

    % Get regressors
    nTRsPerSession = size(ts,1);
    [stimTimecourse,stimTypes] = GetStimTimecourses(beh.data(i),TR,nFirstRemoved,nTRsPerSession);

    % Offset and trim
%     iLast = size(FC_ok,2) - hrfOffset;
%     stimTimecourse = [zeros(size(stimTimecourse,1),hrfOffset),stimTimecourse(:,1:iLast)];
    
    subplot(nRows,nCols,i); cla;
    imagesc([stimTimecourse; ts_ok(:,1:5)']);
end