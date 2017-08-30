function [FC,FC_part2,roiTcCropped] = GetFc_VaryLength(subjects,afniProcFolder,tsFilePrefix,lengths,part2start)

% [FC,FC_part2,roiTcCropped] = GetFc_VaryLength(subjects,afniProcFolder,tsFilePrefix,runComboMethod,lengths)
%
% Created 6/6/17 by DJ from GetFc_AllSubjects.

% Declare defaults
if ~exist('afniProcFolder','var') || isempty(afniProcFolder)
    afniProcFolder = 'AfniProc_MultiEcho_2016-09-22';
end
if ~exist('tsFilePrefix','var') || isempty(tsFilePrefix)
    tsFilePrefix = 'shen268_withSegTc2';
end

% Declare constantas
vars = GetDistractionVariables;
homedir = vars.homedir;
nFirstRemoved = vars.nFirstRemoved;
TR = vars.TR;
hrfOffset = vars.hrfOffset;
fcWinLength = 1; % placeholder
nSubj = numel(subjects);

roiTcCropped = cell(1,nSubj);
% Load timecourses
fprintf('===Loading data for %d subjects...\n',nSubj);
for i=1:nSubj
    % Load fMRI data
    tsFilename = sprintf('%s/Results/SBJ%02d/%s/%s_SBJ%02d_ROI_TS.1D',homedir,subjects(i),afniProcFolder,tsFilePrefix,subjects(i));
    % Load data
    [err,M,Info,Com] = Read_1D(tsFilename);
    if i==1
        nRois = size(M,2);
        isMissingRoi = nan(nSubj,nRois);
        [FC,FC_part2] = deal(nan(nRois,nRois,nSubj,numel(lengths)));
    end
    isMissingRoi(i,:) = all(M==0,1);
    
    % load behavior data
    beh = load(sprintf('%s/Results/SBJ%02d/Distraction-SBJ%02d-Behavior.mat',homedir,subjects(i),subjects(i)));
    % Get times that were during reading
    nRuns = numel(beh.data);
    nT = size(M,1);
    nTR = nT/nRuns + nFirstRemoved;
    isCensored = all(M==0,2);
    
    iTcEventSample_start = GetEventSamples(beh.data, fcWinLength, TR, nFirstRemoved, nTR, hrfOffset,'start');
    [iTcEventSample_end,~,eventNames] = GetEventSamples(beh.data, fcWinLength, TR, nFirstRemoved, nTR, hrfOffset,'end');
    iRunStart = iTcEventSample_start(1:30:end);
    iRunEnd = iTcEventSample_end(30:30:end);

    % concatenate across runs
    isReadingSample = false(nT,1);
    for j=1:nRuns
        isReadingSample(iRunStart(j):iRunEnd(j)) = true;
    end
    % Crop data
    M_crop = M(~isCensored & isReadingSample,:);
    % Get FC matrices
    for j=1:numel(lengths)        
        FC(:,:,i,j) = GetFcMatrices(M_crop(1:lengths(j),:)','sw',lengths(j));
        FC_part2(:,:,i,j) = GetFcMatrices(M_crop(part2start-1+(1:lengths(j)),:)','sw',lengths(j));
    end
    roiTcCropped{i} = M_crop;
end

%% Get missing ROIs
isMissingRoi_anysubj = any(isMissingRoi,1);
fprintf('===Censoring %d ROIs...\n',sum(isMissingRoi_anysubj));

% Censor rows & cols of missing ROIs
FC(isMissingRoi_anysubj,:,:) = nan;
FC(:,isMissingRoi_anysubj,:) = nan;
    
fprintf('===Done!\n');


