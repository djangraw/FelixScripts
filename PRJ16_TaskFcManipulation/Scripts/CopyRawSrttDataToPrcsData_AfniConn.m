function CopyRawSrttDataToPrcsData_AfniConn(subjects,rawFolder,targetFolder)

% CopyRawSrttDataToPrcsData_AfniConn(subjects,rawFolder,targetFolder)
%
% Created 10/6/17 by DJ.
% Updated 10/10/17 by DJ - finished.
% Updated 1/29/18 by DJ - replaced hard-codes with input vars, switched to
%   AfniConn version

% Declare constants/defaults
PRJDIR = '/data/jangrawdc/PRJ16_TaskFcManipulation';
if ~exist('rawFolder','var') || isempty(rawFolder)
    rawFolder = 'RawData';
end
if ~exist('targetFolder','var') || isempty(targetFolder)
    targetFolder = 'AfniConn';
end
if iscell(subjects)
    subjstr = subjects;
else % convert subject list to string list
    subjstr = cell(numel(subjects),1);
    for i=1:numel(subjects)
        subjstr{i} = sprintf('tb%04d',subjects(i));
    end
end
% Declare directories
rawDir = fullfile(PRJDIR,rawFolder);
targetDir = fullfile(PRJDIR,targetFolder);

% Main loop for copying data
for i=1:numel(subjects)
    % Set up
    fprintf('Subject %d/%d...\n',i,numel(subjects));

    % Find files
    anatFile = sprintf('%s/%s/%s.srtt_v3/anat_final.%s+tlrc',rawDir,subjstr{i},subjstr{i},subjstr{i});
    funcFile = sprintf('%s/%s/%s.srtt_v3/all_runs_nonuisance_nowmcsf.%s+tlrc',rawDir,subjstr{i},subjstr{i},subjstr{i});
    gmFile = sprintf('%s/%s/%s.srtt_v3/Segsy/GM_Classes+tlrc',rawDir,subjstr{i},subjstr{i});
    wmFile = sprintf('%s/%s/%s.srtt_v3/Segsy/WM_Classes+tlrc',rawDir,subjstr{i},subjstr{i});
    csfFile = sprintf('%s/%s/%s.srtt_v3/Segsy/CSF_Classes+tlrc',rawDir,subjstr{i},subjstr{i});
    funcFile2 = sprintf('%s/%s/%s.srtt_v3/errts.censorbase15-nofilt.%s_REML+tlrc',rawDir,subjstr{i},subjstr{i},subjstr{i});
    % make symbolic links
%     mkdir(sprintf('%s/%s/',targetDir,subjstr{i}));
    cd(sprintf('%s/%s/',targetDir,subjstr{i}));
%     system(sprintf('ln -s %s* .',anatFile));
%     system(sprintf('ln -s %s.HEAD func_final.%s+tlrc.HEAD',funcFile,subjstr{i}));
%     system(sprintf('ln -s %s.BRIK func_final.%s+tlrc.BRIK',funcFile,subjstr{i}));
%     system(sprintf('3dcopy %s anat_final.%s.nii.gz',anatFile,subjstr{i}));
    system(sprintf('3dcopy -overwrite %s func_censored.%s.nii',funcFile2,subjstr{i}));
%     system(sprintf('3dcopy %s GM_mask.%s.nii',gmFile,subjstr{i}));
%     system(sprintf('3dcopy %s WM_mask.%s.nii',wmFile,subjstr{i}));
%     system(sprintf('3dcopy %s CSF_mask.%s.nii',csfFile,subjstr{i}));

end