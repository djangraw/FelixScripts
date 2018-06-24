%% Set up
subjects = {'an02apr04', 'jeremy15jul04','paul21apr04','robin30jun04','vivek23jun04'};
iSubj = 1;
subject = subjects{iSubj};
tWin = [0 500]; % stim locked
% tWin = [-500 0]; % response-locked
winWidth = 50; % in samples
winShift = 20; % in samples
jlrWinOffset = [-500 500]; % 205

%% Load Stim-Locked
[ALLEEG,EEG,~,RT] = loadSubjectData_facecar(subject);
RT1 = RT.face;
RT2 = RT.car;
% Get truth info
truth = [zeros(1,ALLEEG(1).trials), ones(1,ALLEEG(2).trials)];
faces = find(truth==0);
cars = find(truth==1);
jitter = -[RT1 RT2]+mean([RT1 RT2]);
%% Get JLR Results
jitterrange = [-300 300];
foldername = sprintf('results_%s_noweightprior_10fold_jrange_%d_to_%d',subject,jitterrange(1),jitterrange(2));
% foldername = sprintf('results_%s_noweightprior_10fold_jrange_%d_to_%d_multioffsets',subject,jitterrange(1),jitterrange(2));
% foldername = sprintf('results_%s_noweightprior_10fold_jrange_%d_to_%d_forceOneWinner',subject,jitterrange(1),jitterrange(2));
JLR = load([foldername '/results_10fold']);
JLP = load([foldername '/params_10fold']);
fwdModel = mean(cat(3,JLR.fwdmodels{:}),3);
% [post,~,postTimes,jitter] = GetFinalPosteriors_gaussian(foldername,'10fold',subject);
% avgPost = mean(cat(3,post{:}),3);
postTimes = (1000/JLP.ALLEEG(1).srate*(jitterrange(1):jitterrange(2)));
%% Load Regular LR Az values at multiple window offsets

foldername = sprintf('results_%s_noweightprior_10fold_jrange_0_to_0_resplocked',subject);
LRresp = load([foldername '/results_10fold']);
foldername = sprintf('results_%s_noweightprior_10fold_jrange_0_to_0_stimlocked',subject);
LRstim = load([foldername '/results_10fold']);

%% Compare Regular LR to JLR
figure(iSubj); clf;
hold on;
tAz = ALLEEG(1).times(LRstim.trainingwindowoffset)-mean([RT1 RT2]);
plot(tAz,LRstim.Azloo,'b.-');
tAz = JLP.ALLEEG(1).times(LRresp.trainingwindowoffset);
plot(tAz,LRresp.Azloo,'g.-');
tAz = JLP.ALLEEG(1).times(JLR.trainingwindowoffset);
plot(tAz,JLR.Azloo,'r.-');
set(gca,'ylim',[0.3 1]);
set(gca,'xlim',[-1200 0]);
% plot([0 0],get(gca,'ylim'),'k-');
plot([-mean([RT1 RT2]) -mean([RT1 RT2])],get(gca,'ylim'),'r--')
plot(get(gca,'xlim'),[0.5 0.5],'k--');
plot(get(gca,'xlim'),[0.75 0.75],'k:');
xlabel('time in epoch (ms)');
ylabel('10-fold Az');
legend('Stim-Locked Standard', 'Resp-Locked Standard','Resp-Locked Jittered','Mean RT')
title(show_symbols(sprintf('%s vs. %s,\n regular vs. jittered LR',ALLEEG(1).setname, ALLEEG(2).setname)))
