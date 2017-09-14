% CorrelateAllReadingPredictorMetrics_script.m
%
% Created 9/12/17 by DJ.

% metrics = {'-meanMotion','-blinkRate','saccadeRate','pupilDilation','-globalFc','activityScore','gradcpt_combo','dandmn_combo','read_combo','fracCorrect'};
fprintf('Loading...\n');
load('ReadingFcAndFracCorrect_19subj_Fisher_2017-05-17.mat'); %fracCorrect
load('AllMetricScores_2017-08-31.mat') %score_combo
load('BehaviorPermutations_2017-08-30.mat') %permBeh
load('ReadingPermPredictions_2017-08-30','readperm_combo');
% Tack fracCorrect onto the end of our table
score_combo.fracCorrect = fracCorrect;
metrics = {'minus_meanMotion','minus_meanPageDur','saccadeRate','minus_blinkRate','minus_globalFc','pupilDilation','gradcpt','reading','fracCorrect'};
nMets = numel(metrics);
metrics_display = metrics;
for i=1:nMets
    if strncmp(metrics{i},'minus_',6)
        metrics_display{i} = ['-',metrics{i}(7:end)];
    end
end
% Get r and p values (and CI for r value) for every pair of metrics.
fprintf('Getting correlations between %d metrics...\n',nMets);
[rVals, pVals,rLower,rUpper] = deal(nan(nMets));
for i=1:nMets
    for j=1:nMets
        [rVals(i,j), pVals(i,j)] = corr(score_combo.(metrics{i})(:),score_combo.(metrics{j})(:),'tail','right');
        [~,~,rL,rU]= corrcoef(score_combo.(metrics{i})(:),score_combo.(metrics{j})(:));
        rLower(i,j) = rL(1,2);
        rUpper(i,j) = rU(1,2);
    end
end

% Do same with permuted behavior
pVals_perm = pVals;
nPerms = size(permBeh,2);
iFrac = find(strcmp(metrics,'fracCorrect'));
iRead = find(strcmp(metrics,'reading'));
fprintf('Getting distribution of r values over %d permutations...\n',nPerms);
for i=1:nMets
    rVals_perm_fracCorrect = ones(1,nPerms);
    rVals_perm_reading = ones(1,nPerms);
    if i==iFrac
        for j=1:nPerms
            rVals_perm_reading(j) = corr(permBeh(:,j),readperm_combo(:,j));        
        end
    elseif i==iRead
        for j=1:nPerms
            rVals_perm_fracCorrect(j) = corr(readperm_combo(:,j),permBeh(:,j));        
        end
    else
        for j=1:nPerms
            rVals_perm_fracCorrect(j) = corr(score_combo.(metrics{i})(:),permBeh(:,j));        
            rVals_perm_reading(j) = corr(score_combo.(metrics{i})(:),readperm_combo(:,j));        
        end
    end
    pVals_perm(i,iFrac) = mean(rVals_perm_fracCorrect>rVals(i,iFrac));
    pVals_perm(iFrac,i) = mean(rVals_perm_fracCorrect>rVals(i,iFrac));
    pVals_perm(i,iRead) = mean(rVals_perm_reading>rVals(i,iRead));
    pVals_perm(iRead,i) = mean(rVals_perm_reading>rVals(i,iRead));
end

pVals_perm = pVals_perm.*(diag(nan(1,nMets))+1); % set diagonal p's to nan

