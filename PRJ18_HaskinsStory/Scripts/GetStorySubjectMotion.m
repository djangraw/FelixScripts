function [subjMotion, censorFraction] = GetStorySubjectMotion(subjects)

% [subjMotion, censorFraction] = GetStorySubjectMotion(subjects)
%
% INPUTS:
% -subjects is an N-element cell array of strings indicating the subjects 
% to be analyzed.
%
% OUTPUTS:
% -subjMotion is an N-element vector of the mean subject motion per TR
% (before censoring).
% -censorFraction is an N-element vector of the fraction of TRs censored
% due to excessive motion or outliers.
%
% Created 5/15/18 by DJ based on GetSrttSubjectMotion.
% Updated 5/22/18 by DJ - use censored motion and directory <subj>.storyISC
% Updated 5/23/18 by DJ - use directory <subj>.storyISC_d2

% Set Up
% motionStr = 'average motion (per TR)';
motionStr = 'average censored motion';
censorStr = 'censor fraction';

subjMotion = nan(1,numel(subjects));
censorFraction = nan(1,numel(subjects));
% Get Motion
for i=1:numel(subjects)
    % Get text from file
    filename = sprintf('/data/NIMH_Haskins/a182/%s/%s.storyISC/out.ss_review.%s.txt',subjects{i},subjects{i},subjects{i});
    if ~exist(filename,'file')
        fprintf('Skipping %s...\n',subjects{i});
    else
        fid = fopen(filename);
        allText = textscan(fid,'%s %s','delimiter',':');
        fclose(fid);
        % Extract motion value
        isAvgMotionLine = strncmpi(allText{1},motionStr,length(motionStr));
        subjMotion(i) = str2double(allText{2}{isAvgMotionLine});
        % Extract censor value
        isCensorFracLine = strncmpi(allText{1},censorStr,length(censorStr));
        censorFraction(i) = str2double(allText{2}{isCensorFracLine});
    end
end
    

