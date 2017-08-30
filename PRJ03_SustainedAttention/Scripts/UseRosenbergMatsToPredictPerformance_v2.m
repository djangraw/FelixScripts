% UseRosenbergMatsToPredictPerformance.m
%
% Use the Rosenberg matrices (high-attention and low-attention networks) to
% try to predict performance on reading comprehension questions.
%
% Created 9/23/16 by DJ.
% Updated 11/16/16 by DJ - use new functions for FC from only reading
% samples, avg'd across runs
% Updated 11/28/16 by DJ - added posvnegMatch

%% set up
% subjects = [9:22 24:36];
% subjects = [9:11 13:19 22 24:25 28 30:33 36];
subjects = [9:11 13:19 22 24:25 28 30:34 36];

afniProcFolder = 'AfniProc_MultiEcho_2016-09-22'; % 9-22 = MNI
tsFilePrefix = 'shen268_withSegTc2'; % 'withSegTc2' means with BPFs
% tsFilePrefix = 'shen268_withSegTc_Rose'; % _Rose means with motion squares regressed out and gaussian filter
runComboMethod = 'avgRead'; % average of run-wise FC, limited to reading samples
doPlot = false;

% Load attention matrices
fprintf('Loading attention network matrices...\n')
shenAtlas = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_2mm_268_parcellation.nii.gz');
attnNets = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/attn_nets_268.mat');

[posMatch,negMatch,posvnegMatch,pctCensored,nRuns] = deal(nan(numel(subjects),1));

if doPlot
    [attnNetLabels,labelNames,colors] = GetAttnNetLabels(false);
    figure(683); clf;
    subplot(2,2,1);
    PlotFcMatrix(attnNets.pos_overlap,[-1 1],[],attnNetLabels,[],colors);
end

%% Get FC
[FC,isMissingRoi,FC_runs] = GetFc_AllSubjects(subjects,afniProcFolder,tsFilePrefix,runComboMethod);

%% Get performance
[fracCorrect, RT] = GetFracCorrect_AllSubjects(subjects);

%% Calculate matches
% get match between pos & neg matrices
nSubj = numel(subjects);
fprintf('===Calculating match for %d subjects...\n',nSubj)
for i=1:nSubj
    % crop attn nets
    posTemplate = attnNets.pos_overlap(~isMissingRoi,~isMissingRoi);
    negTemplate = attnNets.neg_overlap(~isMissingRoi,~isMissingRoi);
    if strncmp(runComboMethod,'cat',3)        
        % get matches
        posMatch(i) = GetFcTemplateMatch(FC(~isMissingRoi,~isMissingRoi,i),posTemplate,[],true,'meanmult');
        negMatch(i) = GetFcTemplateMatch(FC(~isMissingRoi,~isMissingRoi,i),negTemplate,[],true,'meanmult');
        posvnegMatch(i) = GetFcTemplateMatch(FC(~isMissingRoi,~isMissingRoi,i),posTemplate-negTemplate,[],true,'meanmult');
    else
        % get match for each run
        posMatch_runs = GetFcTemplateMatch(FC_runs{i}(~isMissingRoi,~isMissingRoi,:),posTemplate,[],true,'meanmult');
        negMatch_runs = GetFcTemplateMatch(FC_runs{i}(~isMissingRoi,~isMissingRoi,:),negTemplate,[],true,'meanmult');
        posvnegMatch_runs = GetFcTemplateMatch(FC_runs{i}(~isMissingRoi,~isMissingRoi,:),posTemplate-negTemplate,[],true,'meanmult');
        posMatch(i) = mean(posMatch_runs);
        negMatch(i) = mean(negMatch_runs);
        posvnegMatch(i) = mean(posvnegMatch_runs);
    end
        
end
fprintf('===Done!\n');

%% Plot results

fprintf('===Calculating and Plotting Correlations...\n')

% Calculate correlations
[r_pos,p_pos] = corr(fracCorrect, posMatch,'tail','right');
[r_neg,p_neg] = corr(fracCorrect, negMatch,'tail','left');
[r_posvneg,p_posvneg] = corr(fracCorrect, posvnegMatch,'tail','right');
fprintf('One-tailed pos: R = %.3g, p = %.3g\n',r_pos,p_pos);
fprintf('One-tailed neg: R = %.3g, p = %.3g\n',r_neg,p_neg);
fprintf('One-tailed pos-neg: R = %.3g, p = %.3g\n',r_posvneg,p_posvneg);

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
[p,F,d] = coefTest(lm);
p = p/2; % one-tailed test
Rsq = lm.Rsquared.Adjusted;
fprintf('R^2 = %.3g, p = %.3g\n',Rsq,p);
title(sprintf('Positive Prediction of Comprehension Accuracy:\nR^2=%.3f, p=%.3f',Rsq,p));

subplot(1,2,2);
lm = fitlm(fracCorrect,negMatch,'Linear','VarNames',{'fracCorrect','GlmCoefficient'}); % least squares
% plot line & CI
lm.plot;
xlabel('Comprehension Accuracy')
ylabel('Low-Attention Network Strength')
% Print results
[p,F,d] = coefTest(lm);
p = p/2; % one-tailed test
Rsq = lm.Rsquared.Adjusted;
fprintf('R^2 = %.3g, p = %.3g\n',Rsq,p);
title(sprintf('Negative Prediction of Comprehension Accuracy:\nR^2=%.3f, p=%.3f',Rsq,p));

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
[p,F,d] = coefTest(lm);
p = p/2; % one-tailed test
Rsq = lm.Rsquared.Adjusted;
fprintf('R^2 = %.3g, p = %.3g\n',Rsq,p);
title(sprintf('Positive and Negative Score Agreement:\nR^2=%.3g, p=%.3g',Rsq,p));

subplot(1,2,2);
lm = fitlm(fracCorrect,posMatch-negMatch,'Linear','VarNames',{'fracCorrect','GlmCoefficient'}); % least squares
% plot line & CI
lm.plot;
xlabel('Comprehension Accuracy')
ylabel('High-Low-Attention Network Strength')
% Print results
[p,F,d] = coefTest(lm);
p = p/2; % one-tailed test
Rsq = lm.Rsquared.Adjusted;
fprintf('R^2 = %.3g, p = %.3g\n',Rsq,p);
title(sprintf('Positive-Negative Prediction of Comprehension Accuracy:\nR^2=%.3f, p=%.3f',Rsq,p));

fprintf('===Done!\n');

