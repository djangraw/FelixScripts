% TestRosenbergPredictions_CogStates_Natasha_wrapper.m
%
% Created 11/22/16 by DJ.
% Updated 12/5/16 by DJ - copied from _Fast to _Natasha, removed perm tests
% and single-block version

%% Get FC matrices
% Set up
subjects = [6:13,16:27];
demeanTs = true;
separateTasks = true;
nSubj = numel(subjects);
% Get FC
FCtmp = GetFcForCogStateData(subjects(1),separateTasks,demeanTs);
FC = nan([size(FCtmp),nSubj]);
winInfo_cell = cell(1,nSubj);
for i=1:nSubj
    [FC(:,:,:,i),winInfo_cell{i}] = GetFcForCogStateData(subjects(i),separateTasks,demeanTs);
end
taskNames = winInfo_cell{1}.winNames;

%% Get behavior
nWindows = size(FC,3);
behavior_avg_RT = nan(nSubj,nWindows);
behavior_avg_PC = nan(nSubj,nWindows);
behDir='/data/jangrawdc/PRJ08_CognitiveStateDetection/PrcsData/Behavior';
for i=1:numel(subjects)
    filename = sprintf('%s/SBJ%02d_Behavior.mat',behDir,i);
    foo = load(filename);
    behavior_avg_RT(i,:) = foo.averageRT;
    behavior_avg_PC(i,:) = foo.percentCorrect;
end

%% Get atlas & attention networks
shenAtlas = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_2mm_268_parcellation.nii.gz');
[shenLabels,shenLabelNames,shenLabelColors] = GetAttnNetLabels(false);
% Get Rosenberg Hi/Low-Attn matrices
attnNets = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/attn_model_268.mat');

%% Run 'True Test' of predicting avg behavior across all tasks using avg FC across all tasks
doRandBeh = false; % for randomizing behavior between subjects
doRand = false; % Randomize FC matrix elements (separately for each subject)
% fcTasks = {'MATH'};
fcTasks = {'REST','BACK','VIDE','MATH'};
% behTasks = {'MATH'};
behTasks = {'BACK','VIDE','MATH'};
doPlot = true;

[P_true,Rsq_true] = TestRosenbergPredictions_CogStates_Natasha(FC,attnNets,behavior_avg_PC,taskNames,doRandBeh,doRand,fcTasks,behTasks,doPlot);


%% Test single-task results
doRandBeh = false; % for randomizing behavior between subjects
doRand = false; % Randomize FC matrix elements (separately for each subject)
% fcTasks = {'MATH'};
fcTasks = {'REST','BACK','VIDE','MATH'};
% behTasks = {'MATH'};
behTasks = {'BACK','VIDE','MATH'};

[P_task,Rsq_task] = deal(nan(numel(fcTasks),numel(behTasks),3));

for i=1:numel(fcTasks)
    for j=1:numel(behTasks)
        [P_tmp,Rsq_tmp] = TestRosenbergPredictions_CogStates_Natasha(FC,attnNets,behavior_avg_PC,taskNames,doRandBeh,doRand,fcTasks(i),behTasks(j));
        P_task(i,j,:) = reshape(P_tmp,1,1,3);
        Rsq_task(i,j,:) = reshape(Rsq_tmp,1,1,3);
    end
end

%% Plot single-task results
figure(824); clf;
names = {'High-Attention','Low-Attention','Combined'};
for i=1:3
    subplot(1,3,i); hold on;
    imagesc(Rsq_task(:,:,i));
    set(gca,'xtick',1:numel(behTasks),'xticklabel',behTasks,...
        'ytick',1:numel(fcTasks),'yticklabel',fcTasks,...
        'clim',[0 1] *max(Rsq_task(:)));%[0 0.1]);
    xlabel('behavior predicted')
    ylabel('FC used')
    [iStars,jStars] = find(P_task(:,:,i)<0.05);
    plot(jStars,iStars,'k*');
    colorbar
    xlim([0 numel(behTasks)]+0.5);
    ylim([0 numel(fcTasks)]+0.5);
    title(sprintf('R^2 values for %s network',names{i}))
end
% Plot how each subject did on each task
figure(825); clf;
avgBeh = nan(nSubj,numel(behTasks));
for i=1:numel(behTasks)
    isOkTask = strncmp(behTasks{i},taskNames,length(behTasks{i}));
    avgBeh(:,i) = nanmean(behavior_avg_PC(:,isOkTask),2);
