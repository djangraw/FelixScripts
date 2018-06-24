% Created 1/7/13 by DJ for one-time use.
% Updated periodically until 1/14/13 by DJ.

jlrtags = {'10fold','cztemplate_f1wON'};
stimtags = {'10fold','stimlockedLR'};
[JLR, JLP] = LoadJlrResults_AcrossSubjects(subjects,jlrtags);
[JLRstim,JLPstim] = LoadJlrResults_AcrossSubjects(subjects,stimtags);

%% Set up
i = 5; % subject
iWin = 6; % window

%% Get prior for JLR
jitterrange = JLP{i}.scope_settings.jitterrange;
[prior,priortimes] = JLP{i}.scope_settings.jitter_fn((1000/JLP{i}.ALLEEG(1).srate)*((jitterrange(1)+1):jitterrange(2)),...
    JLP{i}.scope_settings.jitterparams);
[jitter,truth,RT] = GetJitter(JLP{i}.ALLEEG,'facecar');
faces = find(truth~=0);
cars = find(truth==0);
N = length(RT);

%% Get stim-locked y values from single window
% Get data
raweeg = cat(3,JLPstim{i}.ALLEEG(1).data,JLPstim{i}.ALLEEG(2).data);
% Smooth data
X = nan(size(raweeg));
for k=1:N
     X(:,:,k) = conv2(raweeg(:,:,k),ones(1,JLRstim{i}.trainingwindowlength)/JLRstim{i}.trainingwindowlength,'same'); % valid means exclude zero-padded edges without full overlap
end
tX = JLPstim{i}.ALLEEG(1).times;
X2 = X;
X2(end+1,:,:) = 1; %for easy multiplication with V
% tX = tX(1:size(X2,2))+JLRstim{i}.trainingwindowlength/2; % corresponding times

% Get y values
W = size(JLRstim{i}.vout{1},2); % # windows
Y = zeros(N,size(X2,2),W);
tY = zeros(W,size(tX,2));
for w=1:W
    for j=1:JLPstim{i}.cv.numFolds
        test_trials = [JLPstim{i}.cv.valTrials1{j}, JLPstim{i}.cv.valTrials2{j} + JLPstim{i}.ALLEEG(1).trials];
        for k=1:numel(test_trials)
%             Y(test_trials(k),:,w) = JLRstim{i}.vout{j}(:,w)'*X2(:,:,test_trials(k));
            Y(test_trials(k),:,w) = JLR{i}.vout{j}(:,w)'*X2(:,:,test_trials(k));
        end
    end
    tY(w,:) = tX-tX(JLRstim{i}.trainingwindowoffset(w)) - round(JLRstim{i}.trainingwindowlength/2)+1; % tY=0 indicates training window center time
end


%% Get training-style jitter probability calculations using stim-locked weights
newoffset = JLRstim{i}.trainingwindowoffset - min(JLRstim{i}.trainingwindowoffset)+1; % indices of v
D = size(X2,1);
v = zeros(D,newoffset(end));
T = size(X2,2)-size(v,2);
ptprior = ones(N,T)/T; % uniform prior
labels = [zeros(1,JLPstim{i}.ALLEEG(1).trials), ones(1,JLPstim{i}.ALLEEG(2).trials)];
JP0 = zeros(N,T);
JP1 = zeros(N,T);
for j=1:JLPstim{i}.cv.numFolds
    test_trials = [JLPstim{i}.cv.valTrials1{j}, JLPstim{i}.cv.valTrials2{j} + JLPstim{i}.ALLEEG(1).trials];
    v(:,newoffset) = JLRstim{i}.vout{j};

%     JP(test_trials,:) = computeJitterProbabilities_v1p2(X2(:,:,test_trials),v,labels(test_trials),ptprior(test_trials,:),0);
    JP0(test_trials,:) = computeJitterProbabilities_v1p2(X2(:,:,test_trials),v,zeros(size(test_trials)),ptprior(test_trials,:),0);
    JP1(test_trials,:) = computeJitterProbabilities_v1p2(X2(:,:,test_trials),v,ones(size(test_trials)),ptprior(test_trials,:),0);
%     for k=1:numel(test_trials)
%         Y(test_trials(k),:,w) = JLRstim{i}.vout{j}(:,w)'*X2(:,:,test_trials(k));
%     end
end
tJP = tX((1:T)+round(size(v,2)/2));


%% Plot JLR prior
figure(445); clf;
MakeFigureTitle(sprintf('Subject %d, %s priors, %s y values',i,jlrtags{end},stimtags{end}));

subplot(2,2,1); cla; hold on;
[sorteddata] = ImageSortedData(prior(cars,:),priortimes,1:length(cars),jitter(cars));
[~,iMax] = max(sorteddata,[],2);
plot(priortimes(iMax),1:length(cars),'m.');
[sorteddata] = ImageSortedData(prior(faces,:),priortimes,(1:length(faces))+length(cars),jitter(faces));
[~,iMax] = max(sorteddata,[],2);
plot(priortimes(iMax),(1:length(faces))+length(cars),'m.');
axis([priortimes(1) priortimes(end) 1 N])
colorbar
xlabel('time from response (ms)')
ylabel('<-- cars   |   faces -->')
title('response-locked JLR prior')

subplot(2,2,2); cla; hold on;
tYplot = tX;%tY(iWin,:) + tX(JLRstim{i}.trainingwindowoffset(iWin));
ImageSortedData(Y(cars,:,iWin),tYplot,1:length(cars),RT(cars),'descend');
ImageSortedData(Y(faces,:,iWin),tYplot,(1:length(faces))+length(cars),RT(faces),'descend');
plot([1 1]*tX(JLRstim{i}.trainingwindowoffset(iWin)),get(gca,'ylim'),'k--')
axis([tYplot(1) tYplot(end) 1 N])
colorbar
xlabel ('time from stimulus (ms)')
ylabel('<-- cars   |   faces -->')
title(sprintf('stim-locked Y values from window %d',iWin));

