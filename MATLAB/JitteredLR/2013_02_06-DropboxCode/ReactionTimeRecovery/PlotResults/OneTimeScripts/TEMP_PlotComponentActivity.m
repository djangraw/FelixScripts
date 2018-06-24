% Get activity of component across all trials
% Created 9/19/12 by DJ for one-time use.

X = cat(3,ALLEEG(1).data, ALLEEG(2).data);
t = ALLEEG(1).times;

for i=1:size(X,3);
    Y(i,:) = v(1:end-1)*X(:,:,i)+v(end);
end

figure(55); clf;
% ImageSortedData(Y(faces,:),t,faces,-jitter(faces) + mean([RT1 RT2]) + 25);
% ImageSortedData(Y(cars,:),t,cars,-jitter(cars) + mean([RT1 RT2]) + 25);
imagesc(t,1:size(Y,1),Y);
plot([t(1) t(end)],[max(faces)+1 max(faces)+1],'k:')
PlotVerticalLines([200 250],'k--')
% set(gca,'clim',[-20 20])
set(gca,'clim',[-1.5 1.5])
set(gca,'xlim',[t(1) t(end)])
xlabel('time from stim onset (ms)')
ylabel('<-- faces   |   cars -->')
title(sprintf('discriminating component activity\nstimulus-locked, window offset t=200'))
colorbar

yInWin = mean(Y(:,(t>=200 & t<=250)),2);
figure(56);
% xhist = -8:.5:8;
xhist = -1:.05:1;
yC = hist(yInWin(cars),xhist);
yF = hist(yInWin(faces),xhist);
plot(xhist,[yF;yC])
title('y value in stim-locked window')
xlabel('mean y value in window')
ylabel('# trials')
legend('faces','cars')