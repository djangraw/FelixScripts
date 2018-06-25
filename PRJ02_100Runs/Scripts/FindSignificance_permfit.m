function [pVal, permFit] = FindSignificance_permfit(data,permData,fitType)

% Find which data values are significantly outside the distribution of
% permutation data.
% [pVal, permFit] = FindSignificance_permfit(data,permData,fitType)
%
% Created 1/10/15 by DJ.

if ~exist('fitType','var')
    fitType = 'Normal';
end
% get fit
permFit = fitdist(permData(:),fitType);
% evaluate goodness of fit

% get significance of data
pVal = normcdf(data,permFit.mu,permFit.sigma);

% plot histogram
xhist = linspace(min(data(:)),max(data(:)),100);
pct_data = hist(data(:),xhist) / numel(data)*100;
pct_perm = hist(permData(:),xhist) / numel(permData)*100;
n_fit = pdf(permFit,xhist);
pct_fit = n_fit/sum(n_fit)*100;

plot(xhist,[pct_data; pct_perm; pct_fit]');
xlabel('mean correlation coefficient')
ylabel('% voxels')
legend('data','permutation test',sprintf('Fit to %s',fitType));