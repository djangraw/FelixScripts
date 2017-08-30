%Calculate Match Strength

subjNum = [06:13,16:27];
nWindows = 1;
nSubj = numel(subjNum);
matchStrength_mat = nan(nSubj,nWindows);
matchStrength_neg_mat = nan(nSubj,nWindows);

for iSubject = 1:nSubj
    [matchStrength, matchStrength_neg] = GetRosenbergScoreForCogStateData_AllTasks(subjNum(iSubject));
    matchStrength_mat(iSubject,:) = matchStrength;
    matchStrength_neg_mat(iSubject,:) = matchStrength_neg;
end


%%
%Load Behavioral Data

behavior_avg_RT = nan(nSubj,nWindows);
behavior_avg_PC = nan(nSubj,nWindows);

cd /data/jangrawdc/PRJ08_CognitiveStateDetection/PrcsData/Behavior

for i=1:numel(subjNum)
    filename = sprintf('SBJ%02d_Behavior.mat',i);
    foo = load(filename);
    avg_RT = nanmean(foo.averageRT);
    avg_PC = nanmean(foo.percentCorrect);
    behavior_avg_RT(i,:) = avg_RT;
    behavior_avg_PC(i,:) = avg_PC;
end
%%
for i=1:numel(subjNum)
    behavior_avg_total(i,:) = behavior_avg_PC(i)/behavior_avg_RT(i);
end

%%
R_mat = nan(1,nWindows);
P_mat = nan(1,nWindows);
for i = 1:nWindows
    [RHO, PVAL] = corr(matchStrength_neg_mat(:,i),behavior_avg_PC(:,i));
    R_mat(i) = RHO;
    P_mat(i) = PVAL;
end

%%
R_mat_avg = nan(1,nWindows);
P_mat_avg = nan(1,nWindows);
for i = 1:nWindows
    [RHO_a, PVAL_a] = corr(matchStrength_mat(:,i),behavior_avg_total(:,i));
    R_mat_avg(i) = RHO_a;
    P_mat_avg(i) = PVAL_a;
end

