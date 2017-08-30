function [y_true,y_perm] = RunDistractionClassifier(subject,label1,label0,useEcho2,doPerms,fracTcVarToKeep,fracFcVarToKeep,doFMs)

% Created 12/21/15 by DJ as ComboClassifier_script.
% Updated 1/20/16 by DJ as RunDistractionClassifier.
% Updated 2/18/16 by DJ - added params.demean=true, doFMs input

if ~exist('label1','var') || isempty(label1)
    label1='whiteNoise';
end
if ~exist('label0','var') || isempty(label0)
    label0='other';
end
if ~exist('useEcho2','var') || isempty(useEcho2)
    useEcho2=false;
end
if ~exist('doPerms','var') || isempty(doPerms)
    doPerms=true;
end
if ~exist('fracTcVarToKeep','var') || isempty(fracTcVarToKeep)
    fracTcVarToKeep=-1; % get elbow %0.9;
end
if ~exist('fracFcVarToKeep','var') || isempty(fracFcVarToKeep)
    fracFcVarToKeep=-1; % get elbow %0.7;
end
if ~exist('doFMs','var') || isempty(doFMs)
    doFMs=true; 
end

% subject=8;
% useEcho2=false;%true;
% doPerms=false;
if subject==6
    cd /Users/jangrawdc/Documents/PRJ03_SustainedAttention/Pilots/fMRI/S06_2015-12-17
    load('DistractionTask-6-QuickRun.mat')
    if useEcho2, load('SBJ06_FC_MultiEcho_2015-12-17-Craddock_ECHO2.mat');
    else load('SBJ06_FC_MultiEcho_2015-12-17-Craddock.mat'); 
    end   
    question = questions;
    question.pages_adj = question.qPages_cell;
    question.type = repmat({'reading'},size(question.pages_adj));
    isNotCensoredSample = true(1,size(tc,2));
elseif subject==7
    cd /Users/jangrawdc/Documents/PRJ03_SustainedAttention/Pilots/fMRI/S07_2015-12-18
    load('Distraction-7-QuickRun.mat')
    if useEcho2, load('SBJ07_FC_AfniProc_MultiEcho_2015-12-18_Craddock_ECHO2.mat');
    else load('SBJ07_FC_AfniProc_MultiEcho_2015-12-18_Craddock.mat');
    end
    question = questions;
    question.pages_adj = question.qPages_cell;
    question.type = repmat({'reading'},size(question.pages_adj));
    isNotCensoredSample = true(1,size(tc,2));
elseif subject==8
    cd /Users/jangrawdc/Documents/PRJ03_SustainedAttention/Pilots/fMRI/S08_2015-12-29
    load('Distraction-8-QuickRun-Video.mat')
    if useEcho2, load('SBJ08_FC_MultiEcho_2015-12-30_Craddock_ECHO2.mat');
    else load('SBJ08_FC_MultiEcho_2015-12-30_Craddock.mat');
    end    
    question = questions;
    question.pages_adj = question.qPages_cell;
    question.type = repmat({'reading'},size(question.pages_adj));
    isNotCensoredSample = true(1,size(tc,2));
else
    % Assume we're already in the subject's folder.
    load(sprintf('Distraction-%d-QuickRun.mat',subject));
    [~,tc] = Read_1D(sprintf('SBJ%02d_CraddockAtlas_200Rois_ts.1D',subject));
    tc = tc';
    [~,censorM] = Read_1D(sprintf('censor_SBJ%02d_combined_2.1D',subject));    
    isNotCensoredSample = censorM'>0;
    tc(:,~isNotCensoredSample) = nan;
    [err,atlas,atlasInfo,ErrMsg] = BrikLoad('/Users/jangrawdc/Documents/PRJ03_SustainedAttention/Pilots/fMRI/CraddockAtlas_200Rois+tlrc');
