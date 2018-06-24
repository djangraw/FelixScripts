% SimulateItiDistribution.m
%
% Simulates inter-trial interval distribution given a constant probability
% of a trial starting in every frame (but each ITI must be at least 2
% seconds).
%
% Created 7/17/17 by DJ.

minITI = 2;
pStimAtEachTimeStep = 0.003;
dt = 1/60;
isOn = rand(1,100000000)<pStimAtEachTimeStep;

ITI = diff(find(isOn))*dt + minITI;

hist(ITI,100);

fprintf('mean = %g, 10%% = %g, median = %g, 90%% = %g\n',mean(ITI), ...
    GetValueAtPercentile(ITI, 10), median(ITI),GetValueAtPercentile(ITI,90));