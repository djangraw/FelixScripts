% CompareJlrAnalyses_script.m
%
% Produce various plots to compare JLR to its competition: stim-locked LR,
% resp-locked LR, Woody algorithm, and JLR with alternative parameters.
%
% Created 12/6/12 by DJ.
% Updated various times until 1/14/13 by DJ.
% Updated 1/15/13 by DJ - comments

%% Load JLR data
subjects = {'an02apr04', 'jeremy15jul04','paul21apr04','robin30jun04','vivek23jun04','jeremy29apr04'};
% jlrtags = {'exgauss_offset_NOcondprior', 'exgauss_offset_condprior', 'pcatemplate_-400to0_offset_NOcondprior', 'pcatemplate_-400to0_offset_condprior', 'pcatemplatemax_-400to0_offset_condprior', 'pcatemplatemax_-300to200_offset_condprior', 'matchex_nooffset_condprior'};
% jlrtags = {'pcatemplate_-500to-100_offset_NOcondprior', 'pcatemplate_-400to0_offset_NOcondprior', 'pcatemplate_-300to200_offset_NOcondprior', 'pcatemplate_-200to200_offset_NOcondprior', 'pcatemplate_-100to300_offset_NOcondprior', 'pcatemplatemax_-400to0_offset_condprior', 'pcatemplatemax_-300to200_offset_condprior'};
jlrtags = {{'10fold','pcatemplate_fixedpost_f1wON'},{'10fold','pcatemplateMAX_fixedpost_f1wON'}};
[Az, t, vout, fwdmodels] = CompileJlrResults_AcrossSubjects(subjects,jlrtags);
%% Load LR data
% stimtags = {'stimlocked_width50ms'};
% resptags = {'resplocked_width50ms'};
% stimtags = {'stimlocked_width50ms', 'stimlocked_width100ms', 'stimlocked_width200ms'};
% resptags = {'resplocked_width50ms', 'resplocked_width100ms', 'resplocked_width200ms'};
stimtags = {{'10fold','stimlockedLR'}};
resptags = {{'10fold','resplockedLR'}};
[Az_stim, t_stim, vout_stim, fwdmodels_stim] = CompileJlrResults_AcrossSubjects(subjects,stimtags);
[Az_resp, t_resp, vout_resp, fwdmodels_resp] = CompileJlrResults_AcrossSubjects(subjects,resptags);

%% Get JLR Data
% jlrtags = {'pcatemplate_fixedpost'};
[JLR, JLP] = LoadJlrResults_AcrossSubjects(subjects,jlrtags{1});
JLRavg = cell(size(JLR));
for i=1:numel(JLR)
    JLRavg{i} = AverageJlrResults(JLR{i},JLP{i});
end

%% Get true response times
RTall = cell(1,numel(JLP));
for i=1:numel(subjects)
    [~,~,RTall{i}] = GetJitter(JLP{i}.ALLEEG,'facecar');
end

%% Plot mean Azs across subjects
figure(301); clf;
% tMean = permute(mean(t,1),[2,3,1]);
% AzMean = permute(mean(Az,1),[2,3,1]);
tMean = -700:0;
t_stimMean = tMean+mean([RTall{:}]);
[AzMean,~,AzInterp] = InterpolateJlrResults(Az,t,tMean);
[Az_respMean,~,Az_respInterp] = InterpolateJlrResults(Az_resp,t_resp,tMean);
Az_stimMean = InterpolateJlrResults(Az_stim,t_stim,t_stimMean);
[hStim,hResp] = SetUpJlrAzPlot(t_stimMean,tMean);


% Perform stats on Az values
[h,p] = ttest(AzInterp(:,:,1)',AzInterp(:,:,1)',0.05/10);
% [p,h] = deal(nan(1,size(AzInterp,1)));
% for i=1:size(AzInterp,1)
%     if all(~isnan(AzInterp(i,:)))        
%         [p(:,i),h(:,i)] = signrank(AzInterp(i,:)',Az_respInterp(i,:)','alpha',0.05);
%     end
% end

