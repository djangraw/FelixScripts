
matlabpool open 10


%% Set up
subjects = {'an02apr04', 'jeremy15jul04','paul21apr04','robin30jun04','vivek23jun04'};
iSubj = 5;
subject = subjects{iSubj};

%%
tWin = [0 500]; % stim locked
% tWin = [-500 0]; % response-locked
winWidth = 50; % in samples
winShift = 20; % in samples

%% Load Stim-Locked
[ALLEEG,EEG,~,RT] = loadSubjectData_facecar(subject);
RT1 = RT.face;
RT2 = RT.car;
% Get truth info
truth = [zeros(1,ALLEEG(1).trials), ones(1,ALLEEG(2).trials)];
faces = find(truth==0);
cars = find(truth==1);
jitter = -[RT1 RT2]+mean([RT1 RT2]); % -25 for a 50ms window?

%% Response-Lock
epWindow(1) = (ALLEEG(1).times(1) - min([RT1 RT2]))/1000; % in sec
epWindow(2) = (ALLEEG(1).times(end) - max([RT1 RT2]))/1000; % in sec

ALLEEG(1) = pop_epoch(ALLEEG(1),{'RT'},epWindow);
ALLEEG(2) = pop_epoch(ALLEEG(2),{'RT'},epWindow);

%% Analyze
isGoodTime = EEG.times>tWin(1) & EEG.times<tWin(2);
data = cat(3,ALLEEG(1).data(:,isGoodTime,:), ALLEEG(2).data(:,isGoodTime,:));

[Az, AzLoo, stats] = RunMultiLR(data,truth,50,20);


%% Plot
nPlots = numel(Az);
nRows = ceil(sqrt(nPlots));
nCols = ceil(nPlots/nRows);

t = EEG.times(isGoodTime);
t = t(round((1:winShift:end-winWidth-winShift)+winWidth/2-1));

%
figure(40); clf;
for i=1:nPlots
    subplot(nRows,nCols,i);
    topoplot(stats(i).fwdModel,EEG.chanlocs);
    set(gca,'CLim',[-5 5]);    
    title(sprintf('offset = %0.1f ms: Az = %0.2f', t(i), AzLoo(i)));
end
colorbar;
%
figure(41); clf;
hold on;
plot(t,AzLoo,'b.-');
set(gca,'ylim',[0.3 1]);
set(gca,'xlim',tWin);
% plot([0 0],get(gca,'ylim'),'k-');
plot(get(gca,'xlim'),[0.5 0.5],'k--');
plot(get(gca,'xlim'),[0.75 0.75],'k:');
xlabel('time in epoch (ms)');
ylabel('LOO Az');
title(show_symbols(sprintf('%s vs. %s, standard LR',ALLEEG(1).setname, ALLEEG(2).setname)))

%% Run JLR
jlrWinOffset = [-500 500] - mean([RT1 RT2]); % 205
jitterrange = [-300 300];
ALLEEG = run_logisticregression_jittered_EM_wrapper_RT(subject,0,'10fold',jitterrange,1,jlrWinOffset);

%% Get JLR Results
% jlrWinOffset = -400;
% jitterrange = [-1 1]; jlrWinOffset = 191;
% jitterrange = [-300 300]; jlrWinOffset = -400;
% jitterrange = [-323 323]; jlrWinOffset = -400;
foldername = sprintf('results_%s_noweightprior_10fold_jrange_%d_to_%d',subject,jitterrange(1),jitterrange(2));
% foldername = sprintf('results_%s_noweightprior_10fold_jrange_%d_to_%d_multioffsets',subject,jitterrange(1),jitterrange(2));
% foldername = sprintf('results_%s_noweightprior_10fold_jrange_%d_to_%d_forceOneWinner',subject,jitterrange(1),jitterrange(2));
JLR = load([foldername '/results_10fold']);
JLP = load([foldername '/params_10fold']);
fwdModel = mean(cat(3,JLR.fwdmodels{:}),3);
% [post,~,postTimes,jitter] = GetFinalPosteriors_gaussian(foldername,'10fold',subject);
% avgPost = mean(cat(3,post{:}),3);
postTimes = (1000/JLP.ALLEEG(1).srate*(jitterrange(1):jitterrange(2)));
jitter = -([RT1 RT2]-mean([RT1 RT2]));


%% Plot JLR Results
figure(43); clf;
jitter = -[RT1 RT2]+mean([RT1 RT2]); % -25 for a 50ms window?
subplot(2,2,1);
topoplot(fwdModel,EEG.chanlocs);
% set(gca,'CLim',[-5 5]);
% set(gca,'CLim',[-90 90]);
% set(gca,'CLim',[-2000 2000]);
title(sprintf('Fwd Model, offset = %0.1f ms: Az = %0.2f', jlrWinOffset, JLR.Azloo));
colorbar;
subplot(1,2,2); cla; hold on;

clear post
post(faces,:) = JLR.posterior2(faces,:);
post(cars,:) = JLR.posterior(cars,:);
post = post./repmat(sum(post,2),1,size(post,2)); % Normalize each row to sum to 1
ImageSortedData(post(faces,:),postTimes,faces,jitter(faces));
ImageSortedData(post(cars,:),postTimes,cars,jitter(cars));
set(gca,'clim',[0 0.025])
if numel(postTimes)>1
    xlim([postTimes(1) postTimes(end)])
