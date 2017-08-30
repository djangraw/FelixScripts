% TEMP_ListSubjectsAtProcStages_script.m
%
% Created 8/11/17 by DJ.
% Updated 8/16/17 by DJ - switched to nonuisance file.

[noAllRuns, emptyAllRuns, fullAllRuns] = deal({});
for i=1:numel(subjects)
    filename = sprintf('/data/jangrawdc/PRJ16_TaskFcManipulation/RawData/%s/%s.srtt/all_runs.%s+orig.HEAD',subjects{i},subjects{i},subjects{i});
    if ~exist(filename,'file')
        noAllRuns = [noAllRuns, subjects(i)];
    else
        foo = dir(filename);
        if foo.bytes==0
            empyAllRuns = [emptyAllRuns, subjects{i}];
%             fprintf('%s ',subjects{i})
        else
            fullAllRuns = [fullAllRuns, subjects{i}];
%             fprintf('%s ',subjects{i});
        end
    end
end
% fprintf('\b\n');

fprintf('NoAllRuns: ');
for i=1:numel(noAllRuns)
    fprintf('%s ',noAllRuns{i});
end
fprintf('\b\n');

%%
[noParc, noTs, emptyTs, fullTs] = deal({});
for i=1:numel(subjects)
    filename = sprintf('/data/jangrawdc/PRJ16_TaskFcManipulation/RawData/%s/%s.srtt/all_runs_nonuisance.%s.shen_ROI_TS.1D',subjects{i},subjects{i},subjects{i});
    if ~exist(filename,'file')
        allrunsfilename = sprintf('/data/jangrawdc/PRJ16_TaskFcManipulation/RawData/%s/%s.srtt/all_runs_nonuisance.%s+orig.HEAD',subjects{i},subjects{i},subjects{i});
        if exist(allrunsfilename,'file')
            parcfilename = sprintf('/data/jangrawdc/PRJ16_TaskFcManipulation/RawData/%s/%s.srtt/shen_1mm_268_parcellation.%s+orig.HEAD',subjects{i},subjects{i},subjects{i});
            if ~exist(parcfilename,'file')
                noParc = [noParc, subjects{i}];
            else
                noTs = [noTs, subjects{i}];
            end
        end
    else
        foo = dir(filename);
        if foo.bytes==0
            emptyTs = [emptyTs, subjects{i}];
            delete(filename);
%             fprintf('%s ',subjects{i})
        else
            fullTs = [fullTs, subjects{i}];
%             fprintf('%s ',subjects{i})
        end
    end
end
fprintf('\b\n');

% REMOVE PROBLEM SUBJECTS
fullTs(strcmp(fullTs,'tb5688')) = []; % FIRST RUN IS ONLY 130 TRs

fprintf('NoTs: ');
for i=1:numel(noTs)
    fprintf('%s ',noTs{i});
end
fprintf('\b\n');

%% Get & Save FC
[FC_struct, FC_unstruct, FC_base] = GetFc_SRTT(fullTs);
cd /data/jangrawdc/PRJ16_TaskFcManipulation/Results
save FC_StructUnstructBase_2017-08-16 FC_struct FC_unstruct FC_base fullTs

%% Get & Save diffs
FC_struct_fisher = atanh(FC_struct);
FC_unstruct_fisher = atanh(FC_unstruct);
FC_base_fisher = atanh(FC_base);
thresh = 0.0000001;
[FC_struct_base_thresh,FC_unstruct_base_thresh,FC_struct_unstruct_thresh] = GetFcDiffs_SRTT(FC_struct_fisher,FC_unstruct_fisher,FC_base_fisher,thresh);
cd /data/jangrawdc/PRJ16_TaskFcManipulation/Results
save FC_StructUnstructBase_diff_q0000001_2017-08-16 FC_struct_base_thresh FC_unstruct_base_thresh FC_struct_unstruct_thresh fullTs