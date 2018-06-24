% TEMP_CompareModels_RandFoldDistributions
%
% Check the distribution (across random fold choices) of the MSE of various
% model fits run using RunRidgeTrace_script and loaded using
% CompareModels_script.
%
% Created 2/4/15 by DJ.

iL = 2; % lambda index
xHist = linspace(min(sigmasq_foldmean{1}(:)),max(sigmasq_foldmean{1}(:)),30);
nHist = zeros(numel(xHist),numel(models));
for iM = 1:numel(models) % model index
    nHist(:,iM) = hist(sigmasq_foldmean{2}(:,iL,iM),xHist);
end
cla;
plot(xHist,nHist);
legend(models)

%%
figure(17); clf;
for iM=1:numel(models)
    models_short{iM} = models{iM}(1:find(models{iM}=='-',1)-1);
end

for iExp = 1:3
    subplot(1,3,iExp);
    boxplot(squeeze(sigmasq_foldmean{iExp}(:,iL,:)),models_short);
    ylim([min(sigmasq_foldmean{3}(:)),max(sigmasq_foldmean{1}(:))])
    title([experiments{iExp} ' (v3pt6-rand)'])
    ylabel('MSE across 10 random folds')
    xlabel('Model')
end