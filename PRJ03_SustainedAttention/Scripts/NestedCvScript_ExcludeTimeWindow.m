% NestedCvScript_ExcludeTimeWindow.m
%
% Created 6/16 by DJ (in a hurry for OHBM).
% Updated 7/7/16 by DJ - header.
% Updated 7/13/16 by DJ - added subjects 31-36

% subjects = [9:22 24:30];
subjects = [9:11,13:19];%,22,24:25,28,30:34,36];
separationTimes = 60;%0:20:200; %0:5:125;%0:20:260; % 60;%
nSubj = numel(subjects);
nSepTim = numel(separationTimes);
[AzCv_FC, AzCv_mag] = deal(nan(nSepTim,nSubj));
[fwdModelCv_FC, fwdModelCv_mag] = deal([]);
[statsCv_FC, statsCv_mag,statsCv_FC_perms, statsCv_mag_perms] = deal(cell(1,nSubj));
clear newParams*
inputParams = struct('label1','ignoredSpeech','label0','attendedSpeech');
% inputParams = struct('label1','whiteNoise','label0','other');
% inputParams = struct('label1','ignoredSpeech','label0','other');
inputParams.atlasType = 'Craddock';% 'AllSpheresNoOverlap-scaled'; %
inputParams.fracMagVarToKeep = .9;%1;
inputParams.fracFcVarToKeep = .7;%1;%.9;%0.7; 
inputParams.nPerms = 0;%100;%
inputParams.doPlot = false;
% inputParams.doRandTc = true;
% inputParams.doRandFc = true;
% inputParams.doMagPca = false;
% inputParams.tcNormOption = 'none';
% inputParams.magNormOption = 'none';
% inputParams.fcNormOption = 'none';
inputParams.doBalancedTrainingSet = true;
% inputParams.fcWinLength = 30;

% declare perms variables
[AzCv_FC_perms, AzCv_mag_perms] = deal(nan(nSepTim,inputParams.nPerms,nSubj));
[fwdModelCv_FC_perms, fwdModelCv_mag_perms] = deal([]);

% set up plot
% figure(110); clf;
% figure(111); clf;
% nRows = ceil(sqrt(nSubj));
% nCols = ceil(nSubj/nRows);
%% Classify

for i=1:nSubj
%     figure(110);
%     subplot(nRows,nCols,i);
    [AzCv_mag(:,i), fwdModelCv_mag(:,:,i), statsCv_mag{i}, newParams_mag(i), AzCv_mag_perms(:,:,i), fwdModelCv_mag_perms(:,:,:,i), statsCv_mag_perms{i}] = ClassifySubject_Mag_ExcludeTimeWindow(subjects(i),separationTimes,inputParams);
%     [AzCv_mag(:,i), fwdModelCv_mag(:,:,i), statsCv_mag{i}, newParams_mag(i), AzCv_mag_perms(:,:,i), fwdModelCv_mag_perms(:,:,:,i), statsCv_mag_perms{i}] = ClassifySubject_Mag_LORO(subjects(i),inputParams);
%     legend('');
%     figure(111);
%     subplot(nRows,nCols,i);
    [AzCv_FC(:,i), fwdModelCv_FC(:,:,i), statsCv_FC{i}, newParams_FC(i), AzCv_FC_perms(:,:,i), fwdModelCv_FC_perms(:,:,:,i), statsCv_FC_perms{i}] = ClassifySubject_FC_ExcludeTimeWindow(subjects(i),separationTimes,inputParams);