% Plot Stats results as rectangles
diff_h = diff([0 h 0]);
tUps = tMean(diff_h>0);
tDowns = tMean(diff_h<0);
for i=1:numel(tUps)
    rectangle('Position',[tUps(i) min(get(gca,'ylim')), tDowns(i)-tUps(i), range(get(gca,'ylim'))],...
        'FaceColor',[0.5 0.5 0.5],'EdgeColor',[0.5 0.5 0.5]);
end
% plot(hResp,tMean(h~=0),ones(1,sum(h))*0.3,'k.');

% Plot Az lines
% plot(hStim,t_stimMean,Az_stimMean,'--','linewidth',2)
plot(hResp,tMean,Az_stimMean,'--','linewidth',2)
plot(hResp,tMean,Az_respMean,':','linewidth',2)
plot(hResp,tMean,AzMean,'-','linewidth',2)
plot(hResp,get(hResp,'xlim'),[0.5 0.5],'k--');
plot(hResp,get(hResp,'xlim'),[0.75 0.75],'k:');



% Make Legend Tags
legendtags = [stimtags resptags jlrtags];
for i=1:numel(legendtags)
    if iscell(legendtags{i})
        legendtags{i} = legendtags{i}{end};
    end
end
legend(hResp,show_symbols(legendtags));
title(hStim,'All Subjects')

%% Plot Azs for single subjects
figure(302); clf;
nSubjects = numel(subjects);
nCols = ceil(sqrt(nSubjects));
nRows = ceil(nSubjects/nCols);
for iSubj = 1:numel(subjects)
    subplot(nRows,nCols,iSubj);
%     tSubj = squeeze(t(iSubj,:,:));
%     AzSubj = squeeze(Az(iSubj,:,:));
    [hStim,hResp] = SetUpJlrAzPlot(t_stimMean,tMean);

%     plot(hStim,squeeze(t_stim(iSubj,:,:)),squeeze(Az_stim(iSubj,:,:)),'b.--','linewidth',2)
    plot(hResp,squeeze(t_stim(iSubj,:,:)-mean(RTall{i})),squeeze(Az_stim(iSubj,:,:)),'.--','linewidth',2)
    plot(hResp,squeeze(t_resp(iSubj,:,:)),squeeze(Az_resp(iSubj,:,:)),'.:','linewidth',2)
    plot(hResp,squeeze(t(iSubj,:,:)),squeeze(Az(iSubj,:,:)),'.-','linewidth',2)
    legend(show_symbols(legendtags),'Location','NorthWest');
    title(hStim,sprintf('Subject %d',iSubj))
end

%% Display fwd models
figure(303); clf;
chanlocs = JLP{1}.ALLEEG.chanlocs;
tPlots = (-500:50:-50)+25;
% [AzMean,fwdmodelsMean] = InterpolateJlrResults(Az,t,tPlots,fwdmodels);
[AzMean,fwdmodelsMean] = InterpolateJlrResults(Az,t,tPlots,vout);

nCols = numel(tPlots);
nRows = size(fwdmodelsMean,3);
for i=1:nRows
    for j=1:nCols
        subplot(nRows,nCols,(i-1)*nCols+j);
        topoplot(fwdmodelsMean(:,j,i),chanlocs);
%         colorbar;
        title(sprintf('%d ms',round(tPlots(j))));
        if j==1
            ylabel(show_symbols(jlrtags{i}),'Visible','on');
        end
    end
end

%% Display stim and resp fwd models
figure(304); clf;
chanlocs = JLP{1}.ALLEEG.chanlocs;
tPlots_resp = (-500:50:-50)+25;
tPlots_stim = tPlots_resp+mean([RTall{:}]);
% [AzMean_stim,fwdmodelsMean_stim] = InterpolateJlrResults(Az_stim,t_stim,tPlots_stim,fwdmodels_stim);
% [AzMean_resp,fwdmodelsMean_resp] = InterpolateJlrResults(Az_resp,t_resp,tPlots_resp,fwdmodels_resp);
[AzMean_stim,fwdmodelsMean_stim] = InterpolateJlrResults(Az_stim,t_stim,tPlots_stim,vout_stim);
[AzMean_resp,fwdmodelsMean_resp] = InterpolateJlrResults(Az_resp,t_resp,tPlots_resp,vout_resp);

