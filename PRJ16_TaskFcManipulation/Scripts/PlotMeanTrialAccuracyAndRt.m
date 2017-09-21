behThis=trialBehTable(trialBehTable.Subject==27,:);
iCondChange = find(diff(behThis.Cond)~=0)+0.5;
iRun = (312:312:935)+0.5;

[rawAcc, rawRt] = GetSrttTrialByTrialBeh(trialBehTable);
rawPc = cat(2,rawAcc{isOkSubj})*100; % weird kluge
rawRt = cat(2,rawRt{isOkSubj});
figure(523); clf;

subplot(2,1,1);
plot(mean(rawPc,2))
hold on
PlotVerticalLines(iCondChange,'k--');
PlotVerticalLines(iRun,'r-');
% title(sprintf('Mean Accuracy across %d subjects\n(convolved with half-gaussian, std=%g)',...
%     size(rollingPc,2),10));
title(sprintf('Mean Accuracy across %d subjects',size(rawPc,2)));

ylabel('% Correct');
xlabel('Trial');
legend('Mean','New Condition','New Run')
ylim([75 100]);

subplot(2,1,2);
plot(nanmean(rawRt,2))
hold on
PlotVerticalLines(iCondChange,'k--');
PlotVerticalLines(iRun,'r-');
% title(sprintf('Mean Reaction Time across %d subjects\n(convolved with half-gaussian, std=%g)',...
%     size(rollingPc,2),10));
title(sprintf('Mean Reaction Time across %d subjects',size(rawPc,2)));
ylabel('RT (ms)');
xlabel('Trial');
legend('Mean','New Condition','New Run')
ylim([350 500]);

%% Average across repeated patterns
isStructured = behThis.Cond==2;
pattern = behThis.TargetNum(find(isStructured,12));

rollingPc_pattern = reshape(rawPc(isStructured,:),12,sum(isStructured)/12 * size(rawRt,2));
rollingRt_pattern = reshape(rawRt(isStructured,:),12,sum(isStructured)/12 * size(rawRt,2));

figure(524); clf;
subplot(3,1,1);
% plot(mean(rollingPc_pattern,2))
ErrorPatch((1:12),nanmean(rollingPc_pattern,2)',nanstd(rollingPc_pattern,[],2)'/sqrt(size(rollingPc_pattern,2)));
title(sprintf('Mean Accuracy across %d patterns * %d subjects',sum(isStructured)/12,size(rawPc,2)));
ylabel('% Correct');
xlabel('Trial');
% legend('Mean','New Condition','New Run')
ylim([75 100]);
grid on;

subplot(3,1,2);
ErrorPatch((1:12),nanmean(rollingRt_pattern,2)',nanstd(rollingRt_pattern,[],2)'/sqrt(size(rollingRt_pattern,2)));
% plot(nanmean(rollingRt_pattern,2))
title(sprintf('Mean Reaction Times across %d patterns * %d subjects',sum(isStructured)/12,size(rawPc,2)));
ylabel('RT (ms)');
xlabel('Trial');
% legend('Mean','New Condition','New Run')
ylim([350 500]);
grid on;

subplot(3,1,3);
plot(pattern,'.-')
title('Repeated Motor Pattern');
ylabel('Finger');
xlabel('Trial');
% legend('Mean','New Condition','New Run')
ylim([0 5]);
set(gca,'ytick',1:4);
grid on;

%% Plot distribution of accuracy/RT across subjects
subjPc = mean(rawPc,1);
subjPc_str = mean(rawPc(isStructured,:),1);
subjPc_uns = mean(rawPc(~isStructured,:),1);

rollingRt_correct = rawRt;
rollingRt_correct(rawPc==0) = nan;
subjRt_corr = nanmean(rollingRt_correct,1);
rollingRt_err = rawRt;
rollingRt_err(rawPc>0) = nan;
subjRt_err = nanmean(rollingRt_err,1);

subjRt_corr_str = nanmean(rollingRt_correct(isStructured,:),1);
subjRt_corr_uns = nanmean(rollingRt_correct(~isStructured,:),1);
subjRt_err_str = nanmean(rollingRt_err(isStructured,:),1);
subjRt_err_uns = nanmean(rollingRt_err(~isStructured,:),1);

% Plot individual subjects
figure(525); clf;
subplot(3,1,1);
nTrials = size(rawRt,1);
nSubj = size(rawRt,2);
[ax,h1,h2] = plotyy(1:nSubj,subjPc,1:nSubj,subjRt_corr);
hold(ax(2),'on');
plot(ax(2),1:nSubj,subjRt_err);
legend('% Correct','RT (correct trials)','RT (error trials)');
xlabel('subject');
ylabel(ax(1),'% Correct');
ylabel(ax(2),'Reaction Time (ms)');
title(sprintf('Mean Subject behavior across %d trials',nTrials));

% Plot distribution
subplot(3,2,3);
xHist = 2.5:5:100;
nHist = hist(subjPc,xHist);
bar(xHist,nHist);
xlabel('% correct');
ylabel('# subjects');
title('Accuracy Distribution')

subplot(3,2,4);
xHist = 212.5:25:600;
nHist = hist([subjRt_corr; subjRt_err]',xHist);
bar(xHist,nHist);
xlabel('Mean Reaction Time (ms)');
ylabel('# subjects');
legend('Correct trials','Error trials');
title('Reaction Time Distribution');

% Plot distribution for struct-unstruct
subplot(3,2,5); hold on;
xHist = (.25:.5:30)-15;
nHist = hist(subjPc_str-subjPc_uns,xHist);
bar(xHist,nHist);
xlabel('% correct (structured - unstructured)');
ylabel('# subjects');
title('Accuracy Difference')
PlotVerticalLines(0,'k');

subplot(3,2,6); hold on;
xHist = (5:10:200)-100;
nHist = hist([subjRt_corr_str - subjRt_corr_uns; subjRt_err_str - subjRt_err_uns]',xHist);
bar(xHist,nHist);
xlabel('Mean Reaction Time (structured - unstructured, ms)');
ylabel('# subjects');
legend('Correct trials','Error trials');
title('Reaction Time Difference');
PlotVerticalLines(0,'k');
