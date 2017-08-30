%% SeparateSingingTasks
%
% Created 4/20/17 by DJ.

%% Task data
subjName = 'SBJ03';
outName = 'SBJ03_task';
scans = [24 27 30 33 36 39 42 45];
echoSuffices = {'','_echo02','_echo03'};

% Make directories
cd /data/jangrawdc/PRJ11_Music/PrcsData/
mkdir(outName);
mkdir(sprintf('%s/D00_OriginalData',outName));
mkdir(sprintf('%s/D01_Anatomical',outName));
% Copy functional scans
for i=1:numel(scans)
    for j=1:numel(echoSuffices)
        inFile = sprintf('%s_scan%03d_fmri_3mm_iso_pa_3_echoes%s+orig',subjName,scans(i),echoSuffices{j});
        outFile = sprintf('%s_Run%02d_e%d',outName,i,j);
        cmd = sprintf('3dcopy -overwrite %s/D00_OriginalData/%s %s/D00_OriginalData/%s',...
            subjName,inFile,outName,outFile);
        system(cmd);
    end
end
% Copy anatomical scans
inFile = sprintf('%s_Anat_bc_ns+orig',subjName);
outFile = sprintf('%s_Anat_bc_ns',outName);
cmd = sprintf('3dcopy -overwrite %s/D01_Anatomical/%s %s/D01_Anatomical/%s',...
    subjName,inFile,outName,outFile);
system(cmd);


%% Baseline scans
outName = 'SBJ03_baseline';
scans = [14 48];

% Make directories
cd /data/jangrawdc/PRJ11_Music/PrcsData/
mkdir(outName);
mkdir(sprintf('%s/D00_OriginalData',outName));
mkdir(sprintf('%s/D01_Anatomical',outName));
% Copy functional scans
for i=1:numel(scans)
    for j=1:numel(echoSuffices)
        inFile = sprintf('%s_scan%03d_fmri_3mm_iso_pa_3_echoes%s+orig',subjName,scans(i),echoSuffices{j});
        outFile = sprintf('%s_Run%02d_e%d',outName,i,j);
        cmd = sprintf('3dcopy -overwrite %s/D00_OriginalData/%s %s/D00_OriginalData/%s',...
            subjName,inFile,outName,outFile);
        system(cmd);
    end
end
% Copy anatomical scans
inFile = sprintf('%s_Anat_bc_ns+orig',subjName);
outFile = sprintf('%s_Anat_bc_ns',outName);
cmd = sprintf('3dcopy -overwrite %s/D01_Anatomical/%s %s/D01_Anatomical/%s',...
    subjName,inFile,outName,outFile);
system(cmd);
        
%% Improv scan
outName = 'SBJ03_improv';
scans = [14 51];

% Make directories
cd /data/jangrawdc/PRJ11_Music/PrcsData/
mkdir(outName);
mkdir(sprintf('%s/D00_OriginalData',outName));
mkdir(sprintf('%s/D01_Anatomical',outName));
% Copy functional scans
for i=1:numel(scans)
    for j=1:numel(echoSuffices)
        inFile = sprintf('%s_scan%03d_fmri_3mm_iso_pa_3_echoes%s+orig',subjName,scans(i),echoSuffices{j});
        outFile = sprintf('%s_Run%02d_e%d',outName,i,j);
        cmd = sprintf('3dcopy -overwrite %s/D00_OriginalData/%s %s/D00_OriginalData/%s',...
            subjName,inFile,outName,outFile);
        system(cmd);
    end
end
% Copy anatomical scans
inFile = sprintf('%s_Anat_bc_ns+orig',subjName);
outFile = sprintf('%s_Anat_bc_ns',outName);
cmd = sprintf('3dcopy -overwrite %s/D01_Anatomical/%s %s/D01_Anatomical/%s',...
    subjName,inFile,outName,outFile);
system(cmd);

%% Whole-song scan
outName = 'SBJ03_wholesong';
scans = 54;

