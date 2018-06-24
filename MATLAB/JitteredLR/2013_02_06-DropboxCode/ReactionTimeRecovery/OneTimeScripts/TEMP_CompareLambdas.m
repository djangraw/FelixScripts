% TEMP_CompareLambdas
%
% Plots the stim-locked and JLR results (Az & fwd models) for a single time
% point given various lambda values.
%
% Created 11/9/12 by DJ for one-time use.

%% Load single-subject results
subject = subjects{1};
% lambda = [1e-3 1e0 1e2 1e3 1e4 1e5 1e6 1e9];
lambda = [1e3 1e5 1.08e4 1.27e4 1.37e3 1.49e4 1.61e3 1.74e4 2.04e4 2.40e4 3.04e3 3.86e4 4.18e3 4.52e4 4.89e3 5.3e4 5.74e3 6.21e4 7.28e4 7.88e3 8.53e4 9.24e3];
lambda = sort(lambda,'ascend');
clear stimAz jlrAz stimFM jlrFM jlrPost jlrPost2
for i=1:numel(lambda)
%     if lambda(i)==1e-5
%         [LRstim LPstim] = LoadJlrResults(subject,0,'10fold',[0 0],'_stimlocked_2');
%         [JLR JLP] = LoadJlrResults(subject,0,'10fold',[-500 500],'_sigma1_2');       
%         LRstimavg = AverageJlrResults(LRstim,LPstim);
%         JLRavg = AverageJlrResults(JLR,JLP);
%         stimAz(i) = LRstim.Azloo(31);
%         jlrAz(i) = JLR.Azloo(6);
% %         stimFM(:,i) = LRstimavg.fwdmodels(:,31);
% %         jlrFM(:,i) = JLRavg.fwdmodels(:,6);
%         stimFM(:,i) = LRstimavg.vout(31,1:end-1)';
%         jlrFM(:,i) = JLRavg.vout(6,1:end-1)';
%     else
    try
        [LRstim LPstim] = LoadJlrResults(subject,0,'10fold',[0 0],sprintf('_stimlocked_lambda%1.e_v2p3_condoff',lambda(i)));
        LRstimavg = AverageJlrResults(LRstim,LPstim);
        stimAz(i) = LRstim.Azloo;
%         stimFM(:,i) = LRstimavg.fwdmodels(:,1);
%         stimFM(:,i) = LRstimavg.vout(1,1:end-1)';
        stimFM(:,i) = LRstimavg.vout(1:end-1);
    end
        
        % [LRresp LPresp] = LoadJlrResults(subject,0,'10fold',[0 0],'_resplocked');
%         [JLR JLP] = LoadJlrResults(subject,0,'10fold',[-500 500],sprintf('_sigma1_lambda%1.e_v2p3_condoff',lambda(i)));    
        [JLR JLP] = LoadJlrResults(subject,0,'79fold',[-500 500],sprintf('_lambda_%1.2e',lambda(i)));    
        JLRavg = AverageJlrResults(JLR,JLP);
        jlrAz(i) = JLR.Azloo;
%         jlrFM(:,i) = JLRavg.fwdmodels(:,1);
%         jlrFM(:,i) = JLRavg.vout(1,1:end-1)';
        jlrFM(:,i) = JLRavg.vout(1:end-1);
        jlrPost(:,:,i) = JLRavg.post_avg;
    try
        [JLR2 JLP2] = LoadJlrResults(subject,0,'10fold',[-500 500],sprintf('_sigma1_lambda%1.e_v2p3_prioroff2',lambda(i)));    
        JLRavg2 = AverageJlrResults(JLR2,JLP2);
        jlrAz2(i) = JLR2.Azloo;
%         jlrFM(:,i) = JLRavg.fwdmodels(:,1);
        jlrFM2(:,i) = JLRavg2.vout(1:end-1);
        jlrPost2(:,:,i) = JLRavg2.post;
    end

        
        %     end
end

%% Just JLR
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
subplot(4,1,1);
plot(x,jlrAz,'.-')
xlabel('log_1_0(\\lambda)')
ylabel('testing Az')
legend('JLR')
title('Classification dependence on regularization term ~200ms pre-response')
for i=1:numel(lambda)
%     subplot(6,numel(lambda),numel(lambda)+i);
%     topoplot(stimFM(:,i),JLP.ALLEEG(1).chanlocs);
%     colorbar
%     title(sprintf('Spatial Weights v\n\\lambda = %1.e',lambda(i)))
%     if i==1
%         ylabel('stim-locked LR','visible','on')
%     end
    subplot(8,numel(lambda)/2,numel(lambda)+i);
    topoplot(jlrFM(:,i),JLP.ALLEEG(1).chanlocs);
    colorbar  
    title(sprintf('/lambda = %1.2e',lambda(i)));
    if i==1
        ylabel('JLR','visible','on')
    end
    subplot(4,numel(lambda)/2,numel(lambda)+i);
    ImageSortedData(jlrPost(faces,:,i),JLRavg.postTimes,faces,jitter(faces));
    ImageSortedData(jlrPost(cars,:,i),JLRavg.postTimes,cars,jitter(cars));
    set(gca,'clim',[0 0.01])
    ylim([0.5,size(JLRavg.post,1)+0.5])
    if length(JLRavg.postTimes)>1
        xlim([JLRavg.postTimes(1) JLRavg.postTimes(end)])
    end
