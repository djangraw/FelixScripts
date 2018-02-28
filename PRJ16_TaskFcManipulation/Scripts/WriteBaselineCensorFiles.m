% WriteBaselineCensorFiles.m
%
% Created 2/27/18 by DJ.

[iStruct,iUnstruct,iBase] = GetSrttBlockTiming();

for i=1:numel(subjects)
    % read in censor file
    cd(sprintf('/data/jangrawdc/PRJ16_TaskFcManipulation/RawData/%s/%s.srtt_v3',subjects{i},subjects{i}));
    [Err,censor,info] = Read_1D(sprintf('censor_%s_combined_2.1D',subjects{i}));
    % modify censor
    censor(iBase) = 0;
    % write censor file
    
end
