% TestMultiFeatureRegression_script.m
% Created 10/27/17 by DJ.

% iGoodMetrics = [4 5 7 6 8 9 12 1 2 13 10 14];%[1:2, 4:10,12:14];
goodMetrics = {'pupilDilation','minus_globalFc','minus_dmn','gradcpt','visaud','fracCorrect'};%,'readingActiv','reading','fracCorrect'};
[~,iGoodMetrics] = ismember(goodMetrics,score_combo.Properties.VariableNames);
allMetrics = table2array(score_combo(:,iGoodMetrics));
allRs = corr(allMetrics);
rsWithRecall = allRs(:,end);
metricNames = score_combo.Properties.VariableNames(iGoodMetrics);
%% Plot results
figure(1);
clf; hold on;
bar(rsWithRecall);
set(gca,'xtick',1:numel(rsWithRecall),'xticklabel',metricNames);
xticklabel_rotate;
% Add average metric?
% isGoodMetric = 7:8;%rsWithRecall>0.6 & rsWithRecall<0.9;
% rMean = corr(allMetrics(:,end),mean(allMetrics(:,isGoodMetric),2));
% PlotHorizontalLines(rMean,'k--');

%% Use CV to combine results

% iGeneralMetric = [8 9 12 1 14]; % metrics to use + fracCorrect
% iGeneralMetric = [1:3 8:10 12:14];
iGeneralMetric = iGoodMetrics;
featTable = score_combo(:,iGeneralMetric);

mdlLin = fitrsvm(featTable,'fracCorrect','Standardize',true,'KFold',size(featTable,1));
[rSvm,pSvm] = corr(mdlLin.kfoldPredict,score_combo.fracCorrect,'tail','right');
fprintf('r=%.3f, p=%.3g\n',rSvm,pSvm);

%% Plot results
figure(628); clf;
subplot(1,2,1); hold on;
readingNorm = (score_combo.reading - mean(score_combo.reading))/std(score_combo.reading);
readingAdj = readingNorm*std(score_combo.fracCorrect) + mean(score_combo.fracCorrect);
lm1 = fitlm(readingAdj,score_combo.fracCorrect);
r1 = corr(readingAdj,score_combo.fracCorrect);
h1 = lm1.plot;
set(h1,'color','b');
xlim([0.3 1]);
ylim([0.3 1]);
title('Reading network score (normalized)');

subplot(1,2,2);
lm2 = fitlm(mdlLin.kfoldPredict,score_combo.fracCorrect);
r2 = corr(mdlLin.kfoldPredict,score_combo.fracCorrect);
h2 = lm2.plot;
set(h2,'color','r');
xlim([0.3 1]);
ylim([0.3 1]);
title('Multi-feature SVR')
fprintf('reading network r=%.3f, multi-feature r=%.3f\n',r1,r2);

%% Get and plot weights
nFeats = size(featTable,2)-1;
testmat = [zeros(1,nFeats); eye(nFeats)];

nFolds = mdlLin.KFold;
b = nan(1,nFolds);
w = nan(nFeats,nFolds);
for i=1:nFolds
    % Predict
    pred1 = predict(mdlLin.Trained{i},testmat);
    % extract weights
    b(i) = pred1(1);
    w(:,i) = (pred1(2:end)-b(i));
end

% prediction_est = featValues*w+b;
% get significance
pFeat = nan(1,nFeats);
for i=1:nFeats
    pFeat(i) = signrank(w(i,:));
end
% Plot
figure(629); clf; hold on;
wMean = mean(w,2); % across folds
bar(wMean);
errorbar(wMean,std(w,[],2)/sqrt(nFolds),'k.');
% plot stars
iO = find(pFeat<0.05 & pFeat>=0.01);
plot(iO,wMean(iO)+0.3*sign(wMean(iO)),'k*');
iStars = find(pFeat<0.01);
plot(iStars,wMean(iStars)+0.3*sign(wMean(iStars)),'k*');
featNames = mdlLin.PredictorNames;
set(gca,'xtick',1:nFeats,'xticklabel',featNames);

