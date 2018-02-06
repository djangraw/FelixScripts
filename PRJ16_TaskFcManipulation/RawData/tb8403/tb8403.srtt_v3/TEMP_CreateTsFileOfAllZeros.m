% TEMP_CreateTsFileOfAllZeros.m
%
% Created 2/5/18 by DJ.

cd /gpfs/gsfs8/users/jangrawdc/PRJ16_TaskFcManipulation/RawData/tb8403/tb8403.srtt_v3
fid = fopen('tmp.ROI240_TS.1D','w');
for i=1:450
    fprintf(fid,'0\n');
end
fclose(fid);