% elseif subject==9
%     cd /Users/jangrawdc/Documents/PRJ03_SustainedAttention/Pilots/fMRI/S09_2016-01-15
%     load('Distraction-9-QuickRun.mat')
%     if useEcho2, error('No Echo2 file for SBJ09 yet!');
%     else load('SBJ09_FC_MultiEcho_2016-01-19_Craddock.mat');
%     end
% elseif subject==10
%     cd /Users/jangrawdc/Documents/PRJ03_SustainedAttention/Pilots/fMRI/S10_2016-02-05
%     load('Distraction-10-QuickRun.mat')
%     if useEcho2, error('No Echo2 file for SBJ10 yet!');
%     else load('SBJ10_FC_MultiEcho_2016-02-05_Craddock.mat');
%     end
% elseif subject==11
%     cd /Users/jangrawdc/Documents/PRJ03_SustainedAttention/Pilots/fMRI/S11_2016-02-05
%     load('Distraction-11-QuickRun.mat')
%     if useEcho2, error('No Echo2 file for SBJ11 yet!');
%     else load('SBJ11_FC_MultiEcho_2016-02-05_Craddock.mat');
%     end
end
% normalize TC
for i=1:size(tc,1)
    tc(i,:) = (tc(i,:)-nanmean(tc(i,:)))/nanstd(tc(i,:));
end