%% Run permutations
load('BehaviorPermutations_2017-08-30.mat'); % permBeh
nPerms = size(permBeh,2);
rSvm_perm = nan(1,nPerms);
b_perm = nan(nFolds,nPerms);
w_perm = nan(nFeats,nFolds,nPerms);
featTable_perm = featTable;
for iPerm=1:nPerms
    if mod(iPerm,10)==0
        fprintf('perm %d/%d (%.1f%%)...\n',iPerm,nPerms,iPerm/nPerms*100);
    end
    featTable_perm.fracCorrect = permBeh(:,iPerm);
    mdlLin_perm = fitrsvm(featTable_perm,'fracCorrect','Standardize',true,'KFold',size(featTable,1));
    rSvm_perm(iPerm) = corr(mdlLin_perm.kfoldPredict,featTable_perm.fracCorrect,'tail','right');
    % get weights
    for i=1:nFolds
        % Predict
        pred1 = predict(mdlLin_perm.Trained{i},testmat);
        % extract weights
        b_perm(i,iPerm) = pred1(1);
        w_perm(:,i,iPerm) = (pred1(2:end)-b_perm(i,iPerm));
    end
end

%% Use permutations to get p values
pSvm_perm = mean(rSvm<rSvm_perm); %one-tailed
pFeat_perm = mean(repmat((mean(w,2)),[1 1 nPerms])<(mean(w_perm,2)),3);

% Plot
figure(629); clf; hold on;
wMean = mean(w,2); % across folds
iBeh = 1;
iFmri = 2:numel(wMean);
bar(iBeh,wMean(iBeh),'c');
bar(iFmri,wMean(iFmri),'m');
errorbar(wMean,std(w,[],2)/sqrt(nFolds),'k.');
% plot stars
iO = find(pFeat_perm<0.05 & pFeat_perm>=0.01);
plot(iO,wMean(iO)+0.3*sign(wMean(iO)),'ko');
iStars = find(pFeat_perm<0.01);
plot(iStars,wMean(iStars)+0.3*sign(wMean(iStars)),'k*');
featNames = mdlLin.PredictorNames;
set(gca,'xtick',1:nFeats,'xticklabel',featNames);
ylabel('Mean SVR Weight Across CV Folds');
legend('behavioral','fMRI','StdErr across CV folds','p_{perm}<0.05')

%% Plot r value Bars

% Get confidence intervals
[rLower,rUpper] = deal(nan(1,nFeats+1));
for i=1:nFeats
    [~,~,rL,rU]= corrcoef(score_combo.(metricNames{i})(:),score_combo.fracCorrect(:));
    rLower(i) = rL(1,2);
    rUpper(i) = rU(1,2);
end
[~,~,rL,rU]= corrcoef(mdlLin.kfoldPredict,score_combo.fracCorrect(:));
rLower(nFeats+1) = rL(1,2);
rUpper(nFeats+1) = rU(1,2);

clf; hold on;
bar(iBeh,rsWithRecall(iBeh),'c');
bar(iFmri,rsWithRecall(iFmri),'m');
bar(iFmri(end)+1,rSvm,'g');
rsAll =[rsWithRecall(1:nFeats)', rSvm];
errorbar(1:(nFeats+1),rsAll,rsAll-rLower,rsAll-rUpper,'k.');
% plot stars
% iO = find(pSvm_perm<0.05 & pSvm_perm>=0.01);
% plot(iO,wMean(iO)+0.3*sign(wMean(iO)),'ko');
% iStars = find(pFeat_perm<0.01);
% plot(iStars,wMean(iStars)+0.3*sign(wMean(iStars)),'k*');
featNames = mdlLin.PredictorNames;
set(gca,'xtick',1:nFeats,'xticklabel',featNames);
ylabel('Correlation with Reading Recall');
legend('behavioral','fMRI','Combined','95% C.I.','p_{perm}<0.05','p_{perm}<0.01')

%% Save results

save('MutiFeatRegression_2017-10-30_6feat','featTable','b','w','rSvm','b_perm','w_perm','rSvm_perm');


%% Plot Reading Activation vs. fracCorrect (random SfN Plot)
figure(677); clf;
lm = fitlm(score_combo.fracCorrect*100, score_combo.readingActiv);
rThis = corr(score_combo.fracCorrect*100, score_combo.readingActiv);
rThis_perm = corr(score_combo.readingActiv,permBeh);
pThis_perm = mean(rThis<rThis_perm);
lm.plot;
xlabel('Recall Accuracy (%)');
ylabel('Reading Activation Strength');
title(sprintf('Reading-Task-Trained Activation\nr=%.3f, p_{perm}=%.3g',rThis,pThis_perm));