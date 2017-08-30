% WriteAfniTimingFiles_script
%
% Created 3/14/16 by DJ.
% Updated 5/19/16 by DJ - modified GLT files to match new categories
% (ignored/attended Noise/Speech)
% Updated 1/13/17 by DJ - added all-reading-condition GLT files

subjects = 9:36;
homedir = '/data/jangrawdc/PRJ03_SustainedAttention/Results';
TR = 2;
nFirstTRsRemoved = 3;
% nTRsPerSession = 252-nFirstTRsRemoved;
doRound = false;

for i=1:numel(subjects)
    if subjects(i)==9
        nTRsPerSession = 243;
    else
        nTRsPerSession = 249;
    end
    % get into directory
    cd(sprintf('%s/SBJ%02d',homedir,subjects(i)))
    % Read data file
%     load(sprintf('Distraction-%d-QuickRun',subjects(i)));
    load(sprintf('Distraction-SBJ%02d-Behavior',subjects(i)));
    % Move into AfniProc folder
%     foo = dir('AfniProc*');
%     cd(foo(1).name);
    % make stimuli folder
    mkdir stimuli
    % Write timing files
    WritePageTimesToAfniTimingFiles(data,sprintf('stimuli/SBJ%02d',subjects(i)),TR,nFirstTRsRemoved,nTRsPerSession,doRound);
end

%%
for i=1:numel(subjects)
    % get into directory
    cd(sprintf('%s/SBJ%02d',homedir,subjects(i)))
    % make glt folder
    mkdir glt_files
    cd glt_files
    % write files
    fid = fopen('glt_speech_ign-att.txt','w');
    fprintf(fid,'+ignoredSpeech -attendedSpeech');
    fclose(fid);
    fid = fopen('glt_noise_ign-att.txt','w');
    fprintf(fid,'+ignoredNoise -attendedNoise');
    fclose(fid);
    fid = fopen('glt_noise-speech.txt','w');
    fprintf(fid,'+ignoredNoise +attendedNoise -ignoredSpeech -attendedSpeech');
    fclose(fid);
    fid = fopen('glt_speech.txt','w');
    fprintf(fid,'+ignoredSpeech +attendedSpeech');
    fclose(fid);
    % New 1/13/17
    fid = fopen('glt_read.txt','w');
    fprintf(fid,'+ignoredSpeech +attendedSpeech +ignoredNoise +attendedNoise');
    fclose(fid);
    fid = fopen('glt_read-fix.txt','w');
    fprintf(fid,'+ignoredSpeech +attendedSpeech +ignoredNoise +attendedNoise -4*fixation');
    fclose(fid);
end