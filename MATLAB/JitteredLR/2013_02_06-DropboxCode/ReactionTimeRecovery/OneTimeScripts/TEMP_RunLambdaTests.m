% TEMP_RunLambdaTests.m
% Created 11/20/12 by DJ for one-time use.

%% Run Lambda Tests
iSubject = 1; timeMs = -380;
% iSubject = 4; timeMs = -340;
% iSubject = 5; timeMs = -260;
lambda = [1e-3 1e0 1e1 1e2];

subject = subjects{iSubject};
[LRresp LPresp] = LoadJlrResults(subject,0,'10fold',[0 0],'_resplocked');
[jitter,truth,RTall] = GetJitter(LPresp.ALLEEG,'facecar');

for i=1:numel(lambda)
    run_logisticregression_jittered_EM_wrapper_RT_v2p2(subject,0,'10fold',[0 0],1,timeMs+mean(RTall),false, lambda(i));
    run_logisticregression_jittered_EM_wrapper_RT_v2p2(subject,0,'10fold',[0 0],1,timeMs,true, lambda(i));
    run_logisticregression_jittered_EM_wrapper_RT_v2p2(subject,0,'10fold',[-500 500],1,timeMs,true, lambda(i));
end


%% Load single-subject results
% iSubject = 1; timeMs = -380;
% iSubject = 4; timeMs = -340;
iSubject = 5; timeMs = -260;
subject = subjects{iSubject};
topo_option = 'vout';
post_option = 'post_truth';
lambda = [1e-3 1e0 1e1 1e2];
clear stimAz respAz jlrAz stimFM respFM jlrFM jlrPost
for i=1:numel(lambda)
    try
        [LRstim LPstim] = LoadJlrResults(subject,0,'10fold',[0 0],sprintf('_stimlocked_lambda%1.e_v2p3_condoff2',lambda(i)));
        LRstimavg = AverageJlrResults(LRstim,LPstim);
        stimAz(i) = LRstim.Azloo;
%         stimFM(:,i) = LRstimavg.fwdmodels(:,1);
        stimFM(:,i) = LRstimavg.(topo_option)(1:end-1);
    end
    
    try
        [LRresp LPresp] = LoadJlrResults(subject,0,'10fold',[0 0],sprintf('_stimlocked_lambda%1.e_v2p3_condoff2',lambda(i)));
        LRrespavg = AverageJlrResults(LRresp,LPresp);
        respAz(i) = LRresp.Azloo;
%         stimFM(:,i) = LRstimavg.fwdmodels(:,1);
        respFM(:,i) = LRrespavg.(topo_option)(1:end-1);
    end
        
        [JLR JLP] = LoadJlrResults(subject,0,'10fold',[-500 500],sprintf('_lambda%1.e_v2p3_condoff2',lambda(i)));    
        JLRavg = AverageJlrResults(JLR,JLP);
        jlrAz(i) = JLR.Azloo;
%         jlrFM(:,i) = JLRavg.fwdmodels(:,1);
        jlrFM(:,i) = JLRavg.(topo_option)(1:end-1);
        jlrPost(:,:,i) = JLRavg.(post_option);

        
end
%% Regular vs. JLR
x = log(lambda)/log(10);
[jitter,~, RT] = GetJitter(JLP.ALLEEG,'facecar');
if ~isempty(strfind(JLP.ALLEEG(1).setname,'_F_'));
    faces = find(JLRavg.truth==0);
    cars = find(JLRavg.truth==1);
else
    cars = find(JLRavg.truth==0);
    faces = find(JLRavg.truth==1);
end
clf;
subplot(6,1,1);
bar(x,[stimAz; respAz; jlrAz]')
ylim([0.5 1]); grid on;
xlabel('log_1_0(\\lambda)')
ylabel('10-fold Az')
legend('stimulus-locked LR', 'resp-locked LR','JLR')
title(sprintf('Classification dependence on regularization term\n subject %s, %dms r.t. response',subject,timeMs))
for i=1:numel(lambda)
    subplot(6,numel(lambda),numel(lambda)+i);
    topoplot(stimFM(:,i),JLP.ALLEEG(1).chanlocs);
    colorbar
    title(sprintf('%s\n\\lambda = %1.e',topo_option,lambda(i)))
    if i==1
        ylabel('stim-locked LR','visible','on')
    end
    subplot(6,numel(lambda),2*numel(lambda)+i);
    topoplot(respFM(:,i),JLP.ALLEEG(1).chanlocs);
    colorbar        
    if i==1
        ylabel('resp-locked LR','visible','on')
    end
    subplot(6,numel(lambda),3*numel(lambda)+i);
    topoplot(jlrFM(:,i),JLP.ALLEEG(1).chanlocs);
    colorbar        
    if i==1
        ylabel('JLR','visible','on')
    end
    subplot(3,numel(lambda),2*numel(lambda)+i);
    ImageSortedData(jlrPost(faces,:,i),JLRavg.postTimes,faces,jitter(faces));
    ImageSortedData(jlrPost(cars,:,i),JLRavg.postTimes,cars,jitter(cars));
    set(gca,'clim',[0 0.01])
    ylim([0.5,size(JLRavg.post,1)+0.5])
    if length(JLRavg.postTimes)>1
        xlim([JLRavg.postTimes(1) JLRavg.postTimes(end)])
    end
    title(sprintf('%s: p(t_i|y_i, c_i)',post_option));   
    xlabel('time from window center (ms)')    
end

subplot(3,numel(lambda),2*numel(lambda)+1)
% subplot(5,nWin,4*nWin+1)
if ~isempty(strfind(JLP.ALLEEG(1).setname,'_F_'));
    ylabel('<-- faces     |     cars -->')
else
    ylabel('<-- cars     |     faces -->')
end