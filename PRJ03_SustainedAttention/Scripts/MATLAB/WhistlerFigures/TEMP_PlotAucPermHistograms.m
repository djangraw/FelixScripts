% TEMP_PlotAucPermHistograms
%
% Get and plot permutations' mean AUCs across subjects as cumulative
% histograms.
%
% Created 3/2/16 by DJ for one-time use.

subjects = 9:16;
datestr = '2016-03-01';

[Az_stim,Az_stim_pctPermsBelow, Az_cond,Az_cond_pctPermsBelow]= deal(zeros(numel(subjects),2));
Az_stim_perm = nan(100,2,numel(subjects));

for i=1:numel(subjects)
    subject = subjects(i);      
    % enter folder
    cd(sprintf('/data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ%02d',subject)); 
    
    % Get stimulus results
    foo = load(sprintf('SBJ%02d_MultimodalClassifier_whiteNoise-other_%s',subject,dateString));
    Az_perm_mat = cat(1,foo.Az_perm{:});
    Az_stim_perm(:,:,i) = Az_perm_mat(:,1:2);
    Az_stim(i,:) = foo.Az_true(1:2);
    Az_stim_pctPermsBelow(i,1) = mean(foo.Az_true(1)>Az_perm_mat(:,1))*100;
    Az_stim_pctPermsBelow(i,2) = mean(foo.Az_true(2)>Az_perm_mat(:,2))*100;    
%     Az_stim(i,:) = foo.Az_LTO(1:2);
%     Az_stim_other(i,:) = foo.Az_LTO(3:5);
    % Get condition results
    foo = load(sprintf('SBJ%02d_MultimodalClassifier_ignoredSpeech-attendedSpeech_%s',subject,dateString));    
    Az_perm_mat = cat(1,foo.Az_perm{:});
    Az_cond_perm(:,:,i) = Az_perm_mat(:,1:2);
    Az_cond(i,:) = foo.Az_true(1:2);
    Az_cond_pctPermsBelow(i,1) = mean(foo.Az_true(1)>Az_perm_mat(:,1))*100;
    Az_cond_pctPermsBelow(i,2) = mean(foo.Az_true(2)>Az_perm_mat(:,2))*100;

    
end

%% Plot
% show distribution of permutations' means across subjects
meanPerm_stim = mean(Az_stim_perm,3);
meanPerm_cond = mean(Az_cond_perm,3);

figure(562); clf;
subplot(121); cla; hold on;
xHist = 0:.01:1;
nStim = hist(meanPerm_stim,xHist);
pctStim = cumsum(nStim)./repmat(sum(nStim),numel(xHist),1)*100;
iHist = [find(xHist<mean(Az_stim(:,1)),1,'last'), find(xHist<mean(Az_stim(:,2)),1,'last')];
plot(xHist,pctStim);
plot([1 1]*mean(Az_stim(:,1)), [0 pctStim(iHist(1),1)],'b--');
plot([1 1]*mean(Az_stim(:,2)), [0 pctStim(iHist(2),2)],'r--');
plot([0 mean(Az_stim(:,1))], [1 1]*pctStim(iHist(1),1),'b--');
plot([0 mean(Az_stim(:,2))], [1 1]*pctStim(iHist(2),2),'r--');
title('White Noise vs. Speech')
xlabel('AUC');
ylabel('% permutations with lower AUC')
legend('Permutations (Mag feats)','Permutations (FC feats)','Actual data (Mag)','Actual data (FC)','Location','NorthWest');

subplot(122); cla; hold on;
xHist = 0:.01:1;
nCond = hist(meanPerm_cond,xHist);
pctCond = cumsum(nCond)./repmat(sum(nCond),numel(xHist),1)*100;
iHist = [find(xHist<mean(Az_cond(:,1)),1,'last'), find(xHist<mean(Az_cond(:,2)),1,'last')];
plot(xHist,pctCond);
plot([1 1]*mean(Az_cond(:,1)), [0 pctCond(iHist(1),1)],'b--');
plot([1 1]*mean(Az_cond(:,2)), [0 pctCond(iHist(2),2)],'r--');
plot([0 mean(Az_cond(:,1))], [1 1]*pctCond(iHist(1),1),'b--');
plot([0 mean(Az_cond(:,2))], [1 1]*pctCond(iHist(2),2),'r--');
title('Ignore Sound vs. Attend Sound')
xlabel('AUC');
ylabel('% permutations with lower AUC')
legend('Permutations (Mag feats)','Permutations (FC feats)','Actual data (Mag)','Actual data (FC)','Location','NorthWest');
