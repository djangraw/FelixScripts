function [feats, featNames, labels, labelNames, times, timeNames, iTcEventSample, iFcEventSample, V] = ConstructComboFeatMatrix(data, stats, questions, tc, roiNames, fcWinLength, tcWinLength, TR, nFirstRemoved,nPcsToKeep)

% [feats, featNames, labels, labelNames, times, timeNames, iTcEventSample, iFcEventSample, V] = ConstructComboFeatMatrix(data, stats, questions, tc, roiNames, fcWinLength, tcWinLength, TR, nFirstRemoved,nPcsToKeep)
%
% Created 12/21/15 by DJ.
% Updated 1/20/16 by DJ - updated event_names for new distraction paradigm
% (_d7), qPages
% Updated 6/1/16 by DJ - added V output (rotation matrix from FC SVD)

%% Handle inputs
if ~exist('TR','var') || isempty(TR)
    TR = 2; % repetition time (s)
end
if ~exist('roiNames','var') || isempty(roiNames)
    roiNames = cell(1,size(tc,1));
    for i=1:numel(roiNames)
        roiNames{i} = sprintf('ROI#%d',i);
    end
end
if ~exist('fcWinLength','var') || isempty(fcWinLength)
    fcWinLength = 10; % in TRs
end
if ~exist('tcWinLength','var') || isempty(tcWinLength)
    tcWinLength = 1; % in TRs
end
if ~exist('nFirstRemoved','var') || isempty(nFirstRemoved)
    nFirstRemoved = 3; % TRs removed before fMRI analysis
end
if ~exist('nPcsToKeep','var') || isempty(nPcsToKeep)
    nPcsToKeep = 100; % FC principal components to leave in (dim reduction)
end

% declare related constants
HrfOffset = 0;%6; % Delay due to HRF lag (seconds)
fcWinDur = fcWinLength*TR; % length of FC window (seconds)
pageDur = data(1).params.maxPageTime; % duration of page (seconds)
nSessions = length(data);
nTR = size(tc,2)/nSessions + nFirstRemoved; % # TRs per session before removal
% nTR = 8*60/TR; % # of TRs per 8-minute session
doPCA = (nPcsToKeep~=0);    

%% Get FC
FC = GetFcMatrices(tc,'sw',fcWinLength);

%% Get event times (RELATIVE TO FIRST TR AFTER REMOVAL)
[event_times,event_names,event_sessions] = deal(cell(1,numel(data)));
for i=1:numel(data)
    % Get offsets
    sessionOffset = (i-1)*(nTR-nFirstRemoved)*TR; % time (s) of first kept TR in fMRI data
    startTime = data(i).events.key.time(1)/1000; % this key is a T... the first fMRI trigger.
%     firstKeptTrTime = startTime+nFirstRemoved*TR; 
    % Get times, names, and sessions
%     event_times{i} = [sessionOffset; (data(i).events.soundstart.time - startTime)/1000 + sessionOffset];    
%     event_names{i} = [{'SessionStart'}; data(i).events.soundstart.name];
    isPageSound = ismember(data(i).events.soundstart.name,{'whiteNoiseSound','ignoreSound','attendSound','pageSound'});
    event_times{i} = (data(i).events.soundstart.time(isPageSound)/1000 - startTime) + sessionOffset; % time of event relative to first kept TR
    event_names{i} = data(i).events.soundstart.name(isPageSound);
    if data(i).params.subject<9
        if strncmp(data(i).params.promptType,'AttendReading',length('AttendReading'))
            event_names{i}(strcmp(event_names{i},'pageSound')) = {'ignoredSpeech'};
        else
            event_names{i}(strcmp(event_names{i},'pageSound')) = {'attendedSpeech'};
        end
    else
        event_names{i}(strcmp(event_names{i},'ignoreSound')) = {'ignoredSpeech'};
        event_names{i}(strcmp(event_names{i},'attendSound')) = {'attendedSpeech'};        
    end
    event_names{i}(strcmp(event_names{i},'whiteNoiseSound')) = {'whiteNoise'};
    event_sessions{i} = repmat(i,size(event_names{i}));
end
event_times = cat(1,event_times{:})';
event_names = cat(1,event_names{:});
event_sessions = cat(1,event_sessions{:})';

