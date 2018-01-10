function covarTable = WriteAfniCovarFileForSrttData(subjects,params,outFile)

% WriteAfniCovarFileForSrttData(subjects,params,outFile)
%
% Created 1/8/18 by DJ.

% Declare defaults
if ~exist('subjects','var') || isempty(subjects)
    subjects = 'all';
end
if ~exist('params','var') || isempty(params)
    params = {'subjectID','averageMotion_perTR_','readingPc1','MeanRt','RT_lastRun_UnsMinusStr'};
end
if ~exist('outFile','var') || isempty(outFile)
    outFile = 'srttCovarFile.txt';
end

% Declare exclusion params
exclusionParams = {'fractionTRsCensored','readingPc1','RT_lastRun_UnsMinusStr','MinBlockAcc'};
exclusionFns = {@(x) x>0.2, @isnan, @isnan, @(x) x<0.5};

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
% Convert 
for i=1:size(reviewTable,2)
    if ~isnan(str2double(reviewTable.(varNames{i})(1))) % is it numeric
        reviewTable.(varNames{i}) = str2double(reviewTable.(varNames{i}));
    end
end

%% Crop to requested variables
% Assemble covariates
isParam = ismember(reviewTable.Properties.VariableNames,[params, exclusionParams]);
reviewTableToAdd = reviewTable(:,isParam);

%% Get Behavioral Data
fprintf('Loading reading behavior...\n');
filename = '/data/jangrawdc/PRJ16_TaskFcManipulation/Behavioral/SRTT-Behavior_A182SRTTdata_25Jan2017.xlsx';
behTable = ReadSrttBehXlsFile(filename);
readScore = GetFirstReadingScorePc(behTable);
behSubj = cellfun(@(x) sprintf('tb%04d',str2double(x)), behTable.MRI_ID,'UniformOutput',false);
% Make table
behTable = [behTable, table(behSubj,readScore,'VariableNames',{'subjectID','readingPc1'})];

% Crop to requested params
isParam = ismember(behTable.Properties.VariableNames,[params, exclusionParams]);
behTableToAdd = behTable(:,isParam);

%% Get Accuracy & RT Data
filename = '/data/jangrawdc/PRJ16_TaskFcManipulation/Behavioral/SRTT-Behavior_A182SRTTdata_25Jan2017.xlsx';
fprintf('Loading SRTT task behavior...\n');
trialBehTable = ReadSrttTrialByTrialBeh(filename);
[RT_block,ACC_block,RT_subj,ACC_subj,RT_lastRun_UnsMinusStr] = GetSrttSubjAccAndRtFromRawValues(trialBehTable);
% Convert subject names to strings
subj = unique(trialBehTable.Subject);
trialSubj = cell(numel(subj),1);
for i=1:numel(subj)
    trialSubj{i} = sprintf('tb%04d',subj(i));
end
% Compile into table
trialTable = table(trialSubj,RT_subj,ACC_subj,RT_lastRun_UnsMinusStr,min(ACC_block,[],2),...
    'VariableNames',{'subjectID','MeanRT','MeanACC','RT_lastRun_UnsMinusStr','MinBlockAcc'});

% Crop to requested params
isParam = ismember(trialTable.Properties.VariableNames,[params, exclusionParams]);
trialTableToAdd = trialTable(:,isParam);


%% Combine tables
% Crop to subjects present in both tables
[isInBehTable, iInBehTable] = ismember(reviewTableToAdd.subjectID,behTableToAdd.subjectID);
% Combine
covarTable = join(reviewTableToAdd(isInBehTable,:),behTableToAdd(iInBehTable(isInBehTable),:));
covarTable = join(covarTable,trialTableToAdd);

% Evaluate exclusion criteria and crop to ok subjects & params
isOkSubj = true(size(covarTable,1),1);
for i=1:numel(exclusionParams)
    isProblem = feval(exclusionFns{i},covarTable.(exclusionParams{i}));
    fprintf('Excluding %d subjects where %s meets %s...\n',sum(isProblem),exclusionParams{i},func2str(exclusionFns{i}));
    isOkSubj(isProblem)=false;
end
% Exclude subjects not requested
if ~isequal(subjects,'all')
    isOkSubj(~ismember(covarTable.subjectID,subjects)) = false;
end
% isOkSubj = ~isnan(covarTable.readingPc1) & covarTable.MinBlockAcc>=0.5 & ~isnan(covarTable.RT_lastRun_UnsMinusStr);
% Exclude all params not requested
isOkParam = ismember(covarTable.Properties.VariableNames,params);
covarTable = covarTable(isOkSubj,isOkParam);

%% Append prefix to each element in first column
prefix = 'coef.';
covarTable.subjectID = cellfun(@(x) [prefix, x], covarTable.subjectID,'UniformOutput',false);

%% Write to file
fprintf('Writing results to file...\n');
WriteAfniCovarFile(outFile,covarTable);
fprintf('Done!\n');
