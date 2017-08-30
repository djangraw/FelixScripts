function [FwdModel_bold,FwdModel_fc,FwdModel_bold_perm,FwdModel_fc_perm] = CalculateDistractionFMs(subject,resultsFilename,doPerms,doPlots)

% Created 3/2/16 by DJ.

if ~exist('doPerms','var') || isempty(doPerms)
    doPerms = false;
end
if ~exist('doPlots','var') || isempty(doPlots)
    doPlots = false;
end

%% Load TC and censoring
load(sprintf('Distraction-%d-QuickRun.mat',subject));
[~,tc] = Read_1D(sprintf('SBJ%02d_CraddockAtlas_200Rois_ts.1D',subject));
tc = tc';
[~,censorM] = Read_1D(sprintf('censor_SBJ%02d_combined_2.1D',subject));    
isNotCensoredSample = censorM'>0;
tc(:,~isNotCensoredSample) = nan;
[err,atlas,atlasInfo,ErrMsg] = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/craddock_2011_parcellations/CraddockAtlas_200Rois+tlrc');

% Load results
results = load(resultsFilename);

%% Get truth
truth = nan(1,size(results.labels,2));
iLabel1 = find(strcmp(results.labelNames,results.label1));
truth(results.labels(iLabel1,:)) = 1;
if strcmp(results.label0,'other')
    truth(~results.labels(iLabel1,:)) = 0;
else
    iLabel0 = find(strcmp(results.labelNames,results.label0));
    truth(results.labels(results.iLabel0,:)) = 0;
end

%% Prep inputs
% normalize TC
for i=1:size(tc,1)
    tc(i,:) = (tc(i,:)-nanmean(tc(i,:)))/nanstd(tc(i,:));
end

% Calculate FC
FC = GetFcMatrices(tc,'sw',results.fcWinLength);
% normalize FC
% for i=1:size(FC,1)
%     for j=1:size(FC,2)
%         FC(i,j,:) = (FC(i,j,:) - nanmean(FC(i,j,:)))/nanstd(FC(i,j,:));
%     end
% end

tc2 = tc(1:4,:);
results.tcWinLength = 8;
roiNames = {};
[feats, featNames, labels, labelNames, times, timeNames, iTcEventSample, iFcEventSample] = ConstructComboFeatMatrix(data, stats, question, tc2, roiNames, results.fcWinLength, results.tcWinLength, results.TR, results.nFirstRemoved,results.fracFcVarToKeep);
fprintf('Done!\n');

y_perm_mat = cat(3,results.y_perm{:});
nPerms = numel(results.y_perm);

%% Plot BOLD fwd models
% get fwd model
isOkSample = ~isnan(iTcEventSample) & ~isnan(truth);
isOkSample(isOkSample) = isNotCensoredSample(iTcEventSample(isOkSample)); 
X_bold = tc(:,iTcEventSample(isOkSample));
% get y
y_bold = results.y_true(1,isOkSample);
y_bold_perm = squeeze(y_perm_mat(1,isOkSample,:));
bigTitle = sprintf('SBJ%02d BOLD FwdModels (%s-%s)',subject,results.label1,results.label0);
% get FM
isIncluded = ~isnan(y_bold);
FwdModel_bold = y_bold(:,isIncluded)' \ X_bold(:,isIncluded)'; %(X_bold'y_true)*(X_bold'*X_bold)^-1
% get FM for perms
if doPerms
    FwdModel_bold_perm = nan(size(X_bold,1),nPerms);
    for i=1:size(y_bold_perm,2)
        isIncluded = ~isnan(y_bold_perm(:,i));
        FwdModel_bold_perm(:,i) = y_bold_perm(isIncluded,i) \ X_bold(:,isIncluded)';
    end
else
    FwdModel_bold_perm = [];
end

if doPlots
    % plot fwd model
    dataOut = MapValuesOntoAtlas(atlas,FwdModel_bold);
    figure(599); clf;
    dim = 1;
    iSlices = round(linspace(1,size(atlas,dim),11));
    iSlices = iSlices(2:end-1);
    DisplaySlices(dataOut,dim,iSlices,[],[-.2 .2]);
    colormap jet
    MakeFigureTitle(bigTitle);
end

%% Plot FC fwd models

% get fwd model
isOkSample = ~isnan(iFcEventSample) & ~isnan(truth);
isOkSample(isOkSample) = isNotCensoredSample(iFcEventSample(isOkSample));
X_fc = FC(:,:,iFcEventSample(isOkSample));
% get y
y_fc = results.y_true(2,isOkSample);
y_fc_perm = squeeze(y_perm_mat(2,isOkSample,:,:));
bigTitle = sprintf('SBJ%02d FC FwdModels (%s-%s)',subject,results.label1,results.label0);
% get FM
FwdModel_fc = nan(size(FC,1),size(FC,2));
FwdModel_fc_perm = nan(nPerms,size(FC,2),size(FC,1));
isIncluded = ~isnan(y_fc);
for i=1:size(X_fc,1)    
    FwdModel_fc(i,:) = y_fc(:,isIncluded)' \ squeeze(X_fc(i,:,isIncluded))';
end
% get FM for perms
if doPerms
    for j=1:nPerms
        isIncluded = ~isnan(y_fc_perm(:,j));
        for i=1:size(X_fc,1)
            FwdModel_fc_perm(j,:,i) = y_fc_perm(isIncluded,j) \ squeeze(X_fc(i,:,isIncluded))';
        end
    end
end
% put perms in 3rd dimension
FwdModel_fc_perm = permute(FwdModel_fc_perm,[3 2 1]);

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
    title(bigTitle)
end

%% Plot eye position forward models

% % get fwd model
% isOkSample = true(1,size(normfeats,2)) & ~isnan(truth);
% X_eye = normfeats(isEyeFeat,isOkSample);
% % Get y
% y_eye = y_true(3,isOkSample);
% y_eye_perm = squeeze(y_perm_mat(3,isOkSample,:,:));
% bigTitle = sprintf('SBJ%02d Eye FwdModels (%s-%s)',subject,label1,label0);
% % get FM
% FwdModel_eye = y_eye' \ X_eye'; %(X_bold'y_true)*(X_bold'*X_bold)^-1
% % get FM for perms
% if doPerms
%     FwdModel_eye_perm = y_eye_perm \ X_eye';
% else
%     FwdModel_eye_perm = [];
% end
% 
% % get feature names
% eyeLabels = featNames(isEyeFeat);
% for i=1:numel(eyeLabels)
%     eyeLabels{i} = eyeLabels{i}(5:end-1);
% end
% 
% if doPlots
%     % plot fwd model
%     figure(601); clf;
%     bar(FwdModel_eye);
%     set(gca,'xtick',1:numel(eyeLabels),'xticklabel',eyeLabels);
%     ylabel('Fwd Model');
%     title(bigTitle);
%     xticklabel_rotate([],45);
% end