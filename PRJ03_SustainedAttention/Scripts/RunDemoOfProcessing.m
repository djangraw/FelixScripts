function RunDemoOfProcessing(nSubj,nRois,nT)
%%
% while 1
%% Get activity and FC
load('DemoOfProcessing_data.mat'); % loads act and behavior
[nRois,nT,nSubj] = size(act);

% act = randn(nRois,nT,nSubj);
% behavior = randn(nSubj,1);

fcClim=0.2;

FC = nan(nRois,nRois,nSubj);
for i=1:nSubj
    [r,p] = corr(act(:,:,i)','rows','pairwise');
    FC(:,:,i) = atanh(r);
end
FC = UnvectorizeFc(VectorizeFc(FC),1,true);
% plot
figure(111); set(gcf,'Position',[3   923   759   321]); clf;
subplot(2,2,1);
plot(act(1,:,1));
set(gca,'xtick',[],'ytick',[]);
xlabel('time')
ylabel('activity')
subplot(2,2,3);
plot(act(2,:,1));
set(gca,'xtick',[],'ytick',[]);
xlabel('time')
ylabel('activity')
subplot(1,2,2);
imagesc(FC(:,:,1));
set(gca,'clim',[-1 1]*fcClim);
axis square
colorbar;
colormap gray
set(gca,'xtick',[],'ytick',[]);
xlabel('ROI')
ylabel('ROI');

figure(112); set(gcf,'Position',[660   843   331   492]); clf;
for i=1:nSubj
    subplot(nSubj,1,i);
    imagesc(FC(:,:,i));
    set(gca,'clim',[-1 1]*fcClim);
    axis square
    colorbar;
    colormap gray
    set(gca,'xtick',[],'ytick',[]);
%     xlabel('ROI')
%     ylabel('ROI');
end

% Get correlation with behavior
FC_vec = VectorizeFc(FC);
nEdges = size(FC_vec,1);
[cp,cr] = deal(nan(nEdges,nSubj));
n_train_sub = nSubj-1;
thresh = 0.3;
for i=1:nSubj
    iTrain = [1:(i-1) (i+1):nSubj];
    for j=1:nEdges
        [~,stats] = robustfit(FC_vec(j,iTrain),behavior(iTrain));
        cp(j,i)    = stats.p(2);
        cr(j,i)    = sign(stats.t(2))*sqrt((stats.t(2)^2/(n_train_sub-2))/(1+(stats.t(2)^2/(n_train_sub-2))));
    end
end
cr_mat = UnvectorizeFc(cr,0,true);
cp_mat = UnvectorizeFc(cp,nan,true);
%% plot
figure(1125); set(gcf,'Position',[1220         922         319         308]); clf;
[p,Rsq,lm] = Run1tailedRegression(FC_vec(1,2:end),behavior(2:end),true);
hPlot = lm.plot;
delete(hPlot(3:4));
set(gca,'xtick',[],'ytick',[]);
xlabel('FC');
ylabel('Behavioral Measure')
% set(hPlot(1),'marker','.','markersize',10);
legend('Participant','Linear Fit');
xlim([-1 1]*.15);
ylim([0 1]);
title('');

%%
figure(113); set(gcf,'Position',[995   843   650   492]); clf;
for i=1:nSubj
    subplot(nSubj,3,i*3-2);
    imagesc(cr_mat(:,:,i));
    set(gca,'clim',[-1 1]*1);
    axis square
    colorbar;
    colormap jet
    set(gca,'xtick',[],'ytick',[]);
%     xlabel('ROI')
%     ylabel('ROI');

    subplot(nSubj,3,i*3-1);
    imagesc((cp_mat(:,:,i)<thresh).*sign(cr_mat(:,:,i)));
    set(gca,'clim',[-1 1]*1);
    axis square
    colorbar;
    colormap jet
    set(gca,'xtick',[],'ytick',[]);
%     xlabel('ROI')
%     ylabel('ROI');
end
isPos_mat = UnvectorizeFc(isPos,0,true);
isNeg_mat = UnvectorizeFc(isNeg,0,true);
for i=1:nSubj
    subplot(nSubj,3,i*3);
    imagesc(FC(:,:,i).*(isPos_mat(:,:,i)-isNeg_mat(:,:,i)));
    set(gca,'clim',[-1 1]*fcClim);
    axis square
    colorbar;
    colormap(gca,'gray')
    set(gca,'xtick',[],'ytick',[]);
%     xlabel('ROI')
%     ylabel('ROI');
end


% Score
score = nan(nSubj,1);
[isPos,isNeg] = deal(nan(nEdges,nSubj));
for i=1:nSubj
    isPos(:,i) = cp(:,i)<thresh & cr(:,i)>0;
    isNeg(:,i) = cp(:,i)<thresh & cr(:,i)<0;
    score(i) = FC_vec(:,i)'*(isPos(:,i)-isNeg(:,i))/sum(isPos(:,i)+isNeg(:,i));
%     score(i) = FC_vec(:,i)'*(isPos(:,i)-isNeg(:,i))/sum(isPos(:,i)+isNeg(:,i))*2;
end

networks = UnvectorizeFc(all(isPos,2) - all(isNeg,2),0,true);
%% plot
figure(114); set(gcf,'Position',[1649         946         803         253]); clf;

subplot(1,2,1);
[p,Rsq,lm] = Run1tailedRegression(score,behavior,true);
hPlot = lm.plot;
% set(hPlot(1),'marker','.','markersize',10);
xlabel('Network Strength');
ylabel('Behavioral Measure');
title('');
axis square
set(gca,'xtick',[],'ytick',[]);
legend('Participant','Linear Fit','95% CI','Location','NorthWest')
% plot(score,behavior,'.');

subplot(1,2,2);
imagesc(networks);
set(gca,'clim',[-1 1]*1);
axis square
colorbar;
colormap(gca,'jet');
set(gca,'xtick',[],'ytick',[]);
xlabel('ROI')
ylabel('ROI');



%
%     if any(networks(:)>0) && any(networks(:)<0)
%         break;
%     end
% end

%% External dataset
nSubj2 = 5;
% while r<0.8
% act2 = randn(nRois,nT,nSubj2);
% behavior2 = randn(nSubj2,1);


figure(115); set(gcf,'Position',[3   295   863   543]); clf;
FC2 = nan(nRois,nRois,nSubj);
for i=1:nSubj2
    [r,p] = corr(act2(:,:,i)','rows','pairwise');
    FC2(:,:,i) = atanh(r);
end
FC2 = UnvectorizeFc(VectorizeFc(FC2),1,true);
FC2_vec = VectorizeFc(FC2);
networks_vec = VectorizeFc(networks);
score2 = nan(size(score));
% plot
for i=1:nSubj2
    subplot(nSubj2,4,i*4-3);
    imagesc(FC2(:,:,i));
    set(gca,'clim',[-1 1]*fcClim);
    axis square
    colorbar;
    colormap gray
    set(gca,'xtick',[],'ytick',[]);
%     xlabel('ROI')
%     ylabel('ROI');
    subplot(nSubj2,4,i*4-2);
    imagesc(networks.*FC2(:,:,i));
    set(gca,'clim',[-1 1]*fcClim);
    axis square
    colorbar;
    colormap gray
    set(gca,'xtick',[],'ytick',[]);
%     xlabel('ROI')
%     ylabel('ROI');

    score2(i) = FC2_vec(:,i)'*networks_vec/sum(networks_vec~=0);
%     score2(i) = FC2_vec(:,i)'*networks_vec/sum(networks_vec~=0)*2;
end

subplot(1,2,2);
[p,Rsq,lm] = Run1tailedRegression(score2,behavior2,true);
hPlot = lm.plot;
% set(hPlot(1),'marker','.','markersize',10);
xlabel('Network Strength');
ylabel('Behavioral Measure');
title('');
axis square
set(gca,'xtick',[],'ytick',[]);
legend('Participant','Linear Fit','95% CI','Location','NorthWest')
% plot(score,behavior,'.');
[r,p] = corr(score2,behavior2,'tail','right');
% end
