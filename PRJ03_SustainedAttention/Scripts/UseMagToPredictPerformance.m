function UseMagToPredictPerformance(subjects)

% UseMagToPredictPerformance(subjects)
%
% Use magnitude measure (GLM contrast strength) to predict each subject's
% relative level of performance. (just looks for a correlation).
%
% INPUTS: 
% -subjects is an n-element vector indicating the subject numbers
% (subjects(i)=9 indicates SBJ09).
%
% Created 9/9/16 by DJ.

%%
homedir = '/data/jangrawdc/PRJ03_SustainedAttention/Results/';
% Set up
nSubj = numel(subjects);

% nRows = ceil(sqrt(nSubj));
% nCols = ceil(nSubj/nRows);
[responsiveness,fracCorrect,fracCorrect_WN,fracCorrect_SP] = deal(nan(1,nSubj));
for iSubj = 1:nSubj
    %%
    subject = subjects(iSubj);
    
    fprintf('===SUBJECT %d===\n',subject);
    % Navigate to folder
    cd(sprintf('%sSBJ%02d',homedir,subject));
    beh = load(sprintf('Distraction-SBJ%02d-Behavior.mat',subject));
    datadir = dir('AfniProc*');
    fprintf('entering %s...\n',datadir(1).name);
    cd(datadir(1).name);

%     % Get magnitude data
%     switch atlasType
%         case 'Craddock'
%             [~,tc] = Read_1D(sprintf('SBJ%02d_CraddockAtlas_200Rois_ts.1D',subject));
%         case 'Craddock_e2'
%             [~,tc] = Read_1D(sprintf('SBJ%02d_CraddockAtlas_200Rois_ts_e2.1D',subject));
%         case 'Shen'
%             [~,tc] = Read_1D(sprintf('shen268_withSegTc_SBJ%02d_ROI_TS.1D',subject));
%         otherwise
%             tcFile = sprintf('%s_SBJ%02d_ROI_TS.1D',atlasType,subject);
%             if exist(tcFile,'file')
%                 [~,tc] = Read_1D(tcFile);
%             else
%                 error('Altas not recognized!');
%             end
%     end
%     tc = tc';
%     [~,censorM] = Read_1D(sprintf('censor_SBJ%02d_combined_2.1D',subject));    
%     isNotCensoredSample = censorM'>0;
%     tc(:,~isNotCensoredSample) = nan;
%     nRois = size(tc,1);
%     
%     % Get variance
%     if iSubj==1
%         varTc = nan(nSubj,nRois);
%     end
%     varTc(iSubj,:) = nanvar(tc,[],2);
    
    % Get mask for this subject
    [~,mask,maskInfo] = BrikLoad(sprintf('full_mask.SBJ%02d+tlrc',subject));
    % Get stats from stim-only GLM
    [~,stimStats,stimStatInfo] = BrikLoad(sprintf('stats_stimOnly.SBJ%02d+tlrc',subject));
    brickLabs = strsplit(stimStatInfo.BRICK_LABS,'~');
    iCoeff = find(strcmp(brickLabs,'WhiteNoiseVsSpeech_GLT#0_Coef'),1);
%     iCoeff = find(strcmp(brickLabs,'IgnoredVsAttendedSpeech_GLT#0_Coef'),1);
    coeff = stimStats(:,:,:,iCoeff);
    responsiveness(iSubj) = mean(coeff(mask(:)~=0));
    
    % Get fraction correct
    isReadingQ = strcmp(beh.question.type,'reading');
    fracCorrect(iSubj) = mean(beh.question.isCorrect(isReadingQ));
    
    % Get fraction correct(WN) vs. correct(SP)
    questionType = GetQuestionTypes(beh.data);
    fracCorrect_WN(iSubj) = mean(beh.question.isCorrect(ismember(questionType,{'reading_attendNoise','reading_ignoreNoise'})));
    fracCorrect_SP(iSubj) = mean(beh.question.isCorrect(ismember(questionType,{'reading_attendSpeech','reading_ignoreSpeech'})));
    
end

% %% Plot variances
% figure(325); clf; hold on;
% plot(varTc');
% xlabel('ROI')
% ylabel('variance')
%%
figure(852); clf;
set(gcf,'Position',[282   682   986   379]);
subplot(1,2,1);
lm = fitlm(fracCorrect,responsiveness,'Linear','VarNames',{'fracCorrect','GlmCoefficient'}); % least squares
% plot line & CI
lm.plot;
xlabel('Comprehension Accuracy')
ylabel('White Noise vs. Speech GLM coefficient')
% Print results
[p,F,d] = coefTest(lm);
Rsq = lm.Rsquared.Adjusted;
fprintf('R^2 = %.3g, p = %.3g\n',Rsq,p);
title(sprintf('BOLD Magnitude Prediction of Comprehension Accuracy:\nR^2=%.3f, p=%.3f',Rsq,p));

subplot(1,2,2);
lm = fitlm(fracCorrect_WN-fracCorrect_SP,responsiveness,'Linear','VarNames',{'fracCorrect','GlmCoefficient'}); % least squares
% plot line & CI
lm.plot;
xlabel('Distractablity (Acc(noise) - Acc(speech))')
ylabel('White Noise vs. Speech GLM coefficient')
% Print results
[p,F,d] = coefTest(lm);
Rsq = lm.Rsquared.Adjusted;
fprintf('R^2 = %.3g, p = %.3g\n',Rsq,p);
title(sprintf('BOLD Magnitude Prediction of Comprehension Accuracy:\nR^2=%.3f, p=%.3f',Rsq,p));

%% 
figure(853); clf;
% hist(fracCorrect,0.425:.05:1);
hist(fracCorrect_WN-fracCorrect_SP);
xlabel('Comprehension Accuracy')
ylabel('# of subjects')
xlim([0.4 1]);
title('Performance Histogram')

