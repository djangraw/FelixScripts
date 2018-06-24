% TEMP_CompareLrOnly.m
%
% Compare JLR and LR results across multiple subjects.
%
% Created 11/9/12 by DJ for one-time use, based on TEMP_CompareJlrAndLr.m

%% Load single-subject results
subject = subjects{6};
[LRstim LPstim] = LoadJlrResults(subject,0,'10fold',[0 0],'_stimlocked_2');
[LRresp LPresp] = LoadJlrResults(subject,0,'10fold',[0 0],'_resplocked_2');
% [JLR1 JLP1] = LoadJlrResults(subject,0,'10fold',[-500 500],'_sigma1');
% [JLR5 JLP5] = LoadJlrResults(subject,0,'10fold',[-500 500],'_sigma5');

%% Plot single-subject results
figure;
PlotJlrAcrossOffsets_Compare(LRstim,LPstim,LRresp,LPresp,LRresp,LPresp);


%% Losf all subjects' results
for i=1:6
    subject = subjects{i};
    [LRstim{i} LPstim{i}] = LoadJlrResults(subject,0,'10fold',[0 0],'_stimlocked_2');
    [LRresp{i} LPresp{i}] = LoadJlrResults(subject,0,'10fold',[0 0],'_resplocked_2');
%     [JLR1{i} JLP1{i}] = LoadJlrResults(subject,0,'10fold',[-500
%     500],'_sigma1');
%     [JLR5{i} JLP5{i}] = LoadJlrResults(subject,0,'10fold',[-500 500],'_sigma5');
    %
    figure;
    PlotJlrAcrossOffsets_Compare(LRstim{i},LPstim{i},LRresp{i},LPresp{i},LRresp{i},LPresp{i});
    %
%     figure;
%     [Rval{i},Pval{i}] = GetJitterPosteriorCorrelations(JLR5{i},JLP5{i});
end
%% Average results within subjects
for i=1:6
%     JLRavg{i} = AverageJlrResults(JLR5{i},JLP5{i});
%     JLRavg{i} = AverageJlrResults(JLR1{i},JLP1{i});
    LRstimAvg{i} = AverageJlrResults(LRstim{i},LPstim{i});
    LRrespAvg{i} = AverageJlrResults(LRresp{i},LPresp{i});
end

%% Clean up results for S2 (only 40 offsets instead of 41)
if length(JLR1{2}.Azloo)==40    
    JLR1{2}.Azloo(end+1) = NaN;
%     Rval{2}(:,end+1) = NaN;
%     Pval{2}(:,end+1) = NaN;
end
if size(JLRavg{2}.fwdmodels,2)==40    
    JLRavg{2}.vout(end+1,:) = NaN;
    JLRavg{2}.fwdmodels(:,end+1) = NaN;
    JLRavg{2}.post_truth(:,:,end+1) = NaN;
    JLRavg{2}.post_pred(:,:,end+1) = NaN;
    JLRavg{2}.post_avg(:,:,end+1) = NaN;
    JLRavg{2}.post(:,:,end+1) = NaN;
end

%% Average results across subjects
clear Az_* v* fwd*
for i=1:6
    % Compile results
    Az_stim(i,:) = LRstim{i}.Azloo;
    Az_resp(i,:) = LRresp{i}.Azloo;
%     Az_JLR(i,:) = JLR1{i}.Azloo;    
%     R(:,:,i) = Rval{i};
%     P(:,:,i) = Pval{i};    
    % Compile more
%     vout(:,:,i) = JLRavg{i}.vout;
%     fwdmodels(:,:,i) = JLRavg{i}.fwdmodels;
    vout_resp(:,:,i) = LRrespAvg{i}.vout;
    fwdmodels_resp(:,:,i) = LRrespAvg{i}.fwdmodels;
    vout_stim(:,:,i) = LRstimAvg{i}.vout;
    fwdmodels_stim(:,:,i) = LRstimAvg{i}.fwdmodels;
%     post_avg(:,:,:,i) = JLRavg{i}.post_avg;
%     post_pred(:,:,:,i) = JLRavg{i}.post_pred;
%     post_truth(:,:,:,i) = JLRavg{i}.post_truth;
end

%% Plot Azs and Fwd Models using PlotJlrAcrossOffsets_Compare
% JLRall = JLR5{1};
% JLPall = JLP5{1};
% JLRall = JLR1{1};
% JLPall = JLP1{1};
LRall_stim = LRstim{1};
LPall_stim = LPstim{1};
LRall_resp = LRresp{1};
LPall_resp = LPresp{1};

% JLRall.Azloo = mean(Az_JLR,1);
% JLRall.fwdmodels = nanmean(fwdmodels,3);
LRall_stim.Azloo = mean(Az_stim,1);
LRall_stim.fwdmodels = mean(fwdmodels_stim,3);
LRall_resp.Azloo = mean(Az_resp,1);
LRall_resp.fwdmodels = mean(fwdmodels_resp,3);

PlotJlrAcrossOffsets_Compare(LRall_stim,LPall_stim,LRall_resp,LPall_resp,LRall_resp,LPall_resp);

%%
tAz_stim = LPall_stim.ALLEEG(1).times(round(LRall_stim.trainingwindowoffset+LPall_stim.scope_settings.trainingwindowlength/2));
tAz_resp = LPall_resp.ALLEEG(1).times(round(LRall_resp.trainingwindowoffset+LPall_resp.scope_settings.trainingwindowlength/2));

clf;
hBot = axes; cla; hold on;
set(hBot,'XColor','r','YColor','r')
hTop = axes('Position',get(hBot,'Position'),...
           'XAxisLocation','top',...
           'Color','none',...
           'XColor','b','YColor','k'); hold on;

% axes(hBot)
JackKnife(tAz_stim,mean(Az_stim,1), std(Az_stim,1)/sqrt(size(Az_stim,1)),'b','b');
JackKnife(tAz_resp+round(mean(RT)),mean(Az_resp,1), std(Az_resp,1)/sqrt(size(Az_resp,1)),'r','r');
set(hBot,'xlim',[min(tAz_resp) max(tAz_resp)])
% set(hTop,'Color','none')

RT = nan(1,numel(subjects));
for i=1:numel(subjects)
    [~,~,RTthis] = GetJitter(LPresp{i}.ALLEEG,'facecar');
    RT(i) = mean(RTthis);
end

set(hBot,'ylim',[0.3 1]);
set(hTop,'ylim',[0.3 1]);
set(hTop,'xlim',get(hBot,'xlim')+round(mean(RT)));
plot(hTop,[0 0],get(gca,'ylim'),'k--')
plot(get(gca,'xlim'),[0.5 0.5],'k--');
plot(get(gca,'xlim'),[0.75 0.75],'k:');
xlabel(hBot,'time of response-locked window center (ms)');
xlabel(hTop,'time of stimulus-locked window center (ms)');
ylabel('10-fold Az');
title(show_symbols(sprintf('%s vs. %s, jittered LR',LPall_resp.ALLEEG(1).setname, LPall_resp.ALLEEG(2).setname)))
MakeLegend({'b-','r-'},{'Stim-locked LR','Resp-locked LR'},[2 2]);