nCols = numel(tPlots_resp);
for j=1:nCols
    subplot(2,nCols,j);
    topoplot(fwdmodelsMean_stim(:,j),chanlocs);
%     colorbar;
    title(sprintf('%d ms',round(tPlots_stim(j))));
    if j==1
        ylabel('Stim-Locked','Visible','on');
    end
    subplot(2,nCols,nCols+j);
    topoplot(fwdmodelsMean_resp(:,j),chanlocs);
%     colorbar;
    title(sprintf('%d ms',round(tPlots_resp(j))));
    if j==1
        ylabel('Resp-Locked','Visible','on');
    end
end



%% Display Priors
figure(310); clf;    
for i=1:numel(JLRavg)
    subplot(1,6,i); cla;
    ptprior = JLP{i}.scope_settings.jitter_fn((1000/JLP{i}.ALLEEG(1).srate)*((JLP{i}.scope_settings.jitterrange(1)+1):JLP{i}.scope_settings.jitterrange(2)),JLP{i}.scope_settings.jitterparams);
    jitter = GetJitter(JLP{i}.ALLEEG,'facecar');
    if ~isempty(strfind(JLP{i}.ALLEEG(1).setname,'_F_'));
        faces = find(JLRavg{i}.truth==0);
        cars = find(JLRavg{i}.truth==1);
    else
        cars = find(JLRavg{i}.truth==0);
        faces = find(JLRavg{i}.truth==1);
    end
    [~,iMax] = max(ptprior,[],2);
    [~,order] = ImageSortedData(ptprior(faces,:),JLRavg{i}.postTimes,faces,jitter(faces));    
    plot(JLRavg{i}.postTimes(iMax(faces(order))),faces,'m.');
    [~,order] = ImageSortedData(ptprior(cars,:),JLRavg{i}.postTimes,cars,jitter(cars));
    plot(JLRavg{i}.postTimes(iMax(cars(order))),cars,'m.');
    set(gca,'clim',[0 0.01]);% 0.005])
    ylim([0.5,size(JLRavg{i}.post,1)+0.5])
    if length(JLRavg{i}.postTimes)>1
        xlim([JLRavg{i}.postTimes(1) JLRavg{i}.postTimes(end)])
    end
    title(sprintf('Subject %d Priors:\np(t_i)',i));
    
    xlabel('time from window center (ms)')        
end

% colorbar('EastOutside');
subplot(1,6,1)
if ~isempty(strfind(JLP{i}.ALLEEG(1).setname,'_F_'));
    ylabel('<-- faces     |     cars -->')
else
    ylabel('<-- cars     |     faces -->')
end
MakeFigureTitle(sprintf(['Prior Probability of jitter times']));


%% Display Posteriors
for iWin=1:10
    figure(310+iWin); clf;    
