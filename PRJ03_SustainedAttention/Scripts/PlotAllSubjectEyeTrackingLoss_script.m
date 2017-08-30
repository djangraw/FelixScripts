% PlotAllSubjectEyeTrackingLoss_script.m
%
% Created 5/18/16 by DJ. 

homedir = '/data/jangrawdc/PRJ03_SustainedAttention/Results';
subjects = 9:36;

%%
% Set up figure
figure(192);
% set(gcf,'Position',[3 -120 1916 1065]);

%% Make Eye Tracking Loss Barplot

[pctLost] = deal(nan(1,numel(subjects)));
subjectstr = cell(1,numel(subjects));
for i=1:numel(subjects)
    % enter results directory for this subject
    cd(sprintf('%s/SBJ%02d',homedir,subjects(i)));
    % Read in data file
    data_file = sprintf('Distraction-%d-QuickRun.mat',subjects(i));
    foo = load(data_file,'data');
    % Quantify % censored timepoints
    isLost = [];
    for j=1:numel(foo.data)
        isLost = cat(1,isLost,isnan(foo.data(j).events.samples.position(:,1)));
    end
    pctLost(i) = mean(isLost)*100;
    % Set up subject labels
    subjectstr{i} = sprintf('SBJ%02d',subjects(i));
end

%% Make plot
figure(193);
set(gcf,'Position',[38 686 1420 260]);
bar(pctLost)
set(gca,'xtick',1:numel(subjects),'xticklabel',subjectstr);
xlabel('subject')
% saveas(gcf,sprintf('%s/Figures/CensorBarplot_SBJ%02d-%02d.png',homedir,subjects(1),subjects(end)));
ylabel('% eye samples lost')
% ylim([0 30]); 
grid on