%     title('Posteriors: p(t_i|y_i)');   
    title(sprintf('/lambda = %1.2e',lambda(i)));
    xlabel('time from window center (ms)')    
end

subplot(4,numel(lambda)/2,numel(lambda)+1)
% subplot(5,nWin,4*nWin+1)
if ~isempty(strfind(JLP.ALLEEG(1).setname,'_F_'));
    ylabel('<-- faces     |     cars -->')
else
    ylabel('<-- cars     |     faces -->')
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
bar(x,[stimAz;jlrAz]')
xlabel('log_1_0(\\lambda)')
ylabel('10-fold Az')
legend('stimulus-locked LR','JLR')
title('Classification dependence on regularization term ~200ms pre-response')
for i=1:numel(lambda)
    subplot(6,numel(lambda),numel(lambda)+i);
    topoplot(stimFM(:,i),JLP.ALLEEG(1).chanlocs);
    colorbar
    title(sprintf('Spatial Weights v\n\\lambda = %1.e',lambda(i)))
    if i==1
        ylabel('stim-locked LR','visible','on')
    end
    subplot(6,numel(lambda),2*numel(lambda)+i);
    topoplot(jlrFM(:,i),JLP.ALLEEG(1).chanlocs);
    colorbar        
    if i==1
        ylabel('JLR','visible','on')
    end
    subplot(2,numel(lambda),numel(lambda)+i);
    ImageSortedData(jlrPost(faces,:,i),JLRavg.postTimes,faces,jitter(faces));
    ImageSortedData(jlrPost(cars,:,i),JLRavg.postTimes,cars,jitter(cars));
    set(gca,'clim',[0 0.01])
    ylim([0.5,size(JLRavg.post,1)+0.5])
    if length(JLRavg.postTimes)>1
        xlim([JLRavg.postTimes(1) JLRavg.postTimes(end)])
    end
    title('Posteriors: p(t_i|y_i)');   
    xlabel('time from window center (ms)')    
end

subplot(2,numel(lambda),numel(lambda)+1)
% subplot(5,nWin,4*nWin+1)
if ~isempty(strfind(JLP.ALLEEG(1).setname,'_F_'));
    ylabel('<-- faces     |     cars -->')
else
    ylabel('<-- cars     |     faces -->')
end

%% JLR vs. JLR
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
subplot(5,1,1);
bar(x,[stimAz;jlrAz]')
xlabel('log_1_0(\\lambda)')
ylabel('10-fold Az')
legend('stimulus-locked LR','JLR')
title('Classification dependence on regularization term ~200ms pre-response')
for i=1:numel(lambda)
    subplot(5,numel(lambda),numel(lambda)+i);
    topoplot(stimFM(:,i),JLP.ALLEEG(1).chanlocs);
    colorbar
    title(sprintf('Spatial Weights v\n\\lambda = %1.e',lambda(i)))
    if i==1
        ylabel('stim-locked LR','visible','on')
    end
    subplot(5,numel(lambda),2*numel(lambda)+i);
    topoplot(jlrFM(:,i),JLP.ALLEEG(1).chanlocs);
    colorbar        
    if i==1
        ylabel('JLR','visible','on')
    end
    
    subplot(5,numel(lambda),3*numel(lambda)+i);
    ImageSortedData(jlrPost(faces,:,i),JLRavg.postTimes,faces,jitter(faces));
    ImageSortedData(jlrPost(cars,:,i),JLRavg.postTimes,cars,jitter(cars));
    set(gca,'clim',[0 0.01])
    ylim([0.5,size(JLRavg.post,1)+0.5])
    if length(JLRavg.postTimes)>1
        xlim([JLRavg.postTimes(1) JLRavg.postTimes(end)])
    end
    title('Posteriors: p(t_i|y_i)');   
    
    subplot(5,numel(lambda),4*numel(lambda)+i);
    ImageSortedData(jlrPost2(faces,:,i),JLRavg.postTimes,faces,jitter(faces));
    ImageSortedData(jlrPost2(cars,:,i),JLRavg.postTimes,cars,jitter(cars));
    set(gca,'clim',[0 0.01])
    ylim([0.5,size(JLRavg.post,1)+0.5])
    if length(JLRavg.postTimes)>1
        xlim([JLRavg.postTimes(1) JLRavg.postTimes(end)])
    end
    xlabel('time from window center (ms)')    
end

subplot(5,numel(lambda),3*numel(lambda)+1)
if ~isempty(strfind(JLP.ALLEEG(1).setname,'_F_'));
    ylabel(sprintf('JLR w/ Prior\n<-- faces     |     cars -->'))
else
    ylabel(sprintf('JLR w/ Prior\n<-- faces     |     cars -->'))
end
subplot(5,numel(lambda),4*numel(lambda)+1)
if ~isempty(strfind(JLP.ALLEEG(1).setname,'_F_'));
    ylabel(sprintf('JLR w/o Prior\n<-- faces     |     cars -->'))
else
    ylabel(sprintf('JLR w/o Prior\n<-- faces     |     cars -->'))
end

