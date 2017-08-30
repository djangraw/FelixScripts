%Run GetRosenburgScoreForCogStateData Script

subjNum = [06:13,16:27];
nWindows = 8;
nSubj = numel(subjNum);
winInfo_cell = cell(nSubj,1);
matchStrength_neg_mat = nan(nSubj,nWindows);

for iSubject = 1:nSubj
    [matchStrength_negT,winInfo] = GetRosenbergScoreForCogStateData(subjNum(iSubject));
    winInfo_cell{iSubject} = winInfo;
    matchStrength_negT_mat(iSubject,:) = matchStrength_negT;
end

winInfo_mat = cat(1,winInfo_cell{:});

%%
%Load behavior matrices 
behavior_avg_RT = nan(nSubj,nWindows);
behavior_avg_PC = nan(nSubj,nWindows);

cd /data/jangrawdc/PRJ08_CognitiveStateDetection/PrcsData/Behavior
for i=1:numel(subjNum)
    filename = sprintf('SBJ%02d_Behavior.mat',i);
    foo = load(filename);
    behavior_avg_RT(i,:) = foo.averageRT;
    behavior_avg_PC(i,:) = foo.percentCorrect;
end
%%
%Percent Correct/Reaction Time for simple score that looks at both
%for i=1:numel(subjNum)
  %  for j=1:8
  %  behavior_avg_total(i,j) = behavior_avg_PC(i,j)/behavior_avg_RT(i,j);
 %   end
%end

%%
%Make Matrices for correlation between match strength and percent correct
R_mat = nan(1,nWindows);
P_mat = nan(1,nWindows);
for i = 1:nWindows
    [RHO, PVAL] = corr(matchStrength_negT_mat(:,i),behavior_avg_RT(:,i));
    R_mat(i) = RHO;
    P_mat(i) = PVAL;
end


%%
%Matrices for match strength and other division measure
%R_mat = nan(1,nWindows);
%P_mat = nan(1,nWindows);
%for i = 1:nWindows
%    [RHO, PVAL] = corr(matchStrength_mat(:,i),behavior_avg_total(:,i));
%    R_mat(i) = RHO;
%    P_mat(i) = PVAL;
%end

%%
%Average MatchStrength and Average Performance

matchStrength_avg = mean(matchStrength_negT_mat')

%Average PC and RT
PC_avg = nanmean(behavior_avg_PC');
RT_avg = nanmean(behavior_avg_RT');
%%
%Correlate behavior and match strength



    [RHO, PVAL] = corr(matchStrength_avg(:),PC_avg(:));

%%
%Graph averages

figure
plot(matchStrength_avg,PC_avg, '.')
p = polyfit(matchStrength_avg,PC_avg,1);
f = polyval(p,matchStrength_avg);
hold on
plot(matchStrength_avg,f,'-r')
text(275,65,['R^2=' num2str(RHO)])
xlabel('Match Strength')
ylabel('Percent Correct')
title('Average Match Strength and Percent Correct Across Trials')

%%
%Graph avg behavior and avg match strength
for i = [Memory_1 Video_1 Math_1 Memory_2 Math_2 Video_2];
    fig = figure(i); clf;
    plot(matchStrength_mat(,behavior_avg_PC,'.');
    xlabel('Match Strength')
    ylabel('Percent Correct')
    title(sprintf('Window %d (%s): Match Strength and Percent Correct (Big Mask)',i,blockNames{i}))
    axis([0,600,0,100])
    p = polyfit(matchStrength_mat(:,i),behavior_avg_PC(:,i),1);
    f = polyval(p,matchStrength_mat(:,i));
    hold on
    plot(matchStrength_mat(:,i),f,'-r')
    text(350,10,['R^2=' num2str(R_mat(i))])
    hold on
    saveas(fig, sprintf(['Reg_Window_' num2str(i) '_PC.jpg']), 'jpg')
end

%%
%Make Figures for Reaction Time and Match Strength

Memory_1 = 2;
Video_1 = 3;
Math_1 = 4;
Memory_2 = 5;
Math_2 = 7;
Video_2 = 8;
blockNames = {'Rest1','Memory1','Video1','Math1','Memory2','Rest2','Math2','Video2'};

for i = [Memory_1 Video_1 Math_1 Memory_2 Math_2 Video_2];
    fig = figure(i); clf;
    plot(matchStrength_mat(:,i),behavior_avg_RT(:,i),'.');
    xlabel('Match Strength')
    ylabel('Average Reaction Time (s)')
    title(sprintf('Window %d (%s): Match Strength and Average Reaction Time (Big Mask)',i,blockNames{i}))
    axis([0,600,0,4.5])
    p = polyfit(matchStrength_mat(:,i),behavior_avg_RT(:,i),1);
    f = polyval(p,matchStrength_mat(:,i));
    hold on
    plot(matchStrength_mat(:,i),f,'-r')
    text(350,3.5,['R^2=' num2str(R_mat(i))])
    hold on
    pause(0.5);
    saveas(fig, sprintf(['BigMask_Window' num2str(i) '_RT.jpg']), 'jpg')
end
%%
%Make Figures one by one for each MatchStrength and Percent Correct
% i = task (window number)
Memory_1 = 2;
Video_1 = 3;
Math_1 = 4;
Memory_2 = 5;
Math_2 = 7;
Video_2 = 8;

for i = [Memory_1 Video_1 Math_1 Memory_2 Math_2 Video_2];
    fig = figure(i); clf;
    plot(matchStrength_mat(:,i),behavior_avg_PC(:,i),'.');
    xlabel('Match Strength')
    ylabel('Percent Correct')
    title(sprintf('Window %d (%s): Match Strength and Percent Correct (Big Mask)',i,blockNames{i}))
    axis([0,600,0,100])
    p = polyfit(matchStrength_mat(:,i),behavior_avg_PC(:,i),1);
    f = polyval(p,matchStrength_mat(:,i));
    hold on
    plot(matchStrength_mat(:,i),f,'-r')
    text(350,10,['R^2=' num2str(R_mat(i))])
    hold on
    saveas(fig, sprintf(['Reg_Window_' num2str(i) '_PC.jpg']), 'jpg')
end
