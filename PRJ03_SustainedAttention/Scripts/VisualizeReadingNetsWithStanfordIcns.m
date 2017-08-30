% VisualizeReadingNetsWithStanfordIcns.m
%
% Created 1/10/16 by DJ.

read_comboMask = all(read_posMask_all>0,3)-all(read_negMask_all>0,3);
% clim = [18 18 18];
clim = [18 13 7];

[shenLabels_hem,shenLabelNames_hem,shenColors_hem] = GetAttnNetLabels(true);
[shenLabels_icn,shenLabelNames_icn,shenColors_icn] = GetAttnNetLabels('icn');
invorder = reshape([11:20;1:10],20,1);
order = nan(size(invorder));
for i=1:numel(invorder), order(i) = find(invorder==i); end
shenLabels_hem = order(shenLabels_hem);
shenLabelNames_hem = shenLabelNames_hem(invorder);
shenColors_hem = shenColors_hem(invorder,:);


figure(279); clf;
set(gcf,'Position',[62 722 1731 613]);

subplot(131);
[~,~,~,~,hRect] = PlotFcMatrix(read_comboMask,[-1 1]*clim(1),shenAtlas,shenLabels_hem,true,shenColors_hem,'sum');
title('Reading Network by Region')
% delete(hRect);
set(gca,'xtick',1.5:2:20,'xticklabel',show_symbols(shenLabelNames));
set(gca,'ytick',1.5:2:20,'yticklabel',show_symbols(shenLabelNames));
xticklabel_rotate;

FC_tmp = nan(numel(shenLabelNames_hem),numel(shenLabelNames_icn));
for i=1:numel(shenLabelNames_hem)
    for j=1:numel(shenLabelNames_icn)
        FC_tmp(i,j) = sum(sum(read_comboMask(shenLabels_hem==i,shenLabels_icn==j)));%/sum(shenLabels_icn==j);
    end
end
subplot(132);
imagesc(FC_tmp);
set(gca,'clim',[-1 1]*clim(2))
title('Reading Network by Region/ICN')
colorbar
set(gca,'xtick',1:numel(shenLabelNames_icn),'xticklabel',show_symbols(shenLabelNames_icn));
set(gca,'ytick',1.5:2:20,'yticklabel',show_symbols(shenLabelNames));
xticklabel_rotate;

subplot(133);
[~,~,~,~,hRect] = PlotFcMatrix(read_comboMask,[-1 1]*clim(3),shenAtlas,shenLabels_icn,true,shenColors_icn,'sum');
title('Reading Network by ICN')
% delete(hRect);
set(gca,'xtick',1:numel(shenLabelNames_icn),'xticklabel',show_symbols(shenLabelNames_icn));
set(gca,'ytick',1:numel(shenLabelNames_icn),'yticklabel',show_symbols(shenLabelNames_icn));
xticklabel_rotate;

cmap = othercolor('BuOr_8',128);
colormap(cmap);