function PlotReviewTableInfo(reviewTables)

% PlotReviewTableInfo(reviewTables)
%
% Created 9/20/16 by DJ.


%%
subjIds = reviewTables.subjectID;
nSubj = size(reviewTables,1);

motFields = {'numTRsabovemotlimit','averagemotionperTR','averagecensoredmotion','maxmotiondisplacement','maxcensoreddisplacement'};
censorFields = {'averageoutlierfracTR','numTRsaboveoutlimit','TRstotal','TRstotaluncensored','censorfraction'};
qaFields = {'degreesoffreedomused','degreesoffreedomleft','TSNRaverage','globalcorrelationGCOR','anatEPImaskcorrelation'};

figure(15);
for i=1:5
    subplot(5,1,i);
    bar(reviewTables.(motFields{i}));
    xlim([0 nSubj+1])
    ylabel(motFields{i});
    set(gca,'xtick',1:nSubj,'xticklabel',subjIds);
    xlabel('subject')
    xticklabel_rotate;
end
set(gcf,'Position',[0 30 573 1065]);

figure(16);
for i=1:5
    subplot(5,1,i);
    bar(reviewTables.(censorFields{i}));
    xlim([0 nSubj+1])
    ylabel(censorFields{i});
    set(gca,'xtick',1:nSubj,'xticklabel',subjIds);
    xlabel('subject')
    xticklabel_rotate;
end
set(gcf,'Position',[550 30 573 1065]);

figure(17);
for i=1:5
    subplot(5,1,i);
    bar(reviewTables.(qaFields{i}));
    xlim([0 nSubj+1])
    ylabel(qaFields{i});
    set(gca,'xtick',1:nSubj,'xticklabel',subjIds);
    xlabel('subject')
    xticklabel_rotate;
end
set(gcf,'Position',[1100 30 573 1065]);

figure(18);
imagesc(cat(1,reviewTables.blurestimates{:}));
set(gca,'ytick',1:nSubj,'yticklabel',subjIds);
colorbar;
xlabel('dimension')
title('blur estimates');
set(gcf,'Position',[1627 675 323 420]);
%%
figure(19);
foo = nan(nSubj,6);
for i=1:nSubj
    foo(i,1:length(reviewTables.fractioncensoredperrun{i})) = reviewTables.fractioncensoredperrun{i};
end

imagesc(foo);
set(gca,'ytick',1:nSubj,'yticklabel',subjIds,'clim',[-.1 0.4]);
colorbar;
xlabel('run')
title('fractioncensoredperrun');
set(gcf,'Position',[1627 170 292 420]);