% Make directories
cd /data/jangrawdc/PRJ11_Music/PrcsData/
mkdir(outName);
mkdir(sprintf('%s/D00_OriginalData',outName));
mkdir(sprintf('%s/D01_Anatomical',outName));
% Copy functional scans
for i=1:numel(scans)
    for j=1:numel(echoSuffices)
        inFile = sprintf('%s_scan%03d_fmri_3mm_iso_pa_3_echoes%s+orig',subjName,scans(i),echoSuffices{j});
        outFile = sprintf('%s_Run%02d_e%d',outName,i,j);
        cmd = sprintf('3dcopy -overwrite %s/D00_OriginalData/%s %s/D00_OriginalData/%s',...
            subjName,inFile,outName,outFile);
        system(cmd);
    end
end
% Copy anatomical scans
inFile = sprintf('%s_Anat_bc_ns+orig',subjName);
outFile = sprintf('%s_Anat_bc_ns',outName);
cmd = sprintf('3dcopy -overwrite %s/D01_Anatomical/%s %s/D01_Anatomical/%s',...
    subjName,inFile,outName,outFile);
system(cmd);

%% Separate data files by task type
biopacFilenames = {'DJ_test_sub_032017-04-15T16_55_08.mat' ...
    'DJ_test_sub_032017-04-15T16_58_43.mat' ...
    'DJ_test_sub_032017-04-15T17_01_24.mat' ...
    'DJ_test_sub_032017-04-15T17_07_18.mat' ...
    'DJ_test_sub_032017-04-15T17_14_10.mat' ...
    'DJ_test_sub_032017-04-15T17_20_20.mat' ...
    'DJ_test_sub_032017-04-15T17_26_21.mat' ...
    'DJ_test_sub_032017-04-15T17_32_42.mat' ...
    'DJ_test_sub_032017-04-15T17_38_42.mat' ...
    'DJ_test_sub_032017-04-15T17_45_51.mat' ...
    'DJ_test_sub_032017-04-15T17_53_19.mat' ...
    'DJ_test_sub_032017-04-15T17_59_36.mat' ...
    'DJ_test_sub_032017-04-15T18_04_16.mat' ...
    'DJ_test_sub_032017-04-15T18_09_27.mat'};


%%
subject = 3;
outPath = '/data/jangrawdc/PRJ11_Music/PrcsData';

% Task version
iRuns = 4:11;
outName = 'SBJ03_task';
% Import
cd /data/jangrawdc/PRJ11_Music/RawData/SBJ03/behavior
data = ImportSingingBehaviorAndPhysio(subject,iRuns,biopacFilenames(iRuns));
% save
mkdir(sprintf('%s/%s/D02_Behavior',outPath,outName));
save(sprintf('%s/%s/D02_Behavior/%s_behavior.mat',outPath,outName,outName),'data');

%% Baseline version
iRuns = [2 12];
outName = 'SBJ03_baseline';
% Import
cd /data/jangrawdc/PRJ11_Music/RawData/SBJ03/behavior
data = ImportSingingBehaviorAndPhysio(subject,iRuns,biopacFilenames(iRuns));
% save
mkdir(sprintf('%s/%s/D02_Behavior',outPath,outName));
save(sprintf('%s/%s/D02_Behavior/%s_behavior.mat',outPath,outName,outName),'data');

%% Improv version
iRuns = 13;
outName = 'SBJ03_improv';
% Import
cd /data/jangrawdc/PRJ11_Music/RawData/SBJ03/behavior
data = ImportSingingBehaviorAndPhysio(subject,iRuns,biopacFilenames(iRuns));
% save
mkdir(sprintf('%s/%s/D02_Behavior',outPath,outName));
save(sprintf('%s/%s/D02_Behavior/%s_behavior.mat',outPath,outName,outName),'data');

%% Whole-song version
iRuns = 14;
outName = 'SBJ03_wholesong';
% Import
homedir = '/data/jangrawdc/PRJ11_Music/';
cd /data/jangrawdc/PRJ11_Music/RawData/SBJ03/behavior
clear data
data.params.trialTypes = {'WholeSong'};
data.physio = ImportBiopacData(sprintf('%s/RawData/SBJ%02d/physio/%s',homedir,subject,biopacFilenames{iRuns}));
% save
mkdir(sprintf('%s/%s/D02_Behavior',outPath,outName));
save(sprintf('%s/%s/D02_Behavior/%s_behavior.mat',outPath,outName,outName),'data');


