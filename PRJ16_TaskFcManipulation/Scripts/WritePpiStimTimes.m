% WritePpiStimTimes.m
%
% Created 10/3/17 by DJ.

%% Unstructured
isInCond = zeros(1,150);
tBlocks = [20 100 180 260];
dBlock = 20;
for i=1:numel(tBlocks)
    isInCond(tBlocks(i)+(1:dBlock)) = 1;
end
iInCond = find(isInCond);
% Write to file
fid = fopen('c1_unstr_stimtimes.txt','w');
for i=1:numel(iInCond)
    fprintf(fid,'%s ',num2str(iInCond(i)));
end
fprintf(fid,'\n');
% fprintf(fid,'%s\n',num2str(find(isInCond)));
fclose(fid);

%% Structured

isInCond = zeros(1,150);
tBlocks = [40 120 20];
dBlock = 60;
for i=1:numel(tBlocks)
    isInCond(tBlocks(i)+(1:dBlock)) = 1;
end
iInCond = find(isInCond);
% Write to file
fid = fopen('c2_str_stimtimes.txt','w');
for i=1:numel(iInCond)
    fprintf(fid,'%s ',num2str(iInCond(i)));
end
fprintf(fid,'\n');
% fprintf(fid,'%s\n',num2str(find(isInCond)));
fclose(fid);

%% Baseline

isInCond = zeros(1,150);
tBlocks = [0 280];
dBlock = 20;
for i=1:numel(tBlocks)
    isInCond(tBlocks(i)+(1:dBlock)) = 1;
end
iInCond = find(isInCond);
% Write to file
fid = fopen('c0_baseline_stimtimes.txt','w');
for i=1:numel(iInCond)
    fprintf(fid,'%s ',num2str(iInCond(i)));
end
fprintf(fid,'\n');
% fprintf(fid,'%s\n',num2str(find(isInCond)));
fclose(fid);
