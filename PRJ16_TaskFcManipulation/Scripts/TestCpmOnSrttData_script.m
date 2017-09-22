% TestCpmOnSrttData.m
%
% Created 9/21/17 by DJ.


% load('/data/jangrawdc/PRJ16_TaskFcManipulation/Results/FC_StructUnstructBase_2017-08-16','fullTs'); % subjects with full timeseries file available
% fcSubj = fullTs;
% [FC_wholerun, FC_taskonly] = GetFc_SRTT_wholerun(fcSubj);
load('/data/jangrawdc/PRJ16_TaskFcManipulation/Results/FC_wholerun_2017-09-01.mat','FC_taskonly','fullTs');
subjects = fullTs;
for i=1:numel(fullTs)
    subjects{i} = fullTs{i}(3:end);
end
% Get behavior
filename = 'SRTT-Behavior_A182SRTTdata_25Jan2017.xlsx';
behTable = ReadSrttBehXlsFile(filename);

%% Select matching rows
behSubjects = behTable.Properties.RowNames;
for i=1:numel(behSubjects)
    behSubjects{i} = sprintf('%04d',str2double(behSubjects{i}));
end
[isBehSubj,iBehSubj] = ismember(subjects,behSubjects);

% Get matched FC and behavior
FC_match_fisher = atanh(FC_taskonly(:,:,isBehSubj));
FC_match_fisher = UnvectorizeFc(VectorizeFc(FC_match_fisher),0,true);
behTable_match = behTable(iBehSubj(isBehSubj),:);

%% Test it with... IQ!
isOkSubj = ~isnan(behTable_match.RT_Final_UnsMinusStr);

[r_train,p_train,r_test,p_test,pos_mask_all,neg_mask_all] = ...
    RunCpmWithTrainTestSplit(FC_match_fisher(:,:,isOkSubj),behTable_match.RT_Final_UnsMinusStr(isOkSubj));
