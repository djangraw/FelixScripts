function [iscWin,tWin] = GetSlidingWindowIsc(subj_sorted,readScore_sorted,winLength)

% Created 4/9/19 by DJ.
% Updated 8/22/19 by DJ - added stderr calculations

%% Load data
constants = GetStoryConstants();
nSubj = numel(subj_sorted);

% Load mask to speed up correlations
isInMask = BrikLoad(sprintf('%s/IscResults/Group/MNI_mask_epiRes.nii',constants.dataDir))>0;
nVox = numel(isInMask);
isInMask = reshape(isInMask,[nVox,1]);
nInMask = sum(isInMask);

% Load all data
for i=1:nSubj
    fprintf('Loading subj %d/%d...\n',i,nSubj);
    % load timecourse
    subj = subj_sorted{i};
    [V,Info] = BrikLoad(sprintf('%s/%s/%s.story/errts.%s.fanaticor+tlrc',constants.dataDir,subj,subj,subj));
    % get size
    if i==1
        nT = size(V,4);
        allData = nan(nInMask,nT,nSubj);
    end
    % reshape
    V = reshape(V,[nVox,nT]);
    V(:,all(V==0,1)) = NaN;
    allData(:,:,i) = V(isInMask,:);
end

allData = permute(allData,[3 2 1]); %[nSubj,nT,nInMask]

%% Get subject ID

% Get top/bottom pairs
isTop = readScore_sorted>median(readScore_sorted);
isTopTop = ((isTop'*isTop) .* triu(ones(nSubj),1))>0;
isTopBot = (((~isTop)'*isTop) .* triu(ones(nSubj),1))>0;
isBotBot = (((~isTop)'*(~isTop)) .* triu(ones(nSubj),1))>0;
figure(562);
imagesc(isBotBot+2*isTopBot+3*isTopTop);
set(gca,'ydir','normal');
colorbar()

%% Calculate ISC
% winLength=15;
nWin = nT-winLength+1;
% corrMat = nan(nSubj,nSubj,nWin,nInMask);
[pDiffTopBot,pDiffTopTB,pDiffBotTB] = deal(nan(nInMask,nWin));
[meanTopTop,meanTopBot,meanBotBot] = deal(nan(nInMask,nWin));
[steTopTop,steTopBot,steBotBot] = deal(nan(nInMask,nWin));
for iVox=1:nInMask
    if mod(iVox,100)==0
        fprintf('voxel %d/%d (%.1f%%)...\n',iVox,nInMask,iVox/nInMask*100);
    end
    for iWin=1:nWin
        corrMat = corr(allData(:,(1:winLength)+iWin-1,iVox)');
        zTopTop = r2z(corrMat(isTopTop));
        zTopBot = r2z(corrMat(isTopBot));
        zBotBot = r2z(corrMat(isBotBot));
        % Get means
        meanTopTop(iVox,iWin) = nanmean(zTopTop);
        meanTopBot(iVox,iWin) = nanmean(zTopBot);
        meanBotBot(iVox,iWin) = nanmean(zBotBot);
        
        % Get stderrs
        steTopTop(iVox,iWin) = nanstd(zTopTop)/sqrt(sum(~isnan(zTopTop)));
        steTopBot(iVox,iWin) = nanstd(zTopBot)/sqrt(sum(~isnan(zTopBot)));
        steBotBot(iVox,iWin) = nanstd(zBotBot)/sqrt(sum(~isnan(zBotBot)));
        
        % Get stats
        [~,pDiffTopBot(iVox,iWin)] = ttest2(zTopTop,zBotBot);
        [~,pDiffTopTB(iVox,iWin)] = ttest2(zTopTop,zTopBot);
        [~,pDiffBotTB(iVox,iWin)] = ttest2(zBotBot,zTopBot);
    end
end

%% Convert back to bricks and save

V = zeros(nVox,nWin);
V(isInMask,:) = meanTopTop; % mean z score
V = reshape(V,[Info.DATASET_DIMENSIONS(1:3),nWin]);
filename = sprintf('%s/IscResults/Group/SlidingWindowIsc_win%d_toptop',constants.dataDir,winLength);
Opt = struct('Prefix',filename,'OverWrite','y');
WriteBrik(V,Info,Opt);

V = zeros(nVox,nWin);
V(isInMask,:) = meanTopBot; % mean z score
V = reshape(V,[Info.DATASET_DIMENSIONS(1:3),nWin]);
filename = sprintf('%s/IscResults/Group/SlidingWindowIsc_win%d_topbot',constants.dataDir,winLength);
Opt = struct('Prefix',filename,'OverWrite','y');
WriteBrik(V,Info,Opt);

V = zeros(nVox,nWin);
V(isInMask,:) = meanBotBot; % mean z score
V = reshape(V,[Info.DATASET_DIMENSIONS(1:3),nWin]);
filename = sprintf('%s/IscResults/Group/SlidingWindowIsc_win%d_botbot',constants.dataDir,winLength);
Opt = struct('Prefix',filename,'OverWrite','y');
WriteBrik(V,Info,Opt);

V = zeros(nVox,nWin);
V(isInMask,:) = steTopTop; % mean z score
V = reshape(V,[Info.DATASET_DIMENSIONS(1:3),nWin]);
filename = sprintf('%s/IscResults/Group/SlidingWindowIsc_win%d_toptop_ste',constants.dataDir,winLength);
Opt = struct('Prefix',filename,'OverWrite','y');
WriteBrik(V,Info,Opt);

V = zeros(nVox,nWin);
V(isInMask,:) = steTopBot; % mean z score
V = reshape(V,[Info.DATASET_DIMENSIONS(1:3),nWin]);
filename = sprintf('%s/IscResults/Group/SlidingWindowIsc_win%d_topbot_ste',constants.dataDir,winLength);
Opt = struct('Prefix',filename,'OverWrite','y');
WriteBrik(V,Info,Opt);

V = zeros(nVox,nWin);
V(isInMask,:) = steBotBot; % mean z score
V = reshape(V,[Info.DATASET_DIMENSIONS(1:3),nWin]);
filename = sprintf('%s/IscResults/Group/SlidingWindowIsc_win%d_botbot_ste',constants.dataDir,winLength);
Opt = struct('Prefix',filename,'OverWrite','y');
WriteBrik(V,Info,Opt);

V = zeros(nVox,nWin);
V(isInMask,:) = norminv(pDiffTopBot); % convert to z score
V = reshape(V,[Info.DATASET_DIMENSIONS(1:3),nWin]);
filename = sprintf('%s/IscResults/Group/SlidingWindowIsc_win%d_top-bot',constants.dataDir,winLength);
Opt = struct('Prefix',filename,'OverWrite','y');
WriteBrik(V,Info,Opt);

V = zeros(nVox,nWin);
V(isInMask,:) = norminv(pDiffTopTB); % convert to z score
V = reshape(V,[Info.DATASET_DIMENSIONS(1:3),nWin]);
filename = sprintf('%s/IscResults/Group/SlidingWindowIsc_win%d_top-topbot',constants.dataDir,winLength);
Opt = struct('Prefix',filename,'OverWrite','y');
WriteBrik(V,Info,Opt);

V = zeros(nVox,nWin);
V(isInMask,:) = norminv(pDiffBotTB); % convert to z score
V = reshape(V,[Info.DATASET_DIMENSIONS(1:3),nWin]);
filename = sprintf('%s/IscResults/Group/SlidingWindowIsc_win%d_bot-topbot',constants.dataDir,winLength);
Opt = struct('Prefix',filename,'OverWrite','y');
WriteBrik(V,Info,Opt);