% leave1out_prediction_Distraction.m
%
% Adapted by DJ from leave1out_prediction.m, which is:

% Copyright 2015 Monica Rosenberg, Emily Finn, and Dustin Scheinost

% This code is released under the terms of the GNU GPL v2. This code
% is not FDA approved for clinical use; it is provided
% freely for research purposes. If using this in a publication
% please reference this properly as: 

% Rosenberg MD, Finn ES, Scheinost D, Papademetris X, Shen X, 
% Constable RT & Chun MM. (2016). A neuromarker of sustained
% attention from whole-brain functional connectivity. Nature Neuroscience 
% 19(1), 165-171.

% This code provides a framework for implementing functional
% connectivity-based behavioral prediction with leave-one-out cross-validaiton, as 
% described in Rosenberg, Finn et al 2016 (see above for full reference). 
% The first input ('train_mats') is a pre-calculated MxMxN matrix 
% containing all individual-subject connectivity matrices in the training 
% set, where M = number of nodes in the chosen brain atlas and N = number of
% subjects. Each element (i,j,k) in these matrices represents the
% correlation between the BOLD timecourses of nodes i and j in subject k
% during a single fMRI session. The second input ('behav') is the
% Nx1 vector of scores for the behavior of interest for all subjects.

% As in the reference paper, the predictive power of the model is assessed
% via correlation between predicted and observed scores across all
% subjects. Note that this assumes normal or near-normal distributions for
% both vectors, and does not assess absolute accuracy of predictions (only
% relative accuracy within the sample). It is recommended to explore
% additional/alternative metrics for assessing predictive power, such as
% prediction error sum of squares or prediction r^2.

% Modified 10/4-5/16 by DJ.

% clear;
% clc;

%% Load data
% Run UseRosenbergMatsToPredictPerformance; to get FC & behavior mats?

% subjects = [9:22 24:36];
% subjects = [9:11 13:19 22 24:25 28 30:33 36];
subjects = [9:11 13:19 22 24:25 28 30:34 36];
afniProcFolder = 'AfniProc_MultiEcho_2016-09-22';
tsFilePrefix = 'shen268_withSegTc2';
runComboMethod = 'avgRead';
[FC,isMissingRoi_anysubj,FC_runs] = GetFc_AllSubjects(subjects,afniProcFolder,tsFilePrefix,runComboMethod);
[fracCorrect, medRT] = GetFracCorrect_AllSubjects(subjects);

%%
doRand = false;
doRandBeh = false;
if doRand
    fprintf('===RANDOMIZING...===\n');
    FCrand = RandomizeFc(FC);
    FCmat = cat(3,FCrand{:});
else
    FCmat = FC;%cat(3,FC{:});
end
FCmat = atanh(FCmat);
FCmat(isinf(FCmat)) = max(FCmat(~isinf(FCmat)));
isOkSubj = squeeze(sum(sum(isnan(FCmat),1),2)==0);