for label = [0 1]    
    post_option = sprintf('post_%d',label);
    for i=1:numel(JLRavg)
        subplot(2,6,6*label+i); cla;
        jitter = GetJitter(JLP{i}.ALLEEG,'facecar');
        if ~isempty(strfind(JLP{i}.ALLEEG(1).setname,'_F_'));
            faces = find(JLRavg{i}.truth==0);
            cars = find(JLRavg{i}.truth==1);
        else
            cars = find(JLRavg{i}.truth==0);
            faces = find(JLRavg{i}.truth==1);
        end
        [~,iMax] = max(JLRavg{i}.(post_option)(:,:,iWin),[],2);
        [~,order] = ImageSortedData(JLRavg{i}.(post_option)(faces,:,iWin),JLRavg{i}.postTimes,faces,jitter(faces));    
        plot(JLRavg{i}.postTimes(iMax(faces(order))),faces,'m.');
        [~,order] = ImageSortedData(JLRavg{i}.(post_option)(cars,:,iWin),JLRavg{i}.postTimes,cars,jitter(cars));
        plot(JLRavg{i}.postTimes(iMax(cars(order))),cars,'m.');
        set(gca,'clim',[0 0.01]);% 0.005])
        ylim([0.5,size(JLRavg{i}.post,1)+0.5])
        if length(JLRavg{i}.postTimes)>1
            xlim([JLRavg{i}.postTimes(1) JLRavg{i}.postTimes(end)])
        end
        switch post_option
            case {'post_avg' 'post'}
                title(sprintf('Subject %d\nPosteriors given no label: \np(t_i|y_i)',i));   
            case 'post_truth'
                title(sprintf('Subject %d\nPosteriors given true label: \np(t_i|y_i,c_i)',i));   
            case 'post_pred'
                title(sprintf('Subject %d\nPosteriors given predicted label: \np(t_i|y_i,c''_i)',i));  
            case 'post_0'
                title(sprintf('Subject %d\nPosteriors given label 0: \np(t_i|y_i,c_i=0)',i));  
            case 'post_1'
                title(sprintf('Subject %d\nPosteriors given label 1: \np(t_i|y_i,c_i=1)',i));  
        end
        xlabel('time from window center (ms)')        
    end

    % colorbar('EastOutside');
    subplot(2,6,6*label+1)
    if ~isempty(strfind(JLP{i}.ALLEEG(1).setname,'_F_'));
        ylabel('<-- faces     |     cars -->')
    else
        ylabel('<-- cars     |     faces -->')
    end
end
MakeFigureTitle(sprintf(['Probability of jitter times given label\n'...
    'Window %d: ~%.0fms post-stim, ~%.0fms pre-resp'],...
    iWin,tPlots_stim(iWin),-tPlots_resp(iWin)));
end

%% Plot Match between MEAN forward models

figure(307); clf;
chanlocs = JLP{1}.ALLEEG.chanlocs;
nchan = numel(chanlocs);
tPlots = (-500:-50)+25;
tPlots_resp = tPlots;
tPlots_stim = tPlots_resp+mean([RTall{:}]);
[~,fwdmodelsMean,~,fmInterp] = InterpolateJlrResults(Az,t,tPlots,vout);
[~,fwdmodelsMean_stim,~,fmInterp_stim] = InterpolateJlrResults(Az_stim,t_stim,tPlots_stim,vout_stim);
[~,fwdmodelsMean_resp,~,fmInterp_resp] = InterpolateJlrResults(Az_resp,t_resp,tPlots_resp,vout_resp);

% Perform stats on Az values
[sub_jlrvsresp, sub_jlrvsstim, sub_respvsstim] = deal(zeros(numel(subjects),size(fmInterp,2)));
for j=1:numel(subjects)
    for i=1:size(fmInterp,2)
        sub_jlrvsresp(j,i) = subspace(fmInterp(1:nchan,i,j),fmInterp_resp(1:nchan,i,j));
        sub_jlrvsstim(j,i) = subspace(fmInterp(1:nchan,i,j),fmInterp_stim(1:nchan,i,j));
        sub_respvsstim(j,i) = subspace(fmInterp_resp(1:nchan,i,j),fmInterp_stim(1:nchan,i,j)); 
%         sub_jlrvsresp(j,i) = sqrt(norm(fmInterp(1:nchan,i,j)-fmInterp_resp(1:nchan,i,j)));
%         sub_jlrvsstim(j,i) = sqrt(norm(fmInterp(1:nchan,i,j)-fmInterp_stim(1:nchan,i,j)));
%         sub_respvsstim(j,i) = sqrt(norm(fmInterp_resp(1:nchan,i,j)-fmInterp_stim(1:nchan,i,j))); 
    end
end

% Perform stats test
[h,p] = ttest(sub_jlrvsstim,sub_jlrvsresp,0.05/10);
% Plot Stats results as rectangles
diff_h = diff([0 h 0]);
tUps = tPlots(diff_h>0);
tDowns = tPlots(diff_h<0);
cla; ylim([0 2]); hold on;
for i=1:numel(tUps)
    rectangle('Position',[tUps(i) min(get(gca,'ylim')), tDowns(i)-tUps(i), range(get(gca,'ylim'))],...
        'FaceColor',[0.5 0.5 0.5],'EdgeColor',[0.5 0.5 0.5]);
