function [meanMotion,meanMotion_notCensored,pctCensored,fracCorrect] = CheckMotionAndComprehension(subjects)

% CheckMotionAndComprehension(subjects)
%
% Created 10/21/16 by DJ.
% Updated 12/29/16 by DJ - added outputs

% Set up
homedir = '/data/jangrawdc/PRJ03_SustainedAttention/Results';
[pctCensored,meanMotion,meanMotion_notCensored,fracCorrect] = deal(nan(numel(subjects),1));
subjectstr = cell(1,numel(subjects));

% Load and calculate
fprintf('---Loading Info...\n')
for i=1:numel(subjects)
    % enter results directory for this subject
    cd(sprintf('%s/SBJ%02d',homedir,subjects(i)));
    % Enter subdirectory
    foo = dir('AfniProc*');
    cd(foo(1).name);
    % Read in censor file
    censor_file = sprintf('censor_SBJ%02d_combined_2.1D',subjects(i));
    isNotCensored = Read_1D(censor_file);
    % Quantify % censored timepoints
    pctCensored(i) = mean(~isNotCensored)*100;
    % Read in motion norm file
    motionnorm_file = sprintf('motion_SBJ%02d_enorm.1D',subjects(i));    
    motionnorm = Read_1D(motionnorm_file);
    % Quantify mean motion in all & non-censored timepoints
    meanMotion(i) = mean(motionnorm);
    meanMotion_notCensored(i) = mean(motionnorm(isNotCensored>0));
    subjectstr{i} = sprintf('SBJ%02d',subjects(i));
    
    % Get behavior
    foo = load(sprintf('../Distraction-%d-QuickRun.mat',subjects(i)));
    isReading = strcmp('reading',foo.question.type);
    fracCorrect(i) = mean(foo.question.isCorrect(isReading));
end

% Plot results
fprintf('---Plotting results...\n')
subplot(131);
plot(meanMotion,fracCorrect*100,'.');
xlabel('Mean motion');
ylabel('comprehension accuracy (%)')
[r,p] = corr(meanMotion,fracCorrect);
title(sprintf('r=%.3g, p=%.3g',r,p));
subplot(132);
plot(meanMotion_notCensored,fracCorrect*100,'.');
xlabel('Mean motion (uncensored time points)');
ylabel('comprehension accuracy (%)')
[r,p] = corr(meanMotion_notCensored,fracCorrect);
title(sprintf('r=%.3g, p=%.3g',r,p));
subplot(133);
plot(pctCensored,fracCorrect*100,'.');
xlabel('% time points censored');
ylabel('comprehension accuracy (%)')
[r,p] = corr(pctCensored,fracCorrect);
title(sprintf('r=%.3g, p=%.3g',r,p));
fprintf('---Done!\n')