%=========================
% TR = 2; % repetition time (s)
% nTR = 8*60/TR; % # of TRs per 8-minute session
% nFirstRemoved = 3; % TRs removed before fMRI analysis
% HrfOffset = 6; % Delay due to HRF lag
% pageDur = 14; % duration of page (seconds)
% % winLength = 7; % TRs
% winDur = winLength*TR; % length of FC window (seconds)
% 
% [event_times,event_names] = deal(cell(1,numel(data)));
% for i=1:numel(data)
%     offset = (i-1)*(nTR-nFirstRemoved)*TR; % time (s) of first kept TR in fMRI data
%     startTime = data(i).events.key.time(1); % this key is a T!
% %     TrTimes = (nFirstRemoved:nTR-1)*TR; % times within this session
%     event_times{i} = [offset; (data(i).events.soundstart.time - startTime)/1000 + offset];
%     event_names{i} = [{'SessionStart'}; data(i).events.soundstart.name];    
% end
% event_times = cat(1,event_times{:});
% event_names = cat(1,event_names{:});



%% Get time of event
% get timing of each TR
tTC = (0:(nTR-nFirstRemoved)*nSessions-1)*TR; % time of TR (s)
tTC_adj = tTC - HrfOffset; % adjust for HRF offset (this is the time when the event occurred if the HRF peaks now)
tTC_session = nan(size(tTC));
for i=1:numel(data)
    iOffset = (i-1)*(nTR-nFirstRemoved);
    tTC_session(iOffset+(1:nTR-nFirstRemoved))=i;
end
% Get time of each FC window's START
tFC_winStart = (0:(nTR-nFirstRemoved)*nSessions)*TR; % time of START of window (s)
tFC_winEnd_adj = tFC_winStart + fcWinDur - HrfOffset; % adjust for HRF offset (this is the time when the event window is centered if the HRF peaks now)
tFC_session = nan(size(tFC_winStart));
for i=1:numel(data)
    iOffset = (i-1)*(nTR-nFirstRemoved);
    tFC_session(iOffset+(1:nTR-nFirstRemoved-fcWinLength+1))=i;
end