%% Plot correlations with fracCorrect as bar graph
% Evaluate significance
qVals = mafdr(pVals_perm(1:nMets-1,end),'bhfdr',true);
iOs = find(pVals_perm(1:nMets-1,end)<0.05 & qVals>=0.05);
iStars = find(qVals<0.05);
% Plot
fprintf('Plotting results...\n')
figure(733); clf; 
set(gcf,'Position',[195   350   710   380]);
hold on;
bar(1:4,rVals(1:4,end),'g');
bar(5:6,rVals(5:6,end),'m');
bar(7:8,rVals(7:8,end),'facecolor',[1 1 1]*.5);
errorbar(1:nMets-1,rVals(1:nMets-1,end),rLower(1:nMets-1,end)-rVals(1:nMets-1,end),rUpper(1:nMets-1,end)-rVals(1:nMets-1,end),'k.');
plot(iOs,ones(size(iOs)),'ko');
plot(iStars,ones(size(iStars)),'k*');
set(gca,'xtick',1:nMets-1,'xticklabel',show_symbols(metrics_display(1:end-1)));
xticklabel_rotate;
ylabel('correlation with Reading Comp.');
legend('Behavior Metrics','Arousal Metrics','FC Network Metrics','95% CI','p<0.05','q<0.05','Location','SouthEast');
fprintf('Done!\n');

%% Plot results as matrices
qVals = reshape(mafdr(pVals_perm(:),'bhfdr',true),size(pVals_perm));
figure(734); clf;
set(gcf,'Position',[195  614 1567 620]);
subplot(1,2,1); hold on;
imagesc(rVals)
colorbar
xlabel('Metric')
ylabel('Metric');
axis equal
xlim([0 nMets]+0.5);
ylim([0 nMets-1]+0.5);
set(gca,'clim',[0 1]);
set(gca,'xtick',1:nMets,'xticklabel',show_symbols(metrics_display));
set(gca,'ytick',1:nMets-1,'yticklabel',show_symbols(metrics_display(1:end-1)));
xticklabel_rotate
title(sprintf('correlation of metrics across subjects\n'));
% Add stars
[iOs,jOs] = find(pVals_perm<0.05 & qVals>=0.05);
plot(jOs,iOs,'ko');
[iStars,jStars] = find(qVals<0.05);
plot(jStars,iStars,'k*');
set(gca,'ydir','reverse');

%% Project out each one
[rVals_proj, p_proj,rVals_projcum,p_projcum] = deal(nan(nMets-1));
fprintf('Projecting out each metric...\n');
for i=1:nMets-1
    a = normalise(score_combo.(metrics{i})(:)-mean(score_combo.(metrics{i})));
%     projout_cum = a;
    for j=1:nMets-1
        % project out
        b = normalise(score_combo.(metrics{j})(:)-mean(score_combo.(metrics{j})));
        proj = (a'*b)/(b'*b)*b;
%         proj = (b'*a)/(a'*a)*a;
        projout = a-proj;
        [rVals_proj(i,j+1),p_proj(i,j+1)] = corr(projout(:),fracCorrect(:),'tail','right');
        
%         proj_cum = (projout_cum'*b)/(b'*b)*b;
% %         proj_cum = (b'*projout_cum)/(projout_cum'*projout_cum)*projout_cum;
%         projout_cum = projout_cum-proj;
%         [rVals_projcum(i,j+1),p_projcum(i,j+1)] = corr(projout_cum(:),fracCorrect(:),'tail','right');
    end
    [rVals_proj(i,1),p_proj(i,1)] = corr(score_combo.(metrics{i})(:),fracCorrect(:),'tail','right');
end

