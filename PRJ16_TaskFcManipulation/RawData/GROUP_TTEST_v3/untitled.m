subjects = {'tb0065' 'tb0093' 'tb0137'};
nSubj = numel(subjects);
PRJDIR = '/data/jangrawdc/PRJ16_TaskFcManipulation';
cd(sprintf('%s/RawData/GROUP_TTEST_v3',PRJDIR));
mask = BrikLoad(sprintf('%s/RawData/GROUP_TTEST_v3/MNI_mask.nii',PRJDIR));
mask = (mask~=0);
nVoxels = sum(mask(:));
allData = nan(nVoxels,nSubj);
cd(sprintf('%s/RawData/GROUP_MEAN_v3',PRJDIR));
for i=1:nSubj
    fprintf('Loading subject %d/%d...\n',i,nSubj);
    % cd(sprintf('%s/RawData/%s/%s.srtt_v3',PRJDIR,subjects{i},subjects{i}));
%     brik = BrikLoad(sprintf('errts.%s_REML+tlrc',subjects{i}));
    brik = BrikLoad(sprintf('all_runs_nonuisance.%s+tlrc',subjects{i}));
    allData(:,i) = brik(mask);
end