end
imagesc(avgBeh);
set(gca,'xtick',1:numel(behTasks),'xticklabel',behTasks);
ylabel('subject')
xlabel('behavior from task')
title('Cog States Data Behavior')
colorbar

%% Get task based functional connectivity vs behavior for FC task = behavior task
doRandBeh = false; % for randomizing behavior between subjects
doRand = false; % Randomize FC matrix elements (separately for each subject)
% fcTasks = {'MATH'};
fcTasks = {'REST','BACK','VIDE','MATH'};
% behTasks = {'MATH'};
behTasks = {'BACK','VIDE','MATH'};
doPlot = true;

P_task_com_per = nan(3,numel(behTasks));
Rsq_task_com_per = nan(3,numel(behTasks));
pred_pos_mat = nan(20,numel(behTasks));
pred_neg_mat = nan(20,numel(behTasks));
pred_glm_mat = nan(20,numel(behTasks));
behav_mat = nan(20,numel(behTasks));

for j=1:numel(behTasks)
    [P_tmp,Rsq_tmp,pred_pos,pred_neg,pred_glm,behav] = TestRosenbergPredictions_CogStates_Natasha(FC,attnNets,behavior_avg_PC,taskNames,doRandBeh,doRand,behTasks(j),behTasks(j));
    P_task_com_per(:,j) = P_tmp';
    Rsq_task_com_per(:,j) = Rsq_tmp';
    pred_pos_mat(:,j) = pred_pos;
    pred_neg_mat(:,j) = pred_neg;
    pred_glm_mat(:,j) = pred_glm;
    behav_mat(:,j) = behav;
end

%% Same for beh task = 2-back, FC task varies
P_taskFc_2backBeh = nan(3,numel(fcTasks));
Rsq_taskFc_2backBeh = nan(3,numel(fcTasks));
[pred_pos_taskFc_2backBeh, pred_neg_taskFc_2backBeh, pred_glm_taskFc_2backBeh, behav_taskFc_2backBeh] = ...
    deal(nan(20,numel(behTasks)));

for j=1:numel(fcTasks)
    [P_tmp,Rsq_tmp,pred_pos,pred_neg,pred_glm,behav] = TestRosenbergPredictions_CogStates_Natasha(FC,attnNets,behavior_avg_PC,taskNames,doRandBeh,doRand,fcTasks(j),{'BACK'});
    P_taskFc_2backBeh(:,j) = P_tmp';
    Rsq_taskFc_2backBeh(:,j) = Rsq_tmp';
    pred_pos_taskFc_2backBeh(:,j) = pred_pos;
    pred_neg_taskFc_2backBeh(:,j) = pred_neg;
    pred_glm_taskFc_2backBeh(:,j) = pred_glm;
    behav_taskFc_2backBeh(:,j) = behav;
end
    

%% Plot simply
figure(244); clf;
PlotNetworkBehaviorPredictionLines(behav_mat,pred_pos_mat,pred_neg_mat,pred_glm_mat,behTasks);
figure(245); clf;
PlotNetworkBehaviorPredictionLines(behav_taskFc_2backBeh,pred_pos_taskFc_2backBeh,pred_neg_taskFc_2backBeh,pred_glm_taskFc_2backBeh,fcTasks);



%% Plot on same axes with different line colors

Line_Color = 'rgb';
legendCell = cell(numel(behTasks),3); % row = task, col = pos/neg/glm
for i=1:3
    subplot(1,3,i); cla; hold on;
    for j=1:numel(behTasks)
        plot(-inf,-inf,[Line_Color(j) 'x']);
    end
end

