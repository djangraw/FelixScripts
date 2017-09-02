function [FC_wholerun, FC_taskonly] = GetFc_SRTT_wholerun(subjects)

% [FC_wholerun,FC_taskonly] = GetFc_SRTT_wholerun(subjects)
%
% Calculate the FC between Shen Atlas ROIs in the SRTT dataset.
%
% Created 8/10/17 by DJ.
% Updated 8/16/17 by DJ - switched to nonuisance file, added censoring.

% Set up
PRJDIR = '/data/jangrawdc/PRJ16_TaskFcManipulation/RawData';

% Get times for each task type
[iStruct,iUnstruct,iBase] = GetSrttBlockTiming();
    
% Get FC for each subject/condition
nRois = 268;
nSubj = numel(subjects);
% roiTc = nan(nT,nRois,nSubj);
[FC_wholerun, FC_taskonly] = deal(nan(nRois,nRois,nSubj));
for i=1:nSubj
    tic;
    fprintf('Subj %d/%d...\n',i,nSubj);
    % Load timecourses in each ROI
    filename = sprintf('%s/%s/%s.srtt/all_runs_nonuisance.%s.shen_ROI_TS.1D',PRJDIR,subjects{i},subjects{i},subjects{i});
    [err, roiTc] = Read_1D(filename);
    % Load censor file
    filename = sprintf('%s/%s/%s.srtt/censor_%s_combined_2.1D',PRJDIR,subjects{i},subjects{i},subjects{i});
    [err, isOk] = Read_1D(filename);
    isOk = isOk>0;
    % get FC matrix using non-censored timepoints (TODO: each block separately, then average?)
    FC_wholerun(:,:,i) = corr(roiTc(isOk,:));
    FC_taskonly(:,:,i) = corr(roiTc([iStruct(isOk(iStruct)), iUnstruct(isOk(iUnstruct))],:));
    fprintf('Done! Took %.1f seconds.\n',toc);
end
fprintf('Done!\n');
    