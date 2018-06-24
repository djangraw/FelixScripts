function PlotJlrAcrossOffsets(JLR,JLP,iWin,topo_option,post_option)

% Plots the Az values, forward models, and posteriors for jittered logistic
% regression results.
%
% PlotJlrAcrossOffsets(JLR,JLP,iWin,topo_option,post_option)
%
% INPUTS:
% - JLR and JLP are the outputs of LoadJlrResults.
%
% Created 9/28/12 by DJ.
% Updated 11/23/12 by DJ - added iWin, topo, and post options

if nargin<3
    iWin = []; % pick windows automatically
end
if nargin<4
    topo_option = 'vout'; % 'fwdmodels';
end
if nargin<5
    post_option = 'post';
end

JLRavg = AverageJlrResults(JLR,JLP);
[jitter,~, RT] = GetJitter(JLP.ALLEEG,'facecar');
if ~isempty(strfind(JLP.ALLEEG(1).setname,'_F_'));
    faces = find(JLRavg.truth==0);
    cars = find(JLRavg.truth==1);
else
    cars = find(JLRavg.truth==0);
    faces = find(JLRavg.truth==1);
end

% Plot JLR Posteriors at multiple window offsets
clf;
if isempty(iWin) % pick automatically
    iWin = 1:4:numel(JLR.Azloo); % windows to highlight
end
nWin = numel(iWin);
tAz = JLP.ALLEEG(1).times(round(JLR.trainingwindowoffset+JLP.scope_settings.trainingwindowlength/2));
% avgFwdModel = mean(cat(3,JLR.fwdmodels{:}),3);

subplot(4,1,1); cla; hold on;
plot(tAz,JLR.Azloo,'b.-');
plot(tAz(iWin),JLR.Azloo(iWin),'bo');
set(gca,'ylim',[0.3 1]);
plot([-mean(RT) -mean(RT)],get(gca,'ylim'),'r--')
plot(get(gca,'xlim'),[0.5 0.5],'k--');
plot(get(gca,'xlim'),[0.75 0.75],'k:');
xlabel('time of window center (ms)');
ylabel('10-fold Az');
legend('Az','highlighted times','Mean RT')
title(show_symbols(sprintf('%s vs. %s, jittered LR',JLP.ALLEEG(1).setname, JLP.ALLEEG(2).setname)))

for i=1:nWin
    subplot(4,nWin,nWin+i)
    topoplot(JLRavg.(topo_option)(1:JLP.ALLEEG(1).nbchan,iWin(i)),JLP.ALLEEG(1).chanlocs);
%     set(gca,'CLim',[-2 2]);
    colorbar
    title(sprintf('%s, offset=%.2g\nWindowCtr = %0.1f ms', topo_option, JLRavg.vout(end,iWin(i)), tAz(iWin(i))));
end
for i=1:nWin
    subplot(2,nWin,nWin+i)
    ImageSortedData(JLRavg.(post_option)(faces,:,iWin(i)),JLRavg.postTimes,faces,jitter(faces));
    ImageSortedData(JLRavg.(post_option)(cars,:,iWin(i)),JLRavg.postTimes,cars,jitter(cars));
    set(gca,'clim',[0 0.01]);% 0.005])
    ylim([0.5,size(JLRavg.post,1)+0.5])
    if length(JLRavg.postTimes)>1
        xlim([JLRavg.postTimes(1) JLRavg.postTimes(end)])
    end
    switch post_option
        case {'post_avg' 'post'}
            title(sprintf('Posteriors given no label: \np(t_i|y_i)\nOffset = %.1fms',tAz(iWin(i))));   
        case 'post_truth'
            title(sprintf('Posteriors given true label: \np(t_i|y_i,c_i)\nOffset = %.1fms',tAz(iWin(i))));   
        case 'post_pred'
            title(sprintf('Posteriors given predicted label: \np(t_i|y_i,c''_i)\nOffset = %.1fms',tAz(iWin(i))));   
    end
    xlabel('time from window center (ms)')    
end
colorbar('EastOutside');
subplot(2,nWin,nWin+1)
if ~isempty(strfind(JLP.ALLEEG(1).setname,'_F_'));
    ylabel('<-- faces     |     cars -->')
else
    ylabel('<-- cars     |     faces -->')
end