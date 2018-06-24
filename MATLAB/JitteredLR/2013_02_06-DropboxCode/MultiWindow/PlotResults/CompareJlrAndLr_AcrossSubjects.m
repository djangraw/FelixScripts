function CompareJlrAndLr_AcrossSubjects(subjects,commontags,stimtags,resptags,jlrtags)

% CompareJlrAndLr_AcrossSubjects(subjects,commontags,stimtags,resptags,jlrtags)
%
%
% Created 12/6/12 by DJ.

nSubjects = numel(subjects);

disp('---Loading...')
for i=1:nSubjects
    [LRstim{i} LPstim{i} LRresp{i} LPresp{i} JLR{i} JLP{i}] = CompareJlrAndLr(subjects{i},commontags,stimtags,resptags,jlrtags);
end
disp('---Plotting...')
for i=1:nSubjects
    figure;
    PlotJlrAcrossOffsets_Compare(LRstim{i},LPstim{i},LRresp{i},LPresp{i},JLR{i},JLP{i});
end
disp('---Averaging...')
% Average results within subjects
for i=1:nSubjects
    JLRavg{i} = AverageJlrResults(JLR{i},JLP{i});
    LRstimAvg{i} = AverageJlrResults(LRstim{i},LPstim{i});
    LRrespAvg{i} = AverageJlrResults(LRresp{i},LPresp{i});
end

%% Average results across subjects
for i=1:nSubjects
    % Compile results
    Az_stim(i,:) = LRstim{i}.Azloo;
    Az_resp(i,:) = LRresp{i}.Azloo;
    Az_JLR(i,:) = JLR{i}.Azloo;    
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

% Plot Azs and Fwd Models using PlotJlrAcrossOffsets_Compare
JLRall = JLR{1};
JLPall = JLP{1};
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

disp('---Plotting Average...')
figure;
PlotJlrAcrossOffsets_Compare(LRall_stim,LPall_stim,LRall_resp,LPall_resp,JLRall,JLPall,[],'fwdmodels','post');
disp('---Done!')