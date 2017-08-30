%% Plot FC trained on task vs Behavior

clf;
Line_Color = 'krgc'
AverageColor ='b'
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
    lm3 = fitlm(behav_task(:,1),test(:,5),'Linear','VarNames',{'fracCorrect','ComboGlmPrediction'}); % least squares
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
        title(sprintf('Average Task FC Prediction Accuracy of 2-Back Task Performance'));
        xlabel('Observed Behavior')
        ylabel(sprintf('Pos-Neg Mask Total'))
        legendCell{i,1} = (sprintf('%s: R^2=%.3f, p=%.3g','MEAN',Rsq(6),P(6)));
        hold on
    end    
end

lm6 = fitlm(behav_task(:,1),test(:,5),'Linear','VarNames',{'fracCorrect','ComboGlmPrediction'}); % least squares
[P_this,F,d] = coefTest(lm3);
if lm6.Coefficients.Estimate(2)>0
    P_this = P_this/2; % one-tailed test
else
    P_this = 1-(1-P_this)/2; % one-tailed test
end

Rsq_this = lm6.Rsquared.Adjusted;
fprintf('GLM: R^2 = %.3g, p = %.3g\n',Rsq_this,P_this);
P(6) = P_this; Rsq(6) = Rsq_this;

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
        h6 = lm6.plot;
        set(h6,'color', 'b')
        title(sprintf('Task FC Prediction Accuracy 2-Back Performance'));
        xlabel('Observed Behavior')
        ylabel(sprintf('Pos-Neg Mask Total'))
        legendCell{i,2} = sprintf('%s: R^2=%.3f, p=%.3g',fcTasks{i},Rsq(4),P(4));
        hold on
    end 
end

%h6 = lm6.plot;
%set(h6,'color', 'b')set(h6,'color', 'b')

%Make legends

subplot(1,2,1);
legend(sprintf('%s: R^2=%.3f, p=%.3g','MEAN',Rsq(6),P(6)));
xlim([40 109])

subplot(1,2,2);
legend(legendCell{1:4,2},(sprintf('%s: R^2=%.3f, p=%.3g','MEAN',Rsq(6),P(6))))%('MEAN: R^2=0.546, p=5.93e-05'));
xlim([40 109])
