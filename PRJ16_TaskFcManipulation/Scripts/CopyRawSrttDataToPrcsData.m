function CopyRawSrttDataToPrcsData(subjects,rawFolder,targetFolder)

% CopyRawSrttDataToPrcsData(subjects,rawFolder,targetFolder)
%
% Created 10/6/17 by DJ.
% Updated 10/10/17 by DJ - finished.
% Updated 1/29/18 by DJ - replaced hard-codes with input vars

% Declare constants/defaults
PRJDIR = '/data/jangrawdc/PRJ16_TaskFcManipulation';
if ~exist('rawFolder','var') || isempty(rawFolder)
    rawFolder = 'RawData';
end
if ~exist('targetFolder','var') || isempty(targetFolder)
    rawFolder = 'PrcsData';
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
    cd(sprintf('%s/%s/anat',rawDir,subjstr{i}));
    anatFiles = dir('Sag3DMPRAGE*.nii.gz');
    cd(sprintf('%s/%s/func_srtt',rawDir,subjstr{i}));
    funcFiles = dir('ep2dbold*.nii.gz');
    
    % make symbolic links
    mkdir(sprintf('%s/%s/D00_OriginalData/',targetDir,subjstr{i}));
    mkdir(sprintf('%s/%s/D01_Anatomical/',targetDir,subjstr{i}));
    mkdir(sprintf('%s/%s/D02_Preprocessing/',targetDir,subjstr{i}));
    cd(sprintf('%s/%s/D00_OriginalData/',targetDir,subjstr{i}));
    system(sprintf('ln -s %s .',fullfile(anatFiles(1).folder,anatFiles(1).name)));
    for j=1:numel(funcFiles)
        system(sprintf('ln -s %s .',fullfile(funcFiles(j).folder,funcFiles(j).name)));
    end
    cd(sprintf('%s/%s/D01_Anatomical/',targetDir,subjstr{i}));
    system(sprintf('ln -s %s ./%s_Anat.nii.gz',fullfile(anatFiles(1).folder,anatFiles(1).name),subjstr{i}));
    cd(sprintf('%s/%s/D02_Preprocessing/',targetDir,subjstr{i}));
    for j=1:numel(funcFiles)
        system(sprintf('ln -s %s ./%s_EPI-r%02d.nii.gz',fullfile(funcFiles(j).folder,funcFiles(j).name),subjstr{i},j));
    end

end