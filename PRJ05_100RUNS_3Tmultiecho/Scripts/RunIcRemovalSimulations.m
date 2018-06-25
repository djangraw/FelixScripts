% function RunIcRemovalSimulations
%
% Created 9/17/15 by DJ.


%% Run denoising simulations
nRuns = 100;
nComps = 3;
nVoxels = 50;
nT = 10;

% declare signal
signalcomp = zeros(1,nVoxels);
signalcomp(5:10) = 1;
tcSignal = (1:nT)-mean(1:nT);
% Set up
[dataIn, dataOut] = deal(zeros([numel(signalcomp),numel(tcSignal),nRuns]));
% Run simulations
for i=1:nRuns
    % Get noise component
    noisecomp = randn(1,nVoxels);
    tcNoise = randn(1,nT);
    % Get random noise (not a consistent component)
    randnoise = randn(nVoxels,nT);
    % combine into data
    data = signalcomp'*tcSignal + noisecomp'*tcNoise + randnoise;

    % Run ICA
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
        
    % Create output
    dataIn(:,:,i) = data;
    dataOut(:,:,i) = reconData_denoised;
end

%% Run ISC
% calculate matrix of means across other subjects
fprintf('=== %s - Calculating Means ===\n',datestr(now,0));
meanothers = zeros(size(dataOut));
for iRun=1:nRuns
    fprintf('%s - run %d/%d...\n',datestr(now,0),iRun,nRuns);
    meanothers(:,:,iRun) = mean(dataOut(:,:,[1:iRun-1, iRun+1:nRuns]),3);
end

% find correlations
coeff = zeros(1,nVoxels);
fprintf('=== %s - Calculating Correlation Coefficients ===\n',datestr(now,0));
for i=1:nVoxels
    fprintf('%s - voxel %d/%d...\n',datestr(now,0),i,nVoxels);
    for iRun = 1:nRuns
        this = dataOut(i,:,iRun);
        other = meanothers(i,:,iRun);
        r = corrcoef(this,other); 
        coeff(i,iRun) = r(1,2);               
    end
end

% compare to zero
[hval, pval] = deal(zeros(1,nVoxels));
fprintf('=== %s - Calculating P Values ===\n',datestr(now,0));
for i=1:nVoxels    
    [hval(i),pval(i)] = ttest(coeff(i,:),0);                    
end

%insert false discovery rate correction here
multcompare = 'fdr';
pval_adj = pval;
switch multcompare
    case {'none',''}
        pval_adj = pval;
    case 'fdr' % false discovery rate
        isHigh = pval>0.5;
        pval(isHigh) = 1-pval(isHigh);        
        pval_adj = reshape(mafdr(pval(:),'bhfdr',true),size(pval));
        pval_adj(isHigh) = 1-pval_adj(isHigh);
    case {'bonferroni','bonf'} % bonferroni correction
        isHigh = pval>0.5;
        pval(isHigh) = 1-pval(isHigh);
        pval_adj = bonf_holm(pval);
        pval_adj(pval_adj>0.5) = 0.5;
        pval_adj(isHigh) = 1-pval_adj(isHigh);
    otherwise
        error('multiple comparisons method not recognized!');
end
hval_adj = pval_adj<0.05;

%% Plot true signal and stat tests

figure(142); clf;
% Plot initial data
subplot(2,3,1);
imagesc([signalcomp; noisecomp]');
set(gca,'xtick',1:2,'xticklabel',{'signal','noisecomp'});
ylabel('voxel')
title('TRUE voxel weights')
subplot(2,3,2);
plot([tcSignal;tcNoise]');
xlabel('time (samples)');
ylabel('component strength');
title('TRUE component timecourses')
legend('signal','noisecomp')
subplot(2,3,3);
imagesc(mean(dataIn,3));
xlabel('time (samples)')
ylabel('voxel')
title('TRUE signal + noisecomp + noise');

% Plot distributions of data
subplot(2,2,3);
imagesc(mean(dataOut,3));
xlabel('time (samples)')
ylabel('voxel')
title('DENOISED signal + noisecomp + noise');

% Plot p values
subplot(2,2,4);
plot(pval_adj); hold on;
plot(find(hval_adj==1),pval_adj(hval_adj==1),'r*');
plot(signalcomp);
legend('ISC p value',sprintf('p_{%s}<0.05',multcompare),'true component');