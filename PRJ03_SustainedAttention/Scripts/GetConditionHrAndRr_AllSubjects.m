function GetConditionHrAndRr_AllSubjects(subjects,doPlot)
%
% Created 7/15/16 by DJ. 

nSubj=numel(subjects);
% Get physio data, averaged by condition
nCats = 3;
[HR_cat,RR_cat] = deal(nan(nSubj,nCats));
eventTypes = cell(nSubj,nCats);
for i=1:nSubj
    if doPlot
        figure(200+i);
        set(gcf,'Position',[3   820   394   275]);
    end
    [HR_cat(i,:),RR_cat(i,:),eventTypes(i,:)] = GetConditionHrAndRr(subjects(i),doPlot);
end
eventCategories = eventTypes(1,:);
if doPlot
    CascadeFigures(200+(1:nSubj),5);
end
%% Get average for each event type
disp('Getting Means and Statistics...')
HR_cat_median = median(HR_cat);
RR_cat_median = median(RR_cat);
HR_cat_ste = std(HR_cat)/sqrt(nSubj);
RR_cat_ste = std(RR_cat)/sqrt(nSubj);
% Check for stat differences between categories
[pHR,~,statsHR] = kruskalwallis(HR_cat,eventCategories(1,:),'off');
[pRR,~,statsRR] = kruskalwallis(RR_cat,eventCategories(1,:),'off');
mcHR = multcompare(statsHR,'display','off');
mcRR = multcompare(statsRR,'display','off');

% Plot results
if doPlot
    disp('Plotting...')
    figure(300); clf;
    subplot(2,1,1); cla; hold on;
    bar(HR_cat_median);
    errorbar(HR_cat_median,HR_cat_ste,'k.');      
    % add stars
    if pHR<0.05
        for i=1:size(mcHR,1)
            if mcHR(i,end)<0.05
                plot(mcHR(i,1:2),[1 1]*max(HR_cat_median+HR_cat_ste)+i, 'k.-');
                plot(mean(mcHR(i,1:2)),max(HR_cat_median+HR_cat_ste)+i+.5, 'k*');
            end
        end
    end
    set(gca,'xtick',1:nCats,'xticklabel',eventCategories);
    ylim([min(HR_cat_median-HR_cat_ste)-size(mcHR,1)-1, max(HR_cat_median+HR_cat_ste)+size(mcHR,1)+1])
    xlabel('event type')
    ylabel('HR (bpm)')
    title(sprintf('Heart rate for %d subjects',numel(subjects))); 

    subplot(2,1,2); cla; hold on;
    bar(RR_cat_median);
    errorbar(RR_cat_median,RR_cat_ste,'k.');
    if pRR<0.05
        for i=1:size(mcRR,1)
            if mcRR(i,end)<0.05
                plot(mcRR(i,1:2),[1 1]*max(RR_cat_median+RR_cat_ste)+i, 'k.-');
                plot(mean(mcRR(i,1:2)),max(RR_cat_median+RR_cat_ste)+i+.5, 'k*');
            end
        end
    end
    set(gca,'xtick',1:nCats,'xticklabel',eventCategories);
    ylim([min(RR_cat_median-RR_cat_ste)-size(mcRR,1)-1, max(RR_cat_median+RR_cat_ste)+size(mcRR,1)+1])
    xlabel('event type')
    ylabel('RR (bpm)')
    title(sprintf('Respiration rate for %d subjects',numel(subjects))); 
end
disp('Done!');
