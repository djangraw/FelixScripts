function [Rvalues, Pvalues] = GetJitterPosteriorCorrelations(JLR,JLP,post_option)

% [Rvalues, Pvalues] = GetJitterPosteriorCorrelations(JLR,JLP,post_option)
%
% INPUTS:
% -JLR and JLP are the output structs of LoadJlrResults.
% -post_option is a field (i.e. 'post_truth'... see AverageJlrResults for
% details)
%
% OUTPUTS:
% -Rvalues is an n-element vector, where n is the number of windows
% (i.e., length(JLR.trainingwindowoffset)). Rvalues(i) is the correlation
% coefficient between the 'true jitter time' and the time of max posteriors
% in window i.
% -Pvalues is an n-element vector. Pvalues(i) is the probability that there
% is no correlation between the two (as reported by corrcoef).
%
% Created 9/28/12 by DJ.
% Updated 12/31/12 by DJ - added post_option

if nargin<3 || isempty(post_option)
    post_option = 'post';
end

% Set up
nWin = numel(JLR.trainingwindowoffset);
tWin = JLP.ALLEEG(1).times(round(JLR.trainingwindowoffset+JLR.trainingwindowlength/2));
[jitter, truth] = GetJitter(JLP.ALLEEG,'facecar');

% Calculate (make new figure, then close it at the end)
Rvalues = nan(3,nWin);
Pvalues = nan(3,nWin);
figure;
for i=1:nWin
    peakTimeError = PlotJlrFoms(JLR,JLP,i,post_option);
    [R0 P0] = corrcoef(peakTimeError(truth==0)+jitter(truth==0),jitter(truth==0));
    [R1 P1] = corrcoef(peakTimeError(truth==1)+jitter(truth==1),jitter(truth==1));
    [Rall Pall] = corrcoef(peakTimeError+jitter,jitter);
    Rvalues(:,i) = [R0(1,2); R1(1,2); Rall(1,2)];
    Pvalues(:,i) = [P0(1,2); P1(1,2); Pall(1,2)];
end
close(gcf);

%% Plot results
clf;
subplot(2,1,1);
plot(tWin,Rvalues,'.-')
% Annotate plot
legend('truth==0','truth==1','all trials')
xlabel('time of window center (ms)')
ylabel('R value')
title(show_symbols(sprintf('%s vs. %s\nCorrelation between true jitter and posterior peak',JLP.ALLEEG(1).setname,JLP.ALLEEG(2).setname)))



subplot(2,1,2); hold on;
plot(tWin,Pvalues,'.-')
plot(get(gca,'xlim'),[0.05 0.05],'k--')
plot(get(gca,'xlim'),[0.05 0.05]/nWin,'k:')
% Mark significant time windows
isSig = (Pvalues<.05 & Pvalues>=.05/nWin); % significant
tWinMat = repmat(tWin,3,1);
plot(tWinMat(isSig),Pvalues(isSig),'ko','markersize',10);
isSig = (Pvalues<.05/nWin); % very significant
plot(tWinMat(isSig),Pvalues(isSig),'ks','markersize',10);
% Annotate plot
legend('truth==0','truth==1','all trials','p=0.05',sprintf('p=%.3g (bonferroni)',.05/nWin))
xlabel('time of window center (ms)')
ylabel('p value')
% title(show_symbols(sprintf('%s vs. %s\nCorrelation between true jitter and posterior peak',JLP.ALLEEG(1).setname,JLP.ALLEEG(2).setname)))