n_node      = 268;                % number of nodes
thresh      = 0.01;               % p-value threshold for feature selection
% mask_method = 'cpcr';% CP and CR values
mask_method = 'one'; % binary mask
fit_method = 'mean'; % robustfit, sum, or mean
% thresh      = 1;               % p-value threshold for feature selection
% mask_method = 'log'; % weight = negative log of p value 
train_mats  = FCmat(:,:,isOkSubj);                   % training data (n_node x n_node x n_sub symmetrical connectivity matrices)
test_mats   = FCmat(:,:,isOkSubj);                   % testing data (This will be the same as train_mats when you're training and testing on the same data. If you are training on task matrices and testing on rest matrices, for example, train_mats and test_mats will be different.)
if doRandBeh
    fprintf('===RANDOMIZING BEHAVIOR...===\n');
    fracCorrect_rand = fracCorrect(isOkSubj);
    fracCorrect_rand = fracCorrect_rand(randperm(numel(fracCorrect_rand)));
    behav       = fracCorrect_rand;                   % n_sub x 1 vector of behavior
else
    behav       = fracCorrect(isOkSubj);                   % n_sub x 1 vector of behavior
end
n_sub       = size(train_mats,3); % number of subjects
n_train_sub = n_sub-1;            % number of subjects in each round of cross-validation

pred_pos = zeros(n_sub,1);
pred_neg = zeros(n_sub,1);
pred_glm = zeros(n_sub,1);

aa     = ones(n_node,n_node);
aa_upp = triu(aa,1);
upp_id = find(aa_upp);   % indices of edges in the upper triangular of an n_node x n_node matrix
n_edge = length(upp_id); % total number of edges 

% Added by DJ
tic; % Time execution
[pos_mask_all, neg_mask_all] = deal(nan(n_node,n_node,n_sub));
mask_size_cell = cell(1,n_sub);
fprintf('===FINDING MASKS IN %d LOSO ITERATIONS...===\n',n_sub);
parfor excl_sub = 1:n_sub
    
    fprintf('Subject %d/%d...\n',excl_sub,n_sub);
    warning('off','stats:statrobustfit:IterationLimit'); % suppress this warning to speed up code
    
    % exclude data from left-out subject
    train_mats_tmp = train_mats;
    train_mats_tmp(:,:,excl_sub) = [];
    train_behav = behav;
    train_behav(excl_sub) = [];
    
    % create n_train_sub x n_edge matrix
    train_vect = reshape(train_mats_tmp, n_node*n_node, n_train_sub)';
    upp_vect   = train_vect(:,upp_id); 
    
    % relate behavior to edge strength across training subjects
    cp = zeros(n_edge, 1);
    cr = zeros(n_edge, 1);
    
    for ii = 1:n_edge
        [b,stats] = robustfit(upp_vect(:,ii), train_behav);
        cp(ii)    = stats.p(2);
        cr(ii)    = sign(stats.t(2))*sqrt((stats.t(2)^2/(n_train_sub-2))/(1+(stats.t(2)^2/(n_train_sub-2))));
    end

    % select edges based on threshold
    pos_edge = zeros(1, n_edge);
    neg_edge = zeros(1, n_edge);
    
    cp_pos           = find(cp<thresh & cr>0);
    cp_neg           = find(cp<thresh & cr<0);
    switch mask_method
        case {'one','binary'}
            pos_edge(cp_pos) = 1;
            neg_edge(cp_neg) = 1;
        case 'log'
            pos_edge(cp_pos) = -log(cp(cp_pos)) + log(thresh);
            neg_edge(cp_neg) = -log(cp(cp_neg)) + log(thresh);
        case 'cpcr' % just save out the cp and cr matrices
            pos_edge = cp';
            neg_edge = cr';
    end
    
    pos_mask = zeros(n_node, n_node);
    neg_mask = zeros(n_node, n_node);
        
    pos_mask(upp_id) = pos_edge; % Here, masks are NOT symmetrical. To make symmetrical, set pos_mask = pos_mask + pos_mask'
    neg_mask(upp_id) = neg_edge;
        
    % sum edges for training subjects
    train_pos_sum = zeros(n_train_sub,1);
    train_neg_sum = zeros(n_train_sub,1);
    
    for k = 1:n_train_sub
        train_pos_sum(k) = sum(sum(pos_mask.*train_mats_tmp(:,:,k)));
        train_neg_sum(k) = sum(sum(neg_mask.*train_mats_tmp(:,:,k)));    
    end
    
    switch fit_method
        case 'robustfit'
            b_pos      = robustfit(train_pos_sum, train_behav);
            b_neg      = robustfit(train_neg_sum, train_behav);
            robGLM_fit = robustfit([train_pos_sum train_neg_sum],train_behav);
        case 'sum'
            b_pos = [0 1];
            b_neg = [0 1];
            robGLM_fit = [0 1 -1]; 
        case 'mean'
            b_pos = [0 1]/sum(pos_mask(:));
            b_neg = [0 1]/sum(neg_mask(:));
            b_glm = [0 1]/(sum(neg_mask(:)) + sum(pos_mask(:))) * 2;
            robGLM_fit = [0 1 -1]/(sum(pos_mask(:))+sum(neg_mask(:))); 
    end
    
    % generate predictions for left-out subject
    test_pos_sum = sum(sum(pos_mask.*test_mats(:,:,excl_sub)));
    test_neg_sum = sum(sum(neg_mask.*test_mats(:,:,excl_sub)));
    test_glm_sum = sum(sum((pos_mask-neg_mask).*test_mats(:,:,excl_sub)));
    
    pred_pos(excl_sub) = (b_pos(2)*test_pos_sum) + b_pos(1);
    pred_neg(excl_sub) = (b_neg(2)*test_neg_sum) + b_neg(1);
    pred_glm(excl_sub) = (b_glm(2)*test_glm_sum) + b_glm(1);
%     pred_glm(excl_sub) = robGLM_fit(1) + robGLM_fit(2)*test_pos_sum + robGLM_fit(3)*test_neg_sum;
    
    
%     mask_size(excl_sub,1) = sum(pos_edge);
%     mask_size(excl_sub,2) = sum(neg_edge);

    % Store masks and their sizes
    pos_mask_all(:,:,excl_sub) = pos_mask;
    neg_mask_all(:,:,excl_sub) = neg_mask;
    mask_size_cell{excl_sub} = [sum(pos_edge>0), sum(neg_edge>0)];
end
mask_size = cat(1,mask_size_cell{:});
t_exec = toc; % Time execution
fprintf('Done! Took %.3g seconds.\n',t_exec);

%% Use overlap matrices to predict behavior
fracCorrect = behav;
posMatch = pred_pos;
negMatch = pred_neg;
comboMatch = pred_glm;
% Plot results
figure(855); clf;
set(gcf,'Position',[282   715   986   379]);
subplot(1,2,1);
lm = fitlm(fracCorrect,posMatch,'Linear','VarNames',{'fracCorrect','GlmCoefficient'}); % least squares
% plot line & CI
lm.plot;
xlabel('Comprehension Accuracy')
ylabel('High-Attention Network Strength')
% Print results
[p,Rsq] = Run1tailedRegression(fracCorrect,posMatch,true);
fprintf('R^2 = %.3g, p = %.3g\n',Rsq,p);
title(sprintf('Positive Prediction of Comprehension Accuracy:\nR^2=%.3g, p=%.3g',Rsq,p));

subplot(1,2,2);
lm = fitlm(fracCorrect,negMatch,'Linear','VarNames',{'fracCorrect','GlmCoefficient'}); % least squares
% plot line & CI
lm.plot;
xlabel('Comprehension Accuracy')
ylabel('Low-Attention Network Strength')
% Print results
[p,Rsq] = Run1tailedRegression(fracCorrect,negMatch,false);
fprintf('R^2 = %.3g, p = %.3g\n',Rsq,p);
title(sprintf('Negative Prediction of Comprehension Accuracy:\nR^2=%.3g, p=%.3g',Rsq,p));

% Plot results
figure(856); clf;
set(gcf,'Position',[282   258   986   379]);
subplot(1,2,1);
lm = fitlm(posMatch,negMatch,'Linear','VarNames',{'fracCorrect','GlmCoefficient'}); % least squares
% plot line & CI
lm.plot;
xlabel('High-Attention Network Strength')
ylabel('Low-Attention Network Strength')
% Print results
[p,Rsq] = Run1tailedRegression(posMatch,negMatch,false);
fprintf('R^2 = %.3g, p = %.3g\n',Rsq,p);
title(sprintf('Positive and Negative Score Agreement:\nR^2=%.3g, p=%.3g',Rsq,p));

subplot(1,2,2);
lm = fitlm(fracCorrect,comboMatch,'Linear','VarNames',{'fracCorrect','GlmCoefficient'}); % least squares
% plot line & CI
lm.plot;
xlabel('Comprehension Accuracy')
ylabel('High-Low-Attention Network Strength')
% Print results
[p,Rsq] = Run1tailedRegression(fracCorrect,comboMatch,true);
fprintf('R^2 = %.3g, p = %.3g\n',Rsq,p);
title(sprintf('Positive-Negative Prediction of Comprehension Accuracy:\nR^2=%.3g, p=%.3g',Rsq,p));

fprintf('===Done!\n');

%% Get atlas & attention networks
shenAtlas = BrikLoad('/gpfs/gsfs5/users/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_2mm_268_parcellation.nii.gz');
attnNets = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/attn_nets_268.mat');
uppertri = triu(ones(size(attnNets.pos_overlap,1)),1);
attnNets.pos_overlap(~uppertri) = 0;
attnNets.neg_overlap(~uppertri) = 0;
[attnNetLabels,labelNames,colors] = GetAttnNetLabels(false);
%% Plot matrices
groupByCluster = true;
pos_overlap = mean(pos_mask_all,3)==1;%>0;%
neg_overlap = mean(neg_mask_all,3)==1;%>0;%
clusterClim = [-1 1] * 22;%*.1;
clusterAvgMethod = 'sum'; %'mean';
figure(3);
clf;
subplot(2,2,1);
PlotFcMatrix(pos_overlap-neg_overlap,[-1 1],shenAtlas,attnNetLabels,true,colors,false);
title('Distraction data, pos - neg overlap')
subplot(2,2,2);
PlotFcMatrix(pos_overlap-neg_overlap,clusterClim,shenAtlas,attnNetLabels,true,colors,clusterAvgMethod);
title('Distraction data, pos - neg overlap')

subplot(2,2,3);
PlotFcMatrix(attnNets.pos_overlap-attnNets.neg_overlap,[-1 1],shenAtlas,attnNetLabels,true,colors,false);
title('gradCPT data, pos - neg overlap')
subplot(2,2,4);
PlotFcMatrix(attnNets.pos_overlap-attnNets.neg_overlap,[-1 1]*90,shenAtlas,attnNetLabels,true,colors,clusterAvgMethod);
title('gradCPT data, pos - neg overlap')

MakeLegend(colors,labelNames,2,[.5 .5]);
set(gcf,'Position', [3 329 1023 728]);
MakeFigureTitle(sprintf('threshold p<%.3f',thresh));

%% Make spaghetti plots
[attnNetLabels,labelNames,colors] = GetAttnNetLabels(true);

figure(4);
clf;
subplot(2,2,1);
PlotConnectivityOnCircle(shenAtlas,attnNetLabels,pos_overlap,[],labelNames,true,colors);
title('Distraction data, pos overlap')
set(gca,'ydir','reverse')
axis equal
subplot(2,2,2);
PlotConnectivityOnCircle(shenAtlas,attnNetLabels,-neg_overlap,[],labelNames,true,colors);
title('Distraction data, neg overlap')
set(gca,'ydir','reverse')
axis equal

subplot(2,2,3);
PlotConnectivityOnCircle(shenAtlas,attnNetLabels,attnNets.pos_overlap,[],labelNames,true,colors);
title('gradCPT data, pos overlap')
set(gca,'ydir','reverse')
axis equal
subplot(2,2,4);
PlotConnectivityOnCircle(shenAtlas,attnNetLabels,-attnNets.neg_overlap,[],labelNames,true,colors);
title('gradCPT data, neg overlap')
set(gca,'ydir','reverse')
axis equal

MakeLegend(colors,labelNames,2,[.5 .5]);
set(gcf,'Position', [3 329 1023 728]);
MakeFigureTitle(sprintf('threshold p<%.3f',thresh));




%% Print overlap
figure(62); clf;

% Calculate level of overlap and odds of getting that much my chance:
% p = 1-hygecdf(x, 35778, k, n), where
% x = # overlapping edges
% k = # edges in the high-attention (757) or low-attention (630) network
% n = # edges in your network
distNets = struct('pos_overlap',pos_overlap,'neg_overlap',neg_overlap);
fields = fieldnames(distNets);
[nOverlap,pOverlap] = deal(nan(2));
fprintf('===Overlap significance assessed with hygecdf:\n');
for i=1:2
    for j=1:2
        nOverlap(i,j) = sum(sum(distNets.(fields{i}) & attnNets.(fields{j})));
        nInDistNets = sum(sum(distNets.(fields{i})));
        nInAttnNets = sum(sum(attnNets.(fields{j})));
        pOverlap(i,j) = 1-hygecdf(nOverlap(i,j), n_edge, nInAttnNets, nInDistNets);
        fprintf('Distraction %s vs. Rosenberg %s: p=%.3f\n',fields{i},fields{j},pOverlap(i,j));
    end
end

% plot overlap
hBar = bar(nOverlap);
% color to match Rosenberg JNeuro paper
set(hBar(1),'facecolor',[1 .5 0]);
set(hBar(2),'facecolor',[0 .65 .65]);
% Annotate plot
ylabel('# edges overlapping');
xlabel('Distraction Task Networks')
set(gca,'xticklabel',{'pos','neg'})
legend('Rosenberg pos (High-Attention)','Rosenberg neg (Low-Attention)','Location','NorthWest');
title(sprintf('Network Overlap Across Tasks\nthreshold p<%.3f',thresh));

%% Compare single-subject masks

pos_mask_mean = mean(pos_mask_all,3);
neg_mask_mean = mean(neg_mask_all,3);
% Plot
figure(893); clf;
for i=1:n_sub
    subplot(ceil(n_sub/2),4,i*2-1);
    PlotFcMatrix(pos_mask_all(:,:,i),[0 10],shenAtlas,attnNetLabels,true,colors,false);
    subplot(ceil(n_sub/2),4,i*2);
    PlotFcMatrix(neg_mask_all(:,:,i),[0 10],shenAtlas,attnNetLabels,true,colors,false);
end

%% Are Reading and Rosenberg regions closer than would be expected by chance?

roiPairDistances_pos = CompareRoiPairPositions(pos_overlap,attnNets.pos_overlap,shenAtlas);
roiPairDistances_neg = CompareRoiPairPositions(neg_overlap,attnNets.neg_overlap,shenAtlas);
% roiPairDistances_posneg = CompareRoiPairPositions(pos_overlap,attnNets.neg_overlap,shenAtlas);
% roiPairDistances_negpos = CompareRoiPairPositions(neg_overlap,attnNets.pos_overlap,shenAtlas);
% roiPairDistances_all = CompareRoiPairPositions(ones(n_node),ones(n_node),shenAtlas);
nRand = 100;
roiPairDistances_randpos = nan([size(roiPairDistances_pos),nRand]);
roiPairDistances_randneg = nan([size(roiPairDistances_neg),nRand]);
for i=1:nRand
    fprintf('Randomization %d/%d...\n',i,nRand);
    roiPairDistances_randpos(:,:,i) = CompareRoiPairPositions(RandomizeFc(pos_overlap),attnNets.pos_overlap,shenAtlas);
    roiPairDistances_randneg(:,:,i) = CompareRoiPairPositions(RandomizeFc(neg_overlap),attnNets.neg_overlap,shenAtlas);
end
%%
xHist = linspace(0,42,40);
n1 = hist(min(roiPairDistances_pos,[],2),xHist);
n2 = hist(min(roiPairDistances_neg,[],2),xHist);
% n3 = hist(roiPairDistances_all(roiPairDistances_all<42),xHist);
foo = min(roiPairDistances_randpos,[],2);
n3 = hist(foo(:),xHist);
foo = min(roiPairDistances_randneg,[],2);
n4 = hist(foo(:),xHist);
nPairDist_randpos = nan(nRand,numel(xHist));
nPairDist_randneg = nan(nRand,numel(xHist));
for i=1:nRand
    nPairDist_randpos(i,:) = hist(min(roiPairDistances_randpos(:,:,i),[],2),xHist);
    nPairDist_randneg(i,:) = hist(min(roiPairDistances_randneg(:,:,i),[],2),xHist);
end
[pct05_pos, pct95_pos, pct05_neg, pct95_neg]= deal(nan(1,numel(xHist)));
for j=1:numel(xHist)
    pct05_pos(j) = GetValueAtPercentile(nPairDist_randpos(:,j),5);
    pct95_pos(j) = GetValueAtPercentile(nPairDist_randpos(:,j),95);
    pct05_neg(j) = GetValueAtPercentile(nPairDist_randneg(:,j),5);
    pct95_neg(j) = GetValueAtPercentile(nPairDist_randneg(:,j),95);
end

% n3 = hist(min(roiPairDistances_posneg,[],2),xHist);
% n4 = hist(min(roiPairDistances_negpos,[],2),xHist);
% bar(xHist,[n1;n2;n3;n4]');
% bar(xHist,[n1/sum(n1);n2/sum(n2);n3/sum(n3)]'*100);
% plot(xHist,cumsum([n1/sum(n1);n2/sum(n2);n3/sum(n3);n4/sum(n4)]'*100));


figure(822); clf;
% plot(xHist,[n1/sum(n1);n2/sum(n2);n3/sum(n3);n4/sum(n4)]'*100);
% legend('positive','negative','random (pos)', 'random (neg)');
subplot(121); hold on
% plot(xHist,[n1/sum(n3)*nRand;n3/sum(n3)]'*100);
plot(xHist,n1);
% ErrorPatch(xHist,mean(nPairDist_randpos,1),std(nPairDist_randpos,[],1));
ErrorPatch(xHist,mean(nPairDist_randpos,1),pct05_pos,pct95_pos);
xlabel('dist between Reading edge and nearest Rosenberg edge (voxels)')
ylabel('# edges')
title('positive network')
legend('true','random (5th-95th %ile)')
subplot(122); hold on;
plot(xHist,n2);
% plot(xHist,[n2/sum(n4)*nRand;n4/sum(n4)]'*100);
ErrorPatch(xHist,mean(nPairDist_randneg,1),pct05_neg,pct95_neg);
xlabel('dist between Reading edge and nearest Rosenberg edge (voxels)')
ylabel('# edges')
title('negative network')
legend('true','random (5th-95th %ile)')

%% Use overlap matrices to predict behavior

bothNets_pos = distNets.pos_overlap & attnNets.pos_overlap;
bothNets_neg = distNets.neg_overlap & attnNets.neg_overlap;
[pos_sum_rose, neg_sum_rose, pos_sum_read, neg_sum_read, pos_sum_both,neg_sum_both] = deal(nan(n_sub,1));
for i=1:n_sub
    pos_sum_rose(i) = sum(sum(attnNets.pos_overlap.*test_mats(:,:,i)));
    neg_sum_rose(i) = sum(sum(attnNets.neg_overlap.*test_mats(:,:,i)));
    pos_sum_read(i) = sum(sum(distNets.pos_overlap.*test_mats(:,:,i)));
    neg_sum_read(i) = sum(sum(distNets.neg_overlap.*test_mats(:,:,i)));
    pos_sum_both(i) = sum(sum(bothNets_pos.*test_mats(:,:,i)));
    neg_sum_both(i) = sum(sum(bothNets_neg.*test_mats(:,:,i)));
end

% Correlate
[r_pos_rose,p_pos_rose] = corr(behav, pos_sum_rose);
[r_neg_rose,p_neg_rose] = corr(behav, neg_sum_rose);
[r_pos_read,p_pos_read] = corr(behav, pos_sum_read);
[r_neg_read,p_neg_read] = corr(behav, neg_sum_read);
[r_pos_both,p_pos_both] = corr(behav, pos_sum_both);
[r_neg_both,p_neg_both] = corr(behav, neg_sum_both);

% Plot
figure(522); clf;
ax(1) = subplot(3,2,1);
scatter(behav, pos_sum_rose)
title(sprintf('pos r = %.3g, p = %.3g',r_pos_rose,p_pos_rose))
xlabel('Observed Behavior')
ylabel('Rosenberg Pos Mask Sum')
% axis equal

ax(2) = subplot(3,2,2);
scatter(behav, neg_sum_rose)
title(sprintf('neg r = %.3g, p = %.3g',r_neg_rose,p_neg_rose))
xlabel('Observed Behavior')
ylabel('Rosenberg Neg Mask Sum')
% axis equal

ax(3) = subplot(3,2,3);
scatter(behav, pos_sum_read)
title(sprintf('pos r = %.3g, p = %.3g',r_pos_read,p_pos_read))
xlabel('Observed Behavior')
ylabel('Reading Pos Mask Sum')
% axis equal

ax(4) = subplot(3,2,4);
scatter(behav, neg_sum_read)
title(sprintf('neg r = %.3g, p = %.3g',r_neg_read,p_neg_read))
xlabel('Observed Behavior')
ylabel('Reading Neg Mask Sum')
% axis equal

ax(5) = subplot(3,2,5);
scatter(behav, pos_sum_both)
title(sprintf('pos r = %.3g, p = %.3g',r_pos_both,p_pos_both))
xlabel('Observed Behavior')
ylabel('Overlap Pos Mask Sum')
% axis equal

ax(6) = subplot(3,2,6);
scatter(behav, neg_sum_both)
title(sprintf('neg r = %.3g, p = %.3g',r_neg_both,p_neg_both))
xlabel('Observed Behavior')
ylabel('Overlap Neg Mask Sum')
% axis equal



linkaxes([ax],'xy')
if doRand
    MakeFigureTitle(sprintf('RANDOMIZED Fisher Normed FC, threshold p<%.3g',thresh));
else
    MakeFigureTitle(sprintf('Fisher Normed FC, threshold p<%.3g',thresh));
end


