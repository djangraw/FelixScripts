function [bandCorr, corrName] = PlotBandCorrelations(resultsFilename)

% [bandCorr, corrName] = PlotBandCorrelations(resultsFilename)
%
% INPUTS:
% -resultsFilename is a file saved with FindFigilance_script.
% 
% OUTPUTS:
% -bandCorr is an nchoosek(nBands,2) x nSubjects x nTasks matrix in swhich
% bandCorr(:,i,j) is the correlation between a pair of bands for subject i
% and task j. 
% -corrName is an nchoosek(nBands,2)-element cell array of strings in which
% corrName{k} indicates the bands being correlated to calculate
% bandCorr(k,:,:). 
%
% Created 5/12/15 by DJ.
% Updated 5/15/15 by DJ - added outputs.

%% Set up
% resultsFilename = 'VigilanceResults_2015-01-14_1859.mat';
res = load(resultsFilename);

nTasks = numel(res.tasks);
nBands = numel(res.bandNames);
nSubjects = numel(res.subjects);

%% Get correlations between band power timecourses
% get band correlations
fprintf('Gettting correlations...\n');
bandCorr = nan(nchoosek(nBands,2),nSubjects,nTasks);
iCorr = 0;
for iBand1 = 1:nBands
    for iBand2 = iBand1+1:nBands            
        iCorr = iCorr+1; % increment index
        for iTask = 1:nTasks
            for iSubj = 1:nSubjects
                % simple correlation coefficient
                bandCorr(iCorr,iSubj,iTask) = corr( res.avgPower_common_rampaligned{iBand1}(:,iTask,iSubj), res.avgPower_common_rampaligned{iBand2}(:,iTask,iSubj));                
            end            
        end
    end
end
% get title for each comparison
corrName = cell(nchoosek(nBands,2),1);
iCorr=0;
for iBand1 = 1:nBands
    for iBand2 = iBand1+1:nBands            
        iCorr = iCorr+1;
        corrName{iCorr} = sprintf('%s vs. %s',res.bandNames{iBand1},res.bandNames{iBand2});
    end
end

%% Plot
fprintf('Plotting results...\n');
figure;
for iTask = 1:nTasks
    % plot
    subplot(1,nTasks,iTask);
    hold on;
    boxplot(bandCorr(:,:,iTask)','labels',corrName);
    % annotate
    PlotHorizontalLines(0,'k:');
    title(sprintf('%s task', res.tasks{iTask}));
    xlabel('bands being correlated')
    ylabel('correlation coefficient')
    ylim([-0.5 0.5])   
end
MakeFigureTitle(sprintf('Distribution across %d subjects',nSubjects));

fprintf('Done!\n');
