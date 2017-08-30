function [FwdModel_bold,FwdModel_fc] = CalculateDistractionFMs_general(subject,label0,label1,y_bold,y_fc,doPlots)

% [FwdModel_bold,FwdModel_fc] = CalculateDistractionFMs_general(subject,label0,label1,y_bold,y_fc,doPlots)
%
% INPUTS:
% 
% OUTPUTS:
% -FwdModel_bold
% -FwdModel_FC
%
% Created 5/25/16 by DJ based on CalculateDistractionFMs.

if ~exist('doPlots','var') || isempty(doPlots)
    doPlots = false;
end

%% Load TC and censoring
load(sprintf('Distraction-%d-QuickRun.mat',subject));
% Enter analysis subdirectory
dirName = dir('AfniProc*');
cd(dirName(1).name);
% Load
[~,tc] = Read_1D(sprintf('SBJ%02d_CraddockAtlas_200Rois_ts.1D',subject));
tc = tc';
[~,censorM] = Read_1D(sprintf('censor_SBJ%02d_combined_2.1D',subject));    
isNotCensoredSample = censorM'>0;
tc(:,~isNotCensoredSample) = nan;
[err,atlas,atlasInfo,ErrMsg] = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/craddock_2011_parcellations/CraddockAtlas_200Rois+tlrc');


%% Prep inputs
% normalize TC
for i=1:size(tc,1)
    tc(i,:) = (tc(i,:)-nanmean(tc(i,:)))/nanstd(tc(i,:));
end

% declare other params
tcWinLength = 8;
fcWinLength = 10;
TR = 2;
nFirstRemoved = 3;
roiNames = {};
fracFcVarToKeep = 0.1;

% Calculate FC
FC = GetFcMatrices(tc,'sw',fcWinLength);

% Get feat times
[feats, featNames, labels, labelNames, times, timeNames, iTcEventSample, iFcEventSample] = ConstructComboFeatMatrix(data, stats, question, tc(1:4,:), roiNames, fcWinLength, tcWinLength, TR, nFirstRemoved,fracFcVarToKeep);
fprintf('Done!\n');

%% Get truth
nTrials = size(labels,2);
truth = nan(1,nTrials);
iLabel1 = find(strcmp(labelNames,label1));
truth(labels(iLabel1,:)) = 1;
if strcmp(label0,'other')
    truth(~labels(iLabel1,:)) = 0;
else
    iLabel0 = find(strcmp(labelNames,label0));
    truth(labels(iLabel0,:)) = 0;
end

%% Plot BOLD fwd models
% crop y
isYSample = ~isnan(truth);
iTcEventSample_y = iTcEventSample(isYSample);
isOkYSample = ~isnan(iTcEventSample_y);
isOkYSample(isOkYSample) = isNotCensoredSample(iTcEventSample_y(isOkYSample));
y_bold = y_bold(isOkYSample);
% get fwd model
isOkSample = ~isnan(iTcEventSample) & ~isnan(truth);
isOkSample(isOkSample) = isNotCensoredSample(iTcEventSample(isOkSample)); 
X_bold = tc(:,iTcEventSample(isOkSample));
% get FM
isIncluded = ~isnan(y_bold);
FwdModel_bold = y_bold(:,isIncluded)' \ X_bold(:,isIncluded)'; %(X_bold'y_true)*(X_bold'*X_bold)^-1

if doPlots
    % plot fwd model
    dataOut = MapValuesOntoAtlas(atlas,FwdModel_bold);
    figure(599); clf;
    dim = 1;
    iSlices = round(linspace(1,size(atlas,dim),11));
    iSlices = iSlices(2:end-1);
    DisplaySlices(dataOut,dim,iSlices,[],[-.2 .2]);
    colormap jet
    bigTitle = sprintf('SBJ%02d BOLD FwdModels (%s-%s)',subject,label1,label0);
    MakeFigureTitle(bigTitle);
end

%% Plot FC fwd models

% crop y
isYSample = ~isnan(truth);
iFcEventSample_y = iFcEventSample(isYSample);
isOkYSample = ~isnan(iFcEventSample_y);
isOkYSample(isOkYSample) = isNotCensoredSample(iFcEventSample_y(isOkYSample));
y_fc = y_fc(isOkYSample);
% get & crop x
isOkSample = ~isnan(iFcEventSample) & ~isnan(truth);
isOkSample(isOkSample) = isNotCensoredSample(iFcEventSample(isOkSample));
X_fc = FC(:,:,iFcEventSample(isOkSample));
% get FM
FwdModel_fc = nan(size(FC,1),size(FC,2));
isIncluded = ~isnan(y_fc);
for i=1:size(X_fc,1)    
    FwdModel_fc(i,:) = y_fc(:,isIncluded)' \ squeeze(X_fc(i,:,isIncluded))';
end

if doPlots
    % plot fwd model on circle
    figure(600); clf;
    subplot(121);
    threshold = GetValueAtPercentile(abs(FwdModel_fc(:)),99.5);
    idx = ClusterRoisSpatially(atlas,1);
    PlotConnectivityOnCircle(atlas,idx,FwdModel_fc,threshold);
    xlabel('<-- L  R -->')
    ylabel('<-- A  P -->')
    title(sprintf('SBJ%02d: Top 1%% of Fwd Models',subject))
    % plot fwd model as matrix
    subplot(122);
    PlotFcMatrix(FwdModel_fc,[],atlas,idx);
    bigTitle = sprintf('SBJ%02d FC FwdModels (%s-%s)',subject,label1,label0);
    title(bigTitle)
end

