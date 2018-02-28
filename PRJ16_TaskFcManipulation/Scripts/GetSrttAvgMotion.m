function [motAmp,rotAmp] = GetSrttAvgMotion(subjects)

% [motAmp,rotAmp] = GetSrttAvgMotion(subjects)
%
% Created 2/27/18 by DJ.

% Set up
doCensor=true;
nT = 450;
[motAmp, rotAmp, censor] = deal(nan(nT,numel(subjects)));

% Load and compile
fprintf('Plotting...\n');
for i=1:numel(subjects)
    cd(sprintf('/data/jangrawdc/PRJ16_TaskFcManipulation/RawData/%s/%s.srtt_v3',subjects{i},subjects{i}));
    mot = Read_1D('motion_deriv.1D');
    motAmp(:,i) = sqrt(mean(mot(:,1:3).^2,2)); % convert to RMS
    rotAmp(:,i) = sqrt(mean(mot(:,4:6).^2,2)); % convert to RMS
    % censor
    censor(:,i) = Read_1D(sprintf('censor_%s_combined_2.1D',subjects{i}));
end

% censor = motAmp<0.1;
if doCensor
    motAmp = motAmp.*censor;
    rotAmp = rotAmp.*censor;
    censorSuffix = '(with censoring)';
else
    censorSuffix = '';
end

fprintf('Plotting...\n');
% Plot results
figure(622); clf
subplot(2,1,1); hold on;
title(sprintf('Mean +/- ste motion across %d SRTT subjects %s',numel(subjects),censorSuffix));
plot(mean(motAmp,2),'b','linewidth',2);
steMot = std(motAmp,[],2)/sqrt(numel(subjects));
% ErrorPatch((1:nT)',mean(motAmp,2),steMot);
plot(mean(motAmp,2)+steMot,'b:');
plot(mean(motAmp,2)-steMot,'b:');
xlabel('time (samples)')
ylabel('motion (rms across directions)');
subplot(2,1,2); hold on;
plot(mean(rotAmp,2),'b','linewidth',2);
steRot = std(rotAmp,[],2)/sqrt(numel(subjects));
% ErrorPatch((1:nT)',mean(rotAmp,2),steRot);
plot(mean(rotAmp,2)+steRot,'b:');
plot(mean(rotAmp,2)-steRot,'b:');
xlabel('time (samples)')
ylabel('rotation (rms across directions)');

fprintf('Done!\n');

