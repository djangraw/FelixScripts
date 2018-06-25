% Find100RunsSignificance_MultiNruns.m
%
% Created 1/12/15 by DJ.
% Updated 3/24/15 by DJ - added AFNI support

% declare
subjects = 1;%:3;
nRuns_all = [3 5 10 20:20:100];    
useAfni = true;
% set up
pctSig_Bonf = nan(numel(subjects),numel(nRuns_all));
pctSig_FDR = nan(numel(subjects),numel(nRuns_all));
permFit = repmat(makedist('Normal'),numel(subjects), numel(nRuns_all));

for iSubj = 1:numel(subjects)
    figure(iSubj);
    subject = subjects(iSubj);    
    for i=1:numel(nRuns_all)
        subplot(2,4,i); cla;
        try
            fprintf('--- Subj %d, %d runs\n',subject,nRuns_all(i));
            if useAfni
                [pctSig_Bonf(iSubj,i), pctSig_FDR(iSubj,i), permFit(iSubj,i)] = Find100RunsSignificance_AFNI(subject,nRuns_all(i));
            else
                [pctSig_Bonf(iSubj,i), pctSig_FDR(iSubj,i), permFit(iSubj,i)] = Find100RunsSignificance(subject,nRuns_all(i));
            end
        end
    end
    %% plot
%     clf;
%     plot(nRuns_all,[pctSig_Bonf(iSubj,:); pctSig_FDR(iSubj,:)]','.-')
%     xlabel('# of runs')
%     ylabel('% of voxels with mean ISC > 0 (p<0.05)')
%     legend('Bonferroni corrected','FDR corrected');
%     title(sprintf('SBJ%02d',subject));
end
%% superimpose subjects
% set up
figure(numel(subjects)+1);
clf;
legendstr = cell(1,numel(subjects));
for i=1:numel(subjects)
    legendstr{i} = sprintf('SBJ%02d',subjects(i));
end

% bonf
subplot(2,1,1);
plot(nRuns_all, pctSig_Bonf,'.-');
ylim([0 100])
grid on
xlabel('# of runs')
ylabel('% of voxels with mean ISC > 0 (p<0.05)')
legend(legendstr);
title('Bonferroni Corrected');
% FDR
subplot(2,1,2);
plot(nRuns_all, pctSig_FDR,'.-');
ylim([0 100])
grid on
xlabel('# of runs')
ylabel('% of voxels with mean ISC > 0 (p<0.05)')
legend(legendstr);
title('FDR Corrected');

%% set up
figure(numel(subjects)+2);
clf;

% FDR
% subplot(2,1,2);
sigmas = reshape([permFit.sigma],size(permFit));
sigmas(sigmas==1) = NaN;
plot(nRuns_all, sigmas,'.-');
grid on
xlabel('# of runs')
ylabel('sigma')
legend(legendstr);
title('Reliability of Gaussian fits');
