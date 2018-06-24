% TEMP_CompareJlrAndLr.m
%
% Compare JLR and LR results across multiple subjects.
%
% Created 10/8/12 by DJ for one-time use.

%% Load single-subject results
subject = subjects{2};
[LRstim LPstim] = LoadJlrResults(subject,0,'10fold',[0 0],'_lambda_1.00e+04_stimlocked');
[LRresp LPresp] = LoadJlrResults(subject,0,'10fold',[0 0],'_lambda_1.00e+04_resplocked');
[JLR1 JLP1] = LoadJlrResults(subject,0,'10fold',[-500 500],'_lambda_1.00e+04_JLR');
% [JLR5 JLP5] = LoadJlrResults(subject,0,'10fold',[-500 500],'_sigma5');

%% Plot single-subject results
figure;
PlotJlrAcrossOffsets_Compare(LRstim,LPstim,LRresp,LPresp,JLR1,JLP1,[],'vout','post_truth');
%%
figure;
GetJitterPosteriorCorrelations(JLR1,JLP1);


%% Losf all subjects' results
clear LR* LP* JL*
for i=1:6
    subject = subjects{i};
%     [LRstim{i} LPstim{i}] = LoadJlrResults(subject,0,'10fold',[0 0],'_lambda_1.00e+04_stimlocked');
%     [LRresp{i} LPresp{i}] = LoadJlrResults(subject,0,'10fold',[0 0],'_lambda_1.00e+04_resplocked');
%     [JLR1{i} JLP1{i}] = LoadJlrResults(subject,0,'10fold',[-500 500],'_lambda_1.00e+04_JLR');
    
    [LRstim{i} LPstim{i}] = LoadJlrResults(subject,0,'10fold',[0 0],'_stimlocked_2');
    [LRresp{i} LPresp{i}] = LoadJlrResults(subject,0,'10fold',[0 0],'_resplocked_2');
    [JLR5{i} JLP5{i}] = LoadJlrResults(subject,0,'10fold',[-500 500],'_sigma5');
    %
end
for i=1:6
    figure;
    PlotJlrAcrossOffsets_Compare(LRstim{i},LPstim{i},LRresp{i},LPresp{i},JLR1{i},JLP1{i});
    %
%     figure;
%     [Rval{i},Pval{i}] = GetJitterPosteriorCorrelations(JLR5{i},JLP5{i});
end
%% Average results within subjects
for i=1:6
%     JLRavg{i} = AverageJlrResults(JLR5{i},JLP5{i});
    JLRavg{i} = AverageJlrResults(JLR1{i},JLP1{i});
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
    Az_JLR(i,:) = JLR1{i}.Azloo;    
%     R(:,:,i) = Rval{i};
%     P(:,:,i) = Pval{i};    
    % Compile more
    vout(:,:,i) = JLRavg{i}.vout;
    fwdmodels(:,:,i) = JLRavg{i}.fwdmodels;
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
JLRall = JLR1{1};
JLPall = JLP1{1};
JLRall.post = JLRavg{1}.post;
JLRall.postTimes = JLRavg{1}.postTimes;
LRall_stim = LRstim{1};
LPall_stim = LPstim{1};
LRall_resp = LRresp{1};
LPall_resp = LPresp{1};

JLRall.Azloo = mean(Az_JLR,1);
JLRall.fwdmodels = nanmean(fwdmodels,3);
JLRall.vout = nanmean(vout,3);
LRall_stim.Azloo = mean(Az_stim,1);
LRall_stim.fwdmodels = mean(fwdmodels_stim,3);
LRall_stim.vout = mean(vout_stim,3);
LRall_resp.Azloo = mean(Az_resp,1);
LRall_resp.fwdmodels = mean(fwdmodels_resp,3);
LRall_resp.vout = mean(vout_resp,3);

PlotJlrAcrossOffsets_Compare(LRall_stim,LPall_stim,LRall_resp,LPall_resp,JLRall,JLPall,[],'fwdmodels','post');