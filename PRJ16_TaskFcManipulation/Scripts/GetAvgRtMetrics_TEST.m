% GetAvgRtMetrics_TEST.m
%
% Compare Avg RT metrics calculated by me to that calculated by Haskins
% 
% Created 9/22/17 by DJ.

%% Load
cd /gpfs/gsfs5/users/jangrawdc/PRJ16_TaskFcManipulation/Behavioral
filename = 'SRTT-Behavior_A182SRTTdata_25Jan2017.xlsx';
options = {'filetype','spreadsheet', ...
'ReadVariableNames',true, ...
'ReadRowNames',false, ...
'TreatAsEmpty','.', ...
'Sheet','SRTTrawdata'};
trialBehTable = readtable(filename,options{:});

behTable = ReadSrttBehXlsFile(filename);

%% Get PC/RT
subjects = unique(trialBehTable.Subject);
nSubj = numel(subjects);
[RT_corr_Uns, RT_corr_Str, RT_all_Uns, RT_all_Str, PC_Uns, PC_Str] = deal(nan(3,4,nSubj)); 
[RT_corr_run,RT_all_run, PC_run] = deal(nan(3,nSubj)); 
[RT_corr_subj,RT_all_subj, PC_subj] = deal(nan(nSubj,1)); 
for iSubj = 1:nSubj
    trialBehThis = trialBehTable(trialBehTable.Subject==subjects(iSubj),:);
    isCorrect = trialBehThis.Target_ACC==1;
    isErr = trialBehThis.Target_ACC== 0 & trialBehThis.Target_RT~=0;
    isMissing = trialBehThis.Target_RT==0;
    
    isTooFast = trialBehThis.Target_RT<=200;
    isOutlierRt = trialBehThis.Target_RT>(nanmean(trialBehThis.Target_RT)+3*nanstd(trialBehThis.Target_RT)) | ...
        trialBehThis.Target_RT<(nanmean(trialBehThis.Target_RT)-3*nanstd(trialBehThis.Target_RT));
    
    if any((isCorrect & ~isTooFast)~= (~isnan(trialBehThis.RTclean)))
        fprintf('subj %d\n',subjects(iSubj));
    end
    for iRun = 1:3
        for iBlock = 1:4
            isThis_Uns = (trialBehThis.Session==iRun & trialBehThis.Epoch1==iBlock & trialBehThis.Cond==1); 
            isThis_Str = (trialBehThis.Session==iRun & trialBehThis.Epoch1==iBlock & trialBehThis.Cond==2); 
            RT_corr_Uns(iRun,iBlock,iSubj) = mean(trialBehThis.Target_RT(isCorrect & isThis_Uns));
            RT_corr_Str(iRun,iBlock,iSubj) = mean(trialBehThis.Target_RT(isCorrect & isThis_Str));
            RT_all_Uns(iRun,iBlock,iSubj) = mean(trialBehThis.Target_RT((isCorrect | isErr) & isThis_Uns));
            RT_all_Str(iRun,iBlock,iSubj) = mean(trialBehThis.Target_RT((isCorrect | isErr) & isThis_Str));
            PC_Uns(iRun,iBlock,iSubj) = mean(trialBehThis.Target_ACC(isThis_Uns));
            PC_Str(iRun,iBlock,iSubj) = mean(trialBehThis.Target_ACC(isThis_Str));            
        end
        RT_corr_run(iRun,iSubj) = mean(trialBehThis.Target_RT(trialBehThis.Session==iRun & isCorrect));
        RT_all_run(iRun,iSubj) = mean(trialBehThis.Target_RT(trialBehThis.Session==iRun & (isCorrect | isErr)));            
        PC_run(iRun,iSubj) = mean(trialBehThis.Target_ACC(trialBehThis.Session==iRun));
    end
    RT_corr_subj(iSubj) = mean(trialBehThis.Target_RT(isCorrect));
    RT_all_subj(iSubj) = mean(trialBehThis.Target_RT(isCorrect | isErr));
    PC_subj(iSubj) = mean(trialBehThis.Target_ACC);
end


%% Exclude Subjects
% If % correct in any 1 block is <X%, throw out whole subject
thresh = 0.5;
isOkSubj = squeeze(all(all(PC_Uns>thresh | isnan(PC_Uns),1),2) & all(all(PC_Str>thresh | isnan(PC_Str),1),2));
fprintf('%d/%d = %.1f%% of subjects pass %.3f PC threshold.\n',sum(isOkSubj),numel(subjects),mean(isOkSubj)*100,thresh);

