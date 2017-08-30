function [lm1,lm2,lm3] = PlotBehaviorPredictions(behav,pred_pos,pred_neg,pred_glm)

% [lm1,lm2,lm3] = PlotBehaviorPredictions(behav,pred_pos,pred_neg,pred_glm)
%
% Created 12/5/16 by DJ.

% Set up
P = nan(1,3);
Rsq = nan(1,3);

% Get fit for High-Attention Network Prediction
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

% Get fit for Low-Attention Network Prediction
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

% Get fit for Combined Network Prediction
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


% Plot predictions and fits
subplot(1,3,1);
lm1.plot;
title(sprintf('Positive Prediction of Accuracy:\nR^2=%.3f, p=%.3g',Rsq(1),P(1)));
xlabel('Observed Behavior')
ylabel(sprintf('High-Attention Network Score'))

subplot(1,3,2);
lm2.plot;
title(sprintf('Negative Prediction of Accuracy:\nR^2=%.3f, p=%.3g',Rsq(2),P(2)));
xlabel('Observed Behavior')
ylabel(sprintf('Low-Attention Network Score'))

subplot(1,3,3);
lm3.plot;
title(sprintf('Combined Prediction of Accuracy:\nR^2=%.3f, p=%.3g',Rsq(3),P(3)));
xlabel('Observed Behavior')
ylabel(sprintf('Combined Network Score'))


