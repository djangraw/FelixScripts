% function script_runsynthdata

% Synthesize data, run it through Jittered LR, and compare results with
% the parameters used to produce the data.
%
% script_runsynthdata
%
% Created 8/31/11 by DJ.
% Updated 9/8/11 by DJ - use all saccades to object (to match
% SaveSyntheticData.m).

%% synthetic data
[ALLEEG, EEG, a] = SaveSyntheticData(2);

%% JLR
run_logisticregression_jittered_EM_saccades_wrapper('3DS-TAG-2-synth','allToObject_end',0,'10fold',[0 500]);

%% Posteriors
pt = GetFinalPosteriors('3DS-TAG-2-synth','noweight','allToObject_end','10fold','jrange_0_to_500');

%% Tease out results of interest
iTime = 1; %22;
startpost = [a.posteriors2; a.posteriors1];
respost = pt{1,iTime};
diffpost = respost - startpost;

res = load('results_3DS-TAG-2-synth_allToObject_endSaccades_noweightprior_10fold_jrange_0_to_500/results_10fold.mat');
startweights = a.weights;
resweights = res.vout{1}(iTime,1:end-1);
% fwd model
resfm = res.fwdmodels{1}(:,iTime);

%% Plot Az
Plot_JLR_Az('3DS-TAG-2-synth','allToObject_end','noweight','10fold','_jrange_0_to_500')

%% Plot Weights
figure(121);

subplot(1,3,1);
topoplot(startweights,EEG.chanlocs,'electrodes','on');
title('Synth data weights')
colorbar

subplot(1,3,2);
topoplot(resweights,EEG.chanlocs,'electrodes','on');
title('fold 1 weights')
colorbar

subplot(1,3,3);
topoplot(resfm,EEG.chanlocs,'electrodes','on');
title('fold 1 fwd model')
colorbar

%% Plot posteriors
figure(122);
clear c
c(1) = subplot(2,2,1);
imagesc([0 size(startpost,2)-1]*4,1:size(startpost,1),startpost)
xlabel('time (ms)')
ylabel('trial')
title('synthetic data posteriors - synth params')
colorbar;

c(2) = subplot(2,2,2);
imagesc([0 size(respost,2)-1]*4,1:size(respost,1),respost);
xlabel('time (ms)')
ylabel('trial')
title('synthetic data posteriors - JLR results')
colorbar;

c(3) = subplot(2,1,2);
imagesc([0 size(diffpost,2)-1]*4,1:size(diffpost,1),diffpost);
xlabel('time (ms)')
ylabel('trial')
title('synthetic data posteriors - (results-synth)')
colorbar;

linkaxes(c)