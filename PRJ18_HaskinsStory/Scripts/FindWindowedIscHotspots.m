% FindWindowedIscHotspots.m
%
% Created 4/17/19 by DJ.

% filename = sprintf('%s/MeanErrtsFanaticor_top+tlrc',constants.dataDir);
% filename = sprintf('%s/IscResults/Group/SlidingWindowIsc_win%d_toptop+tlrc',constants.dataDir,winLength);
filename = sprintf('%s/IscResults/Group/SlidingWindowIsc_win%d_botbot+tlrc',constants.dataDir,winLength);
% MakeCarpetPlot(filename);

%% Get principal components
brik = BrikLoad(filename);
mask = ~any(brik==0 | isnan(brik),4);

nT = size(brik,4);
nVox = numel(brik)/nT;
brik2d = reshape(brik,nVox,nT);
mask = mask(:);
brik2d = brik2d(mask,:);


%% Get SVD
[U,S,V] = svd(brik2d,'econ');


%%
winLength = 15;
TR = 2;
t = ((1:nT)+winLength/2)*TR;
figure(1);
subplot(222); cla;
imagesc(t,1:size(brik2d,1),brik2d);
xlabel('time (s)')
ylabel('voxel')
title('mean (z scored) ISC between bottom readers')

% Plot SVD components (in time)
subplot(224); cla;
PlotTimecoursesWithConditions(t,V(:,1:3));
ylabel('Component activity (normalized?)')
% Plot component weightings (across voxels)
subplot(221); cla;
plot(U(:,1:3),1:size(U,1));
set(gca,'ydir','reverse');
ylabel('voxel')
xlabel('component weighting')
legend('PC1','PC2','PC3');

%% View top 3 PC weightings on brain
brikPC2d = nan(nVox,3);
for i=1:3
    brikPC2d(mask,i) = abs(U(:,i));
%     if mean(U(:,i)<0)>0.5
%         fprintf('Flipping PC%d\n',i)
%         brikPC2d(mask,i) = -U(:,i);
%     else
%         brikPC2d(mask,i) = U(:,i);
%     end
end
brikPC = reshape(brikPC2d,size(brik,1),size(brik,2),size(brik,3),3);
GUI_3View(brikPC/GetValueAtPercentile(brikPC(~isnan(brikPC)),99));

%% Plot median weighting P->A

medWt = squeeze(nanmean(nanmean(brikPC,1),3));
figure(1); 
subplot(223);
cla; hold on;
colors = {'r','g','b','c','m','y','k'};
for i=1:3
    plot(medWt(:,i),colors{i},'linewidth',2);
end
xlabel('<-P---A->')
ylabel('Mean abs PC weighting')
legend('PC1','PC2','PC3');


%% Make scree plot
figure(2); clf;
diagS2 = diag(S).^2;
plot(cumsum(diagS2)/sum(diagS2))
ylabel('frac variance explained by first x PCs')
xlabel('PC')
title('SVD of 30s windowed ISC of bottom readers')
foo = diagS2/sum(diagS2);
foo(1:3)