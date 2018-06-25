% Investigate whether removing IC's can lead to spurious signals.
%
% SimulateIcRemoval.m
%
% Created 9/17/15 by DJ.

signalcomp = zeros(1,20);
signalcomp(5:10) = 1;
tcSignal = -4.5:4.5;
% tcSignal = 1:10;

noisecomp = randn(1,20);
tcNoise = randn(1,10);

randnoise = randn(20,10);

data = signalcomp'*tcSignal + noisecomp'*tcNoise + randnoise;

nComps = 3;
[weights,sphere,compvars,bias,signs,lrates,activations] = runica(data,'pca',nComps);

% reconstruct (based on http://sccn.ucsd.edu/eeglab/icatutorial/icafaq.html)
reconActivations = weights*sphere*data;
reconData = pinv(weights*sphere) * reconActivations;

% Denoise by zeroing out components before reconstructing
iCompsToKeep = 1;
weights_denoised = zeros(size(weights));
weights_denoised(iCompsToKeep,:) = weights(iCompsToKeep,:);
reconActivations_denoised = weights_denoised * sphere * data;
reconData_denoised = pinv(weights_denoised*sphere) * reconActivations_denoised;

reconData_denoised_norm = zeros(size(reconData));
for i=1:length(signalcomp)
    reconData_denoised_norm(i,:) = (reconData_denoised(i,:)-mean(reconData_denoised(i,:)))/std(reconData_denoised(i,:));
end
%%
figure(142); clf;
% Plot initial data
subplot(3,3,1);
imagesc([signalcomp; noisecomp]');
set(gca,'xtick',1:2,'xticklabel',{'signal','noisecomp'});
ylabel('voxel')
title('TRUE voxel weights')
subplot(3,3,2);
plot([tcSignal;tcNoise]');
xlabel('time (samples)');
ylabel('component strength');
title('TRUE component timecourses')
legend('signal','noisecomp')
subplot(3,3,3);
imagesc(data);
xlabel('time (samples)')
ylabel('voxel')
title('TRUE signal + noisecomp + noise');
% plot ICA results
subplot(3,3,4);
imagesc(abs(weights'))
set(gca,'xtick',1:nComps);
ylabel('voxel')
title('ICA voxel weights')
subplot(3,3,5);
plot(activations');
xlabel('time (samples)');
ylabel('component strength');
title('ICA component timecourses')
legendstr = cell(1,nComps);
for i=1:nComps
    legendstr{i} = sprintf('comp%d',i);
end
legend(legendstr)
subplot(3,3,6);
imagesc(reconData);
xlabel('time (samples)')
ylabel('voxel')
title('ICA reconstructed data');

%% Get and plot denoised data
% plot denoised results
subplot(3,3,7);
imagesc(abs(weights_denoised'))
set(gca,'xtick',1:nComps);
ylabel('voxel')
title('DENOISED voxel weights')
subplot(3,3,8);
imagesc(reconData_denoised);
xlabel('time (samples)')
ylabel('voxel')
title('DENOISED reconstructed data');
subplot(3,3,9);
reconData_denoised_norm(reconData_denoised_norm(:,1)>0,:) = -reconData_denoised_norm(reconData_denoised_norm(:,1)>0,:);
imagesc(reconData_denoised_norm);
xlabel('time (samples)')
ylabel('voxel')
title('DENOISED reconstructed data (normalized)');
