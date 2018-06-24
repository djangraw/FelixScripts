function PlotJlrAcrossOffsets_Compare(LRstim,LPstim,LRresp,LPresp,JLR,JLP,iWin,topo_option,post_option)

% Plots the Az values, forward models, and posteriors for jittered logistic
% regression results.
%
% PlotJlrAcrossOffsets_Compare(LRstim,LPstim,LRresp,LPresp,JLR,JLP,iWin,topo_option,post_option)
%
% INPUTS:
% - LRstim and LPstim are the outputs of LoadJlrResults, the results and 
% parameters of a stimulus-locked, no-jitter analysis.
% - LRresp and LPresp are the results for response-locked, no-jitter
% analysis.
% - JLR and JLP are the results for response-locked, jittered analysis.
% - iWin is a vector of the window indices you want to see scalp maps and
% posteriors for.  Default is 1:4:end.
% - topo_option is a string indicating whether you'd like to plot scalp
% maps of the weights ('vout', default) or forward models ('fwdmodels').
% - post_option is a string indicating whether you'd like to plot
% posteriors given the true category ('post_truth'), predicted category
% ('post_pred'), or weighted average of both ('post_avg', default).  See
% AverageJlrResults.m for details.
%
% Created 10/2/12 by DJ.
% Updated 10/12 by DJ - added iWin input
% Updated 11/20/12 by DJ - added topo_option, post_option inputs

if nargin<7
    iWin = []; % pick windows automatically
end
if nargin<8
    topo_option = 'vout';
end
if nargin<9
    post_option = 'post';
end

if iscell(LRstim.fwdmodels)
    LRstim_avg = AverageJlrResults(LRstim,LPstim);
    LRresp_avg = AverageJlrResults(LRresp,LPresp);
    JLRavg = AverageJlrResults(JLR,JLP);
else
    LRstim_avg = LRstim;
    LRresp_avg = LRresp;
    JLRavg = JLR;
end

[jitter,~, RT] = GetJitter(JLP.ALLEEG,'facecar');
if ~isempty(strfind(JLP.ALLEEG(1).setname,'_F_'));
    faces = find(JLRavg.truth==0);
    cars = find(JLRavg.truth==1);
else
    cars = find(JLRavg.truth==0);
    faces = find(JLRavg.truth==1);
end
nbchan = JLP.ALLEEG(1).nbchan;


% Plot JLR Posteriors at multiple window offsets
clf;
if isempty(iWin) % pick automatically
%     iWin = 1:4:numel(JLR.Azloo); % windows to highlight
    iWin = 1:4:numel(LRresp.Azloo); % windows to highlight
end
nWin = numel(iWin);

hBot = subplot(5,1,1); cla; hold on;
set(hBot,'XColor','r','YColor','r')
hTop = axes('Position',get(hBot,'Position'),...
           'XAxisLocation','top',...
           'Color','none',...
           'XColor','b','YColor','k'); hold on;

% Stimulus-locked LR
tAz = LPstim.ALLEEG(1).times(round(LRstim.trainingwindowoffset...
    +LPstim.scope_settings.trainingwindowlength/2));
plot(hTop,tAz,LRstim.Azloo,'b.:');
plot(hTop,tAz(iWin),LRstim.Azloo(iWin),'bo');

% Jittered LR
tAz = JLP.ALLEEG(1).times(round(JLR.trainingwindowoffset...
    +JLP.scope_settings.trainingwindowlength/2));
plot(hBot,tAz,JLR.Azloo,'r.-');
shift = numel(LRresp.Azloo)-numel(JLR.Azloo);
plot(hBot,tAz(iWin(iWin>shift)-shift),JLR.Azloo(iWin(iWin>shift)-shift),'ro');
% plot(hBot,tAz(iWin),JLR.Azloo(iWin),'ro');

% Response-locked LR
tAz = LPresp.ALLEEG(1).times(round(LRresp.trainingwindowoffset...
    +LPresp.scope_settings.trainingwindowlength/2));
plot(hBot,tAz,LRresp.Azloo,'r.:');
plot(hBot,tAz(iWin),LRresp.Azloo(iWin),'ro');



set(hBot,'ylim',[0.3 1]);
set(hTop,'ylim',[0.3 1]);
set(hTop,'xlim',get(hBot,'xlim')+round(mean(RT)));
plot(hTop,[0 0],get(gca,'ylim'),'k--')
plot(get(gca,'xlim'),[0.5 0.5],'k--');
plot(get(gca,'xlim'),[0.75 0.75],'k:');
xlabel(hBot,'time of response-locked window center (ms)');
xlabel(hTop,'time of stimulus-locked window center (ms)');
ylabel('10-fold Az');
title(show_symbols(sprintf('%s vs. %s, jittered LR',JLP.ALLEEG(1).setname, JLP.ALLEEG(2).setname)))
MakeLegend({'b.:','r.:','r.-'},{'Stim-locked LR','Resp-locked LR','JLR'});
% set(hTop,'Position',get(hBot,'Position'));
set(hBot,'Position',get(hTop,'Position'));

% Plot forward models
for i=1:nWin
    subplot(5,nWin,nWin+i);
    topoplot(LRstim_avg.(topo_option)(1:nbchan,iWin(i)),LPstim.ALLEEG(1).chanlocs);
    title(sprintf('%s\nOffset = %0.1f ms', topo_option, tAz(iWin(i))));
    colorbar
    subplot(5,nWin,2*nWin+i);
    topoplot(LRresp_avg.(topo_option)(1:nbchan,iWin(i)),LPresp.ALLEEG(1).chanlocs);    
    colorbar;
    
    if iWin(i)>shift        
        subplot(5,nWin,3*nWin+i); 
        topoplot(JLRavg.(topo_option)(1:nbchan,iWin(i)-shift),JLP.ALLEEG(1).chanlocs);
        colorbar
    end
%     subplot(5,nWin,3*nWin+i); 
%     topoplot(JLRavg.fwdmodels(:,iWin(i)),JLP.ALLEEG(1).chanlocs);
%     colorbar
%     set(gca,'CLim',[-2 2]);       
end
% Annotate plot
subplot(5,nWin,nWin+1); ylabel('stim-locked','visible','on');
subplot(5,nWin,2*nWin+1); ylabel('resp-locked','visible','on');
subplot(5,nWin,3*nWin+find(iWin>shift,1)); ylabel('JLR','visible','on');
% subplot(5,nWin,3*nWin+1); ylabel('JLR','visible','on');

for i=1:nWin
    if iWin(i)>shift
        subplot(5,nWin,4*nWin+i)
        ImageSortedData(JLRavg.(post_option)(faces,:,iWin(i)-shift),JLRavg.postTimes,faces,jitter(faces));
        ImageSortedData(JLRavg.(post_option)(cars,:,iWin(i)-shift),JLRavg.postTimes,cars,jitter(cars));
        set(gca,'clim',[0 0.01])
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
end

subplot(5,nWin,4*nWin+find(iWin>shift,1))
% subplot(5,nWin,4*nWin+1)
if ~isempty(strfind(JLP.ALLEEG(1).setname,'_F_'));
    ylabel('<-- faces     |     cars -->')
else
    ylabel('<-- cars     |     faces -->')
end