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
    
    % make symbolic links
     mkdir(sprintf('%s/%s/',targetDir,subjstr{i}));
    cd(sprintf('%s/%s/',targetDir,subjstr{i}));
%     system(sprintf('ln -s %s* .',anatFile));
%     system(sprintf('ln -s %s.HEAD func_final.%s+tlrc.HEAD',funcFile,subjstr{i}));
%     system(sprintf('ln -s %s.BRIK func_final.%s+tlrc.BRIK',funcFile,subjstr{i}));
    system(sprintf('3dcopy %s anat_final.%s.nii.gz',anatFile,subjstr{i}));
    system(sprintf('3dcopy %s func_final.%s.nii.gz',funcFile,subjstr{i}));
end