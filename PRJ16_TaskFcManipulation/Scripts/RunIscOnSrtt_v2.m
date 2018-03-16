% RunIscOnSrtt_v2.m
%
% Created 3/12/18 by DJ.

info = GetSrttConstants();
subjects = info.okSubjNames;
nSubj = numel(subjects);
PRJDIR = '/data/jangrawdc/PRJ16_TaskFcManipulation';
[err, mask, maskInfo, ErrMessage] = BrikLoad(sprintf('%s/RawData/GROUP_TTEST_v3_CensorBase15-nofilt/MNI_mask_epiRes.nii',PRJDIR));
mask = (mask~=0);
nVoxels = sum(mask(:));
cd(sprintf('%s/RawData/GROUP_MEAN_v3_CensorBase15-nofilt',PRJDIR));
nT = 450;

%% Load data
allData = nan(nT,nSubj,nVoxels);
tic;
for i=1:nSubj
    fprintf('Loading subject %d/%d...\n',i,nSubj);
    % cd(sprintf('%s/RawData/%s/%s.srtt_v3',PRJDIR,subjects{i},subjects{i}));
    brik = BrikLoad(sprintf('errts.censorbase15-nofilt.%s_REML+tlrc',subjects{i}));
%     brik = BrikLoad(sprintf('all_runs_nonuisance.%s+tlrc',subjects{i}));
    for j=1:nT
        brikThis = brik(:,:,:,j);
        allData(j,i,:) = brikThis(mask);
    end
end
fprintf('Done! Took %.1f seconds.\n',toc);

%% Run ISC

% Correlate (pairwise)
pAllPairs = nan(1,nVoxels);
tic;
for i=1:nVoxels
    if mod(i,1000)==0
        fprintf('Voxel %d/%d...\n',i,nVoxels);
    end
    [r,p] = corr(allData(:,:,i),'rows','complete');
    % Get average corr coef across all subj pairs
    rAllPairs = VectorizeFc(r);
    % test for significance
    if ~all(isnan(rAllPairs))
        pAllPairs(i) = signrank(rAllPairs,0,'tail','right');   
    end
end
fprintf('Done! Took %.1f seconds.\n',toc);


%% Display results

% Form back into brick
outBrik = zeros(size(mask));
zAllPairs = -norminv(pAllPairs);
zAllPairs(isinf(zAllPairs)) = max(zAllPairs(~isinf(zAllPairs)))+1;
outBrik(mask) = zAllPairs;

% Display it
GUI_3View(outBrik);

% Write it
cd /data/jangrawdc/PRJ16_TaskFcManipulation/Results
Opt = struct('Prefix','SrttIsc_d1','OverWrite','True');
WriteBrik(outBrik,maskInfo,Opt);



%% GROUPED ISC

% Get reading scores
filename = fullfile(info.PRJDIR,'Behavioral/SRTT-Behavior_A182SRTTdata_25Jan2017.xlsx');
behTable = ReadSrttBehXlsFile(filename);
[readScore_all,isOkSubj] = GetFirstReadingScorePc(behTable);
behTableNames = cellfun(@(x) sprintf('tb%04d',str2double(x)),behTable.MRI_ID,'UniformOutput',false);
% crop to our subjects
readScore = readScore_all(ismember(behTableNames,info.okSubjNames));

% Get top-half readers w/ median split
isTopHalf = readScore>median(readScore);

%% Get median-split correlation labels
[isTopToTop,isTopToBot,isBotToBot] = deal(false(nSubj));
isTopToTop(isTopHalf,isTopHalf) = true;
isTopToBot(isTopHalf,~isTopHalf) = true;
isBotToBot(~isTopHalf,~isTopHalf) = true;
isTT_vec = VectorizeFc(isTopToTop)>0;
isTB_vec = VectorizeFc(isTopToBot)>0;
isBB_vec = VectorizeFc(isBotToBot)>0;
groupStr = repmat({'TT'},size(isTT_vec));
groupStr(isTB_vec) = repmat({'TB'},size(groupStr(isTB_vec)));
groupStr(isBB_vec) = repmat({'BB'},size(groupStr(isBB_vec)));

%% Correlate (pairwise)
[pAllPairs,rAllPairs,pTT_BB,pTT_TB,pBB_TB,pctOk,rTT_BB,rTT_TB,rBB_TB] = deal(nan(1,nVoxels));
tic;
for i=1:nVoxels
    if mod(i,1000)==0
        fprintf('Voxel %d/%d (%.1f s)...\n',i,nVoxels,toc);
    end
    [r,p] = corr(allData(:,:,i),'rows','complete');
    % Get average corr coef across all subj pairs
    rAllPairs = VectorizeFc(r);
    % test for significance
    pctOk(i) = mean(~isnan(rAllPairs))*100;
    if pctOk(i)>50 % >1/2 are real
        pAllPairs(i) = signrank(rAllPairs,0,'tail','right');   
        rAllPairs(i) = nanmedian(rAllPairs);
        % find significant differences
        pTT_BB(i) = ranksum(rAllPairs(isTT_vec),rAllPairs(isBB_vec));
        pTT_TB(i) = ranksum(rAllPairs(isTT_vec),rAllPairs(isTB_vec));
        pBB_TB(i) = ranksum(rAllPairs(isBB_vec),rAllPairs(isTB_vec));
        rTT_BB(i) = nanmedian(rAllPairs(isTT_vec))-nanmedian(rAllPairs(isBB_vec));
        rTT_TB(i) = nanmedian(rAllPairs(isTT_vec))-nanmedian(rAllPairs(isTB_vec));
        rBB_TB(i) = nanmedian(rAllPairs(isBB_vec))-nanmedian(rAllPairs(isTB_vec));
        % kruskalwallis
%         [pAllGrps(i),anovatab(i),stats(i)] = kruskalwallis(rAllPairs,grpStr);
    end
end
fprintf('Done! Took %.1f seconds.\n',toc);


%% Save Out results
outVars = {pAllPairs,pTT_BB,pTT_TB,pBB_TB};
outPs = {pAllPairs,pTT_BB,pTT_TB,pBB_TB};
outNames = {'SrttIsc_d1_all_fdr','SrttIsc_d1_TTvBB_fdr','SrttIsc_d1_TTvTB_fdr','SrttIsc_d1_BBvTB_fdr'};

% Form back into brick
for i=1:numel(outVars)
    rOut = outVars{i};
    qOut = conn_fdr(outPs{i});
    zOut = -norminv(qOut);
%     zOut = -norminv(outVars{i});
    zOut(isinf(zOut)) = max(zOut(~isinf(zOut)))+1;
    [outBrik1,outBrik2] = deal(zeros(size(mask)));
    outBrik1(mask) = rOut;
    outBrik2(mask) = zOut;
    Opt = struct('Prefix',outNames{i},'OverWrite','y');

    % Display it
    % GUI_3View(outBrik);

    % Write it
    cd /data/jangrawdc/PRJ16_TaskFcManipulation/Results
    WriteBrik(cat(4,outBrik1,outBrik2),maskInfo,Opt);
end
