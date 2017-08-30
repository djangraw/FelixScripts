function PlotTsnrHistograms(subj,runs,runPrefix)

% Created 3/28/17 by DJ.
% Updated 3/29/17 by DJ - switched from individual echoes to cross-echoes

if ~exist('runPrefix','var')
    runPrefix = 'run'; % 'OCrun'
end

% Set up
homedir = '/data/jangrawdc/PRJ11_Music';
nRuns = numel(runs);
nRows = ceil(sqrt(nRuns+1));
nCols = ceil((nRuns+1)/nRows);
xHist = linspace(0,2000,100);
pct = nan(numel(xHist),nRuns);
meanTsnr = nan(1,nRuns);

for i=1:nRuns
    % Load
    mask = BrikLoad(sprintf('%s/Results/SBJ%02d/%s%03d/full_mask.SBJ%02d+orig',homedir,subj,runPrefix,runs(i),subj));
    filename = sprintf('%s/Results/SBJ%02d/%s%03d/TSNR.SBJ%02d+orig.HEAD',homedir,subj,runPrefix,runs(i),subj);
    if ~exist(filename,'file')
        filename = sprintf('%s/Results/SBJ%02d/%s%03d/TSNR.SBJ%02d.e1+orig.HEAD',homedir,subj,runPrefix,runs(i),subj);
    end        
    V = BrikLoad(filename);
    
    % Calculate
    V_inmask = V(mask>0);
    n = hist(V_inmask,xHist);
    pct(:,i) = n/nansum(n)*100;
    meanTsnr(i) = mean(V_inmask);

    % Plot
    subplot(nRows,nCols,i);
    plot(xHist,pct(:,i));
    xlabel('TSNR')
    ylabel('% voxels')
    title(sprintf('Run %d',runs(i)));
end

% Plot averages
subplot(nRows,nCols,nRuns+1);
bar(meanTsnr);
runStr = cell(1,nRuns);
for i=1:nRuns
    runStr{i} = sprintf('Run %d',runs(i));
end
set(gca,'xtick',1:nRuns,'xticklabel',runStr);
ylabel('Mean TSNR');