function fcDiff = GetBlockWiseFcDifference(subject,atlasType)

%%
if ~exist('atlasType','var') || isempty(atlasType)
    atlasType = 'AllSpheresNoOverlap';
end

% Set up
homedir = '/data/jangrawdc/PRJ03_SustainedAttention/Results/';
cd(sprintf('%sSBJ%02d',homedir,subject));

% Load behavior
beh = load(sprintf('Distraction-SBJ%02d-Behavior.mat',subject));
datadir = dir('AfniProc*');
cd(datadir(1).name);

% Load fMRI
tcFile = sprintf('%s_SBJ%02d_ROI_TS.1D',atlasType,subject);
tc = Read_1D(tcFile);
tc = tc';
[~,censorM] = Read_1D(sprintf('censor_SBJ%02d_combined_2.1D',subject));    
isNotCensoredSample = censorM'>0;
tc(:,~isNotCensoredSample) = nan;

% Get trial times
nRuns = numel(beh.data);
nT = size(tc,2);
nTR = nT/nRuns + nFirstRemoved;
fcWinLength = 1; % placeholder
iTcEventSample_start = GetEventSamples(beh.data, fcWinLength, TR, nFirstRemoved, nTR, HrfOffset,'start');
[iTcEventSample_end,~,eventNames] = GetEventSamples(beh.data, fcWinLength, TR, nFirstRemoved, nTR, HrfOffset,'end');
% get run number for each event
eventRun = ceil(iTcEventSample_start/(nTR-nFirstRemoved));

% Get block start and end times
iBlockStart = 1:15:numel(eventRun);
iBlockEnd = [iBlockStart(2:end)-1, numel(eventRun)];

% Get FC
clear FC
isIgnBlock = false(1,numel(iBlockEnd));
for i=1:numel(iBlockEnd)
    iThisBlock = iTcEventSample_start(iBlockStart(i)):iTcEventSample_end(iBlockEnd(i));
    FC(:,:,i) = GetFcMatrices(tc(:, iThisBlock),'sw',numel(iThisBlock));
    isIgnBlock(i) = any(strcmp(eventNames(iBlockStart(i):iBlockEnd(i)),'ignoredSpeech'));
end

% Get FC difference
fcDiff = FC(:,:,isIgnBlock) - FC(:,:,~isIgnBlock);


