% TEMP_CheckForMissingTsFiles.m
%
% Created 2/5/18 by DJ.

for i=1:numel(info.okSubjNames)
    subj = info.okSubjNames{i};
    if ~exist(sprintf('/data/jangrawdc/PRJ16_TaskFcManipulation/RawData/%s/%s.srtt_v3/all_runs_nonuisance_nowmcsf.%s.shen_ROI_TS.1D',subj,subj,subj),'file')
        fprintf('%s DNE!\n',subj);
    else
        foo = dir(sprintf('/data/jangrawdc/PRJ16_TaskFcManipulation/RawData/%s/%s.srtt_v3/all_runs_nonuisance_nowmcsf.%s.shen_ROI_TS.1D',subj,subj,subj));
        if foo.bytes==0
            fprintf('%s size 0!\n',subj);
        end
    end
end
        