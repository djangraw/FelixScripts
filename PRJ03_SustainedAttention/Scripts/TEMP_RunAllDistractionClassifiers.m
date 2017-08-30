% TEMP_RunAllDistractionClassifiers
% Created 2/12/16 by DJ.

useLtoCv = false; %true; % else LOO

useEcho2 = false;
runPerms = false;%true;
fracTcVarToKeep = 1; %-1 means crop at elbow of S distribution
fracFcVarToKeep = 0.50;
getFwdModels = false;%true;
doPlots = false;

% calculate all
subjects = 9:16;
for i=1:numel(subjects)
    fprintf('===Subject %d/%d...\n',i,numel(subjects));
    subject = subjects(i);
    cd(sprintf('/data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ%02d',subject)); 
    if useLtoCv
        RunDistractionClassifier_LTO(subject,'whiteNoise','other',useEcho2,runPerms,fracTcVarToKeep,fracFcVarToKeep,getFwdModels,doPlots);
        RunDistractionClassifier_LTO(subject,'ignoredSpeech','attendedSpeech',useEcho2,runPerms,fracTcVarToKeep,fracFcVarToKeep,getFwdModels,doPlots);
    else
%         RunDistractionClassifier(subject,'whiteNoise','other',useEcho2,runPerms,fracTcVarToKeep,fracFcVarToKeep,getFwdModels,doPlots);
        RunDistractionClassifier(subject,'ignoredSpeech','attendedSpeech',useEcho2,runPerms,fracTcVarToKeep,fracFcVarToKeep,getFwdModels,doPlots);
    end
end

%% Load and average
dateString = datestr(now,'YYYY-mm-DD');
% dateString = '2016-03-01';
subjects = 9:16;
Az_stim = nan(numel(subjects),2);
Az_cond = nan(numel(subjects),2);
Az_stim_other = nan(numel(subjects),3);
Az_cond_other = nan(numel(subjects),3);
for i = 1:numel(subjects)
    subject = subjects(i);
%     if subject<15
%         dateString = '2016-02-25';
%     else
%         dateString = datestr(now,'YYYY-mm-DD');
%     end
    % enter folder
    cd(sprintf('/data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ%02d',subject)); 
    % get AZ values
    foo = load(sprintf('SBJ%02d_MultimodalClassifier_whiteNoise-other_%s',subject,dateString));
    Az_stim(i,:) = foo.Az_true(1:2);
    Az_stim_other(i,:) = foo.Az_true(3:5);
%     Az_stim(i,:) = foo.Az_LTO(1:2);
%     Az_stim_other(i,:) = foo.Az_LTO(3:5);
    foo = load(sprintf('SBJ%02d_MultimodalClassifier_ignoredSpeech-attendedSpeech_%s',subject,dateString));    
    Az_cond(i,:) = foo.Az_true(1:2);
    Az_cond_other(i,:) = foo.Az_true(3:5);
%     Az_cond(i,:) = foo.Az_LTO(1:2);
%     Az_cond_other(i,:) = foo.Az_LTO(3:5);
end

xTickStr = cell(1,numel(subjects)+1);
for i=1:numel(subjects)
    xTickStr{i} = sprintf('SBJ%02d',subjects(i));
end
xTickStr{end} = 'Mean';

figure;
set(gcf,'Position',[3 629 1029 466]);
subplot(2,1,1); 
cla; hold on;
bar([Az_stim; mean(Az_stim,1)]);
xlabel('subject')
ylabel('AUC')
ylim([0 1])
set(gca,'xtick',1:numel(subjects)+1,'xticklabel',xTickStr)
PlotHorizontalLines(0.5,'k:');
errorbar(numel(subjects)+[0.85 1.15],mean(Az_stim,1),std(Az_stim,[],1)/sqrt(numel(subjects)),'k.')
legend('Mag','FC')
title('Stimulus (white noise > speech)')
subplot(2,1,2);
cla; hold on;
bar([Az_cond; mean(Az_cond,1)]);
xlabel('subject')
ylabel('AUC')
ylim([0 1])
set(gca,'xtick',1:numel(subjects)+1,'xticklabel',xTickStr)
PlotHorizontalLines(0.5,'k:');
errorbar(numel(subjects)+[0.85 1.15],mean(Az_cond,1),std(Az_cond,[],1)/sqrt(numel(subjects)),'k.')
legend('Mag','FC')
title('Speech condition (ignored > attended)')


%% alternative classifiers
figure(46);
subplot(2,1,1); 
cla; hold on;
bar([Az_stim_other; mean(Az_stim_other,1)]);
xlabel('subject')
ylabel('AUC')
ylim([0 1])
set(gca,'xtick',1:numel(subjects)+1,'xticklabel',xTickStr)
PlotHorizontalLines(0.5,'k:');
legend('Eye','fMRI','All')
title('Stimulus (white noise > speech)')
subplot(2,1,2);
cla; hold on;
bar([Az_cond_other; mean(Az_cond_other,1)]);
xlabel('subject')
ylabel('AUC')
ylim([0 1])
set(gca,'xtick',1:numel(subjects)+1,'xticklabel',xTickStr)
PlotHorizontalLines(0.5,'k:');
legend('Eye','fMRI','All')
title('Speech condition (ignored > attended)')