end
title(sprintf('Posteriors: p(t_i|c_i,y_i)'));
xlabel('jitter time (ms)')
ylabel('<-- faces     |     cars -->')
colorbar
MakeFigureTitle(sprintf('%s vs. %s, jittered LR',ALLEEG(1).setname, ALLEEG(2).setname));
%% Get FOMs
postAtJitter = nan(1,numel(truth));
peakTimeError = nan(1,numel(truth));
for i=1:numel(truth)
    [~,iPeak] = max(post(i,:));
    peakTimeError(i) = postTimes(iPeak)-jitter(i);
    iTime = find(postTimes>jitter(i),1,'first');
    if ~isempty(iTime)
        postAtJitter(i) = post(i,iTime);
    end    
end

subplot(4,2,5); cla; hold on; box on;
xTimeError = linspace(jitterrange(1),jitterrange(2),20);
yFace = hist(peakTimeError(faces),xTimeError);
yCar = hist(peakTimeError(cars),xTimeError);
yAll = hist(-jitter,xTimeError);
plot(xTimeError,[yFace/sum(yFace); yCar/sum(yCar); yAll/sum(yAll)]*100);
legend('face trials','car trials','zeros')
xlabel('posterior peak time - actual jitter time (ms)');
ylabel('# trials')
subplot(4,2,7); cla; hold on; box on;
xPost = 0:1e-3:3e-2;
yFace = hist(postAtJitter(faces),xPost);
yCar = hist(postAtJitter(cars),xPost);
yAll = hist(post(:),xPost);
plot(xPost,[yFace/sum(yFace); yCar/sum(yCar); yAll/sum(yAll)]*100);
xlabel('posterior value');
ylabel('% trials')
legend('face at true jitter time','car at true jitter time', 'all at all times')
ylim([0 20])


%% Load Regular LR Az values at multiple window offsets

foldername = sprintf('results_%s_noweightprior_10fold_jrange_0_to_0_resplocked',subject);
LRresp = load([foldername '/results_10fold']);
foldername = sprintf('results_%s_noweightprior_10fold_jrange_0_to_0_stimlocked',subject);
LRstim = load([foldername '/results_10fold']);

%% Compare Regular LR to JLR
figure(43); clf;
hold on;
tAz = JLP.ALLEEG(1).times(JLR.trainingwindowoffset);
plot(tAz,[LRstim.Azloo; LRresp.Azloo; JLR.Azloo]','.-');
set(gca,'ylim',[0.3 1]);
set(gca,'xlim',[-1200 0]);
% plot([0 0],get(gca,'ylim'),'k-');
plot([-mean([RT1 RT2]) -mean([RT1 RT2])],get(gca,'ylim'),'r--')
plot(get(gca,'xlim'),[0.5 0.5],'k--');
plot(get(gca,'xlim'),[0.75 0.75],'k:');
xlabel('time in epoch (ms)');
ylabel('10-fold Az');
legend('Az','Mean RT')
title(show_symbols(sprintf('%s vs. %s, regular vs. jittered LR',ALLEEG(1).setname, ALLEEG(2).setname)))

%% Plot JLR Posteriors at multiple window offsets
figure(44); clf;
hold on;
iWin = 1:3:numel(JLR.Azloo);
nWin = numel(iWin);
tAz = JLP.ALLEEG(1).times(JLR.trainingwindowoffset);
avgFwdModel = mean(cat(3,JLR.fwdmodels{:}),3);

subplot(4,1,1); cla; hold on;
plot(tAz,JLR.Azloo,'b.-');
plot(tAz(iWin),JLR.Azloo(iWin),'bo');
set(gca,'ylim',[0.3 1]);
plot([-mean([RT1 RT2]) -mean([RT1 RT2])],get(gca,'ylim'),'r--')
plot(get(gca,'xlim'),[0.5 0.5],'k--');
plot(get(gca,'xlim'),[0.75 0.75],'k:');
xlabel('time in epoch (ms)');
ylabel('10-fold Az');
legend('Az','highlighted times','Mean RT')
title(show_symbols(sprintf('%s vs. %s, jittered LR',ALLEEG(1).setname, ALLEEG(2).setname)))

for i=1:nWin
    subplot(4,nWin,nWin+i)
    topoplot(avgFwdModel(:,iWin(i)),EEG.chanlocs);
%     set(gca,'CLim',[-2 2]);
    colorbar
    title(sprintf('Fwd Model\nOffset = %0.1f ms', tAz(iWin(i))));
end
for i=1:nWin
    subplot(2,nWin,nWin+i)
    post(faces,:) = JLR.posterior2(faces,:,iWin(i));
    post(cars,:) = JLR.posterior(cars,:,iWin(i));
    post = post./repmat(sum(post,2),1,size(post,2)); % Normalize each row to sum to 1
    ImageSortedData(post(faces,:),postTimes,faces,jitter(faces));
    ImageSortedData(post(cars,:),postTimes,cars,jitter(cars));
    set(gca,'clim',[0 0.01])
    if length(postTimes)>1
        xlim([postTimes(1) postTimes(end)])
    end
    title(sprintf('Posteriors: p(t_i|y_i,c_i)\nOffset = %.1fms',tAz(iWin(i))));   
    xlabel('time from window center (ms)')    
end

subplot(2,nWin,nWin+1)
ylabel('<-- faces     |     cars -->')


