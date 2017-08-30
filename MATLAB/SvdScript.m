% SvdScript.m
% 
% This script runs SVD on the 100-runs data to find the principal
% components of the response timecourses. It then plots them as timecourses
% and maps.
%
% Created 11/14 by DJ.
% Updated 11/25/14 by DJ - added RGB map.

% Load data
datadir = '/data/jangrawdc/PRJ01_100Runs/PrcsData/SBJ01';
filename = 'SBJ01_IRESP_NAVG100_PERM001_TENT+orig';
cd(datadir)
[err, brick, Info, ErrMessage] = BrikLoad (filename);
nVoxels = size(brick,1)*size(brick,2)*size(brick,3);
T = size(brick,4);
%% apply median filter
filtersize = 2;
brickmed = nan(size(brick));
fprintf('Applying Median Filter of size %d\n',filtersize);
for i=1:T
    fprintf('time %d/%d...\n',i,T);
    brickmed(:,:,:,i) = medfilt3(brick(:,:,:,i),[filtersize filtersize filtersize],'symmetric');
end
fprintf('Done!\n')

%% Get SVD components
% nComps = 6;
% [U,S,V] = svd(squeeze(brick(17,44,:,:)));
% [U,S,V] = svd(reshape(brick,nVoxels,T));
fprintf('Running SVD...\n')
tic;
[U,S,V] = svd(reshape(brickmed,nVoxels,T));
fprintf('Done! Took %.2f seconds.\n',toc);

%% plot
nComps = 6;
figure(2); clf;
subplot(2,1,1);
plot(cumsum(diag(S))/sum(S(:))*100,'.-')
xlabel('# PCs')
ylabel('% variance explained');
title('SVD on SBJ01, all voxels after median filter')
subplot(2,1,2);
plot(V(:,1:nComps));
hold on;
plot(get(gca,'xlim'),[0 0],'k:')
xlabel('time (samples)')
ylabel('activity (AU)');
legendstr = cell(1,nComps);
for i=1:nComps, legendstr{i}=sprintf('PC #%d',i); end;
legend(legendstr);

%% Get match with first few components
bricksize = size(brick);
match = nan([bricksize(1:3),nComps]);
amp = nan(bricksize(1:3));
disp('Getting Correlation Coefficients...');
for i=1:size(brick,1);
    fprintf('slice %d/%d...\n',i,size(brick,1));
    for j=1:size(brick,2);
        for k=1:size(brick,3);
            for iComp = 1:nComps
%                 match(i,j,k,iComp) = xcorr(V(:,iComp),squeeze(brick(i,j,k,:)),0);
%                 match(i,j,k,iComp) = xcorr(V(:,iComp),squeeze(brickmed(i,j,k,:)),0);
                foo = corrcoef(V(:,iComp),squeeze(brickmed(i,j,k,:)));
                match(i,j,k,iComp) = foo(1,2);
            end
%             amp(i,j,k) = xcorr(squeeze(brick(i,j,k,:)),0);
        end
    end
end
fprintf('Done! Took %g seconds.\n',toc);

%% SAVE RESULTS
save('SBJ01_IRESP_SVD_CorrCoef.mat','filename','brick','Info','S','V','match','T','filtersize','brickmed','nComps','legendstr');

%% LOAD RESULTS
load SBJ01_IRESP_SVD_CorrCoef

%% Plot match
meanBrick = mean(abs(brickmed),4);
meanBrick_scaled = meanBrick/max(meanBrick(:));
meanBrick_scaled(meanBrick_scaled>0) = 1;
match_scaled = abs(match);%abs(match)/max(abs(match(:)));
match_scaled(isnan(match)) = 0;
colors = [0 0 1; 0 1 0; 1 0 0; 0 1 1; 1 0 1; 1 1 0];

for iComp = 1:nComps
    figure(10+iComp); clf;
    subplot(2,2,1);
    plot(V(:,iComp),'color',colors(iComp,:));
    hold on
    plot(get(gca,'xlim'),[0 0],'k:')
    title(sprintf('component #%d timecourse',iComp))
    xlabel('time (samples)')
    ylabel('timecourse (normalized)')
%     [~,iMax]=max(squeeze(abs(match(17,44,:,iComp))));
%     iMax = [17 44 iMax];
    thismatch = match_scaled(:,:,:,iComp);
    [matchmax,iMax] = max(thismatch(:));
    [iMax(1),iMax(2),iMax(3)] = ind2sub(size(thismatch),iMax);
    subplot(2,2,2);
    Gray = squeeze(meanBrick_scaled(iMax(1),:,:))';
    Overlay = squeeze(abs(match_scaled(iMax(1),:,:,iComp)))';
%     PlotScalpMap(Gray,Gray+Overlay,Gray,[0 2]);
    PlotScalpMap(Gray+Overlay*colors(iComp,1),Gray+Overlay*colors(iComp,2),Gray+Overlay*colors(iComp,3),[0 2]);
    hold on;
    plot(get(gca,'xlim'),[iMax(3) iMax(3)],'g');
    plot([iMax(2) iMax(2)],get(gca,'ylim'),'g');
    set(gca,'ydir','normal')
    title(sprintf('Sagittal (x=%d)',iMax(1)))
    
    subplot(2,2,3);
    Gray = squeeze(meanBrick_scaled(:,iMax(2),:))';
    Overlay = squeeze(abs(match_scaled(:,iMax(2),:,iComp)))';
