% CompareReadingNetworksAcrossLosoIterations.m
%
% Created 12/30/16 by DJ.

% Get CP/CR matrices
% corr_method = 'robustfit';
% mask_method = 'cpcr';
% thresh = 1;
% [~,~,~,cp_all,cr_all] = RunLeave1outBehaviorRegression(FC,fracCorrect,thresh,corr_method,mask_method);

load('ReadingCpCr_20subj_2016-12-30');

%% Correlate between subjects

figure(234); clf;
subplot(121);
crVec = VectorizeFc(cr_all);
[rho,p] = corr(crVec);
imagesc(rho)
colorbar
xlabel('left-out subject')
ylabel('left-out subject')
title('correlation between LOSO iterations'' FC-behavior correlation coeffs')

% Same for binary vector
cpVec = VectorizeFc(cp_all);
isUnder01 = cpVec<0.01;
subplot(122);
[rho,p] = corr(isUnder01);
imagesc(rho)
colorbar
xlabel('left-out subject')
ylabel('left-out subject')
title('correlation between LOSO iterations'' p<0.01 networks')