%% Plot
figure(623); clf;
subplot(2,2,1); hold on;
for i=1:numel(subjects)
    if isOkSubj(i)
        plot(reshape(PC_Uns(:,:,i)',12,1),'.-');
    end
end
plot(reshape(nanmean(PC_Uns(:,:,isOkSubj),3)',12,1),'k.-','linewidth',2);
xlabel('Block');
ylabel('% correct');
title('Unstructured');
subplot(2,2,2); hold on;
for i=1:numel(subjects)
    if isOkSubj(i)
        plot(reshape(PC_Str(:,:,i)',12,1),'.-');
    end
end
plot(reshape(nanmean(PC_Str(:,:,isOkSubj),3)',12,1),'k.-','linewidth',2);
xlabel('Block');
ylabel('% correct');
title('Structured');

subplot(2,2,3); hold on;
for i=1:numel(subjects)
    if isOkSubj(i)
        plot(reshape(RT_corr_Uns(:,:,i)',12,1),'.-');
    end
end
plot(reshape(nanmean(RT_corr_Uns(:,:,isOkSubj),3)',12,1),'k.-','linewidth',2);
xlabel('Block');
ylabel('RT (ms)');
title('Unstructured');
subplot(2,2,4); hold on;
for i=1:numel(subjects)
    if isOkSubj(i)
        plot(reshape(RT_corr_Str(:,:,i)',12,1),'.-');
    end
end
plot(reshape(nanmean(RT_corr_Str(:,:,isOkSubj),3)',12,1),'k.-','linewidth',2);
xlabel('Block');
ylabel('RT (ms)');
title('Structured');
MakeFigureTitle(sprintf('PC/RT across %d subjects passing %.1f%% blockwise threshold',sum(isOkSubj),thresh*100));
%% Correlate with reading scores
figure(625);

readingScore = GetFirstReadingScorePc(behTable);
iqScore = behTable.WASI_PIQ;
% readingScore = iqScore;
% RT_corr_struct vs. 
subplot(2,2,1);
lm = fitlm(squeeze(nanmean(RT_corr_Str(3,:,isOkSubj & ~isnan(readingScore)),2)), readingScore(isOkSubj & ~isnan(readingScore)),'Linear');
lm.plot();
xlabel('Mean RT for correct structured trials in run 3')
ylabel('reading score (1st PC)');
title(sprintf('Structured trials, run 3:\nRsq=%.3g, p=%.3g\n',lm.Rsquared.Ordinary,coefTest(lm)));
% fprintf('Rsq=%.3g,p=%.3g\n',lm.Rsquared.Ordinary,coefTest(lm));
% 
subplot(2,2,2);
lm = fitlm(RT_corr_run(3,isOkSubj & ~isnan(readingScore)), readingScore(isOkSubj & ~isnan(readingScore)),'Linear');
lm.plot();
xlabel('Mean RT for all correct trials in run 3')
ylabel('reading score (1st PC)');
title(sprintf('All trials, run 3:\nRsq=%.3g, p=%.3g\n',lm.Rsquared.Ordinary,coefTest(lm)));
% fprintf('Rsq=%.3g,p=%.3g\n',lm.Rsquared.Ordinary,coefTest(lm));

subplot(2,2,3);
lm = fitlm(RT_corr_subj(isOkSubj & ~isnan(readingScore)), readingScore(isOkSubj & ~isnan(readingScore)),'Linear');
lm.plot();
xlabel('Mean RT for all correct trials in all runs')
ylabel('reading score (1st PC)');
title(sprintf('All trials, all runs:\nRsq=%.3g, p=%.3g\n',lm.Rsquared.Ordinary,coefTest(lm)));
% fprintf('Rsq=%.3g,p=%.3g\n',lm.Rsquared.Ordinary,coefTest(lm));

%% Regress out IQ from reading score, then regress reading score with RT diff

% [r_part,p_part] = partialcorr(RT_corr_subj(isOkSubj & ~isnan(readingScore)), readingScore(isOkSubj & ~isnan(readingScore)), iqScore(isOkSubj & ~isnan(readingScore)))

% [r_part,p_part] = partialcorr(behTable.RT_Final_UnsMinusStr(isOkSubj & ~isnan(readingScore)), readingScore(isOkSubj & ~isnan(readingScore)), iqScore(isOkSubj & ~isnan(readingScore)))

for iRun=1:3
    RtDiff = squeeze(nanmean(RT_corr_Uns(iRun,:,:),2)-nanmean(RT_corr_Str(iRun,:,:),2));
    [r_part,p_part] = partialcorr(RtDiff(isOkSubj & ~isnan(readingScore)), behTable.WJ3_BscR_SS(isOkSubj & ~isnan(readingScore)), iqScore(isOkSubj & ~isnan(readingScore)));
    fprintf('Run %d: r=%.3g, p=%.3g\n',iRun,r_part,p_part);
end

%% Predict Reading Score with CPM
% load('FC_wholerun_2017-09-01.mat','FC_taskonly','fullTs')
% fcSubj = cellfun(@(x) x(3:end),fullTs,'UniformOutput',false);
% [isBehSubj,iBehSubj] = ismember(fcSubj,subjects);
% 
% FC_match_fisher = atanh(FC_taskonly(:,:,isBehSubj));
% FC_match_fisher = UnvectorizeFc(VectorizeFc(FC_match_fisher),0,true);
% behTable_match = behTable(iBehSubj(isBehSubj),:);
% readingScore_match = readingScore(iBehSubj(isBehSubj));
% isOkSubj = ~isnan(readingScore_match);
% 
% corr_method = 'robustfit';
% mask_method = 'one';
% thresh = 0.01;
% [r_train,p_train,r_test,p_test,pos_mask_all,neg_mask_all] = ...
%     RunCpmWithTrainTestSplit(FC_match_fisher(:,:,isOkSubj),readingScore_match(isOkSubj),corr_method,mask_method,thresh);
