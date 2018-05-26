function [FC_wholerun, FC_taskonly] = GetFc_Story_wholerun(subjects,folderSuffix,demeanTs)

% [FC_wholerun,FC_taskonly] = GetFc_Story_wholerun(subjects,folderSuffix,demeanTs)
%
% Calculate the FC between Shen Atlas ROIs in the Haskins Story dataset.
%
% Created 5/24/18 by DJ based on GetFc_SRTT_wholerun.m.

% Set up
info = GetStoryConstants();
if ~exist('folderSuffix','var')
    folderSuffix='_d2';
end
if ~exist('demeanTs','var')
    demeanTs = false;
end
% Get times for each task type
[iAud,iVis,iBase] = GetStoryBlockTiming();
    
% Get FC for each subject/condition
nRois = 268;
nSubj = numel(subjects);
% roiTc = nan(nT,nRois,nSubj);
[FC_wholerun, FC_taskonly] = deal(nan(nRois,nRois,nSubj));
for i=1:nSubj
    tic;
    fprintf('Subj %d/%d...\n',i,nSubj);
    % Load timecourses in each ROI
    filename = sprintf('%s/%s/%s.storyISC%s/shents.%s.roi_ROI_TS.1D',info.dataDir,subjects{i},subjects{i},folderSuffix,subjects{i});
    [err, roiTc] = Read_1D(filename);
    % Load censor file
    filename = sprintf('%s/%s/%s.storyISC%s/censor_%s_combined_2.1D',info.dataDir,subjects{i},subjects{i},folderSuffix,subjects{i});
    [err, isOk] = Read_1D(filename);
    isOk = isOk>0;
    % demean if requested
    if demeanTs
        roiTc = roiTc-repmat(mean(roiTc,2),1,size(roiTc,2));
    end
    % get FC matrix using non-censored timepoints (TODO: each block separately, then average?)
    if ~isempty(roiTc)
        FC_wholerun(:,:,i) = corr(roiTc(isOk,:));
        FC_taskonly(:,:,i) = corr(roiTc([iAud(isOk(iAud)), iVis(isOk(iVis))],:));
    end
    fprintf('Done! Took %.1f seconds.\n',toc);
end
fprintf('Done!\n');