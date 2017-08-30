function PlotDiceCoeffHists(dice)

% Created 2/22/16 by DJ.

% Set up
nParcs = size(dice,1);
xHist = 0.025:.05:1;
n = nan(numel(xHist),nParcs,nParcs);
n_pct = nan(numel(xHist),nParcs,nParcs);

% Get histogram of max dice coefficients for each ROI in parc1
% with any ROI in parc2
for i=1:nParcs
    for j=(i+1):nParcs
        n(:,i,j) = hist(max(dice{i,j}),xHist)';
        n_pct(:,i,j) = n(:,i,j)/sum(n(:,i,j))*100;
%         iPlot = (i-1)*nParcs + j;
%         subplot(size(dice,1),size(dice,2),iPlot);
%         plot(xHist,n/sum(n)*100);
        
        n(:,j,i) = hist(max(dice{i,j},[],2),xHist)';
        n_pct(:,j,i) = n(:,j,i)/sum(n(:,j,i))*100;
%         iPlot = (j-1)*nParcs + i;
%         subplot(nParcs,nParcs,iPlot);
%         plot(xHist,n/sum(n)*100);
    end
end

% Mean across parcellation pairs
n_mean = nanmean(nanmean(n_pct,2),3);
n_mean_pct = n_mean/sum(n_mean)*100;

cla; hold on;
bar(xHist,n_mean_pct);
xlabel(sprintf('Max Dice coefficient with any ROI\n(mean across parcellation pairs)'))
ylabel('% rois');