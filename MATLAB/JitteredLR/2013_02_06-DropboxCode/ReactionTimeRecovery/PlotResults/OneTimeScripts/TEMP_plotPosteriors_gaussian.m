% TEMP_plotPosteriors_gaussian.m
%
% Created 8/16/12 for one-time use.

%% 

% res = load('results_ao_ps_sti_noweightprior_10fold_jrange_-150_to_150/results_10fold.mat');
% [pt,truth,times,jitter] = GetFinalPosteriors_gaussian('results_ao_ps_sti_noweightprior_10fold_jrange_-150_to_150','10fold','ao_ps_sti');
% 
% % Load jittered data 
% par = load('results_ao_ps_sti_noweightprior_10fold_jrange_-150_to_150/params_10fold.mat');
% ALLEEG = par.ALLEEG;

%% 

res = load('results_an02apr04_noweightprior_10fold_jrange_-200_to_200/results_10fold.mat');
[pt,truth,times,jitter] = GetFinalPosteriors_gaussian('results_an02apr04_noweightprior_10fold_jrange_-200_to_200','10fold','an02apr04');

% Load jittered data 
par = load('results_an02apr04_noweightprior_10fold_jrange_-200_to_200/params_10fold.mat');
ALLEEG = par.ALLEEG;



%%
clf;
trial = 1:size(pt{1},1);
for i=1:10
    [~, iMax] = max(pt{i},[],2);
    tMax = times(iMax);
    subplot(5,4,2*i-1); 
    topoplot(res.fwdmodels{i},ALLEEG(1).chanlocs);
    colorbar;
    title(sprintf('Forward Model, slice %d',i));    
    subplot(5,4,2*i);
    cla; hold on;
    imagesc(times,trial,pt{i});  
    title(sprintf('Posterior, slice %d',i));
    plot(jitter,trial,'k.');
    plot(tMax,trial,'r.');
    plot([0 0],[trial(1) trial(end)],'k--');
    xlim([times(1) times(end)]);
    ylim([trial(1) trial(end)]);
    legend('True jitter', 'Max Posterior');
    xlabel('jitter (ms)')
    ylabel('trial');
end

t = par.ALLEEG(par.setlist(1)).times(res.trainingwindowoffset);
MakeFigureTitle(sprintf('Subject an02apr04, %.1fms relative to response, JitterRange [%d %d]',...
    t,res.pop_settings_out(1).jitterrange(1),res.pop_settings_out(1).jitterrange(2)));

%%
clf;
trial = 1:size(pt{1},1);
[~, iMax] = max(pt{1},[],2);
tMax = times(iMax);

subplot(1,2,1); 
topoplot(res.fwdmodels{1},ALLEEG(1).chanlocs);
colorbar;
title('Forward Model, slice 1');    
subplot(1,2,2);
cla; hold on;

% Re-sort by RT
jitter(truth==1) = jitter(truth==1)+10000;
[jitternew, order] = sort(jitter,'ascend');
jitter(truth==1) = jitter(truth==1)-10000;
jitternew(truth(order)==1) = jitternew(truth(order)==1)-10000;
tMaxnew = tMax(order);
ptnew = pt{1}(order,:);


imagesc(times,trial,ptnew);  
title('Posterior, slice 1');
plot(jitternew,trial,'k.');
plot(tMaxnew,trial,'r.');
plot([0 0],[trial(1) trial(end)],'k--');
xlim([times(1) times(end)]);
ylim([trial(1) trial(end)]);
legend('True jitter', 'Max Posterior');
xlabel('jitter (ms)')
ylabel('trial');

t = par.ALLEEG(par.setlist(1)).times(res.trainingwindowoffset);
MakeFigureTitle(sprintf('Subject an02apr04, %.1fms relative to response, JitterRange [%d %d]',...
    t,res.pop_settings_out(1).jitterrange(1),res.pop_settings_out(1).jitterrange(2)));