function PlotGhosting(subj,runs)

% Created 3/30/17 by DJ.

% Set up
homedir = '/data/jangrawdc/PRJ11_Music';
nRuns = numel(runs);
nRows = ceil(sqrt(nRuns+1));
nCols = ceil((nRuns+1)/nRows);
xHist = linspace(0,2000,100);
rois = [];
nRois = size(rois,1);
isInMask = nan(nRois,1);
mask = BrikLoad(sprintf('%s/Results/SBJ%02d/OCrun%03d/full_mask.SBJ%02d+orig',homedir,subj,runs(1),subj));    
roiMask = repmat({zeros(size(mask))},1,nRois);
for i=1:nRois
    isInMask(i) = mask(rois(i,1),rois(i,2),rois(i,3))>0;
    isInRoi = [];
    roiMask{i}(isInRoi) = 1;
end  
pct = nan(numel(xHist),nRuns);
meanGhosting = nan(1,nRuns);
for i=1:nRuns
    % Load
    filename = sprintf('%s/Results/SBJ%02d/OCrun%03d/TSNR.SBJ%02d+orig.HEAD',homedir,subj,runs(i),subj);
    if ~exist(filename,'file')
        filename = sprintf('%s/Results/SBJ%02d/OCrun%03d/TSNR.SBJ%02d.e1+orig.HEAD',homedir,subj,runs(i),subj);
    end        
    V = BrikLoad(filename);
    % Calculate
    for j=1:nRois
    V_inmask = V(roimask{j})>0);
    pct(:,i) = n/nansum(n)*100;
    meanGhosting(i) = mean(V_inmask);
    % Plot
    subplot(nRows,nCols,i);
    plot(xHist,pct(:,i));
    xlabel('TSNR')
    ylabel('% voxels')
    title(sprintf('Run %d',runs(i)));
end

% Plot averages
subplot(nRows,nCols,nRuns+1);
bar(meanGhosting);
runStr = cell(1,nRuns);
for i=1:nRuns
    runStr{i} = sprintf('Run %d',runs(i));
end
set(gca,'xtick',1:nRuns,'xticklabel',runStr);
ylabel('Mean TSNR');

