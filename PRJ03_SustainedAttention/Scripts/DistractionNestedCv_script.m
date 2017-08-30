% DistractionNestedCv_script.m
%
% Created 3/17/16 by DJ.

% subjects=17:20;
homedir = '/data/jangrawdc/PRJ03_SustainedAttention/Results';
% label1 = 'ignoredSpeech';
% label0 = 'attendedSpeech';
fracTcVarToKeep = 1;
fracFcVarToKeep = [0.2:0.05:0.7];
%%
[AzLoo_all,Az_all,LRstats_all,yLoo,newTruth,y_best,bestTcFrac,bestFcFrac] = deal(cell(1,numel(subjects)));
Az_best = nan(1,numel(subjects));
for i=1:numel(subjects)
    fprintf('Subject %d (%d/%d)...\n',subjects(i),i,numel(subjects));
    % load results
    cd(sprintf('%s/SBJ%02d',homedir,subjects(i)));    
    load(sprintf('Distraction-%d-QuickRun.mat',subjects(i))); % data, stats,question
    % enter inner directory
    foo = dir('AfniProc_*');
    cd(foo(1).name);
    % Load timecourse and censor matrices
    [~,tc] = Read_1D(sprintf('SBJ%02d_CraddockAtlas_200Rois_ts.1D',subjects(i)));
    tc = tc';
    [~,censorM] = Read_1D(sprintf('censor_SBJ%02d_combined_2.1D',subjects(i)));    
    isNotCensoredSample = censorM'>0;
    tc(:,~isNotCensoredSample) = nan;
    % Classify
    [AzLoo_all{i},Az_all{i},LRstats_all{i},yLoo{i},newTruth{i}] = PerformNestedCvOnDistractionData(data,stats,question,tc,fracTcVarToKeep,fracFcVarToKeep,label1,label0);
   
    % Get y values associated with best Loo Az
    nTrials = size(yLoo{i},3);
    [y_best{i},bestTcFrac{i},bestFcFrac{i}] = deal(nan(nTrials,1));
    for j=1:nTrials
        [maxes,iMax] = max(AzLoo_all{i}(:,:,j),[],1);
        [~,jMax] = max(maxes,[],2);
        y_best{i}(j) = yLoo{i}(iMax(jMax),jMax,j);
        bestTcFrac{i}(j) = fracTcVarToKeep(iMax(jMax));
        bestFcFrac{i}(j) = fracFcVarToKeep(jMax);
    end
    % Get Az
    Az_best(i) = rocarea(y_best{i},newTruth{i});
    
end

%% Save results
save(sprintf('%s/SBJ%02d-%02d_%s-%s_FC_nestedLooCv',homedir,subjects(1),subjects(end),label1,label0),'subjects','homedir','label1','label0','fracTcVarToKeep','fracFcVarToKeep','AzLoo_all','Az_all','LRstats_all','yLoo','newTruth','y_best','bestTcFrac','bestFcFrac','Az_best');

%% Do the same for Mag variance kept

% subjects=9:16;
% homedir = '/data/jangrawdc/PRJ03_SustainedAttention/Results';
% label1 = 'whiteNoise';
% label0 = 'other';
% fracTcVarToKeep = [0.7:.05:0.9];
fracTcVarToKeep = .85%[0.6:.05:1];

[AzLoo_all,Az_all,LRstats_all,yLoo,newTruth,y_best,bestTcFrac] = deal(cell(1,numel(subjects)));
% Az_best = nan(1,numel(subjects));
for i=1%:numel(subjects)
    fprintf('Subject %d (%d/%d)...\n',subjects(i),i,numel(subjects));
    % load results
    cd(sprintf('%s/SBJ%02d',homedir,subjects(i)));    
    load(sprintf('Distraction-%d-QuickRun.mat',subjects(i))); % data, stats,question
    % enter inner directory
    foo = dir('AfniProc_*');
    cd(foo(1).name);
    % Load timecourse and censor matrices
    [~,tc] = Read_1D(sprintf('SBJ%02d_CraddockAtlas_200Rois_ts.1D',subjects(i)));
    tc = tc';
    [~,censorM] = Read_1D(sprintf('censor_SBJ%02d_combined_2.1D',subjects(i)));    
    isNotCensoredSample = censorM'>0;
    tc(:,~isNotCensoredSample) = nan;
    % Classify
    [AzLoo_all{i},Az_all{i},LRstats_all{i},yLoo{i},newTruth{i}] = PerformNestedCvOnDistractionData_Mag(data,stats,question,tc,fracTcVarToKeep,label1,label0);
   
    %% Get y values associated with best Loo Az
    nTrials = size(yLoo{i},2);
    [y_best{i},bestTcFrac{i},bestFcFrac{i}] = deal(nan(nTrials,1));
    for j=1:nTrials
        [maxes,iMax] = max(AzLoo_all{i}(:,j),[],1);
        y_best{i}(j) = yLoo{i}(iMax,j);
        bestTcFrac{i}(j) = fracTcVarToKeep(iMax);
    end
    % Get Az
    Az_best(i) = rocarea(y_best{i},newTruth{i});
    
end

%% Save results
label1 = 'whiteNoise';
label0 = 'other';
subjects=[21,22,24:30];
save(sprintf('%s/SBJ%02d-%02d_%s-%s_Mag_nestedLooCv',homedir,subjects(1),subjects(end),label1,label0),'subjects','homedir','label1','label0','fracTcVarToKeep','AzLoo_all','Az_all','LRstats_all','yLoo','newTruth','y_best','bestTcFrac','Az_best');
