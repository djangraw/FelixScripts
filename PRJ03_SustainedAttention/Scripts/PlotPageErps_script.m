% PlotPageErps_script.m
%
% Created 1/25/17 by DJ.

% Get timecoureses
iRoi = [212 188]; % lOcc and lTemp Pole (+)
% % iRoi = [212 201]; % lOcc and lVWFA (+)
% % iRoi = [104 11]; % rCer and rPFC
% iRoi = [117 184]; % rCer & lAngGyr (-)
figure(233); clf;
set(gcf,'Position',[3 915 2556 420]);
% Get/plot ROI timecourses
[~,order] = sort(fracCorrect,'descend');
iSubj = order(round(linspace(1,numel(order),6)));
% iSubj = [3 15];
[roi_ts, iTcEventSample_start] = deal(cell(1,numel(iSubj))); 
for i=1:numel(iSubj)
    subplot(numel(iSubj),1,i);
    [roi_ts{i}, iTcEventSample_start{i}] = PlotRoiTimecourseAndEvents(subjects(iSubj(i)),iRoi);
end
% subplot(211);
% [roi_ts_good, iTcEventSample_start_good] = PlotRoiTimecourseAndEvents(subjects(15),iRoi);
% subplot(212);
% [roi_ts_bad, iTcEventSample_start_bad] = PlotRoiTimecourseAndEvents(subjects(15),iRoi);

% Get ERPs
TR = 2;
tWin = [-6 14];
erp = cell(1,numel(iSubj));
for i=1:numel(iSubj)
    [erp{i},tErp] = GetErps(roi_ts{i},(1:size(roi_ts{i},1))*TR,iTcEventSample_start{i}*TR,tWin);
end

% [erp_good,tErp_good] = GetErps(roi_ts_good,(1:size(roi_ts_good,1))*TR,iTcEventSample_start_good*TR,tWin);
% [erp_bad,tErp_bad] = GetErps(roi_ts_bad,(1:size(roi_ts_bad,1))*TR,iTcEventSample_start_bad*TR,tWin);

%% Plot ERPs
figure(234); clf;
set(gcf,'Position',[3 105 1723 724]);
nCols = ceil(sqrt(numel(iSubj)));
nRows = ceil(numel(iSubj)/nCols);
for i=1:numel(iSubj)
    subplot(nRows,nCols,i);
    PlotErps(erp{i},tErp);
    title(sprintf('SBJ%02d (%.1f%% correct): r=%.3g',subjects(iSubj(i)),fracCorrect(iSubj(i))*100,FC(iRoi(1),iRoi(2),iSubj(i))));
    legend(sprintf('ROI %d',iRoi(1)),sprintf('ROI %d',iRoi(2)));
    PlotHorizontalLines(0,'k-');
    xlabel('time from page start (s)');
    ylabel('% signal change in ROI')
end    
linkaxes(GetSubplots(gcf),'xy');
for i=1:numel(iSubj)
    subplot(nRows,nCols,i);
    PlotVerticalLines(0,'k:');
end

% subplot(121);
% PlotErps(erp_good,tErp_good);
% title(sprintf('SBJ%02d (%.1f%% correct): r=%.3g',subjects(3),fracCorrect(3)*100,FC(iRoi(1),iRoi(2),3)));
% legend(sprintf('ROI %d',iRoi(1)),sprintf('ROI %d',iRoi(2)));
% PlotVerticalLines(0,'k:');
% PlotHorizontalLines(0,'k-');
% xlabel('time from page start (s)');
% ylabel('% signal change in ROI')
% subplot(122);
% PlotErps(erp_bad,tErp_bad);
% title(sprintf('SBJ%02d (%.1f%% correct): r=%.3g',subjects(15),fracCorrect(15)*100,FC(iRoi(1),iRoi(2),15)));
% legend(sprintf('ROI %d',iRoi(1)),sprintf('ROI %d',iRoi(2)));
% % PlotVerticalLines(0,'k:');
% xlabel('time from page start (s)');
% ylabel('% signal change in ROI')
% linkaxes(GetSubplots(gcf),'xy');
% PlotVerticalLines(0,'k:');
% PlotHorizontalLines(0,'k-');

%% Plot trajectories in Roi-Roi space
% figure(235); clf;
% subplot(121); hold on;
% for i=1:size(erp_good, 3)
%     plot(erp_good(:,1,i),erp_good(:,2,i));
% end
% xlabel(sprintf('%% signal change in ROI %d',iRoi(1)));
% ylabel(sprintf('%% signal change in ROI %d',iRoi(2)));
% title(sprintf('SBJ%02d (%.1f%% correct): r=%.3g',subjects(3),fracCorrect(3)*100,FC(iRoi(1),iRoi(2),3)));
% 
% subplot(122); hold on;
% for i=1:size(erp_good, 3)
%     plot(erp_bad(:,1,i),erp_bad(:,2,i));
% end
% xlabel(sprintf('%% signal change in ROI %d',iRoi(1)));
% ylabel(sprintf('%% signal change in ROI %d',iRoi(2)));
% title(sprintf('SBJ%02d (%.1f%% correct): r=%.3g',subjects(15),fracCorrect(15)*100,FC(iRoi(1),iRoi(2),15)));
% linkaxes(GetSubplots(gcf),'xy');
% for i=1:2
%     subplot(1,2,i);
%     PlotVerticalLines(0,'k--');
%     PlotHorizontalLines(0,'k--');
% end