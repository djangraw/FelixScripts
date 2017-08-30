%% GetCorrelationBetweenFcTemplateTimecourses.m
%
% Created 10/21/16 by DJ.


% subjects = 9:11;
% CompareRosenbergAndReadingCpCr;
atlasType = 'Shen';
fcTemplates = cat(3,attnNets.pos_overlap, attnNets.neg_overlap,readOverlap_pos,readOverlap_neg);
winLength = 10; % in TRs
TR = 2;
templateNames = {'Rosenberg Positive Network'; 'Rosenberg Negative Network';'Reading Positive Network'; 'Reading Negative Network'};
doPlot = true;

templateMatch = cell(1,numel(subjects));
for i=1:numel(subjects)
    templateMatch{i} = PlotFcTemplateTimecourse(subjects(i),atlasType,fcTemplates,winLength,templateNames,doPlot);
end
%%
figure(2); clf;
nTemplates = size(fcTemplates,3);
nPlots = numel(subjects)+1;
nRows = ceil(sqrt(nPlots));
nCols = ceil(nPlots/nRows);
for i=1:numel(subjects)
    subplot(nRows,nCols,i);
    isLeftCol = mod(i,nCols)==1;
    isBotRow = i>(nPlots-nCols);
    templateCorr(:,:,i) = corrcoef(templateMatch{i}','rows','complete');
    imagesc(templateCorr(:,:,i));
    colorbar
    set(gca,'clim',[-1 1], 'xtick',1:nTemplates,'ytick',1:nTemplates,'xticklabel',{},'yticklabel',{});
    if isLeftCol
        set(gca,'yticklabel',templateNames);
    end
    if isBotRow
        set(gca,'xticklabel',{'Ro+','Ro-','Re+','Re-'});  
%         xticklabel_rotate({},45);
    end
    colormap jet
    title(sprintf('SBJ%02d',subjects(i)));
    axis square
end
% Plot mean
subplot(nRows,nCols,numel(subjects)+1);
imagesc(nanmean(templateCorr,3));
colorbar
set(gca,'clim',[-1 1], 'xtick',1:nTemplates,'ytick',1:nTemplates,'xticklabel',{'Ro+','Ro-','Re+','Re-'},'yticklabel',{});        
% xticklabel_rotate([],45);
colormap jet
title(sprintf('Mean across %d subjects',numel(subjects)));
axis square
MakeFigureTitle(sprintf('%d sec FC window',winLength*TR));