for i=1:numel(behTasks)
    lm1 = fitlm(behav_mat(:,i),pred_pos_mat(:,i),'Linear','VarNames',{'fracCorrect','PosNetworkPrediction'}); % least squares
    [P_this,F,d] = coefTest(lm1);
    if lm1.Coefficients.Estimate(2)>0
        P_this = P_this/2; % one-tailed test
    else
        P_this = 1-(1-P_this)/2; % one-tailed test
    end

    Rsq_this = lm1.Rsquared.Adjusted;
    fprintf('Pos: R^2 = %.3g, p = %.3g\n',Rsq_this,P_this);
    P(1) = P_this; Rsq(1) = Rsq_this;

    lm2 = fitlm(behav_mat(:,i),pred_neg_mat(:,i),'Linear','VarNames',{'fracCorrect','NegNetworkPrediction'}); % least squares
    [P_this,F,d] = coefTest(lm2);
    if lm2.Coefficients.Estimate(2)<0
        P_this = P_this/2; % one-tailed test
    else
        P_this = 1-(1-P_this)/2; % one-tailed test
    end
    Rsq_this = lm2.Rsquared.Adjusted;
    fprintf('Neg: R^2 = %.3g, p = %.3g\n',Rsq_this,P_this);
    P(2) = P_this; Rsq(2) = Rsq_this;

    lm3 = fitlm(behav_mat(:,i),pred_glm_mat(:,i),'Linear','VarNames',{'fracCorrect','ComboGlmPrediction'}); % least squares
    [P_this,F,d] = coefTest(lm3);
    if lm3.Coefficients.Estimate(2)>0
        P_this = P_this/2; % one-tailed test
    else
        P_this = 1-(1-P_this)/2; % one-tailed test
    end
    Rsq_this = lm3.Rsquared.Adjusted;
    fprintf('GLM: R^2 = %.3g, p = %.3g\n',Rsq_this,P_this);
    P(3) = P_this; Rsq(3) = Rsq_this;

    if doPlot
        subplot(1,3,1);
        h1 = lm1.plot;
        set(h1,'color', Line_Color(i));
        title(sprintf('Positive Prediction of Accuracy:\nR^2=%.3f, p=%.3g',Rsq(1),P(1)));
        xlabel('Observed Behavior')
        ylabel(sprintf('Pos Mask Total'))
        legendCell{i,1} = sprintf('%s: R^2=%.3f, p=%.3g',behTasks{i},Rsq(1),P(1));
%         legend(['\nR^2=%.3f, p=%.3g',Rsq(1),P(1)])
        hold on

        subplot(1,3,2);
        h2 = lm2.plot;
        set(h2,'color', Line_Color(i))
        title(sprintf('Negative Prediction of Accuracy:\nR^2=%.3f, p=%.3g',Rsq(2),P(2)));
        xlabel('Observed Behavior')
        ylabel(sprintf('Neg Mask Total'))
        legendCell{i,2} = sprintf('%s: R^2=%.3f, p=%.3g',behTasks{i},Rsq(2),P(2));
        %text(65,0,['\nR^2=%.3f, p=%.3g',Rsq(2),P(2)])
        hold on

        subplot(1,3,3);
        h3 = lm3.plot;
        set(h3,'color', Line_Color(i))
        title(sprintf('Combined Prediction of Accuracy:\nR^2=%.3f, p=%.3g',Rsq(3),P(3)));
        xlabel('Observed Behavior')
        ylabel(sprintf('Pos-Neg Mask Total'))
        legendCell{i,3} = sprintf('%s: R^2=%.3f, p=%.3g',behTasks{i},Rsq(3),P(3));
        %text(65,0,['\nR^2=%.3f, p=%.3g',Rsq(3),P(3)])
        hold on
        
    end
end

%Make legends
for i=1:3
    subplot(1,3,i);
    legend(legendCell{:,i});
    xlim([40 109])
end

















%% ========== OTHER EXPERIMENTS =================%%


%% Get task based functional connectivity vs behavior using FC from REST
doRandBeh = false; % for randomizing behavior between subjects
doRand = false; % Randomize FC matrix elements (separately for each subject)
% fcTasks = {'MATH'};
fcTasks = {'REST','BACK','VIDE','MATH'};
% behTasks = {'MATH'};
behTasks = {'BACK','VIDE','MATH'};
doPlot = true;

%P_task_com_per = nan(3,numel(behTasks));
%Rsq_task_com_per = nan(3,numel(behTasks));
%pred_pos_mat = nan(20,numel(behTasks));
%pred_neg_mat = nan(20,numel(behTasks));
%pred_glm_mat = nan(20,numel(behTasks));
%behav_mat = nan(20,numel(behTasks));



