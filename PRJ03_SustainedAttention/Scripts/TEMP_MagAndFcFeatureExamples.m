% TEMP_MagAndFcFeatureExamples.m
%
% Created 3/23/16 by DJ.

cd /spin1/users/jangrawdc/PRJ03_SustainedAttention/Results/SBJ09/AfniProc_MultiEcho_2016-01-19
Brick = BrikLoad('errts.SBJ09.tproject+tlrc');
foo = load('SBJ09_FC_MultiEcho_2016-01-19_Craddock.mat');

%% perform SVD
% fill in
tc = foo.tc;
tc(:,all(tc==0,1)) = repmat(mean(tc,2),1,sum(all(tc==0,1)));

[U,S,V] = svd(tc',0);

%% Plot components
iComp=3;
atlas2 = MapValuesOntoAtlas(atlas,-V(:,iComp));

GUI_3View(atlas2,round(size(atlas)/2));

%% Plot component timecourse

PCtc = V'*foo.tc;

figure(988); clf;
for i=1:3
    subplot(3,1,i);
    plot(PCtc(i,:));
    xlabel('time (samples)')
    ylabel(sprintf('PC #%d',i));
    ylim([-1 1]*1000);
    xlim([0 size(PCtc,2)])
end


fracVarToKeep = 0.9;
cumsumS = cumsum(diag(S).^2)/sum(diag(S).^2);
nPcsToKeep = find(cumsumS<fracVarToKeep,1,'last');
PCtc_keep = PCtc(1:nPcsToKeep,:);


%% Normalize and plot again

clf;

normPCtc = (PCtc_keep-repmat(mean(PCtc_keep,2),1,size(PCtc_keep,2)))./repmat(std(PCtc_keep,[],2),1,size(PCtc_keep,2));
for i=1:3
    subplot(3,1,i);
    plot(normPCtc(i,:));
    xlabel('time (samples)')
    ylabel(sprintf('normalized\n PC #%d',i));
    ylim([-1 1]*4);
    xlim([0 size(PCtc_keep,2)])
end

%% Smooth and sample

clf;
N = 150; % # trials
l = 8; % # samples per window
tStart = round(linspace(l,N-2*l,N));
trialNormPCtc = zeros(size(normPCtc,1),N);
for i=1:N
    trialNormPCtc(:,i) = mean(normPCtc(:,(1:l)+tStart(i)-1),2);
end


%% Plot as matrices
figure(901); clf;
subplot(231);
BrickMat = reshape(Brick,size(Brick,1)*size(Brick,2)*size(Brick,3),size(Brick,4));
isInBrain = any(BrickMat>0,2);
imagesc(BrickMat(isInBrain,:));
set(gca,'clim',[-1 1]*50);
title('Voxel timecourses')
colormap jet
colorbar

subplot(232);
imagesc(tc);
set(gca,'clim',[-1 1]*50);
title('ROI timecourses')
colorbar

subplot(233);
imagesc(PCtc_keep);
set(gca,'clim',[-1 1]*150);
title('Mag Component timecourses')
colorbar

subplot(234);
imagesc(normPCtc);
set(gca,'clim',[-1 1]*3);
title('Normalized Mag Component timecourses')
colorbar

subplot(235);
imagesc(trialNormPCtc);
title('Mag Features')
colorbar


%% Get FC timecourse

FC = foo.FC;
% get upper triangular matrix to convert mat <-> vec
uppertri = triu(ones(size(FC,1)),1); % above the diagonal

% Turn each time point's matrix into a vector of the unique indices.
% (assume the elements above the diagonal contain all the information)
nT = size(FC,3);
nFC = sum(uppertri(:)); % number of unique elements 
FCvec = nan(nT,nFC);
for i=1:nT
    thisFC = FC(:,:,i); % save out for easy indexing
    FCvec(i,:) = thisFC(uppertri==1); % assume a symmetric matrix
end

% Get FC PCA
[U,S,V,FcPcTc] = PlotFcPca(FC,0,true);
%% Do dim reduction
fracVarToKeep = 0.7;
cumsumS = cumsum(diag(S).^2)/sum(diag(S).^2);
nPcsToKeep = find(cumsumS<fracVarToKeep,1,'last');
FcPcTc_keep = FcPcTc(1:nPcsToKeep,:);

normFcPcTc = (FcPcTc_keep-repmat(mean(FcPcTc_keep,2),1,size(FcPcTc_keep,2)))./repmat(std(FcPcTc_keep,[],2),1,size(FcPcTc_keep,2));
trialNormFcPcTc = zeros(size(normFcPcTc,1),N);
for i=1:N
    trialNormFcPcTc(:,i) = mean(normFcPcTc(:,tStart(i)),2);
end

%% Plot FC steps as matrices
figure(902); clf;
subplot(231);
imagesc(tc);
set(gca,'clim',[-1 1]*50);
title('ROI timecourses')
colorbar
colormap jet

subplot(232);
imagesc(FCvec);
set(gca,'clim',[-1 1]*1);
title('FC timecourses')
colorbar

subplot(233);
imagesc(FcPcTc_keep);
set(gca,'clim',[-1 1]*20);
title('FC Component timecourses')
colorbar

subplot(234);
imagesc(normFcPcTc);
set(gca,'clim',[-1 1]*3);
title('Normalized FC Component timecourses')
colorbar

subplot(235);
imagesc(trialNormFcPcTc);
title('FC Features')
colorbar


