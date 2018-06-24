% TEMP_LineUpTrials_WoodyDemo.m
%
% Created 11/7/13 by DJ for one-time use.

%% Load data

subjects = {'an02apr04','jeremy15jul04','paul21apr04','robin30jun04','vivek23jun04','jeremy29apr04'};
iSubj = 6;
filename = sprintf('facecar_%s_cropped.set',subjects{iSubj});
% filename = 'facecar_an02apr04_cropped.set';
% filename = 'facecar_jeremy15jul04_cropped.set';
% filename = 'facecar_paul21apr04_cropped.set';
% filename = 'facecar_robin30jun04_cropped.set';
% filename = 'facecar_vivek23jun04_cropped.set';
% filename = 'facecar_jeremy29apr04_cropped.set';

% Load
ALLEEG = [];
EEG = pop_loadset('filename',filename,'filepath','/Users/dave/Documents/Data/JitteredLogisticRegression/Data/FaceCar_fromJason/');
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 1 );
%% Epoch
EEG = pop_epoch( EEG, {  'Stim_C_45_correct'  }, [-3  3], 'newname', sprintf('%s_AllData Stim-C45 BigEpochs',subjects{iSubj}), 'epochinfo', 'yes');
EEG = eeg_checkset( EEG );
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0); 
EEG = pop_epoch( EEG, {  'Stim_F_45_correct'  }, [-3  3], 'newname', sprintf('%s_AllData Stim-F45 BigEpochs',subjects{iSubj}), 'epochinfo', 'yes');
EEG = eeg_checkset( EEG );
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0); 
eeglab redraw

%% Jitter data
origdata = cat(3,ALLEEG(2).data,ALLEEG(3).data);

epochrange = [-2000 2000];
jitterrange = [2500 3500];

[newdata,truejitter] = JitterTrials_rawdata(origdata,epochrange,jitterrange);

truejitter_ms = ALLEEG(2).times(truejitter);


%% Recover using CZ
iCZ = find(strcmp('Cz',{EEG.chanlocs.labels}));
options = struct('option_pca',false);
MatchStrength_CZ = LineUpTrials_rawdata(newdata(iCZ,:,:),epochrange(1):epochrange(2),[0 1000],10,EEG.chanlocs(iCZ),-truejitter_ms,options);

%% Recover using 5 elec's
iChans = find(ismember({EEG.chanlocs.labels}, {'Fz','Cz','Pz','POz','Oz'}));
options = struct('option_pca',false);
MatchStrength_5E = LineUpTrials_rawdata(newdata(iChans,:,:),epochrange(1):epochrange(2),[0 1000],30,EEG.chanlocs(iChans),-truejitter_ms,options);

%% Recover using PCA
MatchStrength_PCA = LineUpTrials_rawdata(newdata,epochrange(1):epochrange(2),[0 1000],10,EEG.chanlocs,-truejitter_ms);
% finalMatchStrength = LineUpTrials_rawdata(raweeg,times,tWin,smoothwidth,chanlocs)

%%
figure(3); clf;
t = epochrange(1):epochrange(2)-1000;
[~,order] = sort(-truejitter_ms,'ascend');
ntrials = length(order);
subplot(2,3,1);
ImageSortedData(MatchStrength_CZ,t,1:ntrials,-truejitter_ms);
[~,iMax] = max(MatchStrength_CZ,[],2);
tMax_CZ = t(iMax);
scatter(tMax_CZ(order),1:ntrials,'m.');
xlim([-500 500]);
ylabel('trial');
xlabel('time (ms)');
title('CZ Only');

subplot(2,3,2);
ImageSortedData(MatchStrength_5E,t,1:size(newdata,3),-truejitter_ms);
[~,iMax] = max(MatchStrength_5E,[],2);
tMax_5E = t(iMax);
scatter(tMax_5E(order),1:ntrials,'m.');
xlim([-500 500]);
xlabel('time (ms)');
title('5 Electrodes');

subplot(2,3,3);
ImageSortedData(MatchStrength_PCA,t,1:ntrials,-truejitter_ms);
[~,iMax] = max(MatchStrength_PCA,[],2);
tMax_PCA = t(iMax);
scatter(tMax_PCA(order),1:ntrials,'m.');
xlim([-500 500]);
xlabel('time (ms)');
title('5 PCs');

%% plot accuracy
subplot(2,1,2); cla; hold on;
accuracy{iSubj} = [tMax_CZ+truejitter_ms; tMax_5E+truejitter_ms; tMax_PCA+truejitter_ms]';
boxplot([tMax_CZ+truejitter_ms; tMax_5E+truejitter_ms; tMax_PCA+truejitter_ms]');
ylabel('Estimated - True Jitter')
xlabel('Template')
set(gca,'xtick',[1 2 3],'xticklabel',{'CZ','5Elec','5PC'});
plot(get(gca,'xlim'),[0 0],'k');
ylim([-200 200])


%% save
save(sprintf('TEMP_LineUp_%s',subjects{iSubj}),'filename','newdata','truejitter_ms','MatchStrength_*','epochrange','jitterrange');

%% Plot all accuracy so far
figure(4); clf; hold on;
for i=1:numel(accuracy);
    aMean(i,:) = mean(accuracy{i},1);
    aSE(i,:) = std(accuracy{i},[],1)/sqrt(size(accuracy{i},1));
    n = size(accuracy{i},1);
    randSE(i) = std(1000*(rand(1,n)-rand(1,n)))/sqrt(n);
    zeroSE(i) = std(1000*rand(1,n))/sqrt(n);
end
% Plot
bar([mean(randSE),mean(zeroSE),mean(aSE)]);
errorbar([mean(randSE),mean(zeroSE),mean(aSE)],[std(randSE),std(zeroSE),std(aSE)]/sqrt(numel(accuracy)),'k.');
% bar(mean(aSE));
% errorbar(mean(aMean,1),mean(aSE,1),'.');




ylabel('Std Err of (Estimated - True Jitter)')
xlabel('Template')
set(gca,'xtick',1:5,'xticklabel',{'Random','Zero','CZ','5Elec','5PC'});
% set(gca,'xtick',[1 2 3],'xticklabel',{'CZ','5Elec','5PC'});
plot(get(gca,'xlim'),[0 0],'k');
% ylim([-200 200])
title(sprintf('Mean across %d subjects',length(accuracy)));
