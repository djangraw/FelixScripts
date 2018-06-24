i = 1; % subject

V = JLRavg{i}.vout;
raweeg = cat(3,JLP{i}.ALLEEG(1).data,JLP{i}.ALLEEG(2).data);
N = size(raweeg,3);
[jitter,truth] = GetJitter(JLP{i}.ALLEEG,'facecar');
% Smooth data
X = nan(size(raweeg,1),size(raweeg,2)-JLR{i}.trainingwindowlength+1, N);
for k=1:N
     X(:,:,k) = conv2(raweeg(:,:,k),ones(1,JLR{i}.trainingwindowlength)/JLR{i}.trainingwindowlength,'same'); % valid means exclude zero-padded edges without full overlap
end
t = JLP{i}.ALLEEG(1).times;

figure(1); clf;
for j=1:size(V,2) % window
    subplot(2,10,j); cla; hold on;
    yval = nan(size(X,3),size(X,2));    
    for k=1:N
        yval(k,:) = V(1:end-1,j)'*X(:,:,k) + V(end,j);
    end
    imagesc(t,1:size(X,3),yval);
    axis([0,1500,0,size(yval,1)])
    twin = t(JLR{i}.trainingwindowoffset(j)); % window start
    plot([twin twin],get(gca,'ylim'),'k');
    plot([twin twin]+JLR{i}.trainingwindowlength,get(gca,'ylim'),'k');
%     colorbar
    set(gca,'clim',[-8 8])
    subplot(2,10,10+j); cla; hold on;
    histx = -5:.5:5;
    n0 = hist(yval(truth==0,JLR{i}.trainingwindowoffset(j)),histx);
    n1 = hist(yval(truth==1,JLR{i}.trainingwindowoffset(j)),histx);
    plot(histx,[n0;n1]');
end

%%
X2 = X;
X2(end+1,:,:) = 1;
newoffset = JLR{i}.trainingwindowoffset - JLR{i}.trainingwindowoffset(1)+1;
T = size(X,2)-newoffset(end);
Vbig = nan(size(V,1),newoffset(end));
Vbig(:,newoffset) = V;
prior = ones(N,T)/T;
[jp,pval,winjp,winpval] = computeJitterProbabilities_v1p2(X2,Vbig,truth,prior,0);

%%
t = JLP{i}.ALLEEG(1).times;
twin = -JLR{i}.trainingwindowlength/2; % window start

figure(2); clf;
cla; hold on;
imagesc(t((1:T)+round(newoffset(end)/2)),1:N,jp);
colorbar;
plot([twin twin],get(gca,'ylim'),'k');
plot([twin twin]+JLR{i}.trainingwindowlength,get(gca,'ylim'),'k');



figure(3); clf;
for j=1:size(winjp,3)
    subplot(3,4,j); cla; hold on;
    imagesc(t((1:T)+round(newoffset(end)/2)),1:N,winjp(:,:,j));
    axis([t(1+round(newoffset(end)/2)),t(T+round(newoffset(end)/2)),0,N])    
    plot([twin twin],get(gca,'ylim'),'k');
    plot([twin twin]+JLR{i}.trainingwindowlength,get(gca,'ylim'),'k');
    colorbar
end