for j=1:numel(behTasks)
    [P_tmp,Rsq_tmp,pred_pos,pred_neg,pred_glm,behav] = TestRosenbergPredictions_CogStates_Natasha(FC,attnNets,behavior_avg_PC,taskNames,doRandBeh,doRand,fcTasks(1),behTasks(j));
    %P_task_com_per(:,j) = P_tmp';
    %Rsq_task_com_per(:,j) = Rsq_tmp';
    pred_pos_mat_R(:,j) = pred_pos;
    pred_neg_mat_R(:,j) = pred_neg;
    pred_glm_mat_R(:,j) = pred_glm;
    %behav_mat_R(:,j) = behav;
end

%% Plot task based functional connectivity vs behavior (Use overlap matrices to predict behavior)

% Correlate
% [r_pos,p_pos] = corr(behav, pred_pos);
% [r_neg,p_neg] = corr(behav, pred_neg);
% [r_glm,p_glm] = corr(behav, pred_glm);

P = nan(1,3);
Rsq = nan(1,3);

lm1 = fitlm(behav,pred_pos,'Linear','VarNames',{'fracCorrect','PosNetworkPrediction'}); % least squares
[P_this,F,d] = coefTest(lm1);
if lm1.Coefficients.Estimate(2)>0
    P_this = P_this/2; % one-tailed test
else
    P_this = 1-(1-P_this)/2; % one-tailed test
end
Rsq_this = lm1.Rsquared.Adjusted;
fprintf('Pos: R^2 = %.3g, p = %.3g\n',Rsq_this,P_this);
P(1) = P_this; Rsq(1) = Rsq_this;

lm2 = fitlm(behav,pred_neg,'Linear','VarNames',{'fracCorrect','NegNetworkPrediction'}); % least squares
[P_this,F,d] = coefTest(lm2);
if lm2.Coefficients.Estimate(2)<0
    P_this = P_this/2; % one-tailed test
else
    P_this = 1-(1-P_this)/2; % one-tailed test
end
Rsq_this = lm2.Rsquared.Adjusted;
fprintf('Neg: R^2 = %.3g, p = %.3g\n',Rsq_this,P_this);
P(2) = P_this; Rsq(2) = Rsq_this;

lm3 = fitlm(behav,pred_glm,'Linear','VarNames',{'fracCorrect','ComboGlmPrediction'}); % least squares
[P_this,F,d] = coefTest(lm3);
if lm3.Coefficients.Estimate(2)>0
    P_this = P_this/2; % one-tailed test
else
    P_this = 1-(1-P_this)/2; % one-tailed test
end
Rsq_this = lm3.Rsquared.Adjusted;
fprintf('GLM: R^2 = %.3g, p = %.3g\n',Rsq_this,P_this);
P(3) = P_this; Rsq(3) = Rsq_this;

    text(350,10,['R^2=' num2str(R_mat(i))])
    
    if doPlot
    subplot(1,3,1);
    lm1.plot;
    title(sprintf('Positive Prediction of Accuracy:\nR^2=%.3f, p=%.3g',Rsq(1),P(1)));
    xlabel('Observed Behavior')
    ylabel(sprintf('Pos Mask Total'))
    

    subplot(1,3,2);
    lm2.plot;
    title(sprintf('Negative Prediction of Accuracy:\nR^2=%.3f, p=%.3g',Rsq(2),P(2)));
    xlabel('Observed Behavior')
    ylabel(sprintf('Neg Mask Total'))

    subplot(1,3,3);
    lm3.plot;
    title(sprintf('Combined Prediction of Accuracy:\nR^2=%.3f, p=%.3g',Rsq(3),P(3)));
    xlabel('Observed Behavior')
    ylabel(sprintf('Pos-Neg Mask Total'))


    end




%% Plot Rest vs Behavior

clf;
legendCell = cell(numel(behTasks),2); % row = task, col = pos/neg/glm
for i=1:2
    subplot(1,2,i); cla; hold on;
    for j=1:numel(behTasks)
        plot(-inf,-inf,[Line_Color(j) 'x']);
    end
