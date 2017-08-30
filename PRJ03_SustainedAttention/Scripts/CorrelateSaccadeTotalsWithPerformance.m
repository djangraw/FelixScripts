% CorrelateSaccadeTotalsWithPerformance.m
%
% Created 1/23/17 by DJ.

%% Declare constants
% subjects = [9:11 13:19 22 24:25 28 30:33 36];

%% Get performance
% [fracCorrect, RT] = GetFracCorrect_AllSubjects(subjects);

%% Get # saccades for each subject
onlyOkSamples = true;
[sacRate_all,blinkRate_all,sacRate_runs] = GetSaccadeRate(subjects, onlyOkSamples);

%% Get pupil dilation for each subject
delay = 0;
[pd_all,pd_runs] = GetSubjectPupilDilation(subjects,delay);

%% Correlate & plot

figure(623); clf;
[r,p] = corr(fracCorrect,sacRate_all');
fprintf('fracCorrect vs. # saccades/sec: r=%.3g, p=%.3g\n',r,p);
subplot(131);
lm = fitlm(fracCorrect*100,sacRate_all,'Linear');
lm.plot;
xlabel('% correct on reading comprehension');
ylabel('mean # saccades per second');
title(sprintf('saccade rate vs. reading comprehension\nr=%.3g, p=%.3g',r,p));
axis square

[r,p] = corr(fracCorrect,blinkRate_all');
fprintf('fracCorrect vs. # blinks/sec: r=%.3g, p=%.3g\n',r,p);
subplot(132);
lm = fitlm(fracCorrect*100,blinkRate_all,'Linear');
lm.plot;
xlabel('% correct on reading comprehension');
ylabel('mean # blinks per second');
title(sprintf('blink rate vs. reading comprehension\nr=%.3g, p=%.3g',r,p));
axis square

[r,p] = corr(fracCorrect,pd_all');
fprintf('fracCorrect vs. # blinks/sec: r=%.3g, p=%.3g\n',r,p);
subplot(133);
lm = fitlm(fracCorrect*100,pd_all,'Linear');
lm.plot;
xlabel('% correct on reading comprehension');
ylabel('mean pupil dilation');
title(sprintf('pupil dilation vs. reading comprehension\nr=%.3g, p=%.3g',r,p));
axis square
