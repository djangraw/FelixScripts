% SetUpAfniProc_v2.m
%
% Created 12/18/17 by DJ.

homedir = '/data/jangrawdc/PRJ16_TaskFcManipulation/RawData';
cd(homedir)
foo = dir('tb00*'); 
earlySubjects = {foo(:).name};
for i=1:numel(earlySubjects)
    cd(sprintf('%s/%s',homedir,earlySubjects{i}));
    rmdir(sprintf('%s.srtt_v2',earlySubjects{i}),'s');
    delete(sprintf('afni_srtt_v2_%s.tcsh',earlySubjects{i}));
    delete(sprintf('output.afni_srtt_v2_%s_tcsh',earlySubjects{i}));
end

%%
cd(homedir)
foo = dir('tb*'); 
subjects = {foo(:).name};
bashCmd = sprintf('bash afni_proc_SRTT_v2_swarm.sh %s',strjoin(subjects,' '));
fprintf([bashCmd '\n']);
system(bashCmd);