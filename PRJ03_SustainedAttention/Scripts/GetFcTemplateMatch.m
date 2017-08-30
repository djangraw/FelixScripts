function matchStrength = GetFcTemplateMatch(timecourses,FcTemplate,winLength,normFC,method)

% matchStrength = GetFcTemplateMatch(timecourses,FcTemplate,winLength,normFC,method)
% matchStrength = GetFcTemplateMatch(FC,FcTemplate,winLength,normFC,method)
%
% INPUTS:
% -timecourses is an NxT matrix of the activity in each ROI at each sample,
% where N is the # of ROIs and T is the # of time points.
% -FcTemplate is an NxN matrix providing a template of functional
% connectivity (e.g., associated with high levels of attention)
% -winLength is a scalar
% -normFC is a binary value indicatig whether the FC matrix should be
% Fisher Z-transformed (via atanh) [defaut: false].
% -method is a string indicating how you want to judge the match. It can be 
%  either 'corr' (correlation) [default] or 'mult' (multiplication)
% -FC is a square matrix of the functional connectivity between ROIs.
%
% OUTPUTS:
% -matchStrength is a T-element vector of the level to which each sample's
% FC matches (correlates with) the template.
%
% Created 5/2/16 by DJ.
% Updated 11/16/16 by DJ - allow FC to be input directly
% Updated 11/22/16 by DJ - meanmult now uses nanmean
% Updated 11/28/16 by DJ - fixed meanmult with multiple time points bug,
% changed meanmult to ignore zeros in the template as well as nans
% Updated 12/1/16 by DJ - allow logical FcTemplate.

% Check inputs
[nRois, nT] = size(timecourses);
if ~isequal(size(FcTemplate),[nRois,nRois])
    error('size(timecourses,1), size(FcMat,1) and size(FcMat,2) should match!');
end
if ~exist('winLength','var') || isempty(winLength)
    winLength = 10;
end
if ~exist('normFC','var') || isempty(normFC)
    normFC = false;
end
if ~exist('method','var') || isempty(method)
    method = 'corr';
end

% Get FC matrices
if size(timecourses,1)==size(timecourses,2) % if square matrix, interpret as FC
    fprintf('Interpreting input as FC...\n')
    FC = timecourses;
else
    FC = GetFcMatrices(timecourses,'sw',winLength);
end
% convert both template and FC to vector/matrix
uppertri = triu(ones(nRois),1);
FcTemplate_vec = FcTemplate(uppertri==1);

% reshape upper triangular part of FC 
FC_2dmat = nan(nRois*(nRois-1)/2,size(FC,3));
for i=1:size(FC,3)
    FCthis = FC(:,:,i);
    FC_2dmat(:,i) = FCthis(uppertri==1);
end

if normFC
    FC_2dmat = atanh(FC_2dmat);
end

% Find match between FC and FcMat
switch method
    case 'corr'
        matchStrength = corr(FC_2dmat,FcTemplate_vec);
    case 'mult'
        matchStrength = FC_2dmat'*FcTemplate_vec;
    case 'meanmult'
        matchStrength = nan(1,size(FC,3));
        FcTemplate_vec = double(FcTemplate_vec);
        FcTemplate_vec(FcTemplate_vec==0) = nan;
        for i=1:size(FC,3)
            matchStrength(i) = nanmean(FC_2dmat(:,i).*FcTemplate_vec(:));
        end
end
