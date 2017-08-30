function [matchStrength, matchStrength_neg] = GetRosenbergScoreForCogStateData_AllTasks(subjNum)

% [matchStrength,matchStrength_neg] = GetRosenbergScoreForCogStateData_AllTasks(subjNum)
% 
% Created 10/24/16 by DJ.
% Updated 11/092016 by DJ and NT. - Edited to get matchstrength value for whole run

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

%% LOAD TIME-SERIES 
%  -----------------------------------------------------------------------------------------
fprintf(char(strcat( '(1) LOAD TIMESERIES: ', Subject, ', WL=', num2str(floor(winLength_inTR*TR)), 's...'))); 
fileDir    = char(strcat(PrjDir,'/PrcsData/',Subject,'/',DirPrefix,'_',TaskID));
filePrefix = char(strcat(Subject,'_',TaskID,'.',AtlasID));
fileSuffix = char(strcat('_WL',num2str(floor(winLength_inTR*TR),'%03d'),'_ROI_TS.1D'));
%fileSuffix = char(strcat('_WL',num2str(floor(winLength_inTR*TR),'%03d'),'_BigMask_ROI_TS.1D'));
timecourses = Read_1D(sprintf('%s/%s%s',fileDir,filePrefix,fileSuffix));
fprintf('[DONE]\n');

%% GET FC TEMPLATE
fprintf('(2) Loading Rosenberg Template...\n');
attnNets = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/attn_nets_268.mat');
FcTemplate = attnNets.pos_overlap; % Rosenberg high-attention network
Fc_neg_Template = attnNets.neg_overlap;
fprintf('[DONE]\n');

%% ADJUST TO MATCH
nT = size(timecourses,1);
nROI = size(FcTemplate,2);
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

% Calculate match
matchStrength = GetFcTemplateMatch(timecourses(~isZeroRow,~isZeroCol)',FcTemplate(~isZeroCol,~isZeroCol),sum(~isZeroRow),normFC,matchMethod);
fprintf('[DONE]\n');
matchStrength_neg = GetFcTemplateMatch(timecourses(~isZeroRow,~isZeroCol)',Fc_neg_Template(~isZeroCol,~isZeroCol),sum(~isZeroRow),normFC,matchMethod);
fprintf('[DONE]\n');

