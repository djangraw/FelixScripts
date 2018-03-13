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