end

[sub_jlrvsresp, sub_jlrvsstim, sub_respvsstim] = deal(zeros(1,size(fwdmodelsMean,2)));
for i=1:size(fwdmodelsMean,2)
    sub_jlrvsresp(i) = subspace(fwdmodelsMean(1:nchan,i),fwdmodelsMean_resp(1:nchan,i));
    sub_jlrvsstim(i) = subspace(fwdmodelsMean(1:nchan,i),fwdmodelsMean_stim(1:nchan,i));
    sub_respvsstim(i) = subspace(fwdmodelsMean_resp(1:nchan,i),fwdmodelsMean_stim(1:nchan,i)); 
%     sub_jlrvsresp(i) = sqrt(norm(fwdmodelsMean(1:nchan,i)-fwdmodelsMean_resp(1:nchan,i)));
%     sub_jlrvsstim(i) = sqrt(norm(fwdmodelsMean(1:nchan,i)-fwdmodelsMean_stim(1:nchan,i)));
%     sub_respvsstim(i) = sqrt(norm(fwdmodelsMean_resp(1:nchan,i)-fwdmodelsMean_stim(1:nchan,i))); 

end
plot(tPlots,[sub_jlrvsresp; sub_jlrvsstim; sub_respvsstim]','-')


legend('JLR vs. resp','JLR vs. stim','resp vs. stim')
xlabel('time of window center r.t. response')
ylabel('subspace between average weights (across folds, subjects)')
title('Spatial Weight Matching Metric')

%% Plot match between subject-specific fwd models

figure(308); clf;
chanlocs = JLP{1}.ALLEEG.chanlocs;
nchan = numel(chanlocs);
tPlots = (-500:-50)+25;
tPlots_resp = tPlots;
tPlots_stim = tPlots_resp+mean([RTall{:}]);
[~,fwdmodelsMean,~,fmInterp] = InterpolateJlrResults(Az,t,tPlots,vout);
[~,fwdmodelsMean_stim,~,fmInterp_stim] = InterpolateJlrResults(Az_stim,t_stim,tPlots_stim,vout_stim);
[~,fwdmodelsMean_resp,~,fmInterp_resp] = InterpolateJlrResults(Az_resp,t_resp,tPlots_resp,vout_resp);

for j=1:numel(subjects)
    subplot(2,3,j); cla;
    [sub_jlrvsresp, sub_jlrvsstim, sub_respvsstim] = deal(zeros(1,size(fmInterp,2)));
    for i=1:size(fmInterp,2)
        sub_jlrvsresp(i) = subspace(fmInterp(1:nchan,i,j),fmInterp_resp(1:nchan,i,j));
        sub_jlrvsstim(i) = subspace(fmInterp(1:nchan,i,j),fmInterp_stim(1:nchan,i,j));
        sub_respvsstim(i) = subspace(fmInterp_resp(1:nchan,i,j),fmInterp_stim(1:nchan,i,j)); 
%         sub_jlrvsresp(i) = sqrt(norm(fmInterp(1:nchan,i,j)-fmInterp_resp(1:nchan,i,j)));
%         sub_jlrvsstim(i) = sqrt(norm(fmInterp(1:nchan,i,j)-fmInterp_stim(1:nchan,i,j)));
%         sub_respvsstim(i) = sqrt(norm(fmInterp_resp(1:nchan,i,j)-fmInterp_stim(1:nchan,i,j))); 

    end
    plot(tPlots,[sub_jlrvsresp; sub_jlrvsstim; sub_respvsstim]','-')
    legend('JLR vs. resp','JLR vs. stim','resp vs. stim')
    xlabel('time of window center r.t. response')
    ylabel('subspace between average weights (across folds)')
    title(sprintf('Subject %d, Spatial Weight Matching',j))
    ylim([0 2])
%     ylim([0 0.3])
end