end
for i=1:numel(behTasks)
    
    lm3 = fitlm(behav_mat(:,i),pred_glm_mat(:,i),'Linear','VarNames',{'fracCorrect','ComboGlmPrediction'}); % least squares
    [P_this,F,d] = coefTest(lm3);
    if lm3.Coefficients.Estimate(2)>0
        P_this = P_this/2; % one-tailed test
    else
        P_this = 1-(1-P_this)/2; % one-tailed test
    end
    
    Rsq_this = lm3.Rsquared.Adjusted;
    fprintf('GLM: R^2 = %.3g, p = %.3g\n',Rsq_this,P_this);
    P(3) = P_this; Rsq(3) = Rsq_this;
    
    lm4 = fitlm(behav_mat(:,i),pred_glm_mat_R(:,i),'Linear','VarNames',{'fracCorrect','ComboGlmPrediction'}); % least squares
    [P_this,F,d] = coefTest(lm4);
    if lm4.Coefficients.Estimate(2)>0
        P_this = P_this/2; % one-tailed test
    else
        P_this = 1-(1-P_this)/2; % one-tailed test
    end
    
    Rsq_this = lm4.Rsquared.Adjusted;
    fprintf('GLM: R^2 = %.3g, p = %.3g\n',Rsq_this,P_this);
    P(4) = P_this; Rsq(4) = Rsq_this;
    
    if doPlot
        subplot(1,2,1);
        h3 = lm3.plot;
        set(h3,'color', Line_Color(i))
        title(sprintf('Grad-CPT Network: FC Matched with Performance'));
        xlabel('Observed Behavior')
        ylabel(sprintf('Pos-Neg Mask Total'))
        legendCell{i,1} = sprintf('%s: R^2=%.3f, p=%.3g',behTasks{i},Rsq(3),P(3));
        %text(65,0,['\nR^2=%.3f, p=%.3g',Rsq(3),P(3)])
        hold on

        subplot(1,2,2);
        h4 = lm4.plot;
        set(h4,'color', Line_Color(i))
        title(sprintf('Rest: Combined Prediction of Accuracy'));
        xlabel('Observed Behavior')
        ylabel(sprintf('Pos-Neg Mask Total'))
        legendCell{i,2} = sprintf('%s: R^2=%.3f, p=%.3g',behTasks{i},Rsq(4),P(4));
        %text(65,0,['\nR^2=%.3f, p=%.3g',Rsq(3),P(3)])
        hold on
    end
end 

%Make legends
for i=1:2
    subplot(1,2,i);
    legend(legendCell{:,i});
    xlim([40 109])
end

%% Plot Rest vs Behavior - outliers

%Outliers: Subject 5 and Subject 14
%Generate Outlier Matrices
%First duplicate variables and rename then delete like example below
%pred_glm_mat_R_woo(5,:) = []
%pred_glm_mat_R_woo(13,:) = []

clf;
legendCell = cell(numel(behTasks),2); % row = task, col = pos/neg/glm
for i=1:2
    subplot(1,2,i); cla; hold on;
    for j=1:numel(behTasks)
        plot(-inf,-inf,[Line_Color(j) 'x']);
    end
end
for i=1:numel(behTasks)
    
    lm3 = fitlm(behav_mat_woo(:,i),pred_glm_mat_woo(:,i),'Linear','VarNames',{'fracCorrect','ComboGlmPrediction'}); % least squares
    [P_this,F,d] = coefTest(lm3);
    if lm3.Coefficients.Estimate(2)>0
        P_this = P_this/2; % one-tailed test
    else
        P_this = 1-(1-P_this)/2; % one-tailed test
    end
    
    Rsq_this = lm3.Rsquared.Adjusted;
    fprintf('GLM: R^2 = %.3g, p = %.3g\n',Rsq_this,P_this);
    P(3) = P_this; Rsq(3) = Rsq_this;
    
    lm4 = fitlm(behav_mat_woo(:,i),pred_glm_mat_R_woo(:,i),'Linear','VarNames',{'fracCorrect','ComboGlmPrediction'}); % least squares
    [P_this,F,d] = coefTest(lm4);
    if lm4.Coefficients.Estimate(2)>0
        P_this = P_this/2; % one-tailed test
    else
        P_this = 1-(1-P_this)/2; % one-tailed test
    end
    
    Rsq_this = lm4.Rsquared.Adjusted;
    fprintf('GLM: R^2 = %.3g, p = %.3g\n',Rsq_this,P_this);
    P(4) = P_this; Rsq(4) = Rsq_this;
    
    if doPlot
        subplot(1,2,1);
        h3 = lm3.plot;
        set(h3,'color', Line_Color(i))
        title(sprintf('Matched: Combined Prediction of Accuracy\n w/o Outliers Subject 5 and Subject 14'));
        xlabel('Observed Behavior')
        ylabel(sprintf('Pos-Neg Mask Total'))
        legendCell{i,1} = sprintf('%s: R^2=%.3f, p=%.3g',behTasks{i},Rsq(3),P(3));
        %text(65,0,['\nR^2=%.3f, p=%.3g',Rsq(3),P(3)])
        hold on

        subplot(1,2,2);
        h4 = lm4.plot;
        set(h4,'color', Line_Color(i))
        title(sprintf('Rest: Combined Prediction of Accuracy\n w/o Outliers Subject 5 and Subject 14'));
        xlabel('Observed Behavior')
        ylabel(sprintf('Pos-Neg Mask Total'))
        legendCell{i,2} = sprintf('%s: R^2=%.3f, p=%.3g',behTasks{i},Rsq(4),P(4));
        %text(65,0,['\nR^2=%.3f, p=%.3g',Rsq(3),P(3)])
        hold on
    end
