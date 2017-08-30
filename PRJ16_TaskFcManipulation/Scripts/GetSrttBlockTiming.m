function [iStruct,iUnstruct,iBase] = GetSrttBlockTiming()

% [iStruct,iUnstruct,iBase] = GetSrttBlockTiming()
%
% Created 8/21/17 by DJ.

TR = 2;
nRuns = 3;
tRun = 300;
tStart_struct = [40 120 200];
tStart_unstruct = [20 100 180 260];
tStart_base = [0 280];
tDur_struct = 60;
tDur_unstruct = 20;
tDur_base = 20;
[iStruct,iUnstruct,iBase] = deal([]);
for i=1:nRuns
    for j=1:numel(tStart_struct)
        iStruct = [iStruct, (i-1)*tRun/TR + tStart_struct(j)/TR + (1:tDur_struct/TR)];
    end
    for j=1:numel(tStart_unstruct)
        iUnstruct = [iUnstruct, (i-1)*tRun/TR + tStart_unstruct(j)/TR + (1:tDur_unstruct/TR)];
    end
    for j=1:numel(tStart_base)
        iBase = [iBase, (i-1)*tRun/TR + tStart_base(j)/TR + (1:tDur_base/TR)];
    end
end