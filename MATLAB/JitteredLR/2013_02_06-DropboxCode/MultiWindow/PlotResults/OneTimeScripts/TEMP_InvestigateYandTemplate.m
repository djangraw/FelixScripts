
% Created 1/7/12 by DJ for one-time use.

i=5;
iWin = 6;

% Get data
raweeg = cat(3,JLP{i}.ALLEEG(1).data,JLP{i}.ALLEEG(2).data);
N = size(raweeg,3);
% Smooth data
X = nan(size(raweeg,1),size(raweeg,2)-JLR{i}.trainingwindowlength+1, N);
for k=1:N
     X(:,:,k) = conv2(raweeg(:,:,k),ones(1,JLR{i}.trainingwindowlength)/JLR{i}.trainingwindowlength,'valid'); % valid means exclude zero-padded edges without full overlap
end
t = JLP{i}.ALLEEG(1).times;
X2 = X;
X2(end+1,:,:) = 1;


Y = zeros(N,size(X2,2));
for j=1:JLP{i}.cv.numFolds
    test_trials = [JLP{i}.cv.valTrials1{j}, JLP{i}.cv.valTrials2{j} + JLP{i}.ALLEEG(1).trials];
    for k=1:numel(test_trials)
        Y(test_trials(k),:) = JLR{i}.vout{j}(:,iWin)'*X2(:,:,test_trials(k));
    end
end
% 
% for j=1:size(X2,3)
%     Y(j,:) = V(:,iWin)'*X2(:,:,j);
% end

figure(336); clf;
subplot(2,2,1);
t2 = t(1:size(Y,2))+JLR{i}.trainingwindowlength/2;
twin = t2(JLR{i}.trainingwindowoffset(iWin)); % window start
cla; hold on;
imagesc(t2,1:size(Y,1),Y)
plot([twin twin],get(gca,'ylim'),'k');
colorbar
clim = get(gca,'clim');

subplot(2,4,3); cla; hold on;
plot(Y(:,JLR{i}.trainingwindowoffset(iWin)),1:size(Y,1),'b.-');
plot([0 0], get(gca,'ylim'), 'k');

plot(JLRavg{i}.pred(:,iWin),1:size(Y,1),'r.-');

subplot(2,4,4); cla; hold on;
chanlocs = JLP{i}.ALLEEG(1).chanlocs;
topoplot(JLRavg{i}.vout(1:numel(chanlocs),iWin),chanlocs);
colorbar;
title(sprintf('subject = %d, iWin = %d',i,iWin))

%%
tWin_template = [100 500];
% tWin_template = [-400 0];
% plot template matching measure
isInWin = JLP{i}.ALLEEG(1).times > tWin_template(1) & JLP{i}.ALLEEG(1).times < tWin_template(2);
% template = mean(X2(:,isInWin,:),3);
% matchStrength = UpdateTemplateMatchStrength(X2,template);

[template,data] = GetEegTemplate(JLP{i}.ALLEEG,'Cz',tWin_template,JLR{i}.trainingwindowlength);
matchStrength = UpdateTemplateMatchStrength(data,template);

subplot(2,2,3); cla; hold on;
tMatch = JLP{i}.ALLEEG(1).times(1:size(matchStrength,2))-tWin_template(1);
imagesc(tMatch,1:size(matchStrength,1),matchStrength);
colorbar


%%

[t_ok, isok_t2, isok_tMatch] = intersect(t2-twin,tMatch);
subplot(2,2,4); cla; hold on;
colorthing = zeros(N,length(t_ok),3);
colorthing(:,:,1) = Y(:,isok_t2)/max(max(Y(:,isok_t2)));
colorthing(:,:,2) = matchStrength(:,isok_tMatch)/max(max(matchStrength(:,isok_tMatch)));
colorthing(colorthing<0) = 0;
imagesc(t_ok,1:N,colorthing);

%%
trials = [1:8 N-7:N];

figure(337); clf;
for iTrial = 1:numel(trials)
    subplot(4,4,iTrial); cla; hold on;
    plot(tMatch,matchStrength(trials(iTrial),:)*1000);
    plot(t2-twin,Y(trials(iTrial),:),'r');
    plot([0 0],get(gca,'ylim'),'k')
    title(sprintf('trial %d',trials(iTrial)))
end