end 

%Make legends
for i=1:2
    subplot(1,2,i);
    legend(legendCell{:,i});
    xlim([40 109])
end


%% Use overlap matrices to predict behavior without outliers

% Correlate
% [r_pos,p_pos] = corr(behav, pred_pos);
% [r_neg,p_neg] = corr(behav, pred_neg);
% [r_glm,p_glm] = corr(behav, pred_glm);

P = nan(1,3);
Rsq = nan(1,3);

lm1 = fitlm(behav,pred_pos,'Linear','VarNames',{'fracCorrect','PosNetworkPrediction'}); % least squares
[P_this,F,d] = coefTest(lm1);
if lm1.Coefficients.Estimate(2)>0
    P_this = P_this/2; % one-tailed test
else
    P_this = 1-(1-P_this)/2; % one-tailed test
end
Rsq_this = lm1.Rsquared.Adjusted;
fprintf('Pos: R^2 = %.3g, p = %.3g\n',Rsq_this,P_this);
P(1) = P_this; Rsq(1) = Rsq_this;

lm2 = fitlm(behav,pred_neg,'Linear','VarNames',{'fracCorrect','NegNetworkPrediction'}); % least squares
[P_this,F,d] = coefTest(lm2);
if lm2.Coefficients.Estimate(2)<0
    P_this = P_this/2; % one-tailed test
else
    P_this = 1-(1-P_this)/2; % one-tailed test
end
Rsq_this = lm2.Rsquared.Adjusted;
fprintf('Neg: R^2 = %.3g, p = %.3g\n',Rsq_this,P_this);
P(2) = P_this; Rsq(2) = Rsq_this;

lm3 = fitlm(behav_woo,pred_glm_woo,'Linear','VarNames',{'fracCorrect','ComboGlmPrediction'}); % least squares
[P_this,F,d] = coefTest(lm3);
if lm3.Coefficients.Estimate(2)>0
    P_this = P_this/2; % one-tailed test
else
    P_this = 1-(1-P_this)/2; % one-tailed test
end
Rsq_this = lm3.Rsquared.Adjusted;
fprintf('GLM: R^2 = %.3g, p = %.3g\n',Rsq_this,P_this);
P(3) = P_this; Rsq(3) = Rsq_this;