% Add permutation tests
p_proj_perm = p_proj;
fprintf('Getting distribution of r values over %d permutations...\n',nPerms);
for i=1:nMets-1
    rVals_perm_fracCorrect = ones(1,nPerms);
    if i==iRead
        for j=1:nMets-1
            for iPerm=1:nPerms
                a = normalise(readperm_combo(:,iPerm)-mean(readperm_combo(:,iPerm)));            
                if j==iRead
                    b = a;
                else                
                    b = normalise(score_combo.(metrics{j})(:)-mean(score_combo.(metrics{j})));
                end
                proj = (a'*b)/(b'*b)*b;
        %         proj = (b'*a)/(a'*a)*a;
                projout = a-proj;
                rVals_perm_fracCorrect(iPerm) = corr(projout(:),permBeh(:,iPerm));

            end
            % get new p value
            p_proj_perm(i,j+1) = mean(rVals_perm_fracCorrect>rVals_proj(i,j+1));
        end        
    else
        a = normalise(score_combo.(metrics{i})(:)-mean(score_combo.(metrics{i})));
        for j=1:nMets-1
            rVals_perm_fracCorrect = nan(1,nPerms);
            for iPerm=1:nPerms
                if j==iRead
                    b = normalise(readperm_combo(:,iPerm)-mean(readperm_combo(:,iPerm)));
                else
                    b = normalise(score_combo.(metrics{j})(:)-mean(score_combo.(metrics{j})));
                end
                proj = (a'*b)/(b'*b)*b;
        %         proj = (b'*a)/(a'*a)*a;
                projout = a-proj;                   
                rVals_perm_fracCorrect(iPerm) = corr(projout(:),permBeh(:,iPerm));
            end
            % get new p value
            p_proj_perm(i,j+1) = mean(rVals_perm_fracCorrect>rVals_proj(i,j+1));

        end
    end
end

% remove diagonals
for i=1:nMets-1
    p_proj_perm(i,i+1) = nan;
end
% Apply FDR correction
% rVals_projcum(:,1) = rVals_proj(:,1);
% p_projcum(:,1) = p_proj(:,1);
q_proj = reshape(mafdr(p_proj_perm(:),'bhfdr',true),size(p_proj_perm));
% q_projcum = reshape(mafdr(p_projcum(:),'bhfdr',true),size(p_projcum));
fprintf('Done!\n');


%% Plot results
subplot(1,2,2); hold on;
imagesc(rVals_proj)
colorbar
set(gca,'clim',[0 1]);
set(gca,'ytick',1:nMets-1,'yticklabel',show_symbols(metrics_display(1:end-1)));
set(gca,'xtick',1:nMets,'xticklabel',show_symbols([{'none'}, metrics_display(1:end-1)]));
xlabel('Metric X')
ylabel('Metric Y');
axis equal
xlim([0 nMets]+0.5);
ylim([0 nMets-1]+0.5);
title(sprintf('correlation of metric Y with fracCorrect\n after regressing out metric X'));
xticklabel_rotate
% Add stars
[iOs,jOs] = find(p_proj<0.05 & q_proj>=0.05);
plot(jOs,iOs,'ko');
[iStars,jStars] = find(q_proj<0.05);
plot(jStars,iStars,'k*');
set(gca,'ydir','reverse');


% subplot(1,3,3); hold on;
% imagesc(rVals_projcum)
% colorbar
% set(gca,'clim',[-1 1]);
% set(gca,'ytick',1:nMets-1,'yticklabel',show_symbols(metrics_display(1:end-1)));
% set(gca,'xtick',1:nMets,'xticklabel',show_symbols([{'none'}, metrics_display(1:end-1)]));
% xlabel('Metric X')
% ylabel('Metric Y');
% xlim([0 nMets]+0.5);
% ylim([0 nMets-1]+0.5);
% title(sprintf('correlation of metric Y with fracCorrect\n after regressing out metrics 1 to X'));
% xticklabel_rotate
% axis square
% % Add stars
% [iOs,jOs] = find(p_projcum<0.05 & q_projcum>=0.05);
% plot(jOs,iOs,'ko');
% [iStars,jStars] = find(q_projcum<0.05);
% plot(jStars,iStars,'k*');
% set(gca,'ydir','reverse');

%% Check whether CPM could use FC to predict motion
thresh = 0.01;
corr_method = 'robustfit';
mask_method = 'one';
[read_mot_pos, read_mot_neg, read_mot_combo] = RunLeave1outBehaviorRegression(FC_fisher,score_combo.minus_meanMotion,thresh,corr_method,mask_method);
fprintf('Done!\n');
