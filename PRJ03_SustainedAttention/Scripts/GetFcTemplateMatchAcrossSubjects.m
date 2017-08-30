% GetFcTemplateMatchAcrossSubjects.m
%
% Created 5/9/16 by DJ.

subjects = [9:22 24:36];
homedir = '/data/jangrawdc/PRJ03_SustainedAttention/Results/';
fprintf('Loading attention network matrices...\n')
attnNets = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/attn_nets_268.mat');
demean = false;

[fracCorrect,RT,posMatch,negMatch,pctCensored,nRuns] = deal(nan(numel(subjects),1));
[FC,subjects_str,isMissingRoi] = deal(cell(numel(subjects),1));

% cla; hold on;
for i=1:numel(subjects)
    % set up
    cd(homedir);
    subject = sprintf('SBJ%02d',subjects(i));
    fprintf('Getting FC for subject %d...\n',subjects(i))
    cd(subject)
    foo = dir('AfniProc*');
    cd(foo(1).name);
    % load atlased data
%     filename = sprintf('shen268_%s_ROI_TS.1D',subject);
    filename = sprintf('shen268_withSegTc_%s_ROI_TS.1D',subject);
    try
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
        foo = load(sprintf('../Distraction-%d-QuickRun.mat',subjects(i)));
        isReading = strcmp('reading',foo.question.type);
        fracCorrect(i) = mean(foo.question.isCorrect(isReading));
        RT(i) = median(foo.question.RT(isReading));
        % get matches
        posMatch(i) = GetFcTemplateMatch(M_crop',posTemplate,nT,true,'mult');
        negMatch(i) = GetFcTemplateMatch(M_crop',negTemplate,nT,true,'mult');
        
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
        
    catch
        fprintf('could not load.\n');
    end
end
fprintf('Done!\n');
%% Plot results
% Get normalized stats
posMatchNorm = (posMatch - mean(posMatch))/std(posMatch);
negMatchNorm = (negMatch - mean(negMatch))/std(negMatch);
fracCorrectNorm = (fracCorrect - mean(fracCorrect))/std(fracCorrect);
RTNorm = (RT - mean(RT))/std(RT);
pctCensoredNorm = (pctCensored - mean(pctCensored))/std(pctCensored);
% Plot bars
subplot(311);
cla;
bar([posMatchNorm,negMatchNorm,fracCorrectNorm,RTNorm,pctCensoredNorm]);
set(gca,'xtick',1:numel(subjects),'xticklabel',subjects_str);
xlabel('subject')
legend('pos attn match','neg attn match','fracCorrect','RT','frac TRs censored');
ylabel('normalized stat (see legend)');

% Check for pairwise correlations and plot
AllStats = table;
AllStats.posMatch = posMatch;
AllStats.negMatch = negMatch;
AllStats.fracCorrect = fracCorrect;
AllStats.RT = RT;
AllStats.pctCensored = pctCensored;
nStats = width(AllStats);
iPlot = 0;
nPlots = nStats*(nStats-1)/2;
isOutlier = pctCensored>15 | nRuns<4; % arbitrary cutoff
% [r,p] = corrcoef(table2array(AllStats)); % Get p values for linear fits
[r,p] = corrcoef(table2array(AllStats(~isOutlier,:))); % Get p values for linear fits
for i=1:nStats
    for j=i+1:nStats
        % Get  linear fit between this pair of variables
%         lm = fitlm(AllStats(:,[i j]),'linear');
        lm = fitlm(AllStats(~isOutlier,[i j]),'linear');
        % Set up plot
        iPlot = iPlot+1;
        subplot(3,nPlots/2,iPlot+nPlots/2);
        cla; hold on;
        % Plot trend line and CIs
        h = lm.plot;
        title(sprintf('%s vs. %s:\np=%.03g',lm.VariableNames{2},lm.VariableNames{1},p(i,j)));
        % Plot outliers
        plot(table2array(AllStats(isOutlier,i)),table2array(AllStats(isOutlier,j)),'mo');
        % Print stats
        fprintf('%s = %.3g %s + %.3g: p=%.3g\n',lm.VariableNames{2}, lm.Coefficients.Estimate(2), lm.VariableNames{1},lm.Coefficients.Estimate(1), lm.Coefficients.pValue(2));
    end
end