subplot(2,2,3); cla; hold on;
ImageSortedData(JP0(cars,:),tJP,1:length(cars),RT(cars),'descend');
ImageSortedData(JP0(faces,:),tJP,(1:length(faces))+length(cars),RT(faces),'descend');
axis([tJP(1) tJP(end) 1 N])
colorbar
xlabel ('time from stimulus (ms)')
ylabel('<-- cars   |   faces -->')
title('Jitter Probabilities given all weights, assuming c=0')

subplot(2,2,4); cla; hold on;
ImageSortedData(JP1(cars,:),tJP,1:length(cars),RT(cars),'descend');
ImageSortedData(JP1(faces,:),tJP,(1:length(faces))+length(cars),RT(faces),'descend');
axis([tJP(1) tJP(end) 1 N])
colorbar
xlabel ('time from stimulus (ms)')
ylabel('<-- cars   |   faces -->')
title('Jitter Probabilities given all weights, assuming c=1')

%% Plot single-window y values from stim-locked analysis
figure(446); clf;
MakeFigureTitle(sprintf('Subject %d, %s y values',i,stimtags{end}));

for w=1:W

    subplot(3,4,w); cla; hold on;
    tYplot = tX;%tY(iWin,:) + tX(JLRstim{i}.trainingwindowoffset(iWin));
    ImageSortedData(Y(cars,:,w),tYplot,1:length(cars),RT(cars),'descend');
    ImageSortedData(Y(faces,:,w),tYplot,(1:length(faces))+length(cars),RT(faces),'descend');
    plot([1 1]*tX(JLRstim{i}.trainingwindowoffset(w)),get(gca,'ylim'),'k--')
    axis([tYplot(1) tYplot(end) 1 N])
    colorbar
    xlabel ('time from stimulus (ms)')
    ylabel('<-- cars   |   faces -->')
    title(sprintf('Y values from window %d',w));

end


%% plot JLR prior, single-window y values, and cross-window jitter probabilities
trials = [1:8 N-7:N];

figure(447); clf;
MakeFigureTitle(sprintf('Subject %d, %s y values, %s templates',i,stimtags{end},jlrtags{end}));

for k = 1:numel(trials)
    subplot(4,4,k); cla; hold on;
    plot(priortimes,prior(trials(k),:));
    isInWin = tY(iWin,:)+jitter(trials(k))>=priortimes(1) & tY(iWin,:)+jitter(trials(k))<=priortimes(end);    
%     plot(tY(isInWin)-mean(RT),Y(trials(k),isInWin),'r');
%     isInWin = 1:length(tY);
    plot(tY(iWin,isInWin)+jitter(trials(k)),Y(trials(k),isInWin,iWin)/1000,'r');
    isInWin = tJP+jitter(trials(k))>=priortimes(1) & tJP+jitter(trials(k))<=priortimes(end);
    plot(tJP(isInWin)+jitter(trials(k)),JP0(trials(k),isInWin),'g');
    plot(tJP(isInWin)+jitter(trials(k)),JP1(trials(k),isInWin),'c');
    plot([0 0],get(gca,'ylim'),'k')
    plot([1 1]*jitter(trials(k)),get(gca,'ylim'),'m');
    title(sprintf('trial %d',trials(k)))
end
legend('Cz template prior',sprintf('v*x (window %d)',iWin),'JitterProb | c=0', 'JitterProb | c=1')

%% single-window y values for all windows
trials = [1:8 N-7:N];

figure(448); clf;
MakeFigureTitle(sprintf('Subject %d, %s y values',i,stimtags{end}));
colors = {'b-','r-','g-','c-','m-','b--','r--','g--','c--','m--'};
for k = 1:numel(trials)
    subplot(4,4,k); cla; hold on;
    for w=1:W
        isInWin = tY(w,:)+jitter(trials(k))>=priortimes(1) & tY(w,:)+jitter(trials(k))<=priortimes(end);    
    %     plot(tY(isInWin)-mean(RT),Y(trials(k),isInWin),'r');
    %     isInWin = 1:length(tY);
        plotY(w,:) = Y(trials(k),isInWin,w);
        plot(tY(w,isInWin)+jitter(trials(k)),Y(trials(k),isInWin,w)/1000,colors{w});
    end
    [~,p0] = ttest(plotY,0,0.05,'left');   
    [~,p1] = ttest(plotY,0,0.05,'right');   
    meanY = mean(plotY,1);    
    plot(tY(w,isInWin)+jitter(trials(k)),p0/100,'b','linewidth',2);
    plot(tY(w,isInWin)+jitter(trials(k)),p1/100,'r','linewidth',2);
    plot(tY(w,isInWin)+jitter(trials(k)),meanY/1000,'k','linewidth',2);
    plot([0 0],get(gca,'ylim'),'k')
    plot(get(gca,'xlim'),[0 0],'k')
    plot([1 1]*jitter(trials(k)),get(gca,'ylim'),'m');
    title(sprintf('trial %d',trials(k)))    
end

%% quick check on Az values
clear p Az
for w=1:W    
    for k=1:N    
        p(k,w) = Y(k,tY(w,:)==0,w);
    end
    Az(w) = rocarea(p(:,w),truth);
end

if isequal(JLRstim{i}.Azloo,Az)
    disp('Stim-locked Az values match these calculations.')
else
    disp('WARNING: Az values DO NOT match!!!');
end