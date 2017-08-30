% LoadDistractionData_ShenAtlas.m
%
% Load ROI timecourses (of Shen Atlas ROIs) and event information for each 
% subject into a separate cell.
%
% Created 6/8/16 by DJ.

% Declare parameters
subjects = [9:22 24:30]; % acceptable subjects
homedir = '/data/jangrawdc/PRJ03_SustainedAttention/Results/'; % where the 'SBJXX' folders live

TR = 2; % in seconds
fcWinLength = 10; % window length used to process FC
nFirstRemoved = 3; % TRs removed during processing
HrfOffset = 6; % kluge for now

[tc_all,iTcEventSample_all,iFcEventSample_all,eventNames_all,eventRun_all] = deal(cell(1,numel(subjects)));
fprintf('===Loading data from %d subjects...\n',numel(subjects));
for i=1:numel(subjects) 
    % Set up
    subject = subjects(i);
    fprintf('Subject %d...\n',subject);
    cd(homedir)
    fprintf('Loading files...\n');
    % Load behavioral data
    cd(sprintf('%sSBJ%02d',homedir,subject));
    behavior = load(sprintf('Distraction-%d-QuickRun.mat',subject));
    % Load timecourses
    datadir = dir('AfniProc*'); % for Helix
    cd(datadir(1).name); % for Helix
    [~,tc] = Read_1D(sprintf('shen268_withSegTc_SBJ%02d_ROI_TS.1D',subject));
    tc = tc'; % make size (ROIs x time)
    [~,censorM] = Read_1D(sprintf('censor_SBJ%02d_combined_2.1D',subject));    
    isNotCensoredSample = censorM'>0;
    tc(:,~isNotCensoredSample) = nan;
      
    % Get event/page/trial times
    nRuns = numel(behavior.data); 
    nT = size(tc,2); % total number of time points across all runs
    nTR = nT/nRuns + nFirstRemoved; % number of TRs per run before any were removed
    [iTcEventSample,iFcEventSample,eventNames] = GetEventSamples(behavior.data, fcWinLength, TR, nFirstRemoved, nTR, HrfOffset);
    eventRun = ceil(iFcEventSample/(nTR-nFirstRemoved)); % which run each event is in

    % Add to cells
    tc_all{i} = tc;
    iTcEventSample_all{i} = iTcEventSample;
    iFcEventSample_all{i} = iFcEventSample;
    eventNames_all{i} = eventNames';
    eventRun_all{i} = eventRun;
    
end
fprintf('===Done!\n');