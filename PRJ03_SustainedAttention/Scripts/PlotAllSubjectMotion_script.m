% PlotAllSubjectMotion_script.m
%
% Created 4/7/16 by DJ. 

homedir = '/data/jangrawdc/PRJ03_SustainedAttention/Results';
subjects = 36;
% Declare constants
TR = 2;
%%
% Set up figure
figure(192);
set(gcf,'Position',[3 -120 1916 1065]);

for i=1:numel(subjects)
    % enter results directory for this subject
    cd(sprintf('%s/SBJ%02d',homedir,subjects(i)));   
    % Load experimental timing data
    load(sprintf('Distraction-%d-QuickRun.mat',subjects(i)),'data'); % data, stats,question
    % Enter subdirectory
    foo = dir('AfniProc*');
    cd(foo(1).name);
    % get data
    motion_file = 'motion_demean.1D';
    deriv_file = 'motion_deriv.1D'; 
    censor_file = sprintf('censor_SBJ%02d_combined_2.1D',subjects(i));  
    % Get constants
    nRuns = numel(data);
    % Make plot
    PlotMotionData(motion_file,deriv_file,censor_file,TR,nRuns)
    % save plot
    saveas(gcf,sprintf('%s/Figures/Motion_SBJ%02d.png',homedir,subjects(i)));
end

%% Make Censor Barplot

[pctCensored,meanMotion,meanMotion_notCensored] = deal(nan(1,numel(subjects)));
subjectstr = cell(1,numel(subjects));
for i=1:numel(subjects)
    censor_file = sprintf('censor_SBJ%02d_combined_2.1D',subjects(i));
    % enter results directory for this subject
    cd(sprintf('%s/SBJ%02d',homedir,subjects(i)));
    % Enter subdirectory
    foo = dir('AfniProc*');
    cd(foo(1).name);
    % Read in censor file
    censor_file = sprintf('censor_SBJ%02d_combined_2.1D',subjects(i));
    isNotCensored = Read_1D(censor_file);
    % Quantify % censored timepoints
    pctCensored(i) = mean(~isNotCensored)*100;
    % Read in motion norm file
    motionnorm_file = sprintf('motion_SBJ%02d_enorm.1D',subjects(i));    
    motionnorm = Read_1D(motionnorm_file);
    % Quantify mean motion in all & non-censored timepoints
    meanMotion(i) = mean(motionnorm);
    meanMotion_notCensored(i) = mean(motionnorm(isNotCensored>0));
    subjectstr{i} = sprintf('SBJ%02d',subjects(i));
end

% Make censor plot
figure(193);
set(gcf,'Position',[38 686 1420 260]);
bar([pctCensored/100;meanMotion;meanMotion_notCensored]')
set(gca,'xtick',1:numel(subjects),'xticklabel',subjectstr);
xlabel('subject')
% saveas(gcf,sprintf('%s/Figures/CensorBarplot_SBJ%02d-%02d.png',homedir,subjects(1),subjects(end)));
ylabel('motion/censoring')
ylim([0 .3]); 
grid on
legend('frac TRs censored','mean motion','mean uncensored motion');