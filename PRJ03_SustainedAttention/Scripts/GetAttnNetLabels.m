function [attnNetLabels,labelNames,colors] = GetAttnNetLabels(separateHems)

% [attnNetLabels,labelNames,colors] = GetAttnNetLabels(separateHems)
%                                   = GetAttnNetLabels(labelType)
%
% Get the Rosenberg paper's labels/colors for each ROI in the Shen atlas.
%
% INPUTS:
% -separateHems is a binary value indicating whether separate hemispheres
% should have separate labels.
% -labelType is a string indicating the labels you're looking for. Options:
% 'icn' (networks),'region-hem' (group by region first, hemisphere second)
%
% OUTPUTS:
% -attnNetLabels is a 268x1 vector, where attnNetLabels(i) indicates the
% label (number) for ROI i.
% -labelNames is a 1xN cell array of strings, where N is the number of
% labels.
% -colors is an Nx3 matrix, where colors(j,:) is the RGB values for label j
% as seen in the Rosenberg paper (this is my estimate, not directly from
% the paper).
% 
% Created 9/28/16 by DJ.
% Updated 1/10/17 by DJ  - added ICN version
% Updated 2/9/17 by DJ - added region-hem version

if ~exist('separateHems','var') || isempty(separateHems)
    separateHems = false;
end


if ischar(separateHems) && strcmpi(separateHems,'icn')
    load('/data/jangrawdc/PRJ03_SustainedAttention/StanfordFineLab_Functional_ROIs/ShenIcnLabels.mat');
    labelNames = icnNames;
    colors = icnColors;
    attnNetLabels = icnLabels;
    
elseif ischar(separateHems) && strcmpi(separateHems,'region-hem')
    [attnNetLabels,labelNames,colors] = GetAttnNetLabels(true);
    % Reorder to group by macroscale region first, hemisphere second
    invorder = reshape([11:20;1:10],20,1);
    order = nan(size(invorder));
    for i=1:numel(invorder)
        order(i) = find(invorder==i); 
    end
    attnNetLabels = order(attnNetLabels);
    labelNames = labelNames(invorder);
    colors = colors(invorder,:);
    
elseif separateHems
    labelNames = {'R_prefrontal','R_motor','R_insula','R_parietal','R_temporal',...
        'R_occipital','R_limbic','R_cerebellum','R_subcortex','R_brainstem',...
        'L_prefrontal','L_motor','L_insula','L_parietal','L_temporal',...
        'L_occipital','L_limbic','L_cerebellum','L_subcortex','L_brainstem'};
    
    colors = [204 0 0; 204 102 0; 204 204 0; 0 204 0; 0 0 204; 178 102 255; ...
        0 204 204; 102 102 51; 153 76 0; 76 0 153; ...
        204 0 0; 204 102 0; 204 204 0; 0 204 0; 0 0 204; 178 102 255; ...
        0 204 204; 102 102 51; 153 76 0; 76 0 153]/255;
    
    attnNetLabels = nan(268,1);
    attnNetLabels(1:22) = 1;
    attnNetLabels(23:33) = 2;
    attnNetLabels(34:37) = 3;
    attnNetLabels(38:50) = 4;
    attnNetLabels(51:71) = 5;
    attnNetLabels(72:82) = 6;
    attnNetLabels(83:99) = 7;
    attnNetLabels(100:119) = 8;
    attnNetLabels(120:128) = 9;
    attnNetLabels(129:133) = 10;
    attnNetLabels(134:157) = 11;
    attnNetLabels(158:167) = 12;
    attnNetLabels(168:170) = 13;
    attnNetLabels(171:184) = 14;
    attnNetLabels(185:202) = 15;
    attnNetLabels(203:216) = 16;
    attnNetLabels(217:235) = 17;
    attnNetLabels(236:256) = 18;
    attnNetLabels(257:264) = 19;
    attnNetLabels(265:268) = 20;
    
else
    labelNames = {'Prefrontal','Motor','Insula','Parietal','Temporal',...
        'Occipital','Limbic','Cerebellum','Subcortex','Brainstem'};
    
    colors = [204 0 0; 204 102 0; 204 204 0; 0 204 0; 0 0 204; 178 102 255;...
        0 204 204; 102 102 51; 153 76 0; 76 0 153]/255;
    
    attnNetLabels = nan(268,1);
    attnNetLabels(1:22) = 1;
    attnNetLabels(23:33) = 2;
    attnNetLabels(34:37) = 3;
    attnNetLabels(38:50) = 4;
    attnNetLabels(51:71) = 5;
    attnNetLabels(72:82) = 6;
    attnNetLabels(83:99) = 7;
    attnNetLabels(100:119) = 8;
    attnNetLabels(120:128) = 9;
    attnNetLabels(129:133) = 10;
    attnNetLabels(134:157) = 1;
    attnNetLabels(158:167) = 2;
    attnNetLabels(168:170) = 3;
    attnNetLabels(171:184) = 4;
    attnNetLabels(185:202) = 5;
    attnNetLabels(203:216) = 6;
    attnNetLabels(217:235) = 7;
    attnNetLabels(236:256) = 8;
    attnNetLabels(257:264) = 9;
    attnNetLabels(265:268) = 10;
end