% ====================
% % Get time of each FC window's START
% tFC = (0:size(PCtc,2))*TR;
% % tFC = (0:599)*TR - HrfOffset;
% tTC = (0:size(PCtc,2))*TR;
% 
% % Get FC and tc event sample numbers
% iEventSample = nan(1,numel(event_times));
% iTcEventSample = nan(1,numel(event_times));
% for i=1:numel(event_times)
%     if event_times(i)<tFC(end)
%         if ~isempty(find(tFC + winDur <= event_times(i) + pageDur,1,'last'))
%             % Get indices of FC matrix that end at the END of a page
%             iEventSample(i) = find(tFC + winDur <= event_times(i) + pageDur,1,'last');    
%             % Get indices of tc matrix that start in the middle of the page.
%             iTcEventSample(i) = find(tTC <= event_times(i) + pageDur/2,1,'last');
%         end
%     end
% end
% % Get truth data
% truth = strcmp(event_names,'whiteNoiseSound')';
% truth = truth(~isnan(iEventSample) & ~isnan(iTcEventSample) & ~strcmp(event_names','SessionStart'));
% ====================

%% Get FC and tc event sample numbers
iFcEventSample = nan(1,numel(event_times));
iTcEventSample = nan(1,numel(event_times));

event_times_pageEnd = event_times + pageDur; % end of page
event_times_pageMid = event_times + pageDur/2; % middle of page
for i=1:numel(event_times)
    if event_times(i)<tFC_winStart(end)
        % Get indices of FC window that ends at the end of a page            
        iFC = find(tFC_winEnd_adj <= event_times_pageEnd(i) & tFC_session==event_sessions(i),1,'last');
        % Get indices of tc matrix that starts in the middle of the page.            
        iTC = find(tTC_adj <= event_times_pageMid(i) & tTC_session==event_sessions(i),1,'last');
        if ~isempty(iFC) && event_times_pageEnd(i)-tFC_winEnd_adj(iFC)<TR
            iFcEventSample(i) = iFC;                        
        end
        if ~isempty(iTC) && event_times_pageMid(i)-tTC_adj(iTC)<TR
            iTcEventSample(i) = iTC;
        end
    end
end

%% Compile features
% make TC label matrix
nRois = size(tc,1);
tcLabelVec = cell(nRois,1);
for i=1:nRois
    tcLabelVec{i} = sprintf('BOLD(%s)',roiNames{i});
end
% get FC feats
if doPCA
    % perform SVD
    [U,S,V,FcPcTc] = PlotFcPca(FC,0,true);
    if nPcsToKeep==-1
        cumsumS = cumsum(diag(S).^2)/sum(diag(S).^2);
        nPcsToKeep = getelbow(cumsumS');
        fracVarToKeep = cumsumS(nPcsToKeep);
        fprintf('Found elbow at %d PCs (%.1f%% variance)\n',nPcsToKeep,fracVarToKeep*100);
    elseif nPcsToKeep<1
        fracVarToKeep = nPcsToKeep;
        cumsumS = cumsum(diag(S).^2)/sum(diag(S).^2);
        nPcsToKeep = find(cumsumS<fracVarToKeep,1,'last');
    end
    fc_2dmat = FcPcTc(1:nPcsToKeep,:);    
    % get labels
    fcLabelVec = cell(nPcsToKeep,1);
    for i=1:nPcsToKeep
        fcLabelVec{i} = sprintf('FC<PC#%d>',i);
    end
else
    % reshape upper triangular part of FC 
    fc_2dmat = nan(nRois*(nRois-1)/2,size(FC,3));
    for i=1:size(FC,3);
        FCthis = FC(:,:,i);
        fc_2dmat(:,i) = FCthis(triu(ones(nRois),1)==1);
    end
    % get roi-based labels 
    fcLabelMat = cell(nRois);    
    for i=1:nRois
        for j=1:nRois
            fcLabelMat{i,j} = sprintf('FC<%s-%s>',roiNames{i},roiNames{j});
        end        
    end
    fcLabelVec = fcLabelMat(triu(ones(nRois),1)==1);
end

% get eye feats
eyeFields = fieldnames(stats);
eyeFeats = nan(numel(eyeFields),numel(stats.(eyeFields{1})));
eyeFeatLabels = cell(size(eyeFields));
for i=1:numel(eyeFields)
    eyeFeats(i,:) = stats.(eyeFields{i});
    eyeFeatLabels{i} = sprintf('EYE[%s]',eyeFields{i});
end

%% Get all fMRI feats

% smooth TC
tc_smooth = nan(size(tc));
for i=1:size(tc,2)
    iWin = round((1:tcWinLength)-tcWinLength/2)+i-1;
    tc_smooth(:,i) = nanmean(tc(:,iWin(iWin>0 & iWin<=size(tc,2))),2);
end

nEvents = numel(iTcEventSample);
tcFeats= nan(size(tc,1),nEvents);
tcFeats(:,~isnan(iTcEventSample)) = tc_smooth(:,iTcEventSample(~isnan(iTcEventSample)));
fcFeats = nan(size(fc_2dmat,1),nEvents);
fcFeats(:,~isnan(iFcEventSample)) = fc_2dmat(:,iFcEventSample(~isnan(iFcEventSample)));
% compile feats
feats = cat(1,tcFeats,fcFeats,eyeFeats);
featNames = cat(1,tcLabelVec, fcLabelVec, eyeFeatLabels);



%% Get truth data
isWhiteNoise = strcmp(event_names,'whiteNoise')';
% isWhiteNoise = isWhiteNoise(~isnan(iFcEventSample) & ~isnan(iTcEventSample) & ~strcmp(event_names','SessionStart'));

isIgnoredSpeech = strcmp(event_names,'ignoredSpeech')';
% isIgnoredSpeech = isIgnoredSpeech(~isnan(iFcEventSample) & ~isnan(iTcEventSample) & ~strcmp(event_names','SessionStart'));

isAttendedSpeech = strcmp(event_names,'attendedSpeech')';
% isAttendedSpeech = isAttendedSpeech(~isnan(iFcEventSample) & ~isnan(iTcEventSample) & ~strcmp(event_names','SessionStart'));

% questions
isReading = strcmp(questions.type,'reading');
qPages = questions.pages_adj(isReading);
nQ = numel(qPages);
isCorrect = false(size(isWhiteNoise));
isIncorrect = false(size(isWhiteNoise));
for i=1:nQ
    if questions.isCorrect(i)
        isCorrect(qPages{i}) = true;
    else
        isIncorrect(qPages{i}) = true;
    end
end

% assemble output
labels = cat(1,isWhiteNoise,isIgnoredSpeech,isAttendedSpeech,isCorrect,isIncorrect);
labelNames = {'whiteNoise';'ignoredSpeech';'attendedSpeech';'correct';'incorrect'};

%% assemble times output

times = cat(1,event_times,event_sessions,iTcEventSample,iFcEventSample);
timeNames = {'PageStartTime';'PageSession';'BoldEventIndex';'FcEventIndex'};