%     PlotScalpMap(Gray,Gray+Overlay,Gray,[0 2]);
    PlotScalpMap(Gray+Overlay*colors(iComp,1),Gray+Overlay*colors(iComp,2),Gray+Overlay*colors(iComp,3),[0 2]);
    hold on;
    plot(get(gca,'xlim'),[iMax(3) iMax(3)],'g');
    plot([iMax(1) iMax(1)],get(gca,'ylim'),'g');
    set(gca,'ydir','normal')
    title(sprintf('Coronal (y=%d)',iMax(2)))
    
    subplot(2,2,4);
    Gray = squeeze(meanBrick_scaled(:,:,iMax(3)));
    Overlay = squeeze(abs(match_scaled(:,:,iMax(3),iComp)));
%     PlotScalpMap(Gray,Gray+Overlay,Gray,[0 2]);
    PlotScalpMap(Gray+Overlay*colors(iComp,1),Gray+Overlay*colors(iComp,2),Gray+Overlay*colors(iComp,3),[0 2]);
    hold on;
    plot(get(gca,'xlim'),[iMax(1) iMax(1)],'g');
    plot([iMax(2) iMax(2)],get(gca,'ylim'),'g');
    title(sprintf('Axial (z=%d)',iMax(3)))
end

%% Plot RGB map of 1st 2-3 components

figure(20); clf;
subplot(2,2,1); hold on;
for iComp = 1:2
    plot(V(:,iComp),'color',colors(iComp,:));
end
legend(legendstr(1:2));
plot(get(gca,'xlim'),[0 0],'k:')
title(sprintf('components 1-2 timecourse'))
xlabel('time (samples)')
ylabel('timecourse (normalized)')
    
thismatch = sum(match_scaled(:,:,:,1:3),4);
[matchmax,iMax] = max(thismatch(:));
[iMax(1),iMax(2),iMax(3)] = ind2sub(size(thismatch),iMax);
    
B = squeeze(abs(match_scaled(iMax(1),:,:,1)))';
G = squeeze(abs(match_scaled(iMax(1),:,:,2)))';
R = squeeze(abs(match_scaled(iMax(1),:,:,3)))';
R(:)=0;
subplot(2,2,2);
PlotScalpMap(R,G,B,[0 2]);
hold on;
plot(get(gca,'xlim'),[iMax(3) iMax(3)],'g');
plot([iMax(2) iMax(2)],get(gca,'ylim'),'g');
set(gca,'ydir','normal')
title(sprintf('Sagittal (x=%d)',iMax(1)))
    
B = squeeze(abs(match_scaled(:,iMax(2),:,1)))';
G = squeeze(abs(match_scaled(:,iMax(2),:,2)))';
R = squeeze(abs(match_scaled(:,iMax(2),:,3)))';
R(:)=0;
subplot(2,2,3);
PlotScalpMap(R,G,B,[0 2]);
hold on;
plot(get(gca,'xlim'),[iMax(3) iMax(3)],'g');
plot([iMax(1) iMax(1)],get(gca,'ylim'),'g');
set(gca,'ydir','normal')
title(sprintf('Coronal (y=%d)',iMax(2)))

B = squeeze(abs(match_scaled(:,:,iMax(3),1)));
G = squeeze(abs(match_scaled(:,:,iMax(3),2)));
R = squeeze(abs(match_scaled(:,:,iMax(3),3)));
R(:)=0;
subplot(2,2,4);
PlotScalpMap(R,G,B,[0 2]);
hold on;
plot(get(gca,'xlim'),[iMax(1) iMax(1)],'g');
plot([iMax(2) iMax(2)],get(gca,'ylim'),'g');
title(sprintf('Axial (z=%d)',iMax(3)))

figure(21); clf;
[X,Y] = meshgrid(linspace(0,1,256));
imagesc(X(1,:),X(1,:),cat(3,zeros(size(X)),Y,X));
set(gca,'ydir','normal')
xlabel(legendstr{1});ylabel(legendstr{2});
title('Color mapping')

%% Write brick
foo = match_scaled(:,:,:,[3 2 1]);
foo(:,:,:,1) = 0;
[err,errMessage,InfoOut] = WriteBrik(foo,Info,struct('Prefix','SvdTop2','OverWrite','y'));

%% Map G(G+B) onto single slice and write brik for viewing in AFNI
G = match_scaled(:,:,:,2);
B = match_scaled(:,:,:,1);
BoverGB = B./(G+B);
BoverGB(isnan(BoverGB)) = 0;
[err,errMessage,InfoOut] = WriteBrik(BoverGB,Info,struct('Prefix','Svd1over12','OverWrite','y'));

%% View with matlab GUI
% GUI_3View('SvdTop2+orig');
foo = match_scaled(:,:,:,[3 2 1]);
foo(:,:,:,1) = 0;
GUI_3View(foo);
%%
foo = zeros(size(match(:,:,:,1:3)));

foo(:,:,:,1) = match(:,:,:,1).*(match(:,:,:,1)>0);
foo(:,:,:,2) = (match(:,:,:,2)+1)/2;
foo(:,:,:,3) = -match(:,:,:,1).*(match(:,:,:,1)<0);
GUI_3View(foo);
figure(999);
[X,Y] = meshgrid(linspace(-1,1,256),linspace(-1,1,256));
imagesc(X(1,:),Y(:,1)',cat(3,X.*(X>0),(Y+1)/2,-X.*(X<0)));
set(gca,'ydir','normal')
xlabel(legendstr{1});ylabel(legendstr{2});
title('Color mapping')