%% Run PCA on tcs
% fracTcVarToKeep = 0.9;
[U,S,V] = svd(tc(:,isNotCensoredSample)');
fracVar = cumsum(diag(S).^2)/sum(diag(S).^2);
if fracTcVarToKeep<=0    
    fracTcVarToKeep = fracVar(getelbow(fracVar'));
    lastToKeep = find(fracVar<=fracTcVarToKeep,1,'last');
    fprintf('Found elbow at %d PCs (%.1f%% variance)\n',lastToKeep,fracTcVarToKeep*100)
else
    lastToKeep = find(fracVar<=fracTcVarToKeep,1,'last');
    fprintf('Keeping %d PCs (%.1f%% variance)\n',lastToKeep,fracTcVarToKeep*100)
end
tc2 = V(:,1:lastToKeep)'*tc; % multiply each weight vec by each FC vec


%% Get feature matrix
fcWinLength = 10;
tcWinLength = 8;
TR = 2;
nFirstRemoved = 3;
roiNames = {};
% if length(tc)<1000
%     fracFcVarToKeep = -1;%0.7;%size(tc2,1);
% else
%     fracFcVarToKeep = [];%0.7;
% end
[feats, featNames, labels, labelNames, times, timeNames, iTcEventSample, iFcEventSample] = ConstructComboFeatMatrix(data, stats, question, tc2, roiNames, fcWinLength, tcWinLength, TR, nFirstRemoved,fracFcVarToKeep);
fprintf('Done!\n');

%% Do classification
% declare params
params.regularize=1;
params.lambda=1e-6;
params.lambdasearch=true;
params.eigvalratio=1e-4;
params.vinit=zeros(size(feats,1)+1,1);
params.show=0;
params.LOO=true;
params.demean=true;
% remove nans
newFeats = feats;
for i=1:size(newFeats,1)
    newFeats(i,isnan(newFeats(i,:))) = nanmean(newFeats(i,:));
end
% normalize
normfeats = zeros(size(newFeats));
for i=1:size(newFeats,1)
    normfeats(i,:) = (newFeats(i,:)-nanmean(newFeats(i,:)))/nanstd(newFeats(i,:));
end
% Break down feats
isBoldFeat = strncmp('BOLD',featNames,4);
isFcFeat = strncmp('FC',featNames,2);
isEyeFeat = strncmp('EYE',featNames,3);
fprintf('%d BOLD, %d FC, %d EYE feats\n',sum(isBoldFeat),sum(isFcFeat),sum(isEyeFeat))

% Classify!
% label1 = 'ignoredSpeech';%
% label0 = 'attendedSpeech';%
truth = nan(1,size(labels,2));
iLabel1 = find(strcmp(labelNames,label1));
truth(labels(iLabel1,:)) = 1;
if strcmp(label0,'other')
    truth(~labels(iLabel1,:)) = 0;
else
    iLabel0 = find(strcmp(labelNames,label0));
    truth(labels(iLabel0,:)) = 0;
end
isOkTrial = ~isnan(truth);
% truth = labels(1,:);
% isOkTrial = true(size(truth));
[~,AzLoo_bold,LRstats_bold] = RunSingleLR(permute(normfeats(isBoldFeat,isOkTrial),[1 3 2]),truth(isOkTrial),params);
if sum(isFcFeat)>0
    [~,AzLoo_fc,LRstats_fc] = RunSingleLR(permute(normfeats(isFcFeat,isOkTrial),[1 3 2]),truth(isOkTrial),params);
else
    fprintf('No FC features... classifier can''t run!\n')
    AzLoo_fc = 0;
end
[~,AzLoo_eye,LRstats_eye] = RunSingleLR(permute(normfeats(isEyeFeat,isOkTrial),[1 3 2]),truth(isOkTrial),params);
[~,AzLoo_fmri,LRstats_fmri] = RunSingleLR(permute(normfeats(isBoldFeat | isFcFeat,isOkTrial),[1 3 2]),truth(isOkTrial),params);
[~,AzLoo_all,LRstats_all] = RunSingleLR(permute(normfeats(:,isOkTrial),[1 3 2]),truth(isOkTrial),params);

% Print results
fprintf('LOO Az: BOLD = %.3f, FC = %.3f, EYE = %.3f, FMRI = %.3f, ALL = %.3f\n',AzLoo_bold,AzLoo_fc,AzLoo_eye,AzLoo_fmri,AzLoo_all);

%% Get y for all trials
y_bold = mean(LRstats_bold.wtsLoo,2)'*[normfeats(isBoldFeat,:); ones(1,size(normfeats,2))];
y_bold(isOkTrial) = LRstats_bold.yLoo;
if sum(isFcFeat)>0
    y_fc = mean(LRstats_fc.wtsLoo,2)'*[normfeats(isFcFeat,:); ones(1,size(normfeats,2))];
    y_fc(isOkTrial) = LRstats_fc.yLoo;
else
    y_fc = zeros(size(y_bold));
end
y_eye = mean(LRstats_eye.wtsLoo,2)'*[normfeats(isEyeFeat,:); ones(1,size(normfeats,2))];
y_eye(isOkTrial) = LRstats_eye.yLoo;
y_fmri = mean(LRstats_fmri.wtsLoo,2)'*[normfeats(isBoldFeat | isFcFeat,:); ones(1,size(normfeats,2))];
y_fmri(isOkTrial) = LRstats_fmri.yLoo;
y_all = mean(LRstats_all.wtsLoo,2)'*[normfeats; ones(1,size(normfeats,2))];
y_all(isOkTrial) = LRstats_all.yLoo;

%% Plot results
% plot features
figure(415); clf;
subplot(231); cla;
imagesc([normfeats; labels]);
xlabel('time (TRs)');
ylabel('label | feature');
% set(gca,'ytick',1:(numel(featNames)+numel(labelNames)),'yticklabel',[featNames; labelNames]);
% draw rectangles
nTrials = numel(truth);
rectangle('Position',[0.5 0.5 nTrials sum(isBoldFeat)],'edgecolor','r');
rectangle('Position',[0.5 0.5+sum(isBoldFeat) nTrials sum(isFcFeat)],'edgecolor','g');
rectangle('Position',[0.5 0.5+sum(isBoldFeat | isFcFeat) nTrials sum(isEyeFeat)],'edgecolor','b');
rectangle('Position',[0.5 0.5+sum(isBoldFeat | isFcFeat | isEyeFeat) nTrials size(labels,1)],'edgecolor','c');
title(sprintf('SBJ%02d, Craddock Atlas, normalized features',subject));
colorbar

subplot(234); cla;
% outPlot = [LRstats_bold.yLoo; LRstats_fc.yLoo; LRstats_eye.yLoo; LRstats_all.yLoo];
outPlot = [y_bold; y_fc; y_eye; y_fmri; y_all];
outPlotTitles = {'BOLD feats','FC feats','Eye feats','All fMRI feats','All feats'}; 
outPlotAzs = [AzLoo_bold, AzLoo_fc, AzLoo_eye, AzLoo_fmri, AzLoo_all]; 
% normalize
for i=1:size(outPlot,1)
    outPlot(i,:) = (outPlot(i,:)-nanmean(outPlot(i,:)))/nanstd(outPlot(i,:));
end
plot([outPlot; truth]');
xlabel('time (TRs)');
ylabel('LOO y value')
legend([outPlotTitles, {'truth'}]);
title(sprintf('trained on %s > %s',label1,label0),'interpreter','none');

% middle: histograms
% right: Azs between all pairs
nLabels = numel(labelNames);
AzPairs = nan(nLabels,nLabels,size(outPlot,1));
for i=1:size(outPlot,1)
    for j=1:nLabels
        for k=j+1:nLabels
            p = [outPlot(i,labels(j,:)), outPlot(i,labels(k,:))];
            pLabel = [ones(1,sum(labels(j,:))), zeros(1,sum(labels(k,:)))];
            AzPairs(j,k,i) = rocarea(p,pLabel);
            AzPairs(k,j,i) = 1-AzPairs(j,k,i);
        end
        % this vs. other
        p = [outPlot(i,labels(j,:)), outPlot(i,~labels(j,:))];
        pLabel = [ones(1,sum(labels(j,:))), zeros(1,sum(~labels(j,:)))];
        AzPairs(j,j,i) = rocarea(p,pLabel);
        if AzPairs(j,j,i)<0.5, AzPairs(j,j,i) = 1-AzPairs(j,j,i); end
    end
end

xHist = linspace(-2,2,20);
nHist = zeros(nLabels,numel(xHist),size(outPlot,1));
for j=1:size(outPlot,1)
    for i=1:nLabels
        nHist(i,:,j) = hist(outPlot(j,labels(i,:)),xHist);
    end
    subplot(size(outPlot,1),3,3*j-1);
    plot(xHist,nHist(:,:,j));
    xlabel('LOO y value');
    ylabel('# trials');
    legend(labelNames);
    title(sprintf('%s: LOO Az = %.3f',outPlotTitles{j},outPlotAzs(j)));
    
    subplot(size(outPlot,1),3,3*j);
    imagesc(AzPairs(:,:,j));
    set(gca,'clim',[0.5, 1],'xtick',1:nLabels,'xticklabel',labelNames,'ytick',1:nLabels,'yticklabel',labelNames);
    title(sprintf('%s: label y>x Azs',outPlotTitles{j}));
    axis square;
    colorbar
    xticklabel_rotate([],45);
end
colormap jet

% FOR NFEATS CHECKS...
% y_true = outPlotAzs;
% y_perm = [sum(isBoldFeat), sum(isFcFeat), sum(isEyeFeat), sum(isBoldFeat | isFcFeat), sum(isBoldFeat | isFcFeat | isEyeFeat)];
% return; % JUST FOR NOW

%% make sure originals aren't overwritten by permutations
Az_true = outPlotAzs;
y_true = outPlot;
AzPairs_true = AzPairs;

%% Run permutations
nPerms = 100;
if doPerms    

    [Az_perm, y_perm, AzPairs_perm] = deal(cell(1,nPerms));
    for iPerm=1:nPerms
        fprintf('Perm %d/%d...\n',iPerm,nPerms);
        % permute truth
        permtruth = truth(isOkTrial);
        permtruth = permtruth(randperm(numel(permtruth)));
        % get results
        [~,AzLoo_bold,LRstats_bold] = RunSingleLR(permute(normfeats(isBoldFeat,isOkTrial),[1 3 2]),permtruth,params);
        [~,AzLoo_fc,LRstats_fc] = RunSingleLR(permute(normfeats(isFcFeat,isOkTrial),[1 3 2]),permtruth,params);
        [~,AzLoo_eye,LRstats_eye] = RunSingleLR(permute(normfeats(isEyeFeat,isOkTrial),[1 3 2]),permtruth,params);
        [~,AzLoo_fmri,LRstats_fmri] = RunSingleLR(permute(normfeats(isBoldFeat | isFcFeat,isOkTrial),[1 3 2]),permtruth,params);
        [~,AzLoo_all,LRstats_all] = RunSingleLR(permute(normfeats(:,isOkTrial),[1 3 2]),permtruth,params);

        % assemble
        y_bold = mean(LRstats_bold.wtsLoo,2)'*[normfeats(isBoldFeat,:); ones(1,size(normfeats,2))];
        y_bold(isOkTrial) = LRstats_bold.yLoo;
        y_fc = mean(LRstats_fc.wtsLoo,2)'*[normfeats(isFcFeat,:); ones(1,size(normfeats,2))];
        y_fc(isOkTrial) = LRstats_fc.yLoo;
        y_eye = mean(LRstats_eye.wtsLoo,2)'*[normfeats(isEyeFeat,:); ones(1,size(normfeats,2))];
        y_eye(isOkTrial) = LRstats_eye.yLoo;
        y_fmri = mean(LRstats_fmri.wtsLoo,2)'*[normfeats(isBoldFeat | isFcFeat,:); ones(1,size(normfeats,2))];
        y_fmri(isOkTrial) = LRstats_fmri.yLoo;
        y_all = mean(LRstats_all.wtsLoo,2)'*[normfeats; ones(1,size(normfeats,2))];
        y_all(isOkTrial) = LRstats_all.yLoo;
        outPlot = [y_bold; y_fc; y_eye; y_fmri; y_all];
        outPlotAzs = [AzLoo_bold, AzLoo_fc, AzLoo_eye, AzLoo_fmri, AzLoo_all]; 

        % get Az for every pair
        AzPairs = nan(nLabels,nLabels,size(outPlot,1));
        for i=1:size(outPlot,1)
            for j=1:nLabels
                for k=j+1:nLabels
                    p = [outPlot(i,labels(j,:)), outPlot(i,labels(k,:))];
                    pLabel = [ones(1,sum(labels(j,:))), zeros(1,sum(labels(k,:)))];
                    AzPairs(j,k,i) = rocarea(p,pLabel);
                    AzPairs(k,j,i) = 1-AzPairs(j,k,i);
                end
                % this vs. other
                p = [outPlot(i,labels(j,:)), outPlot(i,~labels(j,:))];
                pLabel = [ones(1,sum(labels(j,:))), zeros(1,sum(~labels(j,:)))];
                AzPairs(j,j,i) = rocarea(p,pLabel);
                if AzPairs(j,j,i)<0.5, AzPairs(j,j,i) = 1-AzPairs(j,j,i); end
            end
        end       
        
        % assemble
        Az_perm{iPerm} = outPlotAzs;
        y_perm{iPerm} = outPlot;
        AzPairs_perm{iPerm} = AzPairs;

    end
    fprintf('Done!\n')
    %% SAVE!
    save(sprintf('SBJ%02d_MultimodalClassifier_%s-%s_%s',subject,label1,label0,datestr(now,'YYYY-mm-DD')),'Az_true','y_true','AzPairs_true','Az_perm','y_perm','AzPairs_perm','subject','fcWinLength','TR','nFirstRemoved','fracTcVarToKeep','fracFcVarToKeep','labels','labelNames','label0','label1');

    %% Get permutation significance
    % turn into matrices (4th dimension = permutations)
    Az_perm_mat = cat(4,Az_perm{:});
    y_perm_mat = cat(4,y_perm{:});
    AzPairs_perm_mat = cat(4,AzPairs_perm{:});

    % for each Az value, get # of permutations that exceed it
    p_Az_true = nan(size(Az_true));
    for i=1:numel(Az_true)
        p_Az_true(i) = mean(Az_perm_mat(:,i,:,:)>Az_true(i),4);
    end
    p_AzPairs_true = nan(size(AzPairs_true));
    for i=1:size(AzPairs_true,1);
        for j=1:size(AzPairs_true,2);
            for k=1:size(AzPairs_true,3);
                p_AzPairs_true(i,j,k) = mean(AzPairs_perm_mat(i,j,k,:)>AzPairs_true(i,j,k),4);
            end
        end
    end

    figure(416); clf;
    subplot(1,size(p_AzPairs_true,3)+1,1); hold on;
    bar(p_Az_true);
    set(gca,'xtick',1:numel(p_Az_true),'xticklabel',outPlotTitles);
    ylabel('permutation p value')
    title(sprintf('SBJ%02d, trained on %s > %s',subject,label1,label0))
    PlotHorizontalLines(0.05,'r--');
    axis square; % to match the others
    xticklabel_rotate;
    for i=1:size(p_AzPairs_true,3)
        subplot(1,size(p_AzPairs_true,3)+1,i+1);
        imagesc(p_AzPairs_true(:,:,i));
        set(gca,'clim',[0 0.05],'xtick',1:nLabels,'xticklabel',labelNames,'ytick',1:nLabels,'yticklabel',labelNames);
        title(sprintf('%s: label y>x Azs',outPlotTitles{i}));
        axis square;
        colorbar
        xticklabel_rotate;
    end
    colormap jet
else   
    % SAVE!
    save(sprintf('SBJ%02d_MultimodalClassifier_%s-%s_%s',subject,label1,label0,datestr(now,'YYYY-mm-DD')),'Az_true','y_true','AzPairs_true','subject','fcWinLength','TR','nFirstRemoved','fracTcVarToKeep','fracFcVarToKeep','label0','label1');    
    y_perm_mat = nan(5,size(y_true,2),1,nPerms);
end

if doFMs
    %% Set up forward models
    fmType = 'Each'; %'Multimodal'; %'FC';%'Eye'; %

    %% Plot BOLD forward models
    % get fwd model
    isOkSample = ~isnan(iTcEventSample);
    isOkSample(isOkSample) = isNotCensoredSample(iTcEventSample(isOkSample)); 
    X_bold = tc(:,iTcEventSample(isOkSample));
    switch fmType
        case 'Multimodal'
            y_bold = y_true(5,isOkSample);
            y_bold_perm = squeeze(y_perm_mat(5,isOkSample,:,:));
            bigTitle = sprintf('SBJ%02d BOLD FwdModels (%s-%s, multimodal classifier)',subject,label1,label0);
        case 'FC'
            y_bold = y_true(2,isOkSample);
            y_bold_perm = squeeze(y_perm_mat(2,isOkSample,:,:));
            bigTitle = sprintf('SBJ%02d BOLD FwdModels (%s-%s, FC classifier)',subject,label1,label0);
        case 'Eye'
            y_bold = y_true(3,isOkSample);
            y_bold_perm = squeeze(y_perm_mat(3,isOkSample,:,:));
            bigTitle = sprintf('SBJ%02d BOLD FwdModels (%s-%s, eye classifier)',subject,label1,label0);
        otherwise
            y_bold = y_true(1,isOkSample);
            y_bold_perm = squeeze(y_perm_mat(1,isOkSample,:,:));
            bigTitle = sprintf('SBJ%02d BOLD FwdModels (%s-%s)',subject,label1,label0);
    end
    FwdModel_bold = y_bold' \ X_bold'; %(X_bold'y_true)*(X_bold'*X_bold)^-1
    % get FM for perms
    FwdModel_bold_perm = y_bold_perm \ X_bold';

    % plot fwd model
    dataOut = MapValuesOntoAtlas(atlas,FwdModel_bold);
    figure(599); clf;
    dim = 1;
    iSlices = round(linspace(1,size(atlas,dim),11));
    iSlices = iSlices(2:end-1);
    DisplaySlices(dataOut,dim,iSlices,[],[-.2 .2]);
    colormap jet
    MakeFigureTitle(bigTitle);

    %% Plot FC fwd models
    % (re)calculate FC
    FC = GetFcMatrices(tc,'sw',fcWinLength);
    % get fwd model
    isOkSample = ~isnan(iFcEventSample);
    isOkSample(isOkSample) = isNotCensoredSample(iFcEventSample(isOkSample));
    X_fc = FC(:,:,iFcEventSample(isOkSample));
    switch fmType
        case 'Multimodal'
            y_fc = y_true(5,isOkSample);
            y_fc_perm = squeeze(y_perm_mat(5,isOkSample,:,:));
            bigTitle = sprintf('SBJ%02d FC FwdModels (%s-%s, multimodal classifier)',subject,label1,label0);
        case 'FC'
            y_fc = y_true(2,isOkSample);
            y_fc_perm = squeeze(y_perm_mat(2,isOkSample,:,:));
            bigTitle = sprintf('SBJ%02d FC FwdModels (%s-%s, FC classifier)',subject,label1,label0);
        case 'Eye'
            y_fc = y_true(3,isOkSample);
            y_fc_perm = squeeze(y_perm_mat(3,isOkSample,:,:));
            bigTitle = sprintf('SBJ%02d FC FwdModels (%s-%s, eye classifier)',subject,label1,label0);
        otherwise
            y_fc = y_true(2,isOkSample);
            y_fc_perm = squeeze(y_perm_mat(2,isOkSample,:,:));
            bigTitle = sprintf('SBJ%02d FC FwdModels (%s-%s)',subject,label1,label0);
    end
    FwdModel_fc = nan(size(FC,1),size(FC,2));
    FwdModel_fc_perm = nan(nPerms,size(FC,2),size(FC,1));
    for i=1:size(X_fc,1)
        FwdModel_fc(i,:) = y_fc' \ squeeze(X_fc(i,:,:))';
        % get FM for perms
        FwdModel_fc_perm(:,:,i) = y_fc_perm \ squeeze(X_fc(i,:,:))';
    end
    % put perms in 3rd dimension
    FwdModel_fc_perm = permute(FwdModel_fc_perm,[3 2 1]);

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

    %% Plot eye position forward models

    % get fwd model
    isOkSample = true(1,size(normfeats,2));
    X_eye = normfeats(isEyeFeat,isOkSample);
    switch fmType
        case 'Multimodal'
            y_eye = y_true(5,isOkSample);
            y_eye_perm = squeeze(y_perm_mat(5,isOkSample,:,:));
            bigTitle = sprintf('SBJ%02d Eye FwdModels (%s-%s, multimodal classifier)',subject,label1,label0);
        case 'FC'
            y_eye = y_true(2,isOkSample);
            y_eye_perm = squeeze(y_perm_mat(2,isOkSample,:,:));
            bigTitle = sprintf('SBJ%02d Eye FwdModels (%s-%s, FC classifier)',subject,label1,label0);
        case 'Eye'
            y_eye = y_true(3,isOkSample);
            y_eye_perm = squeeze(y_perm_mat(3,isOkSample,:,:));
            bigTitle = sprintf('SBJ%02d Eye FwdModels (%s-%s, eye classifier)',subject,label1,label0);
        otherwise
            y_eye = y_true(3,isOkSample);
            y_eye_perm = squeeze(y_perm_mat(3,isOkSample,:,:));
            bigTitle = sprintf('SBJ%02d Eye FwdModels (%s-%s)',subject,label1,label0);
    end

    FwdModel_eye = y_eye' \ X_eye'; %(X_bold'y_true)*(X_bold'*X_bold)^-1
    % get FM for perms
    FwdModel_eye_perm = y_eye_perm \ X_eye';

    % get feature names
    eyeLabels = featNames(isEyeFeat);
    for i=1:numel(eyeLabels)
        eyeLabels{i} = eyeLabels{i}(5:end-1);
    end

    % plot fwd model
    figure(601); clf;
    bar(FwdModel_eye);
    set(gca,'xtick',1:numel(eyeLabels),'xticklabel',eyeLabels);
    ylabel('Fwd Model');
    title(bigTitle);
    xticklabel_rotate([],45);

    %% Save results
    save(sprintf('SBJ%02d_MultimodalFwdModels_%s-%s_%s',subject,label1,label0,datestr(now,'YYYY-mm-DD')),'FwdModel_fc','FwdModel_bold','FwdModel_eye','FwdModel_fc_perm','FwdModel_bold_perm','FwdModel_eye_perm');

end
