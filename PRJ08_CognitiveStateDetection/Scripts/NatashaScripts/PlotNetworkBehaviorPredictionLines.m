function PlotNetworkBehaviorPredictionLines(behav_mat,pred_pos_mat,pred_neg_mat,pred_glm_mat,behTasks)

% Written 6/22/17 by DJ.
doPlot = true;
%Line_Color = 'rgbkcmy';
Line_Color = 'krgb';
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
        title(sprintf('Positive Prediction of Accuracy'));
        xlabel('Observed Behavior')
        ylabel(sprintf('Pos Mask Total'))
        legendCell{i,1} = sprintf('%s: R^2=%.3f, p=%.3g',behTasks{i},Rsq(1),P(1));
%         legend(['\nR^2=%.3f, p=%.3g',Rsq(1),P(1)])
        hold on

        subplot(1,3,2);
        h2 = lm2.plot;
        set(h2,'color', Line_Color(i))
        title(sprintf('Negative Prediction of Accuracy'));
        xlabel('Observed Behavior')
        ylabel(sprintf('Neg Mask Total'))
        legendCell{i,2} = sprintf('%s: R^2=%.3f, p=%.3g',behTasks{i},Rsq(2),P(2));
        %text(65,0,['\nR^2=%.3f, p=%.3g',Rsq(2),P(2)])
        hold on

        subplot(1,3,3);
        h3 = lm3.plot;
        set(h3,'color', Line_Color(i))
        title(sprintf('Combined Prediction of Accuracy'));
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
