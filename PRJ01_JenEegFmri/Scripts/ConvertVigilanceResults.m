% Convert from VigilanceResults files saved by FindVigilance_script to more
% intuitive variable names.
%
% ConvertVigilanceResults.m
%
% Created 1/9/15 by DJ.
% Updated 1/14/15 by DJ - new version.

clear
% load results from FindVigilance_script
% foo = load('VigilanceResults_Jan09_v3.mat');
foo = load('VigilanceResults_2015-01-14_1859.mat');

% convert most interpretable variables
foo2.subjects = foo.subjects;
foo2.tasks = foo.tasks;
foo2.filenames = foo.filenames;
foo2.HRF = foo.HRF;
foo2.tTR = foo.tTR;
foo2.t_Hrf = foo.t_common;

for i=1:numel(foo.bandNames)
    foo2.(sprintf('%sLimits',foo.bandNames{i})) = foo.bandLimits{i};
    foo2.(sprintf('%sPower',foo.bandNames{i})) = foo.power(:,:,i);
    foo2.(sprintf('%sChans',foo.bandNames{i})) = foo.bandChans{i};
    foo2.(sprintf('%sAvg',foo.bandNames{i})) = foo.avgPower(:,:,i);
    foo2.(sprintf('%sAvg_Hrf',foo.bandNames{i})) = foo.avgPower_hrf{i}; 
    foo2.(sprintf('%sAvg_AlignedHrf',foo.bandNames{i})) = foo.avgPower_hrf_rampaligned{i}; 
end

%% save
UnpackStruct(foo2);
clear foo*
save(sprintf('VigilanceTracking_%s_%s',datestr(now,'mm-dd'),datestr(now,'HHMM')));
