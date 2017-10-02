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

%% Get
subjects = unique(trialBehTable.Subject);
nSubj = numel(subjects);
[RT_corr_Uns, RT_corr_Str, RT_all_Uns, RT_all_Str, PC_Uns, PC_Str] = deal(nan(3,4,nSubj)); 
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
    end
end

%% Plot
figure(623); clf;
subplot(2,2,1); hold on;
for i=1:numel(subjects)
    plot(reshape(PC_Uns(:,:,i)',12,1),'.-');
end
xlabel('Block');
ylabel('% correct');
title('Unstructured');
subplot(2,2,2); hold on;
for i=1:numel(subjects)
    plot(reshape(PC_Str(:,:,i)',12,1),'.-');
end
xlabel('Block');
ylabel('% correct');
title('Structured');

subplot(2,2,3); hold on;
for i=1:numel(subjects)
    plot(reshape(RT_corr_Uns(:,:,i)',12,1),'.-');
end
xlabel('Block');
ylabel('RT (ms)');
title('Unstructured');
subplot(2,2,4); hold on;
for i=1:numel(subjects)
    plot(reshape(RT_corr_Str(:,:,i)',12,1),'.-');
end
xlabel('Block');
ylabel('RT (ms)');
title('Structured');

%% Exclude Subjects


