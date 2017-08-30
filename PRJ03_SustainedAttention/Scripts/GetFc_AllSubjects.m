function [FC,isMissingRoi_anysubj,FC_runs] = GetFc_AllSubjects(subjects,afniProcFolder,tsFilePrefix,runComboMethod)

% [FC,isMissingRoi_anysubj] = GetFc_AllSubjects(subjects,afniProcFolder,tsFilePrefix,runComboMethod)
%
% Created 11/16/16 by DJ.
% Updated 2/22/17 by DJ - added /Results to homedir

% Declare defaults
if ~exist('afniProcFolder','var') || isempty(afniProcFolder)
    afniProcFolder = 'AfniProc_MultiEcho_2016-09-22';
end
if ~exist('tsFilePrefix','var') || isempty(tsFilePrefix)
    tsFilePrefix = 'shen268_withSegTc2';
end
if ~exist('runComboMethod','var') || isempty(runComboMethod)
    runComboMethod = 'avgRead';
end

% Declare constantas
vars = GetDistractionVariables;
homedir = vars.homedir;
nFirstRemoved = vars.nFirstRemoved;
TR = vars.TR;
hrfOffset = vars.hrfOffset;
fcWinLength = 1; % placeholder
nSubj = numel(subjects);


% Load timecourses
fprintf('===Loading data for %d subjects...\n',nSubj);
FC_runs = cell(1,nSubj);
for i=1:nSubj
    % Load fMRI data
    tsFilename = sprintf('%s/Results/SBJ%02d/%s/%s_SBJ%02d_ROI_TS.1D',homedir,subjects(i),afniProcFolder,tsFilePrefix,subjects(i));
    % Load data
    [err,M,Info,Com] = Read_1D(tsFilename);
    if i==1
        nRois = size(M,2);
        isMissingRoi = nan(nSubj,nRois);
        FC = nan(nRois,nRois,nSubj);
    end
    isMissingRoi(i,:) = all(M==0,1);
    
    % load behavior data
    beh = load(sprintf('%s/Results/SBJ%02d/Distraction-SBJ%02d-Behavior.mat',homedir,subjects(i),subjects(i)));
    % Get times that were during reading
    nRuns = numel(beh.data);
    nT = size(M,1);
    nTR = nT/nRuns + nFirstRemoved;
    isCensored = all(M==0,2);
    if strcmp(runComboMethod,'catRuns') % Use all runs together
        M_crop = M(~isCensored,:);
        % Get FC matrices
        FC(:,:,i) = GetFcMatrices(M_crop','sw',size(M_crop,1));
    elseif strcmp(runComboMethod,'avgRuns')
        FC_run = nan(nRois,nRois,nRuns);
        iRunStart = 1:(nT/nRuns):nT;
        iRunEnd = (nT/nRuns):(nT/nRuns):nT;
        for j=1:nRuns            
            isInRun = false(nT,1);            
            isInRun(iRunStart(j):iRunEnd(j)) = true;
            % Crop data
            M_crop = M(~isCensored & isInRun,:);
            % Get FC matrices
            FC_run(:,:,j) = GetFcMatrices(M_crop','sw',size(M_crop,1));
        end
        FC(:,:,i) = mean(FC_run,3);
        FC_runs{i} = FC_run;
    else
        iTcEventSample_start = GetEventSamples(beh.data, fcWinLength, TR, nFirstRemoved, nTR, hrfOffset,'start');
        [iTcEventSample_end,~,eventNames] = GetEventSamples(beh.data, fcWinLength, TR, nFirstRemoved, nTR, hrfOffset,'end');
        iRunStart = iTcEventSample_start(1:30:end);
        iRunEnd = iTcEventSample_end(30:30:end);
        if strcmp(runComboMethod,'catRead') % concatenate across runs
            isReadingSample = false(nT,1);
            for j=1:nRuns
                isReadingSample(iRunStart(j):iRunEnd(j)) = true;
            end
            % Crop data
            M_crop = M(~isCensored & isReadingSample,:);
            % Get FC matrices
            FC(:,:,i) = GetFcMatrices(M_crop','sw',size(M_crop,1));
        elseif strcmp(runComboMethod,'avgRead')
            FC_run = nan(nRois,nRois,nRuns);
            for j=1:nRuns
                isInRun = false(nT,1);            
                isInRun(iRunStart(j):iRunEnd(j)) = true;
                % Crop data
                M_crop = M(~isCensored & isInRun,:);
                % Get FC matrices
                FC_run(:,:,j) = GetFcMatrices(M_crop','sw',size(M_crop,1));
            end
            FC(:,:,i) = mean(FC_run,3);
            FC_runs{i} = FC_run;
        else
            error('method %s not recognized!',runComboMethod)
        end
    end
    
end

%% Get missing ROIs
isMissingRoi_anysubj = any(isMissingRoi,1);
fprintf('===Censoring %d ROIs...\n',sum(isMissingRoi_anysubj));

% Censor rows & cols of missing ROIs
FC(isMissingRoi_anysubj,:,:) = nan;
FC(:,isMissingRoi_anysubj,:) = nan;
    
fprintf('===Done!\n');


