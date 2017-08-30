function PlotErps(erp,tErp)

% Created 1/25/17 by DJ.

% Set up
[nT,nRois,nEvents] = size(erp);
meanErp = nanmean(erp,3);
steErp = nanstd(erp,[],3)/sqrt(nEvents);
colors = distinguishable_colors(nRois);

% Plot mean lines
cla; hold on;
for i=1:nRois
    plot(tErp(:),meanErp(:,i),'color',colors(i,:),'linewidth',2);
end
% Plot error bars (in separate loop for legend purposes)
for i=1:nRois
    plot(tErp(:),[meanErp(:,i)-steErp(:,i), meanErp(:,i)+steErp(:,i)],'--','color',colors(i,:));
%     [hPatch(i),hLine(i)] = ErrorPatch(tErp(:),meanErp(:,i),steErp(:,i),colors(i,:),colors(i,:));
end
% Annotate plot
xlabel('time (s)')
ylabel('mean timecourse in ROI');
