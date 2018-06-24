function [peakTimeError, postAtJitter] = PlotJlrFoms(JLR,JLP,iWin,post_option)

% Plots the forward model, posteriors, and figures of merit in the current
% window.
%
% PlotJlrFoms(JLR,JLP,iWin,post_option)
% 
% INPUTS:
% -JLR and JLP are the outputs of LoadJlrResults
% -iWin is a scalar indicating the number of the window whose results you
%  want to plot.  
% -post_option is a field (i.e. 'post_truth'... see AverageJlrResults for
% details)
% 
% OUTPUTS:
% -peakTimeError is an n-element vector, where n is the number of trials.
%  peakTimeError(i) is the time of maximum posterior minus the actual 
%  jitter time on trial i.
% -postAtJitter is an n-element vector, where n is the number of trials.
%  peakTimeError(i) is the value of the posterior at the actual jitter time
%  on trial i.
%
% Created 9/27/12 by DJ.
% Updated 12/31/12 by DJ - added post_option

% Handle defaults
if nargin<4 || isempty(post_option)
    post_option = 'post';
end

% Set up
JLRavg = AverageJlrResults(JLR,JLP);
jitter = GetJitter(JLP.ALLEEG,'facecar');
tOffset = JLP.ALLEEG(1).times(round(JLP.trainingwindowoffset(iWin)+JLP.scope_settings.trainingwindowlength/2));
if ~isempty(strfind(JLP.ALLEEG(1).setname,'_F_'));
    faces = find(JLRavg.truth==0);
    cars = find(JLRavg.truth==1);
else
    cars = find(JLRavg.truth==0);
    faces = find(JLRavg.truth==1);
end
clf;
MakeFigureTitle(sprintf('%s vs. %s, jittered LR',JLP.ALLEEG(1).setname, JLP.ALLEEG(2).setname));

% Plot forward model
subplot(2,2,1);
topoplot(JLRavg.fwdmodels(:,iWin),JLP.ALLEEG(1).chanlocs);
title(sprintf('Fwd Model, offset = %0.1f ms: Az = %0.2f', tOffset, JLR.Azloo(iWin)));
colorbar;
subplot(1,2,2); cla; hold on;

% Plot posteriors
ImageSortedData(JLRavg.(post_option)(faces,:,iWin),JLRavg.postTimes,faces,jitter(faces));
ImageSortedData(JLRavg.(post_option)(cars,:,iWin),JLRavg.postTimes,cars,jitter(cars));
ylim([0.5,size(JLRavg.(post_option),1)+0.5])
% set(gca,'clim',[0 0.01])
% set(gca,'clim',[0 0.04])
if numel(JLRavg.postTimes)>1
    xlim([JLRavg.postTimes(1) JLRavg.postTimes(end)])
end
title(sprintf('Posteriors: p(t_i|c_i,y_i)'));
xlabel('jitter time (ms)')
if ~isempty(strfind(JLP.ALLEEG(1).setname,'_F_'));
    ylabel('<-- faces     |     cars -->')
else
    ylabel('<-- cars     |     faces -->')
end
colorbar

% Get FOMs
postAtJitter = nan(1,numel(JLRavg.truth));
peakTimeError = nan(1,numel(JLRavg.truth));
for i=1:numel(JLRavg.truth)
    [~,iPeak] = max(JLRavg.(post_option)(i,:,iWin));    
    peakTimeError(i) = JLRavg.postTimes(iPeak)-jitter(i);
    iTime = find(JLRavg.postTimes>jitter(i),1,'first');
    if ~isempty(iTime)
        postAtJitter(i) = JLRavg.(post_option)(i,iTime,iWin);
    end    
end

% Plot posterior peak time error
subplot(4,2,5); cla; hold on; box on;
jitterrange = JLP.pop_settings.jitterrange;
xTimeError = linspace(jitterrange(1),jitterrange(2),20);
yFace = hist(peakTimeError(faces),xTimeError);
yCar = hist(peakTimeError(cars),xTimeError);
yAll = hist(-jitter,xTimeError);
plot(xTimeError,[yFace/sum(yFace); yCar/sum(yCar); yAll/sum(yAll)]*100);
legend('face trials','car trials','zeros')
title('Posterior Peak Time Error')
xlabel('posterior peak time - actual jitter time (ms)');
ylabel('# trials')

% Plot posterior at true jitter time
subplot(4,2,7); cla; hold on; box on;
xPost = 0:1e-3:3e-2;
yFace = hist(postAtJitter(faces),xPost);
yCar = hist(postAtJitter(cars),xPost);
allPost = JLRavg.(post_option)(:,:,iWin);
yAll = hist(allPost(:),xPost);
plot(xPost,[yFace/sum(yFace); yCar/sum(yCar); yAll/sum(yAll)]*100);
title('Posterior At True Jitter Time')
xlabel('posterior value');
ylabel('% trials')
legend('face at true jitter time','car at true jitter time', 'all at all times')
ylim([0 20])