%     [AzCv_FC(:,i), fwdModelCv_FC(:,:,i), statsCv_FC{i}, newParams_FC(i), AzCv_FC_perms(:,:,i), fwdModelCv_FC_perms(:,:,:,i), statsCv_FC_perms{i}] = ClassifySubject_FC_LORO(subjects(i),inputParams);
%     legend('');
%     drawnow;
end
%% put legend on final plot
% figure(110);
% legend('AUC','frac training trials left','frac trials in same run','frac trials in same run & condition','median time between events','mean condition length','mean run length')
% MakeFigureTitle(sprintf('%s > %s, Mag features',newParams_mag(1).label1,newParams_mag(1).label0));
% 
% figure(111);
% % legend('AUC','frac training trials left','frac trials in same run','frac trials in same run & condition','median time between events','mean condition length','mean run length')
% legend('AUC','frac training trials left','frac trials in same run','frac trials in same run & condition','median time between events','frac training trials in category','mean condition length','mean run length')
% 
% MakeFigureTitle(sprintf('%s > %s, FC features',newParams_FC(1).label1,newParams_FC(1).label0));

%% SAVE RESULTS
cd /data/jangrawdc/PRJ03_SustainedAttention/Results
filename = sprintf('Distraction_ExcludeTime_S%d-%d_%s-%s_NewBehTiming.mat',subjects(1),subjects(end),newParams_mag(1).label1,newParams_mag(1).label0);
fprintf('Saving results as %s...\n',filename);
% save(filename,'AzCv_mag','fwdModelCv_mag','statsCv_mag','newParams_mag','AzCv_FC','fwdModelCv_FC','statsCv_FC','newParams_FC','subjects','separationTimes','inputParams');
save(filename,'AzCv_mag','fwdModelCv_mag','newParams_mag','AzCv_FC','fwdModelCv_FC','newParams_FC','subjects','separationTimes','inputParams','AzCv_mag_perms','fwdModelCv_mag_perms');
fprintf('Done!\n');

%% Compile results
subjStr = cell(1,nSubj);
for i=1:nSubj
    subjStr{i} = sprintf('SBJ%02d',subjects(i));
end
badSubj = [12, 20, 21, 26, 27, 29, 35];
iOkSubj = find(~ismember(subjects,badSubj));
figure(212); clf;
% Plot mag version
subplot(121); hold on;
plot(separationTimes*newParams_mag(1).TR, AzCv_mag(:,iOkSubj), '.-');
plot(separationTimes*newParams_mag(1).TR, mean(AzCv_mag(:,iOkSubj),2),'.-','linewidth',2);
PlotHorizontalLines(0.5,'k:');
legend([subjStr(iOkSubj), {'mean','chance'}])
xlabel('event times excluded from training set (s)')
ylabel('Cross-validated AUC');
title(sprintf('%s > %s, Mag features, VarKept=(%.2f,%.2f)',newParams_mag(1).label1,newParams_mag(1).label0,newParams_mag(1).fracMagVarToKeep,newParams_mag(1).fracFcVarToKeep));

subplot(122); hold on;
plot(separationTimes*newParams_mag(1).TR, AzCv_FC(:,iOkSubj), '.-');
plot(separationTimes*newParams_mag(1).TR, mean(AzCv_FC(:,iOkSubj),2),'.-','linewidth',2);
PlotHorizontalLines(0.5,'k:');
legend([subjStr(iOkSubj), {'mean','chance'}])
xlabel('event times excluded from training set (s)')
ylabel('Cross-validated AUC');
title(sprintf('%s > %s, FC features, VarKept=(%.2f,%.2f)',newParams_mag(1).label1,newParams_mag(1).label0,newParams_mag(1).fracMagVarToKeep,newParams_mag(1).fracFcVarToKeep));
linkaxes([subplot(121),subplot(122)]);
ylim([.3 1]);

%% Select best separation time and extract it.
AzCv_mag_okSubj = AzCv_mag(:,iOkSubj);
AzCv_FC_okSubj = AzCv_FC(:,iOkSubj);
nOkSubj = numel(iOkSubj);
AzCv_mag_okSubj_perms = AzCv_mag_perms(:,:,iOkSubj);
AzCv_FC_okSubj_perms = AzCv_FC_perms(:,:,iOkSubj);

