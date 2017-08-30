function comboMask = GetNetworkAtThreshold(cr,cp,threshold)

% comboMask = GetNetworkAtThreshold(cr,cp,threshold)
% 
% INPUTS:
% -cr and cp are mxmxn matrices containing the LOSO r and p values
% correlating FC strength with performance across subjects.
% -threshold is a scalar indicating the max p value that will be considered
% part of the overall (cross-subject) network.
% 
% OUTPUTS:
% -comboMask is an mxm matrix that is +1 for edges that correlate
% positively with behavior and -1 for edges that correlate negatively with
% behavior across all LOSO iterations at the given p value threshold.
%
% Created 3/9/17 by DJ.

% Set up
cp_max = max(cp,[],3); % worst LOSO iteration
cr_sign = sign(cr(:,:,1)); % + or - correlation?
isMixedSign = ~(all(cr<0,3) | all(cr>0,3)); % mixed-sign edges don't count
% Create mask
comboMask = cr_sign;
comboMask(cp_max>threshold | isMixedSign) = 0; % remove things below threshold
comboMask(eye(size(comboMask,1))>0) = 0; % remove diagonals
