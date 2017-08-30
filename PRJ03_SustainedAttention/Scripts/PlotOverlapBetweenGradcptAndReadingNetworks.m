% PlotOverlapBetweenGradcptAndReadingNetworks.m
%
% Created 6/21/17 by DJ.

type = 'p01';%'73edge';

% Get overlap

if strcmp(type,'p01')
    % load
    load('GradCptNetwork_p01.mat');
    load('ReadingNetwork_p01.mat');
    % get overlap
    overlap = (gradCptNetwork_p01>0 & readingNetwork_p01>0) - (gradCptNetwork_p01<0 & readingNetwork_p01<0);
elseif strcmp(type,'73edge')
    load('GradCptNetwork_73edge');
    load('ReadingNetwork_73edge');
    overlap = (gradCptNetwork>0 & readingNetwork>0) - (gradCptNetwork<0 & readingNetwork<0);        
end
fprintf('%d pos, %d neg edges\n',sum(VectorizeFc(overlap)>0),sum(VectorizeFc(overlap)<0));

%% Plot results in 3D

atlasFile = '/Users/jangrawdc/Documents/PRJ03_SustainedAttention/Shen_2013_parcellations/shen_1mm_268_parcellation+tlrc';
h = PlotAtlasFcIn3d_Conn(atlasFile,overlap,[],[]);
Save3dFcImages_Conn(h);

%% Check if overlap is predictive
load('/Volumes/data/PRJ03_SustainedAttention/Results/ReadingFcAndFracCorrect_19subj_2017-02-09.mat');
FC_fisher = atanh(FC);
FC_fisher = UnvectorizeFc(VectorizeFc(FC_fisher),0,true);
GetFcMaskMatch(FC_fisher,overlap);