% % Nested CV: use LOSO to select each subject's sepTime.
% [iBestSepTime_mag, AzCv_mag_okSubj_best, iBestSepTime_FC, AzCv_FC_okSubj_best] = deal(nan(1,nOkSubj));
% for i=1:nOkSubj
%     AzCv_mag_meanOthers = mean(AzCv_mag_okSubj(:, [1:(i-1), (i+1):end]),2);
%     [~,iBestSepTime_mag(i)] = max(AzCv_mag_meanOthers(2:end));
%     iBestSepTime_mag(i) = iBestSepTime_mag(i)+1;
%     AzCv_mag_okSubj_best(i) = AzCv_mag_okSubj(iBestSepTime_mag(i),i);
%     
%     AzCv_FC_meanOthers = mean(AzCv_FC_okSubj(:, [1:(i-1), (i+1):end]),2);
%     [~,iBestSepTime_FC(i)] = max(AzCv_FC_meanOthers(2:end));
%     iBestSepTime_FC(i) = iBestSepTime_FC(i)+1;
%     AzCv_FC_okSubj_best(i) = AzCv_FC_okSubj(iBestSepTime_FC(i),i);
% end

% OR: just declare a "best" separation time
iBestSepTime = 1;
AzCv_mag_okSubj_best = AzCv_mag_okSubj(iBestSepTime,:);
AzCv_FC_okSubj_best = AzCv_FC_okSubj(iBestSepTime,:);
[iBestSepTime_mag, iBestSepTime_FC] = deal(repmat(iBestSepTime,1,nOkSubj));

% Do same with permutations
AzCv_mag_okSubj_perms_best = AzCv_mag_okSubj_perms(iBestSepTime,:,:);
AzCv_FC_okSubj_perms_best = AzCv_FC_okSubj_perms(iBestSepTime,:,:);
AzCv_mag_okSubj_perms_best_mean = mean(AzCv_mag_okSubj_perms_best,3);
AzCv_FC_okSubj_perms_best_mean = mean(AzCv_FC_okSubj_perms_best,3);

AzCv_mag_okSubj_best_mean = mean(AzCv_mag_okSubj_best);
AzCv_mag_okSubj_best_ste = std(AzCv_mag_okSubj_best)/sqrt(nOkSubj);
AzCv_FC_okSubj_best_mean = mean(AzCv_FC_okSubj_best);
AzCv_FC_okSubj_best_ste = std(AzCv_FC_okSubj_best)/sqrt(nOkSubj);

