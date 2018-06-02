function [roiTc, isOk] = GetStoryTc_ShenAtlas(subjects,folderSuffix)

% [roiTc, isOk] = GetStoryTc_ShenAtlas(subjects,folderSuffix)
%
% Calculate the timecourse of activity in Shen Atlas ROIs in the Haskins Story dataset.
%
% Created 6/1/18 by DJ based on GetFc_Story_wholerun.m.

% Set up
info = GetStoryConstants();
if ~exist('folderSuffix','var')
    folderSuffix='_d2';
end
    
% Get FC for each subject/condition
nRois = 268;
nSubj = numel(subjects);
% roiTc = nan(nT,nRois,nSubj);
roiTc = nan(info.nT,nRois,nSubj);
isOk = nan(info.nT,nSubj);
for i=1:nSubj
    tic;
    fprintf('Subj %d/%d...\n',i,nSubj);
    % Load timecourses in each ROI
    filename = sprintf('%s/%s/%s.storyISC%s/shents.%s.roi_ROI_TS.1D',info.dataDir,subjects{i},subjects{i},folderSuffix,subjects{i});
    [err, roiTc(:,:,i)] = Read_1D(filename);
    % Load censor file
    filename = sprintf('%s/%s/%s.storyISC%s/censor_%s_combined_2.1D',info.dataDir,subjects{i},subjects{i},folderSuffix,subjects{i});
    [err, isOk(:,i)] = Read_1D(filename);
    isOk = isOk>0;
end