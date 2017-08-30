function [FC,winInfo,timecourses] = GetFcForCogStateData(subjNum,separateTasks,demeanTs)

% [matchStrength,winInfo,timecourses] = GetFcForCogStateData(subjNum,separateTasks,demeanTs)
%
% Created 10/24/16 by DJ.
% Updated 11/21/16 by DJ - adapted from GetRosenbergScoreForCogStateData.m,
% modified to get connectivity instead of match score, added demeanTs
% optional input
% Updated 11/23/16 by DJ - added timecourses output

if ~exist('separateTasks','var') || isempty(separateTasks)
    separateTasks = true;
end
if ~exist('demeanTs','var') || isempty(demeanTs)
    demeanTs = false;
end

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
FcTemplate = attnNets.pos_overlap; % Rosenberg high-attention network
fprintf('[DONE]\n');

%% ADJUST TO MATCH
nT = size(timecourses,1);
nROI = size(FcTemplate,2);

% Adjust to match real # ROIs in atlas
if size(timecourses,2)<nROI
    fprintf('Adding Zeros columns to timecourse to match # ROIs...\n');
    timecourses = cat(2,timecourses,zeros(nT,nROI-size(timecourses,2)));
end

%% Set zeroed ROIs to NaNs
isBadRoi = all(timecourses==0,1);
timecourses(:,isBadRoi) = NaN;
% DEMEAN IF REQUESTED
if demeanTs
    timecourses = timecourses-repmat(nanmean(timecourses,2),1,size(timecourses,2));
end

%% GET MATCH WITH TEMPLATE
fprintf('(3) Getting match with template...\n');
normFC = true;
% crop out bad rows/cols
isZeroRow = all(isnan(timecourses) | timecourses==0,2);
isZeroCol = all(isnan(timecourses) | timecourses==0,1);
fprintf('Keeping %d/%d TRs and %d/%d ROIs...\n',sum(~isZeroRow),nT,sum(~isZeroCol),nROI);

% Get task window times
[~,~,winInfo] = func_CSD_GetWinInfo_Experiment01(winLength_inTR,winStep_inTR);
nWin = numel(winInfo.onsetTRs);
if separateTasks
    % For each window
    FC = nan(nROI,nROI,nWin);
    for iWin = 1:nWin
        % Get time points in this window
        isInWin = (1:nT >= winInfo.onsetTRs(iWin) & 1:nT <= winInfo.offsetTRs(iWin))';

        % Calculate FC
        FC_win = GetFcMatrices(timecourses(~isZeroRow & isInWin,:)', 'sw', sum(~isZeroRow & isInWin));
        % Normalize
        if normFC
            FC(:,:,iWin) = atanh(FC_win);
        else
            FC(:,:,iWin) = FC_win;
        end
        fprintf('[DONE]\n');
    end
    
else
    FC_win = GetFcMatrices(timecourses(~isZeroRow,:)', 'sw', sum(~isZeroRow));
    % Normalize
    if normFC
        FC = atanh(FC_win);
    else
        FC = FC_win;
    end
    fprintf('[DONE]\n');
end
