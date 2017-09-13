% CorrelateAllReadingPredictorMetrics_script.m
%
% Created 9/12/17 by DJ.

% metrics = {'-meanMotion','-blinkRate','saccadeRate','pupilDilation','-globalFc','activityScore','gradcpt_combo','dandmn_combo','read_combo','fracCorrect'};
load('ReadingFcAndFracCorrect_19subj_Fisher_2017-05-17.mat'); %score_combo
load('AllMetricScores_2017-08-31.mat') %fracCorrect
load('BehaviorPermutations_2017-08-30.mat') %permBeh
% Tack fracCorrect onto the end of our table
score_combo.fracCorrect = fracCorrect;
metrics = {'minus_meanMotion','meanPageDur','saccadeRate','minus_blinkRate','pupilDilation','minus_globalFc','gradcpt','reading','fracCorrect'};
% Get r and p values (and CI for r value) for every pair of metrics.
nMets = numel(metrics);
[rVals, pVals,rLower,rUpper] = deal(nan(nMets));
for i=1:nMets
    for j=1:nMets
        [rVals(i,j), pVals(i,j)] = corr(score_combo.(metrics{i})(:),score_combo.(metrics{j})(:),'tail','right');
        [~,~,rL,rU]= corrcoef(score_combo.(metrics{i})(:),score_combo.(metrics{j})(:));
        rLower(i,j) = rL(1,2);
        rUpper(i,j) = rU(1,2);
    end
end
% Evaluate significance
pVals = pVals.*(diag(nan(1,nMets))+1); % set diagonal p's to nan
qVals = mafdr(pVals(1:nMets,end),'bhfdr',true);
iOs = find(pVals(1:nMets,end)<0.05 & qVals>=0.05);
iStars = find(qVals<0.05);

% Plot correlations with fracCorrect as bar graph
figure(733); clf; 
set(gcf,'Position',[195   350   710   380]);
hold on;
bar(1:4,rVals(1:4,end),'g');
bar(5:6,rVals(5:6,end),'m');
bar(7:8,rVals(7:8,end),'facecolor',[1 1 1]*.5);
errorbar(1:nMets-1,rVals(1:nMets-1,end),rLower(1:nMets-1,end)-rVals(1:nMets-1,end),rUpper(1:nMets-1,end)-rVals(1:nMets-1,end),'k.');
plot(iOs,ones(size(iOs)),'ko');
plot(iStars,ones(size(iStars)),'k*');
set(gca,'xtick',1:nMets-1,'xticklabel',show_symbols(metrics(1:end-1)));
xticklabel_rotate;
ylabel('correlation with Reading Comp.');
legend('Behavior Metrics','Arousal Metrics','FC Metrics','95% CI','p<0.05','q<0.05','Location','SouthEast');

%% Plot results as matrices
qVals = reshape(mafdr(pVals(:),'bhfdr',true),size(pVals));
figure(734); clf;
set(gcf,'Position',[195  614 1567 620]);
subplot(1,3,1); hold on;
imagesc(rVals)
colorbar
xlim([0 nMets]+0.5);
ylim([0 nMets]+0.5);
set(gca,'clim',[0 1]);
set(gca,'ytick',1:nMets,'yticklabel',show_symbols(metrics));
set(gca,'xtick',1:nMets,'xticklabel',show_symbols(metrics));
xticklabel_rotate
title('correlation of metrics across subjects');
axis square
% Add stars
[iOs,jOs] = find(pVals<0.05 & qVals>=0.05);
plot(jOs,iOs,'ko');
[iStars,jStars] = find(qVals<0.05);
plot(jStars,iStars,'k*');
set(gca,'ydir','reverse');

% Project out each one
[rVals_proj, p_proj,rVals_projcum,p_projcum] = deal(nan(nMets-1));
for i=1:nMets-1
    a = normalise(score_combo.(metrics{i})(:)-mean(score_combo.(metrics{i})));
    projout_cum = a;
    for j=1:nMets-1
        % project out
        b = normalise(score_combo.(metrics{j})(:)-mean(score_combo.(metrics{j})));
        proj = (a'*b)/(b'*b)*b;
%         proj = (b'*a)/(a'*a)*a;
        projout = a-proj;
        [rVals_proj(i,j+1),p_proj(i,j+1)] = corr(projout(:),fracCorrect(:),'tail','right');
        
        proj_cum = (projout_cum'*b)/(b'*b)*b;
%         proj_cum = (b'*projout_cum)/(projout_cum'*projout_cum)*projout_cum;
        projout_cum = projout_cum-proj;
        [rVals_projcum(i,j+1),p_projcum(i,j+1)] = corr(projout_cum(:),fracCorrect(:),'tail','right');
    end
    [rVals_proj(i,1),p_proj(i,1)] = corr(score_combo.(metrics{i})(:),fracCorrect(:),'tail','right');
end
rVals_projcum(:,1) = rVals_proj(:,1);
p_projcum(:,1) = p_proj(:,1);
q_proj = reshape(mafdr(p_proj(:),'bhfdr',true),size(p_proj));
q_projcum = reshape(mafdr(p_projcum(:),'bhfdr',true),size(p_projcum));

% TO DO: Add permutation tests


%% Plot results
subplot(1,3,2); hold on;
imagesc(rVals_proj)
colorbar
set(gca,'clim',[0 1]);
set(gca,'ytick',1:nMets-1,'yticklabel',show_symbols(metrics(1:end-1)));
set(gca,'xtick',1:nMets,'xticklabel',show_symbols([{'none'}, metrics(1:end-1)]));
xlabel('Metric X')
ylabel('Metric Y');
xlim([0 nMets]+0.5);
ylim([0 nMets-1]+0.5);
title(sprintf('correlation of metric Y with fracCorrect\n after regressing out metric X'));
xticklabel_rotate
axis square
% Add stars
[iOs,jOs] = find(p_proj<0.05 & q_proj>=0.05);
plot(jOs,iOs,'ko');
[iStars,jStars] = find(q_proj<0.05);
plot(jStars,iStars,'k*');
set(gca,'ydir','reverse');


subplot(1,3,3); hold on;
imagesc(rVals_projcum)
colorbar
set(gca,'clim',[-1 1]);
set(gca,'ytick',1:nMets-1,'yticklabel',show_symbols(metrics(1:end-1)));
set(gca,'xtick',1:nMets,'xticklabel',show_symbols([{'none'}, metrics(1:end-1)]));
xlabel('Metric X')
ylabel('Metric Y');
xlim([0 nMets]+0.5);
ylim([0 nMets-1]+0.5);
title(sprintf('correlation of metric Y with fracCorrect\n after regressing out metrics 1 to X'));
xticklabel_rotate
axis square
% Add stars
[iOs,jOs] = find(p_projcum<0.05 & q_projcum>=0.05);
plot(jOs,iOs,'ko');
[iStars,jStars] = find(q_projcum<0.05);
plot(jStars,iStars,'k*');
set(gca,'ydir','reverse');