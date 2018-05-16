function [iAud,iVis,iBase] = GetStoryBlockTiming()

% [iAud,iVis,iBase] = GetStoryBlockTiming()
%
% Note that these are based on the c0_resting.txt, c1_auditory.txt, and
% c2_visual.txt files.
%
% Created 5/15/18 by DJ based on GetSrttBlockTiming.

TR = 2;
nRuns = 2;
tRun = 360;
tStart_aud = [123 249; 74 191]-10;
tStart_vis = [72 188; 138 252]-10;
tStart_base = [12 310; 12 307]-10;
tDur_aud = [64 60; 62 59];
tDur_vis = [48 59; 51 54];
tDur_base = [60 62; 62 64];
[iAud,iVis,iBase] = deal([]);
for i=1:nRuns
    for j=1:size(tStart_aud,2)
        iAud = cat(2,iAud, (i-1)*tRun/TR + tStart_aud(i,j)/TR -1 + (1:tDur_aud(i,j)/TR));
    end
    for j=1:size(tStart_vis,2)
        iVis = cat(2,iVis, (i-1)*tRun/TR + tStart_vis(i,j)/TR -1 + (1:tDur_vis(i,j)/TR));
    end
    for j=1:size(tStart_base,2)
        iBase = cat(2,iBase, (i-1)*tRun/TR + tStart_base(i,j)/TR -1 + (1:tDur_base(i,j)/TR));
    end
end
% round
iAud = round(iAud);
iVis = round(iVis);
iBase = round(iBase);