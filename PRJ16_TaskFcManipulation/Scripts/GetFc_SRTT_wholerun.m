function [FC_wholerun, FC_taskonly] = GetFc_SRTT_wholerun(subjects,folderSuffix,demeanTs)

% [FC_wholerun,FC_taskonly] = GetFc_SRTT_wholerun(subjects,folderSuffix,demeanTs)
%
% Calculate the FC between Shen Atlas ROIs in the SRTT dataset.
%
% Created 8/10/17 by DJ.
% Updated 8/16/17 by DJ - switched to nonuisance file, added censoring.
% Updated 1/26/18 by DJ - added folderSuffix and demeanTs inputs

% Set up
PRJDIR = '/data/jangrawdc/PRJ16_TaskFcManipulation/RawData';
if ~exist('folderSuffix','var')
    folderSuffix='';
end
if ~exist('demeanTs','var')
    demeanTs = false;
end
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
    filename = sprintf('%s/%s/%s.srtt%s/all_runs_nonuisance.%s.shen_ROI_TS.1D',PRJDIR,subjects{i},subjects{i},folderSuffix,subjects{i});
    [err, roiTc] = Read_1D(filename);
    % Load censor file
    filename = sprintf('%s/%s/%s.srtt%s/censor_%s_combined_2.1D',PRJDIR,subjects{i},subjects{i},folderSuffix,subjects{i});
    [err, isOk] = Read_1D(filename);
    isOk = isOk>0;
    % demean if requested
    if demeanTs
        roiTc = roiTc-repmat(mean(roiTc,2),1,size(roiTc,2));
    end
    % get FC matrix using non-censored timepoints (TODO: each block separately, then average?)
    FC_wholerun(:,:,i) = corr(roiTc(isOk,:));
    FC_taskonly(:,:,i) = corr(roiTc([iStruct(isOk(iStruct)), iUnstruct(isOk(iUnstruct))],:));
    fprintf('Done! Took %.1f seconds.\n',toc);
end
fprintf('Done!\n');
    