if doPlot
    subplot(1,3,1);
    lm1.plot;
    title(sprintf('Positive Prediction of Accuracy:\nR^2=%.3f, p=%.3g',Rsq(1),P(1)));
    xlabel('Observed Behavior')
    ylabel(sprintf('Pos Mask Total'))

    subplot(1,3,2);
    lm2.plot;
    title(sprintf('Negative Prediction of Accuracy:\nR^2=%.3f, p=%.3g',Rsq(2),P(2)));
    xlabel('Observed Behavior')
    ylabel(sprintf('Neg Mask Total'))

    subplot(1,3,3);
    lm3.plot;
    title(sprintf('Combined Prediction of Accuracy:\n w/o Outliers Subject 5 and Subject 15\nR^2=%.3f, p=%.3g',Rsq(3),P(3)'));
    xlabel('Observed Behavior')
    ylabel(sprintf('Pos-Neg Mask Total'))
    %R^2=%.3f, p=%.3g',Rsq(3),P(3)

end


%% Plot Rest vs Behavior - outliers

%Outliers: Subject 5 and Subject 14
%Generate Outlier Matrices
%First duplicate variables and rename then delete like example below
%pred_glm_mat_R_woo(5,:) = []
%pred_glm_mat_R_woo(13,:) = []

clf;
legendCell = cell(numel(behTasks),2); % row = task, col = pos/neg/glm
for i=1:2
    subplot(1,2,i); cla; hold on;
    for j=1:numel(behTasks)
        plot(-inf,-inf,[Line_Color(j) 'x']);
    end
end
for i=1:numel(behTasks)
    
    lm3 = fitlm(behav_woo,pred_glm_woo,'Linear','VarNames',{'fracCorrect','ComboGlmPrediction'}); % least squares
    [P_this,F,d] = coefTest(lm3);
    if lm3.Coefficients.Estimate(2)>0
        P_this = P_this/2; % one-tailed test
    else
        P_this = 1-(1-P_this)/2; % one-tailed test
    end
    
    Rsq_this = lm3.Rsquared.Adjusted;
    fprintf('GLM: R^2 = %.3g, p = %.3g\n',Rsq_this,P_this);
    P(3) = P_this; Rsq(3) = Rsq_this;
    
    lm4 = fitlm(behav_mat_woo(:,i),pred_glm_mat_R_woo(:,i),'Linear','VarNames',{'fracCorrect','ComboGlmPrediction'}); % least squares
    [P_this,F,d] = coefTest(lm4);
    if lm4.Coefficients.Estimate(2)>0
        P_this = P_this/2; % one-tailed test
    else
        P_this = 1-(1-P_this)/2; % one-tailed test
    end
    
    Rsq_this = lm4.Rsquared.Adjusted;
    fprintf('GLM: R^2 = %.3g, p = %.3g\n',Rsq_this,P_this);
    P(4) = P_this; Rsq(4) = Rsq_this;
    
    if doPlot
        subplot(1,2,1);
        h3 = lm3.plot;
        set(h3,'color', Line_Color(i))
        title(sprintf('Matched: Combined Prediction of Accuracy\n w/o Outliers Subject 5 and Subject 14'));
        xlabel('Observed Behavior')
        ylabel(sprintf('Pos-Neg Mask Total'))
        legendCell{i,1} = sprintf('%s: R^2=%.3f, p=%.3g',Rsq(3),P(3));
        %text(65,0,['\nR^2=%.3f, p=%.3g',Rsq(3),P(3)])
        hold on

        subplot(1,2,2);
        h4 = lm4.plot;
        set(h4,'color', Line_Color(i))
        title(sprintf('Rest: Combined Prediction of Accuracy\n w/o Outliers Subject 5 and Subject 14'));
        xlabel('Observed Behavior')
        ylabel(sprintf('Pos-Neg Mask Total'))
        legendCell{i,2} = sprintf('%s: R^2=%.3f, p=%.3g',behTasks{i},Rsq(4),P(4));
        %text(65,0,['\nR^2=%.3f, p=%.3g',Rsq(3),P(3)])
        hold on
    end
end 

%Make legends
for i=1:2
    subplot(1,2,i);
    legend(legendCell{:,i});
    xlim([40 109])
end

%% Plot FC trained on task vs Behavior

clf;
Line_Color = 'krgb'
legendCell = cell(numel(fcTasks),2); % row = task, col = pos/neg/glm

subplot(1,2,1); cla; hold on;
for j=1:numel(behTasks)
        plot(-inf,-inf,[Line_Color(j+1) 'x']);
end

subplot(1,2,2); cla; hold on;
for j=1:numel(fcTasks)
        plot(-inf,-inf,[Line_Color(j) 'x']);
end

for i=1:numel(behTasks)
    lm3 = fitlm(behav_task(:,(i+1),i),pred_glm_task(:,(i+1),i),'Linear','VarNames',{'fracCorrect','ComboGlmPrediction'}); % least squares
    [P_this,F,d] = coefTest(lm3);
    if lm3.Coefficients.Estimate(2)>0
        P_this = P_this/2; % one-tailed test
    else
        P_this = 1-(1-P_this)/2; % one-tailed test
    end

    Rsq_this = lm3.Rsquared.Adjusted;
    fprintf('GLM Trained: R^2 = %.3g, p = %.3g\n',Rsq_this,P_this);
    P(3) = P_this; Rsq(3) = Rsq_this;
    
    if doPlot
        subplot(1,2,1);
        h3 = lm3.plot;
        set(h3,'color', Line_Color(i+1))
        title(sprintf('Task FC Prediction Accuracy of Respective Task Performance '));
        xlabel('Observed Behavior')
        ylabel(sprintf('Pos-Neg Mask Total'))
        legendCell{i,1} = sprintf('%s: R^2=%.3f, p=%.3g',behTasks{i},Rsq(3),P(3));
        hold on
    end    
end


for i=1:numel(fcTasks)
        
    lm4 = fitlm(behav_task(:,i,1),pred_glm_task(:,i,1),'Linear','VarNames',{'fracCorrect','ComboGlmPrediction'}); % least squares
    [P_this,F,d] = coefTest(lm4);
    if lm4.Coefficients.Estimate(2)>0
        P_this = P_this/2; % one-tailed test
    else
        P_this = 1-(1-P_this)/2; % one-tailed test
    end
    
    Rsq_this = lm4.Rsquared.Adjusted;
    fprintf('GLM: R^2 = %.3g, p = %.3g\n',Rsq_this,P_this);
    P(4) = P_this; Rsq(4) = Rsq_this;
    
    if doPlot
        subplot(1,2,2);
        h4 = lm4.plot;
        set(h4,'color', Line_Color(i))
        title(sprintf('Task FC Prediction Accuracy 2-Back Performance'));
        xlabel('Observed Behavior')
        ylabel(sprintf('Pos-Neg Mask Total'))
        legendCell{i,2} = sprintf('%s: R^2=%.3f, p=%.3g',fcTasks{i},Rsq(4),P(4));
        hold on
    end 
end

%Make legends

subplot(1,2,1);
legend(legendCell{1:3,1});
xlim([40 109])

subplot(1,2,2);
legend(legendCell{1:4,2});
xlim([40 109])


%%

    
for i=1:numel(behTasks)
    
    lm3 = fitlm(behav_task(:,(i+1),i),pred_glm_task(:,(i+1),i),'Linear','VarNames',{'fracCorrect','ComboGlmPrediction'}); % least squares
    [P_this,F,d] = coefTest(lm3);
    if lm3.Coefficients.Estimate(2)>0
        P_this = P_this/2; % one-tailed test
    else
        P_this = 1-(1-P_this)/2; % one-tailed test
    end
    
    Rsq_this = lm3.Rsquared.Adjusted;
    fprintf('GLM Trained: R^2 = %.3g, p = %.3g\n',Rsq_this,P_this);
    P(3) = P_this; Rsq(3) = Rsq_this;
    
    lm4 = fitlm(behav_task(:,i,1),pred_glm_task(:,i,1),'Linear','VarNames',{'fracCorrect','ComboGlmPrediction'}); % least squares
    [P_this,F,d] = coefTest(lm4);
    if lm4.Coefficients.Estimate(2)>0
        P_this = P_this/2; % one-tailed test
    else
        P_this = 1-(1-P_this)/2; % one-tailed test
    end
    
    Rsq_this = lm4.Rsquared.Adjusted;
    fprintf('GLM: R^2 = %.3g, p = %.3g\n',Rsq_this,P_this);
    P(4) = P_this; Rsq(4) = Rsq_this;
    
    if doPlot
        subplot(1,2,1);
        h3 = lm3.plot;
        set(h3,'color', Line_Color(i))
        title(sprintf('Rest Trained: Combined Prediction of Accuracy'));
        xlabel('Observed Behavior')
        ylabel(sprintf('Pos-Neg Mask Total'))
        legendCell{i,1} = sprintf('%s: R^2=%.3f, p=%.3g',behTasks{i},Rsq(3),P(3));
        %text(65,0,['\nR^2=%.3f, p=%.3g',Rsq(3),P(3)])
        hold on

        subplot(1,2,2);
        h4 = lm4.plot;
        set(h4,'color', Line_Color(i))
        title(sprintf('Rest: Combined Prediction of Accuracy'));
        xlabel('Observed Behavior')
        ylabel(sprintf('Pos-Neg Mask Total'))
        legendCell{i,2} = sprintf('%s: R^2=%.3f, p=%.3g',behTasks{i},Rsq(4),P(4));
        %text(65,0,['\nR^2=%.3f, p=%.3g',Rsq(3),P(3)])
        hold on
    end
end 

%%

