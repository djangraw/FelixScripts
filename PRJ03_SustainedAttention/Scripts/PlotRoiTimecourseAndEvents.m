function [roi_ts, iTcEventSample_start] = PlotRoiTimecourseAndEvents(subject,iRois)

% [roi_ts, iTcEventSample_start] = PlotRoiTimecourseAndEvents(subject,iRois)
%
% Created 1/25/17 by DJ.

homedir = '/data/jangrawdc/PRJ03_SustainedAttention/Results';
afniProcFolder = 'AfniProc_MultiEcho_2016-09-22';
tsFilePrefix = 'shen268_withSegTc';
nFirstRemoved = 3; 
fcWinLength = 1;
hrfOffset = 6;
TR = 2;

% Load fMRI data
tsFilename = sprintf('%s/SBJ%02d/%s/%s_SBJ%02d_ROI_TS.1D',homedir,subject,afniProcFolder,tsFilePrefix,subject);
% Load data
[err,M,Info,Com] = Read_1D(tsFilename);
% isMissingRoi = all(M==0,1);

% Load behavior data
beh = load(sprintf('%s/SBJ%02d/Distraction-SBJ%02d-Behavior.mat',homedir,subject,subject));
% Get times that were during reading
nRuns = numel(beh.data);
nT = size(M,1);
nTR = nT/nRuns + nFirstRemoved;
isCensored = all(M==0,2);
% censor with nans
M(isCensored,:) = nan;

% Get event times
iTcEventSample_start = GetEventSamples(beh.data, fcWinLength, TR, nFirstRemoved, nTR, hrfOffset,'start');
% [iTcEventSample_end,~,eventNames] = GetEventSamples(beh.data, fcWinLength, TR, nFirstRemoved, nTR, hrfOffset,'end');
iRunStart = 1:(nT/nRuns):nT;
% iRunEnd = iTcEventSample_end(30:30:end);

% make legend string
legendstr = cell(1,numel(iRois));
for i=1:numel(iRois)
    legendstr{i} = sprintf('ROI %d',iRois(i));
end
legendstr = [legendstr {'Page Start','Run Start'}];
% Plot
cla; hold on;
roi_ts = M(:,iRois);
plot(roi_ts);
PlotVerticalLines(iTcEventSample_start,'g:');
% PlotVerticalLines(iTcEventSample_end,'r:');
PlotVerticalLines(iRunStart,'k--');
legend(legendstr)
xlabel('time (samples)');
ylabel('% signal change in ROI');
title(sprintf('Subject %d',subject));