% Plot results
figure(118); clf; hold on;
bar([AzCv_mag_okSubj_best,AzCv_mag_okSubj_best_mean; AzCv_FC_okSubj_best,AzCv_FC_okSubj_best_mean]')
set(gca,'xtick',1:(nOkSubj+1),'xticklabel',[subjStr(iOkSubj), {'Mean'}])
errorbar(nOkSubj+0.875,AzCv_mag_okSubj_best_mean,AzCv_mag_okSubj_best_ste,'k.');
errorbar(nOkSubj+1.125,AzCv_FC_okSubj_best_mean,AzCv_FC_okSubj_best_ste,'k.');
PlotHorizontalLines(0.5,'k:');
xlim([0 nSubj+2]);
% add stars
fracPermsToExceed = 1.0;
for i=1:nOkSubj
    if mean(AzCv_mag_okSubj_best(i)>AzCv_mag_okSubj_perms_best(:,:,i))>=fracPermsToExceed
        plot(i-.125,AzCv_mag_okSubj_best(i)+0.03,'k*');
    end
    if mean(AzCv_FC_okSubj_best(i)>AzCv_FC_okSubj_perms_best(:,:,i))>=fracPermsToExceed
        plot(i+.125,AzCv_FC_okSubj_best(i)+0.03,'k*');
    end
end
if mean(AzCv_mag_okSubj_best_mean>AzCv_mag_okSubj_perms_best_mean)>=fracPermsToExceed
    plot(nOkSubj+0.875,AzCv_mag_okSubj_best_mean+0.075,'k*');
end
if mean(AzCv_FC_okSubj_best_mean>AzCv_FC_okSubj_perms_best_mean)>=fracPermsToExceed
    plot(nOkSubj+1.125,AzCv_FC_okSubj_best_mean+0.075,'k*');
end
% Annotate plot
xlabel('subject');
ylabel('Cross-validated AUC');
legend('Mag feats','FC feats');
grid on;
title(sprintf('%s > %s, VarKept=(%.2f,%.2f)',newParams_mag(1).label1,newParams_mag(1).label0,newParams_mag(1).fracMagVarToKeep,newParams_mag(1).fracFcVarToKeep));
set(gcf,'Position',[63 497 1139 379])
ylim([0 1])

%% Forward Models
FMs_mag_okSubj = fwdModelCv_mag(:,:,iOkSubj);
FMs_FC_okSubj = fwdModelCv_FC(:,:,iOkSubj);
% permutation tests
FMs_mag_okSubj_perms = fwdModelCv_mag_perms(:,:,:,iOkSubj);
FMs_FC_okSubj_perms = fwdModelCv_FC_perms(:,:,:,iOkSubj);
nPerms = size(AzCv_mag_perms,2);
switch newParams_mag(1).atlasType
    case {'Craddock','Craddock_e2'}
        nROIs = 200;
    case 'Shen'
        nROIs = 268;
    case 'AllSpheresNoOverlap'
        nROIs = 33;
    otherwise
        error('Atlas type not recognized!')
end
% Extract FMs from version with "best" separation times
FMs_mag_okSubj_best = nan(nROIs,nOkSubj);
FMs_FC_okSubj_best = nan(nROIs,nROIs,nOkSubj);
FMs_mag_okSubj_perms_best = nan(nROIs,nPerms,nOkSubj);
FMs_FC_okSubj_perms_best = nan(nROIs,nROIs,nPerms,nOkSubj);
for i=1:nOkSubj
    fprintf('Subject %d/%d...\n',i,nOkSubj);
    FMs_mag_okSubj_best(:,i) = FMs_mag_okSubj(iBestSepTime_mag(i),:,i)';
    
    FMs_FC_okSubj_best_1dmat = FMs_FC_okSubj(iBestSepTime_FC(i),:,i)';
    FMs_FC_okSubj_best_2dmat = UnvectorizeFc(FMs_FC_okSubj_best_1dmat,NaN);
    % Normalize
%     FMs_FC_okSubj_best(:,:,i) = (FMs_FC_okSubj_best_2dmat-nanmean(FMs_FC_okSubj_best_2dmat(:)))/nanstd(FMs_FC_okSubj_best_2dmat(:));
    % Don't normalize    
    FMs_FC_okSubj_best(:,:,i) = FMs_FC_okSubj_best_2dmat;
    
    % Do same with perm tests
    FMs_mag_okSubj_perms_best(:,:,i) = squeeze(FMs_mag_okSubj_perms(iBestSepTime_mag(i),:,:,i));
    
    FMs_FC_okSubj_perms_best_2dmat = squeeze(FMs_FC_okSubj_perms(iBestSepTime_FC(i),:,:,i));
    FMs_FC_okSubj_perms_best_3dmat = UnvectorizeFc(FMs_FC_okSubj_perms_best_2dmat,NaN);
    % Normalize
%     for j=1:nPerms
%         FM_this = FMs_FC_okSubj_perms_best_3dmat(:,:,j);
%         FMs_FC_okSubj_perms_best(:,:,j,i) = (FM_this-nanmean(FM_this(:)))/nanstd(FM_this(:));
%     end
    % Don't normalize
    FMs_FC_okSubj_perms_best(:,:,:,i) = FMs_FC_okSubj_perms_best_3dmat;

end

%% Mag: Take median and sort
FMs_mag_okSubj_best_median = nanmedian(FMs_mag_okSubj_best,2);
[~, order] = sort(FMs_mag_okSubj_best_median);
FMs_mag_okSubj_best_sorted = FMs_mag_okSubj_best(order,:);
subjStr_okSubj = subjStr(iOkSubj);

% Get fraction of perms each exceeds
% fracPermsExceeded_mag = nan(nROIs,nOkSubj);
% for i=1:nOkSubj
%     for j=1:nROIs
%         fracPermsExceeded_mag(j,i) = mean(abs(FMs_mag_okSubj_best(j,i))>abs(FMs_mag_okSubj_perms_best(j,:,i)));
%     end
% end
fracPermsExceeded_mag_median = nan(nROIs,1);
FMs_mag_okSubj_perms_best_median = nanmedian(FMs_mag_okSubj_perms_best,3);
for j=1:nROIs
    fracPermsExceeded_mag_median(j) = mean(abs(FMs_mag_okSubj_best_median(j))>abs(FMs_mag_okSubj_perms_best_median(j,:)));
end
% Plot mag
figure(114); clf;
hold on;
plot(FMs_mag_okSubj_best_sorted);
plot(mean(FMs_mag_okSubj_best_sorted,2),'linewidth',2);
xlabel('ROI');
ylabel('FwdModel');
title(sprintf('Mean across %d subjects',nOkSubj));
legend([subjStr_okSubj, {'Mean'}]);

%% FC FMs: Take mean and sort
clim = [-1 1]*.02;
% clim = [-1 1]*2;
FMs_FC_okSubj_best_roiMean = nanmean(FMs_FC_okSubj_best,2);
FMs_FC_okSubj_best_roiMean_median = median(FMs_FC_okSubj_best_roiMean,3);

[~, order] = sort(FMs_FC_okSubj_best_roiMean_median);
FMs_FC_okSubj_best_sorted = FMs_FC_okSubj_best(order,order,:);

% Get fraction of perms each exceeds
% fracPermsExceeded_FC = nan(nROIs,nOkSubj);
% for i=1:nOkSubj
%     for j=1:nROIs
%         for k=1:nROIs
%             fracPermsExceeded_FC(j,k,i) = mean(abs(FMs_FC_okSubj_best(j,k,i))>abs(FMs_FC_okSubj_perms_best(j,k,:,i)));
%         end
%     end
% end
fracPermsExceeded_FC_roiMean_median = nan(1,nROIs);
FMs_FC_okSubj_perms_best_roiMean = nanmean(FMs_FC_okSubj_perms_best,2);
FMs_FC_okSubj_perms_best_roiMean_median = squeeze(nanmedian(FMs_FC_okSubj_perms_best_roiMean,4));
for j=1:nROIs
    fracPermsExceeded_FC_roiMean_median(j) = mean(abs(FMs_FC_okSubj_best_roiMean_median(j))>abs(FMs_FC_okSubj_perms_best_roiMean_median(j,:)));
end


% Plot results
figure(115); clf;
nRows = ceil(sqrt(nOkSubj+1));
nCols = ceil((nOkSubj+1)/nRows);
subjStr_okSubj = subjStr(iOkSubj);
subplot(nRows,nCols,1);
imagesc(mean(FMs_FC_okSubj_best_sorted,3));
set(gca,'clim',clim/2);
colorbar
xlabel('ROI');
ylabel('ROI');
title(sprintf('Mean across %d subjects',nOkSubj));
for i=1:nOkSubj
    subplot(nRows,nCols,i+1);
    imagesc(FMs_FC_okSubj_best_sorted(:,:,i));
    set(gca,'clim',clim);
    colorbar
    xlabel('ROI');
    ylabel('ROI');
    title(subjStr_okSubj{i});
end
colormap jet

%% Visualization
switch newParams_mag(1).atlasType
    case {'Craddock','Craddock_e2'}
        [atlas,atlasInfo] = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/craddock_2011_parcellations/CraddockAtlas_200Rois+tlrc');
    case 'Shen'
        [atlas,atlasInfo] = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_1mm_268_parcellation+tlrc');
    case 'AllSpheresNoOverlap'
        [atlas,atlasInfo] = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/MasksFromMerage/SphericalSeeds/AllSpheresNoOverlap+tlrc');
    otherwise
        error('Atlas type not recognized!')
end
% foo = nanmean(FMs_mag_okSubj_best,2);
% foo(fracPermsExceeded_mag_median<1) = 0;
foo = FMs_FC_okSubj_best_roiMean_median;
foo(fracPermsExceeded_FC_roiMean_median<1) = 0;

% foo = FMs_FC_okSubj_best_median_roiMean;
% foo(fracPermsExceeded_FC_median_roiMean<1) = 0;

% foo = foo-mean(foo);
foo = foo/nanmax(abs(foo));
GUI_3View(MapColorsOntoAtlas(atlas,cat(2,foo.*(foo>0),(1:nROIs)'/nROIs,-foo.*(foo<0))));
% clear foo

%% Save Mag FMs as AFNI Brick
cd /data/jangrawdc/PRJ03_SustainedAttention/Results
filename = sprintf('Distraction_Exclude120s_S%d-%d_%s-%s_MagFwdModels',subjects(1),subjects(end),newParams_mag(1).label1,newParams_mag(1).label0);
fprintf('Saving results as %s...\n',filename);

atlasInfo.BRICK_TYPES = [3 3];
atlasInfo.BRICK_STATS = [min(FMs_mag_okSubj_best_median(:)), max(FMs_mag_okSubj_best_median(:)); ...
    min(fracPermsExceeded_mag_median*100), max(fracPermsExceeded_mag_median*100)];
atlasInfo.BRICK_LABS = 'subjMedian_MagFwdModel~PctPermsBelow';

Opt.Prefix=filename;
Opt.OverWrite='y';

brick1 = MapValuesOntoAtlas(atlas,FMs_mag_okSubj_best_median);
brick2 = MapValuesOntoAtlas(atlas,fracPermsExceeded_mag_median*100);
brick1(isnan(brick1)) = 0;
brick2(isnan(brick2)) = 0;
WriteBrik(cat(4,brick1,brick2),atlasInfo,Opt);
fprintf('Done!\n');

%% Save FC FMs as AFNI Brick
cd /data/jangrawdc/PRJ03_SustainedAttention/Results
filename = sprintf('Distraction_Exclude120s_S%d-%d_%s-%s_MedianFcFwdModels',subjects(1),subjects(end),newParams_mag(1).label1,newParams_mag(1).label0);
fprintf('Saving results as %s...\n',filename);

atlasInfo.BRICK_TYPES = [3 3];
atlasInfo.BRICK_STATS = [min(FMs_FC_okSubj_best_roiMean_median(:)), max(FMs_FC_okSubj_best_roiMean_median(:)); ...
    min(fracPermsExceeded_FC_roiMean_median*100), max(fracPermsExceeded_FC_roiMean_median*100)];
atlasInfo.BRICK_LABS = 'roiMean_subjMedian_FcFwdModel~PctPermsBelow';

Opt.Prefix=filename;
Opt.OverWrite='y';

brick1 = MapValuesOntoAtlas(atlas,FMs_FC_okSubj_best_roiMean_median);
brick2 = MapValuesOntoAtlas(atlas,fracPermsExceeded_FC_roiMean_median*100);
brick1(isnan(brick1)) = 0;
brick2(isnan(brick2)) = 0;
WriteBrik(cat(4,brick1,brick2),atlasInfo,Opt);
fprintf('Done!\n');
