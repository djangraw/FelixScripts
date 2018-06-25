subject = 'SBJ01';
sessions = [1 1 2 2 3 3 5 5 6 6 7 7 8 9 9];
runs = [1 2 1 2 1 2 1 2 1 2 1 2 1 1 2];

masks = {'TestSphere_olap', 'TestSphere2_olap', 'SBJ01_FullBrain_EPIRes'};
colors = {'b','r','k'};
TC_roi = cell(1,numel(masks));
for i=1:numel(masks)
    subplot(numel(masks),1,i); cla; hold on;
    TC_roi{i} = [];
    for j=1:numel(sessions)
        filename = sprintf('%s_S%02d_R%02d_%s_top2svd_TC.1D',subject,sessions(j),runs(j),masks{i});
        TC_temp = str2num(fileread(filename))';                
        TC_roi{i}(j,:) = sum(TC_temp,1);
    end
    avg_Vroi = mean(TC_roi{i},1);
    ste_Vroi = std(TC_roi{i},[],1)/sqrt(size(TC_roi{i},1));
%     ErrorPatch(t,avg_Vroi,ste_Vroi,colors{i},colors{i});
    plot(t,TC_roi{i});
    plot(t,mean(TC_roi{i},1),'k','linewidth',2);
    PlotHorizontalLines(0,'k--');
    xlabel('time (s)');
    ylabel('timecourse of top 2 PCs (A.U.)')
    title(masks{i},'Interpreter','none');
end

%%
ROI_avg = mean(TC_roi{1},1);
FB_avg = mean(TC_roi{3},1);
figure(345); clf;
plot(t,ROI_avg-FB_avg);