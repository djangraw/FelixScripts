function [isHiMot,subj_sorted_new,readScore_sorted_new] = RemoveHighMotionSubjects(subj_sorted,readScore_sorted,cenCutoff)

% RemoveHighMotionSubjects(subj_sorted,readScore_sorted)
%
% Created 5/23/18 by DJ.

if ~exist('cenCutoff','var') || isempty(cenCutoff)
    cenCutoff = 0.15;
end

isTop = readScore_sorted>median(readScore_sorted);
[subjMotion, censorFraction] = GetStorySubjectMotion(subj_sorted);

figure(65); clf;
subplot(1,3,1); hold on;
hist(censorFraction,0:0.02:0.22);
xlabel('fraction of TRs censored');
ylabel('# subjects')
PlotVerticalLines(cenCutoff,'r--');

subplot(1,3,2); hold on;
plot(subjMotion,censorFraction,'.')
xlabel('mean subject motion (after censoring)')
ylabel('fraction of TRs censored');
PlotHorizontalLines(cenCutoff,'r--');

subplot(1,3,3); hold on;
plot(readScore_sorted,censorFraction,'.')
xlabel('reading score')
ylabel('fraction of TRs censored');
PlotHorizontalLines(cenCutoff,'r--');


% check for significant difference in motion
pMot_all = ranksum(subjMotion(~isTop),subjMotion(isTop));
fprintf('===Ranksum tests of mean subject motion in top vs. bottom half of readers:\n');
fprintf('Starting with %d subjects.\n',numel(subj_sorted));
fprintf('pMot_all = %.3g\n',pMot_all);
% check for significant difference in censor fraction
pCen_all = ranksum(censorFraction(~isTop),censorFraction(isTop));
fprintf('pCen_new = %.3g\n',pCen_all);


% remove hi-motion subjects and try again
% motCutoff = 0.2;%0.15;
% isHiMot = subjMotion>motCutoff;
% fprintf('removing %d subjects with motion>%.3f...\n',sum(isHiMot),motCutoff);
isHiMot = censorFraction>cenCutoff;
fprintf('removing %d subjects with >%.3f%% of TRs censored...\n',sum(isHiMot),cenCutoff*100);

subj_sorted_new = subj_sorted(~isHiMot);
readScore_sorted_new = readScore_sorted(~isHiMot);
[subjMotion_new, censorFraction_new] = GetStorySubjectMotion(subj_sorted_new);
isTop_new = readScore_sorted_new>median(readScore_sorted_new);

% check for significant difference in motion
pMot_new = ranksum(subjMotion_new(~isTop_new),subjMotion_new(isTop_new));
fprintf('pMot_new = %.3g\n',pMot_new);
% check for significant difference in censor fraction
pCen_new = ranksum(censorFraction_new(~isTop_new),censorFraction_new(isTop_new));
fprintf('pCen_new = %.3g\n',pCen_new);
