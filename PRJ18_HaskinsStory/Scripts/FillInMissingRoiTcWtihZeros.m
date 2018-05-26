% FillInMissingRoiTcWtihZeros.m
%
% Created 5/23/18 by DJ.

%% Write missing ROI
cd('/data/NIMH_Haskins/a182/tb0275/tb0275.storyISC_d2');
tmp = Read_1D('tmp.ROI024_TS.1D');
fid = fopen('tmp.ROI243_TS.1D','w');
for i=1:numel(tmp)
    fprintf(fid,'0\n');
end
fclose(fid);

%% concatenate
system('1dcat tmp.ROI*.1D >> shents.tb0275.roi_ROI_TS.1D');