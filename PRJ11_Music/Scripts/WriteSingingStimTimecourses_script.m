% WriteSingingStimTimecourses_script.m
%
% Created 4/20/17 by DJ.
subjName = 'SBJ03';
runTypes = {'task'};%,'baseline','improv','wholesong'};
homedir = '/data/jangrawdc/PRJ11_Music';
for i=1:numel(runTypes)
    % Load data
    load(sprintf('%s/PrcsData/%s_%s/D02_Behavior/%s_%s_behavior.mat',homedir,subjName,runTypes{i},subjName,runTypes{i}));
    % Write results
    outDir = sprintf('%s/Results/%s_%s/stimuli',homedir,subjName,runTypes{i});
    mkdir(outDir);
    % Write files
    WriteSingingStimTimecourses(data,outDir,sprintf('%s_%s',subjName,runTypes{i}));
end