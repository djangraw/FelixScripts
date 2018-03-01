% WriteBaselineCensorFiles.m
%
% Created 2/27/18 by DJ.

info = GetSrttConstants();
subjects = info.okSubjNames;

[iStruct,iUnstruct,iBase] = GetSrttBlockTiming();

for i=1:numel(subjects)
    % read in censor file
    cd(sprintf('/data/jangrawdc/PRJ16_TaskFcManipulation/RawData/%s/%s.srtt_v3',subjects{i},subjects{i}));
    [Err,censor,info] = Read_1D(sprintf('censor_%s_combined_2.1D',subjects{i}));
    % modify censor
    censor(iBase) = 0;
    % write censor file
    fid = fopen(sprintf('censor_%s_combined_2_nobase.1D',subjects{i}),'w');
    fprintf(fid,'%d\n',censor);
    fclose(fid);
end
