function covarTable = WriteAfniCovarFileForSrttData(subjects,params,outFile)

% WriteAfniCovarFileForSrttData(subjects,params,outFile)
%
% Created 1/8/18 by DJ.

% Declare defaults
if ~exist('subjects','var') || isempty(subjects)
    subjects = 'all';
end
if ~exist('params','var') || isempty(params)
    params = {'subjectID','averageMotion_perTR_'};
end

%% Load fMRI-based data
fprintf('Loading fMRI roiStats...\n');
filename = '/data/jangrawdc/PRJ16_TaskFcManipulation/RawData/QA/review_table.xls';
reviewTable = readtable(filename,'FileType','text','MultipleDelimsAsOne',false);
reviewTable(1,:) = [];

% Replace missing names (2nd, 3rd, etc. in a category) with <category>_x<number>
isVar = strncmp(reviewTable.Properties.VariableNames,'Var',numel('Var'));
iVar = find(isVar);
varNames = reviewTable.Properties.VariableNames;
for i=1:numel(iVar)
    iLastNonVar = find(~isVar(1:iVar(i)),1,'last');
    varNames{iVar(i)} = sprintf('%s_x%d',reviewTable.Properties.VariableNames{iLastNonVar},iVar(i)-iLastNonVar+1);
end
reviewTable.Properties.VariableNames = varNames;

%% Remove subjects with problematic fracTrsCensored
param = 'fractionTRsCensored';
thresh = 0.2;
isParam = strncmp(varNames,param,length(param));
isProblem = any(str2double(table2array(reviewTable(:,isParam)))>thresh,2);
% Remove lines with problem subjects
fprintf('Removing %d subjects with %s over %g...\n',sum(isProblem),param,thresh);
reviewTable(isProblem,:) = [];

%% Get fMRI-BasedData
% Assemble covariates
isParam = ismember(varNames,params);
if isequal(subjects,'all')
    subjects = reviewTable.subjectID;
end
[isInTable,iSubj] = ismember(subjects,reviewTable.subjectID);
iSubj(~isInTable) = NaN;
reviewTableToAdd = reviewTable(iSubj,isParam);

%% Get Behavioral Data
fprintf('Loading reading behavior...\n');
filename = '/data/jangrawdc/PRJ16_TaskFcManipulation/Behavioral/SRTT-Behavior_A182SRTTdata_25Jan2017.xlsx';
behTable = ReadSrttBehXlsFile(filename);
readScore = GetFirstReadingScorePc(behTable);
behSubj = cellfun(@(x) sprintf('tb%04d',str2double(x)), behTable.MRI_ID,'UniformOutput',false);

%% Get Accuracy & RT Data
filename = '/data/jangrawdc/PRJ16_TaskFcManipulation/Behavioral/SRTT-Behavior_A182SRTTdata_25Jan2017.xlsx';
trialBehTable = ReadSrttTrialByTrialBeh(filename);
[RT_block,ACC_block,RT_subj,ACC_subj,RT_lastRun_UnsMinusStr] = GetSrttSubjAccAndRtFromRawValues(trialBehTable);
% Convert subject names to strings
subj = unique(trialBehTable.Subject);
trialSubj = cell(numel(subj),1);
for i=1:numel(subj)
    trialSubj{i} = sprintf('tb%04d',subj(i));
end
% Compile into table
trialTable = table(trialSubj,RT_subj,ACC_subj,RT_lastRun_UnsMinusStr,min(ACC_block,2),...
    'VariableNames',{'subjectID','MeanRT','MeanACC','RT_lastRun_UnsMinusStr','MinBlockAcc'});


%% Combine and Write
% Make table
behTableToAdd = table(behSubj,readScore,behTable.RT_Final_UnsMinusStr,'VariableNames',{'subjectID','readingPc1','RtFinalUnsMinusStr'});
% Crop to subjects present in both tables
[isInBehTable, iInBehTable] = ismember(reviewTableToAdd.subjectID,behTableToAdd.subjectID);
% Combine
covarTable = join(reviewTableToAdd(isInBehTable,:),behTableToAdd(iInBehTable(isInBehTable),:));
covarTable = join(covarTable,trialTable);
isOkSubj = ~isnan(covarTable.readingPc1);
covarTable = covarTable(isOkSubj,:);
% Write to file
fprintf('Writing results to file...\n');
WriteAfniCovarFile(outFile,covarTable);
fprintf('Done!\n');
