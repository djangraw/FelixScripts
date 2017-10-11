function CopyRawSrttDataToPrcsData(subjects)

% Created 10/6/17 by DJ.
% Updated 10/10/17 by DJ - finished.

% Parse inputs
if iscell(subjects)
    subjstr = subjects;
else % convert subject list to string list
    subjstr = cell(numel(subjects),1);
    for i=1:numel(subjects)
        subjstr = sprintf('tb%04d',subjects(i));
    end
end

for i=1:numel(subjects)
    % Set up
    fprintf('Subject %d/%d...\n',i,numel(subjects));
    % Find files
    cd(sprintf('/data/jangrawdc/PRJ16_TaskFcManipulation/RawData/%s/anat',subjstr{i}));
    anatFiles = dir('Sag3DMPRAGE*.nii.gz');
    cd(sprintf('/data/jangrawdc/PRJ16_TaskFcManipulation/RawData/%s/func_srtt',subjstr{i}));
    funcFiles = dir('ep2dbold*.nii.gz');
    
    % make symbolic links
    mkdir(sprintf('/data/jangrawdc/PRJ16_TaskFcManipulation/PrcsData/%s/D00_OriginalData/',subjstr{i}));
    mkdir(sprintf('/data/jangrawdc/PRJ16_TaskFcManipulation/PrcsData/%s/D01_Anatomical/',subjstr{i}));
    mkdir(sprintf('/data/jangrawdc/PRJ16_TaskFcManipulation/PrcsData/%s/D02_Preprocessing/',subjstr{i}));
    cd(sprintf('/data/jangrawdc/PRJ16_TaskFcManipulation/PrcsData/%s/D00_OriginalData/',subjstr{i}));
    system(sprintf('ln -s %s .',fullfile(anatFiles(1).folder,anatFiles(1).name)));
    for j=1:numel(funcFiles)
        system(sprintf('ln -s %s .',fullfile(funcFiles(j).folder,funcFiles(j).name)));
    end
    cd(sprintf('/data/jangrawdc/PRJ16_TaskFcManipulation/PrcsData/%s/D01_Anatomical/',subjstr{i}));
    system(sprintf('ln -s %s ./%s_Anat.nii.gz',fullfile(anatFiles(1).folder,anatFiles(1).name),subjstr{i}));
    cd(sprintf('/data/jangrawdc/PRJ16_TaskFcManipulation/PrcsData/%s/D02_Preprocessing/',subjstr{i}));
    for j=1:numel(funcFiles)
        system(sprintf('ln -s %s ./%s_EPI-r%02d.nii.gz',fullfile(funcFiles(j).folder,funcFiles(j).name),subjstr{i},j));
    end

end