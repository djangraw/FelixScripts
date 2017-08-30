% UseRosenbergMatsToPredictPerformance.m
%
% Use the Rosenberg matrices (high-attention and low-attention networks) to
% try to predict performance on reading comprehension questions.
%
% Created 9/23/16 by DJ.

% subjects = [9:22 24:36];
% subjects = [9:11 13:19 22 24:25 28 30:33 36];
subjects = [9:11 13:19 22 24:25 28 30:34 36];

homedir = '/data/jangrawdc/PRJ03_SustainedAttention/Results/';
fprintf('Loading attention network matrices...\n')
shenAtlas = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_2mm_268_parcellation.nii.gz');
attnNets = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/attn_nets_268.mat');
demean = false;

[fracCorrect,RT,posMatch,negMatch,comboMatch,pctCensored,nRuns] = deal(nan(numel(subjects),1));
[FC,subjects_str,isMissingRoi] = deal(cell(numel(subjects),1));

doPlot = false;
if doPlot
    [attnNetLabels,labelNames,colors] = GetAttnNetLabels(false);
    figure(683); clf;
    subplot(2,2,1);
    PlotFcMatrix(attnNets.pos_overlap,[-1 1],[],attnNetLabels,[],colors);
end

% Get performance
for i=1:numel(subjects)
    % set up
    cd(homedir);
    subject = sprintf('SBJ%02d',subjects(i));
    fprintf('Getting FC for subject %d...\n',subjects(i))
    cd(subject)
%     foo = dir('AfniProc*');
%     cd(foo(1).name);
    cd('AfniProc_MultiEcho_2016-09-22');
    % load atlased data
%     filename = sprintf('shen268_%s_ROI_TS.1D',subject);
%     filename = sprintf('shen268_withSegTc_%s_ROI_TS.1D',subject); % No temporal filter
    filename = sprintf('shen268_withSegTc2_%s_ROI_TS.1D',subject); % 0.01-0.1Hz BPF
%     try
        % Load data
        [err,M,Info,Com] = Read_1D(filename);
        % Crop data
        isCensored = all(M==0,2);
        isZeroCol = all(M==0,1); % ROIs without enough voxels
        isMissingRoi{i} = isZeroCol;
        fprintf('Removing %d censored samples and %d (near-)empty ROIs\n',sum(isCensored),sum(isZeroCol))
        M_crop = M(~isCensored,~isZeroCol);
        nT = size(M_crop,1);
        % De-mean M and M_crop
        if demean
            M = M - repmat(mean(M,2),1,size(M,2));
            M_crop = M_crop - repmat(mean(M_crop,2),1,size(M_crop,2));
        end
%         plot(mean(M,2));
        % crop attn nets
        posTemplate = attnNets.pos_overlap(~isZeroCol,~isZeroCol);
        negTemplate = attnNets.neg_overlap(~isZeroCol,~isZeroCol);
        % load behavior data
        foo = load(sprintf('../Distraction-SBJ%02d-Behavior.mat',subjects(i)));
        isReading = strcmp('reading',foo.question.type);
        fracCorrect(i) = mean(foo.question.isCorrect(isReading));
        RT(i) = median(foo.question.RT(isReading));
        % get matches
        posMatch(i) = GetFcTemplateMatch(M_crop',posTemplate,nT,true,'mult');
        negMatch(i) = GetFcTemplateMatch(M_crop',negTemplate,nT,true,'mult');
        comboMatch(i) = GetFcTemplateMatch(M_crop',posTemplate-negTemplate,nT,true,'mult');
        
        % Read in censor file
        censor_file = sprintf('censor_SBJ%02d_combined_2.1D',subjects(i));
        isNotCensored = Read_1D(censor_file);
        % Quantify % censored timepoints
        pctCensored(i) = mean(~isNotCensored)*100;
        nRuns(i) = numel(foo.data);
        % get subject string
        subjects_str{i} = subject;
        % Get FC matrices (for plotting later)
        FC{i} = GetFcMatrices(M(~isCensored,:)','sw',nT);
        
        if doPlot && i<4
            subplot(2,2,i+1);
            fcPlot = atanh(FC{i});
            fcPlot(logical(eye(size(fcPlot)))) = 0;
            PlotFcMatrix(fcPlot,[-1 1]*.6,shenAtlas,attnNetLabels(~isZeroCol),[],colors);
            title(sprintf('S%d Functional Connectivity',i))
        else
%             error('Placeholder!');
        end
%     catch
%         fprintf('could not load.\n');
%     end
end
fprintf('Done!\n');
%% Plot results
% Get normalized stats
posMatchNorm = (posMatch - mean(posMatch))/std(posMatch);
negMatchNorm = (negMatch - mean(negMatch))/std(negMatch);
fracCorrectNorm = (fracCorrect - mean(fracCorrect))/std(fracCorrect);
RTNorm = (RT - mean(RT))/std(RT);
pctCensoredNorm = (pctCensored - mean(pctCensored))/std(pctCensored);


[r_pos,p_pos] = corr(fracCorrect, posMatch,'tail','right');
[r_neg,p_neg] = corr(fracCorrect, negMatch,'tail','left');
fprintf('One-tailed pos: R = %.3g, p = %.3g\n',r_pos,p_pos);
fprintf('One-tailed neg: R = %.3g, p = %.3g\n',r_neg,p_neg);

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
title(sprintf('Positive Prediction of Comprehension Accuracy:\nR^2=%.3f, p=%.3g',Rsq,p));

subplot(1,2,2);
lm = fitlm(fracCorrect,negMatch,'Linear','VarNames',{'fracCorrect','GlmCoefficient'}); % least squares
% plot line & CI
lm.plot;
xlabel('Comprehension Accuracy')
ylabel('Low-Attention Network Strength')
% Print results
[p,Rsq] = Run1tailedRegression(fracCorrect,negMatch,false);
fprintf('R^2 = %.3g, p = %.3g\n',Rsq,p);
title(sprintf('Negative Prediction of Comprehension Accuracy:\nR^2=%.3f, p=%.3g',Rsq,p));

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
title(sprintf('Positive-Negative Prediction of Comprehension Accuracy:\nR^2=%.3f, p=%.3g',Rsq,p));

% subplot(1,2,2);
% lm = fitlm(fracCorrect_WN-fracCorrect_SP,posMatch,'Linear','VarNames',{'fracCorrect','GlmCoefficient'}); % least squares
% % plot line & CI
% lm.plot;
% xlabel('Distractablity (Acc(noise) - Acc(speech))')
% ylabel('High-Attention Network Strength')
% % Print results
% [p,F,d] = coefTest(lm);
% Rsq = lm.Rsquared.Adjusted;
% fprintf('R^2 = %.3g, p = %.3g\n',Rsq,p);
% title(sprintf('BOLD FC Prediction of Distractability:\nR^2=%.3f, p=%.3f',Rsq,p));
