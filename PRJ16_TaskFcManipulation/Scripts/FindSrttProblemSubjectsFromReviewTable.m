% FindSrttProblemSubjectsFromReviewTable.m
%
% Created 1/4/18 by DJ.

filename = '/data/jangrawdc/PRJ16_TaskFcManipulation/RawData/QA/review_table.xls';

% Read in table
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

% Find problematic subjects
param = 'fractionTRsCensored';
thresh = 0.2;
isParam = strncmp(varNames,param,length(param));
isProblem = any(str2double(table2array(reviewTable(:,isParam)))>thresh,2);
subjects = reviewTable.subjectID;
problemSubjects = subjects(isProblem);

% Plot histogram of subject fracCensored (max for any condition).
maxParam = max(str2double(table2array(reviewTable(:,isParam))),[],2);
hist(maxParam,20);
xlabel(sprintf('Max %s',param));
ylabel('# subjects');
title(sprintf('Exclusion criterion for %d SRTT subjects',numel(maxParam)));
