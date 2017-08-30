% PlotClassifierTimecourse_script.m
%
% Created 3/20/16 by DJ.

% Declare params
iSubj = 5;
fcWinLength = 10;
fracFcVarToKeep = 0.5;
TR = 2;
nFirstTRsRemoved = 3;
nTRsPerSession = 243;
doRound = 0;
hrfOffset_samples = 3;
plotQuestions=true;
% LR params
params.regularize=1;
params.lambda=1e-6;
params.lambdasearch=true;
params.eigvalratio=1e-4;
% params.vinit=zeros(size(feats,1)+1,1);
params.show=0;
params.LOO=true; % false; %
params.demean=false;
params.LTO=false;%true;

% Load subject data
subjects = 9:16;
homedir = '/spin1/users/jangrawdc/PRJ03_SustainedAttention/Results';
cd(sprintf('%s/SBJ%02d',homedir,subjects(iSubj)));

% Get timecourses
fprintf('===Loading timecourse data...\n');
load(sprintf('Distraction-%d-QuickRun.mat',subjects(iSubj))); % data, stats,question
[~,tc] = Read_1D(sprintf('SBJ%02d_CraddockAtlas_200Rois_ts.1D',subjects(iSubj)));
tc = tc';
[~,censorM] = Read_1D(sprintf('censor_SBJ%02d_combined_2.1D',subjects(iSubj)));    
isNotCensoredSample = censorM'>0;
tc(:,~isNotCensoredSample) = nan;

% normalize timecourses
fprintf('===Normalizing timecourse data...\n');
for i=1:size(tc,1)
    tc(i,:) = (tc(i,:)-nanmean(tc(i,:)))/nanstd(tc(i,:));
end
% Run PCA on timecourses
fprintf('===Performing SVD on timecourse data...\n');
isNotCensoredSample = ~any(isnan(tc));
[U,S,V] = svd(tc(:,isNotCensoredSample)');
tc2 = V'*tc; % multiply each weight vec by each FC vec

% Calculate FC
fprintf('===Calculating FC...\n');
FC = GetFcMatrices(tc,'sw',fcWinLength);

% Do PCA & DimRed on FC
fprintf('===Performing SVD on FC data...\n');
[U,S,V,FcPcTc] = PlotFcPca(FC,0,true);
cumsumS = cumsum(diag(S).^2)/sum(diag(S).^2);
nPcsToKeep = find(cumsumS<fracFcVarToKeep,1,'last');
fc_2dmat = FcPcTc(1:nPcsToKeep,:);

%% Get samples for each trial
fprintf('===Getting trial times...\n')
[pageStartTimes,pageEndTimes,eventSessions,eventTypes] = GetEventBoldSessionTimes(data);
% get indices of page start events
iPageStart_combo = ConvertBoldSessionTimeToComboTime(pageStartTimes,eventSessions,TR,nFirstTRsRemoved,nTRsPerSession,doRound);
% get indices of page end (fixation start) events
iPageEnd_combo = ConvertBoldSessionTimeToComboTime(pageEndTimes,eventSessions,TR,nFirstTRsRemoved,nTRsPerSession,doRound);
% Get event types
uniqueEventTypes = unique(eventTypes);
nEventTypes = numel(uniqueEventTypes);
[~,iEventType] = ismember(eventTypes,uniqueEventTypes);

%% Classify and get (LOO?) weights
fprintf('===Building Classifier...\n')
% get trials
iPage_fc = round(iPageEnd_combo - fcWinLength + hrfOffset_samples);
isOkTrial = ismember(eventTypes,{'attendedSpeech','ignoredSpeech'}) & iPage_fc>0;
% get indices
fcFeatMat = fc_2dmat(:,iPage_fc(isOkTrial));
truth = strcmp('ignoredSpeech', eventTypes(isOkTrial));

normfeats = fcFeatMat;

% remove nans
% newFeats = fcFeatMat;
% for i=1:size(newFeats,1)
%     newFeats(i,isnan(newFeats(i,:))) = nanmean(newFeats(i,:));
% end
% % normalize
% normfeats = zeros(size(newFeats));
% for i=1:size(newFeats,1)
%     normfeats(i,:) = (newFeats(i,:)-nanmean(newFeats(i,:)))/nanstd(newFeats(i,:));
% end


% Build classifier
params.vinit=zeros(size(normfeats,1)+1,1);
[Az, AzLoo, stats, AzLto] = RunSingleLR(permute(normfeats,[1 3 2]),truth,params);
fprintf('AzLoo = %.3f\n',AzLoo);

% Apply weights to all timepoints
wts = stats.wts;
y = [fc_2dmat; ones(1,size(fc_2dmat,2))]'*stats.wts;


%% Plot y values
figure(610+iSubj); clf;
cla; hold on;
plot(y)
colors = 'mcb';
for i=1:nEventTypes
    isThis = strcmp(uniqueEventTypes{i},eventTypes);
    iThis_fc = round(iPageEnd_combo(isThis) - fcWinLength + hrfOffset_samples);
    isOk = (iThis_fc>0 & iThis_fc<size(fc_2dmat,2));
    plot(iThis_fc(isOk),y(iThis_fc(isOk)),[colors(i) 'o']);
end
xlim([0 size(fc_2dmat,2)]);
% PlotVerticalLines(nTRsPerSession:nTRsPerSession:size(fc_2dmat,2), 'k--');
% PlotHorizontalLines(0,'k:');
xlabel('time (samples)')
ylabel('classifier output')
% legend([{'all TRs'}; uniqueEventTypes; {'Session breaks'}]);
title(sprintf('SBJ%02d',subjects(iSubj))); 

% overlay correct vs. incorrect trials
if plotQuestions
    isReading = strcmp('reading',question.type);
    pages_adj = cellfun(@min,question.pages_adj(isReading));
    isCorrect = question.isCorrect(isReading);

    % Plot correct
    iPages_fc = round(iPageEnd_combo(pages_adj) - fcWinLength + hrfOffset_samples);
    isOk = (iPages_fc>0 & iPages_fc<size(fc_2dmat,2));
    plot(iPages_fc(isOk & isCorrect),y(iPages_fc(isOk & isCorrect)),'gs','markersize',10);
    plot(iPages_fc(isOk & ~isCorrect),y(iPages_fc(isOk & ~isCorrect)),'rs','markersize',10);
    legendstr = [{'all TRs'}; uniqueEventTypes; {'Correct';'Incorrect';'Session breaks'}];
else
    legendstr = [{'all TRs'}; uniqueEventTypes; {'Session breaks'}];
end
PlotVerticalLines(nTRsPerSession:nTRsPerSession:size(fc_2dmat,2), 'k--');
PlotHorizontalLines(0,'k:');
legend(legendstr);

