function [matchStrength_negT,winInfo] = GetRosenbergScoreForCogStateData(subjNum)

% [matchStrength_negT,winInfo] = GetRosenbergScoreForCogStateData(subjNum)
%
% Created 10/24/16 by DJ.

%% Declare constants
% Subject & Run Information
  Subject = char(strcat('SBJ',num2str(subjNum,'%02d'))); %'SBJ06';%char(strcat('SBJ',num2str($SBJ,'%02d')));
  NumAcq  = 1017;
  TR      = 1.5;
% Data Location
  PrjDir    = '/data/jangrawdc/PRJ08_CognitiveStateDetection';
  TaskID    = 'CTask001';
  DirPrefix = 'D02';
% Atlas Info
%   NumROIsAtlas = 268;%$NROI;
  AtlasID        = 'Shen';
  winLength = 180;
  winLength_inTR = winLength/TR;
  winStep_inTR = 0;

%% LOAD TIME-SERIES 
%  -----------------------------------------------------------------------------------------
fprintf(char(strcat( '(1) LOAD TIMESERIES: ', Subject, ', WL=', num2str(floor(winLength_inTR*TR)), 's...'))); 
fileDir    = char(strcat(PrjDir,'/PrcsData/',Subject,'/',DirPrefix,'_',TaskID));
filePrefix = char(strcat(Subject,'_',TaskID,'.',AtlasID));
fileSuffix = char(strcat('_WL',num2str(floor(winLength_inTR*TR),'%03d'),'_BigMask_ROI_TS.1D'));
timecourses = Read_1D(sprintf('%s/%s%s',fileDir,filePrefix,fileSuffix));
fprintf('[DONE]\n');

%% GET FC TEMPLATE
fprintf('(2) Loading Rosenberg Template...\n');
attnNets = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/attn_nets_268.mat');
%FcTemplate_T = attnNets.pos_overlap; % Rosenberg high-attention network
%fprintf('[DONE]\n');
FcTemplate_negT = attnNets.neg_overlap; % Rosenberg low-attention network
fprintf('[DONE]\n');

%% ADJUST TO MATCH
nT = size(timecourses,1);
nROI = size(FcTemplate_negT,2);
% Adjust to match
if size(timecourses,2)<nROI
    fprintf('Adding Zero columns to timecourse to match # ROIs...\n');
    timecourses = cat(2,timecourses,zeros(nT,nROI-size(timecourses,2)));
end

%% GET MATCH WITH TEMPLATE
fprintf('(3) Getting match with template...\n');
normFC = true;
matchMethod = 'mult';
% crop out bad rows/cols
isZeroRow = all(timecourses==0,2);
isZeroCol = all(timecourses==0,1);
fprintf('Keeping %d/%d TRs and %d/%d ROIs...\n',sum(~isZeroRow),nT,sum(~isZeroCol),nROI);

% Get task window times
[~,~,winInfo] = func_CSD_GetWinInfo_Experiment01(winLength_inTR,winStep_inTR);
nWin = numel(winInfo.onsetTRs);
% For each window
matchStrength = nan(1,nWin);
for iWin = 1:nWin
    % Get time points in this window
    isInWin = (1:nT >= winInfo.onsetTRs(iWin) & 1:nT <= winInfo.offsetTRs(iWin))';

    % Calculate match
    matchStrength_negT(iWin) = GetFcTemplateMatch(timecourses(~isZeroRow & isInWin,~isZeroCol)',FcTemplate_negT(~isZeroCol,~isZeroCol),sum(~isZeroRow & isInWin),normFC,matchMethod);
    fprintf('[DONE]\n');
end
