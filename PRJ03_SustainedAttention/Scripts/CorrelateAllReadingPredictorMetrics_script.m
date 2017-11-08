% CorrelateAllReadingPredictorMetrics_script.m
%
% Created 9/12/17 by DJ.

% metrics = {'-meanMotion','-blinkRate','saccadeRate','pupilDilation','-globalFc','activityScore','gradcpt_combo','dandmn_combo','read_combo','fracCorrect'};
fprintf('Loading...\n');
load('ReadingFcAndFracCorrect_19subj_Fisher_2017-05-17.mat'); %fracCorrect
load('AllMetricScores_2017-08-31.mat') %score_combo
load('BehaviorPermutations_2017-08-30.mat') %permBeh
load('ReadingPermPredictions_2017-08-30','readperm_combo');
% Add DMN FC
load('DanDmnNetwork_match15.mat');
[dandmn_pos,dandmn_neg,dandmn_combo] = GetFcMaskMatch(FC_fisher,DanDmnNetwork>0,DanDmnNetwork<0);
[dandmn_pos,dandmn_neg,dandmn_combo] = deal(dandmn_pos',dandmn_neg',dandmn_combo');
score_combo.minus_dmn = -dandmn_neg; % only DMN part
score_combo.dan = dandmn_pos; % only DAN part
% Add Activation
load('ReadingMeanActivityScores.mat','activityScore');
score_combo.readingActiv = activityScore;
% Tack fracCorrect onto the end of our table
score_combo.fracCorrect = fracCorrect;
% metrics =
% {'minus_meanMotion','minus_meanPageDur','saccadeRate','minus_blinkRate','minus_globalFc','pupilDilation','gradcpt','reading','fracCorrect'}; % For NeuroImage Paper Figure S5
metrics = {'minus_meanMotion','minus_meanPageDur','minus_blinkRate','saccadeRate','pupilDilation','minus_globalFc','minus_dmn','gradcpt','visaud','readingActiv','reading','fracCorrect'}; % For SfN2017 Talk
iBeh=1:5; iRdg=6:11;
% metrics = {'minus_meanMotion','pupilDilation','minus_globalFc','minus_dmn','gradcpt','readingActiv','reading','fracCorrect'}; % Pared-down version for SfN2017 Talk
% iBeh=1:2; iRdg=3:7;

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
iOs = find(pVals_perm(1:nMets-1,end)<0.05 & pVals_perm(1:nMets-1,end)>=0.01);
iStars = find(pVals_perm(1:nMets-1,end)<0.01);
% Plot
fprintf('Plotting results...\n')
figure(733); clf; 
set(gcf,'Position',[195   350   710   380]);
hold on;
bar(iBeh,rVals(iBeh,end),'facecolor',[1 1 1]*.5);
% bar(iEng,rVals(iEng,end),'m');
bar(iRdg,rVals(iRdg,end),'m');
errorbar(1:nMets-1,rVals(1:nMets-1,end),rLower(1:nMets-1,end)-rVals(1:nMets-1,end),rUpper(1:nMets-1,end)-rVals(1:nMets-1,end),'k.');
plot(iOs,ones(size(iOs)),'ko');
plot(iStars,ones(size(iStars)),'k*');
set(gca,'xtick',1:nMets-1,'xticklabel',show_symbols(metrics_display(1:end-1)));
xticklabel_rotate;
ylabel('correlation with Reading Comp.');
legend('Behavioral Metrics','fMRI Metrics','95% CI','p<0.05','p<0.01','Location','SouthEast');
fprintf('Done!\n');

%% Plot results as matrices
qVals = reshape(mafdr(pVals_perm(:),'bhfdr',true),size(pVals_perm));
figure(734); clf;
set(gcf,'Position',[195  614 1567 620]);
subplot(1,3,1); hold on;
imagesc(rVals)
colorbar
xlabel('Metric')
ylabel('Metric');
axis equal
xlim([0 nMets]+0.5);
ylim([0 nMets-1]+0.5);
set(gca,'clim',[-1 1]);
set(gca,'xtick',1:nMets,'xticklabel',show_symbols(metrics_display));
set(gca,'ytick',1:nMets-1,'yticklabel',show_symbols(metrics_display(1:end-1)));
xticklabel_rotate
title(sprintf('correlation of metrics across subjects\n'));
% Add stars
% [iOs,jOs] = find(pVals_perm<0.05 & qVals>=0.05);
oThresh = 0.05;
xThresh = 0.01;
[iOs,jOs] = find(pVals_perm<oThresh & pVals_perm>=xThresh);
plot(jOs,iOs,'ko');
% [iStars,jStars] = find(qVals<0.05);
[iStars,jStars] = find(pVals_perm<xThresh);
plot(jStars,iStars,'k*');
set(gca,'ydir','reverse');
legend('p<0.05','p<0.01');
% Make boxes
rectangle('Position',[iBeh(1)-.5, iBeh(1)-.5, numel(iBeh), numel(iBeh)], 'linewidth',2,'edgecolor','c');
% rectangle('Position',[iEng(1)-.5, iEng(1)-.5, numel(iEng), numel(iEng)], 'linewidth',2,'edgecolor','m');
rectangle('Position',[iRdg(1)-.5, iRdg(1)-.5, numel(iRdg), numel(iRdg)], 'linewidth',2,'edgecolor',[1 1 1]*.5);

%% Use partial correlation to find independent relationships

[rVals_part, p_part, rVals_partbeh, p_partbeh] = deal(nan(nMets-1));
for i=1:nMets-1
    [rVals_part(i,1),p_part(i,1)] = corr(score_combo.(metrics{i})(:),fracCorrect(:),'tail','right');
    [rVals_partbeh(i,1),p_partbeh(i,1)] = corr(score_combo.(metrics{i})(:),fracCorrect(:),'tail','right');
    for j=1:nMets-1
        % partial out metric
        [rVals_part(i,j+1),p_part(i,j+1)] = partialcorr(score_combo.(metrics{i})(:),fracCorrect(:),score_combo.(metrics{j})(:),'tail','right');        
        % partial out behavior
        [rVals_partbeh(i,j+1),p_partbeh(i,j+1)] = partialcorr(score_combo.(metrics{i})(:),score_combo.(metrics{j})(:),fracCorrect(:),'tail','right');        
    end
end

% Run Permutation Tests
p_part_perm = p_part;
p_partbeh_perm = p_partbeh;
fprintf('Getting distribution of r values over %d permutations...\n',nPerms);
for i=1:nMets-1
    for j=1:nMets-1
        rVals_perm_fracCorrect = nan(1,nPerms);
        rValsPartbeh_perm_fracCorrect = nan(1,nPerms);
        for iPerm=1:nPerms
            if i==iRead
                a = readperm_combo(:,iPerm);
            else
                a = score_combo.(metrics{i})(:);
            end
            if j==iRead
                b = readperm_combo(:,iPerm);
            else
                b = score_combo.(metrics{j})(:);
            end
            rVals_perm_fracCorrect(iPerm) = partialcorr(a,permBeh(:,iPerm),b);
            rValsPartbeh_perm_fracCorrect(iPerm) = partialcorr(a,b,permBeh(:,iPerm));
        end
        % get new p value
        p_part_perm(i,j+1) = mean(rVals_perm_fracCorrect>rVals_part(i,j+1));
        p_partbeh_perm(i,j+1) = mean(rValsPartbeh_perm_fracCorrect>rVals_partbeh(i,j+1));
    end
end

% remove diagonals
for i=1:nMets-1
    p_part_perm(i,i+1) = nan;
    p_partbeh_perm(i,i+1) = nan;
end

% Correct for multiple comparisions
q_part = reshape(mafdr(p_part_perm(:),'bhfdr',true),size(p_part_perm));
q_partbeh = reshape(mafdr(p_partbeh_perm(:),'bhfdr',true),size(p_partbeh_perm));
fprintf('Done!\n');

%% Plot
subplot(1,3,2); hold on;
imagesc(rVals_part)
colorbar
set(gca,'clim',[-1 1]);
set(gca,'ytick',1:nMets-1,'yticklabel',show_symbols(metrics_display(1:end-1)));
set(gca,'xtick',1:nMets,'xticklabel',show_symbols([{'none'}, metrics_display(1:end-1)]));
xlabel('Metric X');
ylabel('Metric Y');
axis equal
xlim([0 nMets]+0.5);
ylim([0 nMets-1]+0.5);
title(sprintf('partial correlation of metric Y with fracCorrect\n after controlling for metric X'));
xticklabel_rotate
% Add stars
% [iOs,jOs] = find(p_part_perm<0.05 & q_part>=0.05);
[iOs,jOs] = find(p_part_perm<oThresh & p_part_perm>=xThresh);
plot(jOs,iOs,'ko');
% [iStars,jStars] = find(q_part<0.05);
[iStars,jStars] = find(p_part_perm<xThresh);
plot(jStars,iStars,'k*');
set(gca,'ydir','reverse');
% Make boxes
rectangle('Position',[iBeh(1)+.5, iBeh(1)-.5, numel(iBeh), numel(iBeh)], 'linewidth',2,'edgecolor','c');
rectangle('Position',[iEng(1)+.5, iEng(1)-.5, numel(iEng), numel(iEng)], 'linewidth',2,'edgecolor','m');
rectangle('Position',[iRdg(1)+.5, iRdg(1)-.5, numel(iRdg), numel(iRdg)], 'linewidth',2,'edgecolor',[1 1 1]*.5);

subplot(1,3,3); hold on;
imagesc(rVals_partbeh(:,2:end))
colorbar
set(gca,'clim',[-1 1]);
set(gca,'ytick',1:nMets-1,'yticklabel',show_symbols(metrics_display(1:end-1)));
set(gca,'xtick',1:nMets-1,'xticklabel',show_symbols(metrics_display(1:end-1)));
xlabel('Metric X')
ylabel('Metric Y');
axis equal
xlim([0 nMets-1]+0.5);
ylim([0 nMets-1]+0.5);
title(sprintf('partial correlation of metric X with metric Y \n after controlling for fracCorrect'));
xticklabel_rotate
% Add stars
% [iOs,jOs] = find(p_part_perm<0.05 & q_part>=0.05);
[iOs,jOs] = find((p_partbeh(:,2:end)<oThresh/2 & p_partbeh(:,2:end)>=xThresh/2) | ...
                 (p_partbeh(:,2:end)>(1-oThresh/2) & p_partbeh(:,2:end)<=(1-xThresh/2)));
plot(jOs,iOs,'ko');
% [iStars,jStars] = find(q_part<0.05);
[iStars,jStars] = find(p_partbeh(:,2:end)<xThresh/2 | ...
                       p_partbeh(:,2:end)>(1-xThresh/2));
plot(jStars,iStars,'k*');
set(gca,'ydir','reverse');
% Make boxes
rectangle('Position',[iBeh(1)-.5, iBeh(1)-.5, numel(iBeh), numel(iBeh)], 'linewidth',2,'edgecolor','c');
rectangle('Position',[iEng(1)-.5, iEng(1)-.5, numel(iEng), numel(iEng)], 'linewidth',2,'edgecolor','m');
rectangle('Position',[iRdg(1)-.5, iRdg(1)-.5, numel(iRdg), numel(iRdg)], 'linewidth',2,'edgecolor',[1 1 1]*.5);






%% Check whether CPM could use FC to predict motion
thresh = 0.01;
corr_method = 'robustfit';
mask_method = 'one';
[read_mot_pos, read_mot_neg, read_mot_combo, read_mot_posMask_all,read_mot_negMask_all] = RunLeave1outBehaviorRegression(FC_fisher,-score_combo.minus_meanMotion,thresh,corr_method,mask_method);
fprintf('Done!\n');
[r_mot,p_mot] = corr(read_mot_combo,-score_combo.minus_meanMotion,'tail','right');
fprintf('Predicting motion with CPM:\n');
fprintf('r=%.3g, p=%.3g\n',r_mot,p_mot);

%% Permutation tests
nSubj = numel(subjects);
permMot = nan(nSubj,nPerms);
for i=1:nPerms
    permMot(:,i) = -score_combo.minus_meanMotion(randperm(nSubj)');
end
% Use LOO to predict motion
r_mot_perm = nan(1,nPerms);
tic;
fprintf('===Running %d permutations...\n',nPerms);
parfor iPerm=1:nPerms
    fprintf('perm %d/%d (t=%s)...\n',iPerm,nPerms,datestr(now,'hh:mm'));
    [~,~,read_mot_combo_perm] = RunLeave1outBehaviorRegression(FC_fisher,permMot(:,iPerm),thresh,'corr',mask_method);
    r_mot_perm(iPerm) = corr(read_mot_combo_perm,permMot(:,iPerm),'tail','right');
end
fprintf('===Done! Took %.1f seconds.\n',toc);
p_mot_perm = mean(r_mot_perm>r_mot);
fprintf('Predicting motion with CPM:\n');
fprintf('r=%.3g, p_perm=%.3g\n',r_mot,p_mot_perm);
save('MotionPermutations_2017-09-14.mat','permMot','r_mot_perm','r_mot','p_mot_perm');

%% Get masks predictive of motion
read_mot_posMask = all(read_mot_posMask_all,3);
read_mot_negMask = all(read_mot_negMask_all,3);
nPos = sum(VectorizeFc(read_mot_posMask));
nNeg = sum(VectorizeFc(read_mot_negMask));
fprintf('%d pos edges, %d neg edges\n',nPos,nNeg);
% Display as matrix
figure(111); clf;
subplot(1,2,1);
PlotFcMatrix(read_mot_posMask-read_mot_negMask,[-1 1]*7,shenAtlas,shenLabels_hem,true,shenColors_hem,'sum');
subplot(1,2,2);
PlotFcMatrix(read_mot_posMask-read_mot_negMask,[-1 1],shenAtlas,shenLabels_hem,true,shenColors_hem);
% Save NegBothPos AFNI brik
isInNeg = any(read_mot_posMask);
isInPos = any(read_mot_negMask);
GUI_3View(MapColorsOntoAtlas(shenAtlas,cat(2,isInPos,ones(size(isInPos)),isInNeg)));
BrickToWrite = MapValuesOntoAtlas(shenAtlas,(isInNeg&~isInPos) + 2*(isInNeg&isInPos) + 3*(~isInNeg&isInPos));
Opt = struct('Prefix',sprintf('MotionCPM_negbothpos+tlrc'));
WriteBrik(BrickToWrite,shenInfo,Opt);

%% Get any edges predictive of motion, regress them out
[read_mot_all_pos, read_mot_all_neg, read_mot_all_combo, read_mot_all_pos_mask,read_mot_all_neg_mask] = ...
    RunTrainingBehaviorRegression(FC_fisher,-score_combo.minus_meanMotion,thresh,corr_method,mask_method);

%%
nPos = sum(VectorizeFc(read_mot_all_pos_mask));
nNeg = sum(VectorizeFc(read_mot_all_neg_mask));
fprintf('%d pos edges, %d neg edges\n',nPos,nNeg);

% exclude these edges 
isMotionEdge = VectorizeFc(read_mot_all_pos_mask | read_mot_all_neg_mask)~=0;
FC_temp = VectorizeFc(FC_fisher);
FC_temp(isMotionEdge,:) = 0;
FC_fisher_noMotionEdges = UnvectorizeFc(FC_temp,0,true);

% look at gradCPT performance without these edges
[gradcpt_nomot_pos,gradcpt_nomot_neg,gradcpt_nomot_combo] = GetFcMaskMatch(FC_fisher_noMotionEdges,attnNets.pos_overlap,attnNets.neg_overlap);
[gradcpt_nomot_pos,gradcpt_nomot_neg,gradcpt_nomot_combo] = deal(gradcpt_nomot_pos',gradcpt_nomot_neg',gradcpt_nomot_combo');
[r,p] = corr(gradcpt_nomot_combo,fracCorrect,'tail','right');
fprintf('Predicting reading comp with GradCPT, no motion edges:\n');
fprintf('r=%.3g, p=%.3g\n',r,p);

% train new reading networks
[read_nomot_pos, read_nomot_neg, read_nomot_combo, read_nomot_posMask_all,read_nomot_negMask_all] = RunLeave1outBehaviorRegression(FC_fisher_noMotionEdges,fracCorrect,thresh,corr_method,mask_method);
fprintf('Done!\n');
[r,p] = corr(read_nomot_combo,fracCorrect,'tail','right');
fprintf('Predicting reading comp with CPM, no motion edges:\n');
fprintf('r=%.3g, p=%.3g\n',r,p);

%% Print results again
fprintf('===Excluding %d edges correlated (p<0.05) with subject motion. (%d pos edges, %d neg edges)\n',nPos+nNeg,nPos,nNeg);

[r,p] = corr(gradcpt_nomot_combo,fracCorrect,'tail','right');
fprintf('Predicting reading comp with GradCPT, no motion edges:\n');
fprintf('r=%.3g, p=%.3g\n',r,p);

[r,p] = corr(read_nomot_combo,fracCorrect,'tail','right');
fprintf('Predicting reading comp with CPM, no motion edges:\n');
fprintf('r=%.3g, p=%.3g\n',r,p);

%% Permutation tests for this!
