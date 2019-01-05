% CopyA182Data_v2.m
%
% Take data from subjects included in version 2 of the Haskins story 
% analysis and copy to the appropriate new folders.
%
% Created 1/4/19 by DJ.

%% Read behavior spreadsheet
behFile = '/data/NIMH_Haskins/a182_v2/A182IncludedSubjectBehavior_2019-01-04.xlsx';

behData = readtable(behFile);

%% For each subject, create a new folder and move the anat, story, and fastloc data into it
basedir = '/data/NIMH_Haskins/a182_v2';
transferdir = '/data/NIMH_Haskins/a182_transfer_take2';
nSubj = size(behData,1);
fprintf('Copying data for %d subjects...\n',nSubj);
tic;
for i=1:nSubj
    fprintf('subject %d/%d (%s)...\n',i,nSubj,behData.haskinsID{i})
    % Make directories
    mkdir(basedir,behData.haskinsID{i});
    cd(sprintf('%s/%s',basedir,behData.haskinsID{i}));
    mkdir('stim_times');
    mkdir('anat');
    % document this
    fid = fopen(sprintf('%s.history.txt',behData.haskinsID{i}),'w');
    fprintf(fid,'mkdir(%s,%s);\n',basedir,behData.haskinsID{i});
    fprintf(fid,'cd(''%s/%s'');\n',basedir,behData.haskinsID{i});
    fprintf(fid,'mkdir(''stim_times'');\n');
    fprintf(fid,'mkdir(''anat'');\n');
    % copy data into this folder
    try
        copyfile(sprintf('%s/%s/Sag3DMPRAGE*',transferdir,behData.storyID{i}),'anat')
        fprintf(fid,'copyfile(''%s/%s/Sag3DMPRAGE*'',''anat'');\n',transferdir,behData.storyID{i});
    catch
        fprintf('  Anat not found in storyID folder. Copying from rest folder instead.\n')
        copyfile(sprintf('%s/%s/Sag3DMPRAGE*',transferdir,behData.restID{i}),'anat')
        fprintf(fid,'copyfile(''%s/%s/Sag3DMPRAGE*'',''anat'');\n',transferdir,behData.restID{i});
    end
    copyfile(sprintf('%s/%s/func_story',transferdir,behData.storyID{i}),'func_story')
    copyfile(sprintf('%s/%s/func_fastloc',transferdir,behData.fastlocID{i}),'func_fastloc')
    copyfile(sprintf('%s/%s/stim_times/stim_times_story',transferdir,behData.storyID{i}),'stim_times/stim_times_story')
    copyfile(sprintf('%s/%s/stim_times/stim_times_fastloc',transferdir,behData.fastlocID{i}),'stim_times/stim_times_fastloc')

    fprintf(fid,'copyfile(''%s/%s/func_story'',''func_story'');\n',transferdir,behData.storyID{i});
    fprintf(fid,'copyfile(''%s/%s/func_fastloc'',''func_fastloc'');\n',transferdir,behData.fastlocID{i});
    fprintf(fid,'copyfile(''%s/%s/stim_times/stim_times_story'',''stim_times/stim_times_story'');\n',transferdir,behData.storyID{i});
    fprintf(fid,'copyfile(''%s/%s/stim_times/stim_times_fastloc'',''stim_times/stim_times_fastloc'');\n',transferdir,behData.fastlocID{i});
    fclose(fid);
end
fprintf('Done! Took %.1f seconds.\n',toc);

%% do quality check
isBad = false(1,nSubj);
for i=1:nSubj
    fprintf('subject %d/%d (%s)...\n',i,nSubj,behData.haskinsID{i})
    cd(sprintf('%s/%s',basedir,behData.haskinsID{i}));
    if length(dir('anat'))<1
        disp no anat
    end
    if length(dir('func_story'))<2
        disp missing story data
        isBad(i) = true;
    end
    if length(dir('func_fastloc'))<2
        disp missing fastloc data
        isBad(i) = true;
    end
    if length(dir('stim_times'))<2
        disp missing stim times
        isBad(i) = true;
    end
end
fprintf('%d/%d subjects ok.\n',sum(~isBad),nSubj)