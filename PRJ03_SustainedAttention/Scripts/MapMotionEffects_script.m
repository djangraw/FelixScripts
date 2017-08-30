% MapMotionEffects_script.m
%
% Created 11/15/16 by DJ.

% Set up
subject = 27;
cd(sprintf('/data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ%02d/AfniProc_MultiEcho_2016-09-22',subject));
preMoCoFilename = sprintf('pb02.SBJ%02d.r01_e2.tshift+orig',subject);
postMoCoFilename = sprintf('pb03.SBJ%02d.r01_e2.volreg+tlrc',subject);
mo1dFilename = 'mot_demean.r01.1D';
moDer1dFilename = 'mot_deriv.r01.1D';
% Load
[preErr,preBrick,preInfo,preErrMsg] = BrikLoad(preMoCoFilename);
[postErr,postBrick,postInfo,postErrMsg] = BrikLoad(postMoCoFilename);
moTs = Read_1D(mo1dFilename);
moTs = moTs(1:size(preBrick,4),:);
moDerTs = Read_1D(moDer1dFilename);
moDerTs = moDerTs(1:size(preBrick,4),:);

%% Get spatial gradients
dataBrick = postBrick;
[Gx,Gy,Gz] = MapLocalGradient(dataBrick(:,:,:,1));
% scale
val95 = GetValueAtPercentile(abs([Gx(Gx~=0); Gy(Gy~=0); Gz(Gz~=0)]),95);
Gx_scaled = Gx/val95;
Gy_scaled = Gy/val95;
Gz_scaled = Gz/val95;

dataVar = MapLocalVar(dataBrick(:,:,:,1),3);
% Scale
dataVar_scaled = dataVar/GetValueAtPercentile(dataVar(dataVar>0),95);
% Plot
GUI_3View(cat(4,Gx_scaled,Gy_scaled,Gz_scaled));

%% Plot motion
figure(839); clf;
PlotMotionData(moTs,moDerTs);

%% Plot signal during motion

iDim = 1;
[maxMot, iMaxMot] = max(abs(moDerTs(:,iDim)));
% Plot
figure(839);
subplot(6,2,iDim*2-1); hold on;
plot(iMaxMot-1,moTs(iMaxMot-1,iDim),'ro');
plot(iMaxMot,moTs(iMaxMot,iDim),'go');
plot(iMaxMot+1,moTs(iMaxMot+1,iDim),'bo');
subplot(6,2,iDim*2); hold on;
plot(iMaxMot-1,moDerTs(iMaxMot-1,iDim),'ro');
plot(iMaxMot,moDerTs(iMaxMot,iDim),'go');
plot(iMaxMot+1,moDerTs(iMaxMot+1,iDim),'bo');

tmp = dataBrick(:,:,:,iMaxMot+(-1:1));
maxTmp = max(tmp(:));
tmp = tmp - repmat(mean(tmp,4),[1 1 1 3]); % mean 0
% tmp = tmp/max(tmp(:)); % max 1
tmp = tmp/GetValueAtPercentile(tmp(tmp>0),99.99); % max 1

% tmp(:,:,:,2) = dataBrick(:,:,:,iMaxMot)/maxTmp;
tmp(:,:,:,2) = Gx_scaled;

GUI_3View(tmp);

%% Scatter plot of motion susceptibility vs. stddev
timeVar = std(dataBrick,0,4);
timeVar(timeVar==0) = nan;
spaceVar = dataVar;
spaceVar(timeVar==0) = nan;
GUI_ScatterSelect(spaceVar,timeVar);

%% Get correlation
lm = fitlm(spaceVar(~isnan(timeVar)),timeVar(~isnan(timeVar)),'Linear','VarNames',{'TimeStddev','SpaceVariance'}); % least squares
% plot line & CI
figure(56); clf;
lm.plot;
xlabel('Spatial Variance in 3x3x3-voxel neighborhood')
ylabel('StdDev over time')
% Print results
[p,F,d] = coefTest(lm);
Rsq = lm.Rsquared.Adjusted;
fprintf('R^2 = %.3g, p = %.3g\n',Rsq,p);
title(sprintf('Spatial vs. Temporal Variance:\nR^2=%.3f, p=%.3g',Rsq,p));


%% Plot as RGB
timeVarNorm = timeVar/max(timeVar(:));
spaceVarNorm = spaceVar/max(spaceVar(:));
GUI_3View(cat(4,timeVarNorm,timeVar*0,spaceVarNorm))

%% Compare results with motion regressor outputs

bucketFilename = sprintf('cbucket.SBJ%02d_REML+tlrc.BRIK',subject);
maskFilename = sprintf('full_mask.SBJ%02d+tlrc.BRIK',subject);
% Load
[bucketErr,bucketBrick,bucketInfo,bucketErrMsg] = BrikLoad(bucketFilename);
[maskErr,maskBrick,maskInfo,maskErrMsg] = BrikLoad(maskFilename);
% For each voxel, get RMS across motion 
bucketLabels = strsplit(bucketInfo.BRICK_LABS,'~');
isMotionReg = false(1,numel(bucketLabels));
motionStrings = {'roll','pitch','yaw','dS','dL','dP'};
nRows = numel(motionStrings)+1;
nCols = 2;
midVoxel = round(size(bucketBrick)/2);
midVoxel = midVoxel(1:3);
clim = [-1 1]*5;

% Get motion regressor responses and plot
figure(623); clf;
MakeFigureTitle(sprintf('SBJ%02d Motion Regressor Responses',subject));
for i=1:numel(motionStrings)
    % Find
    isThis = strncmp(motionStrings{i},bucketLabels,length(motionStrings{i}));
    iThis = find(isThis);
%     isThis = find(isThis,1,'first');
    thisMotionResponse = mean(bucketBrick(:,:,:,iThis(1:end/2)),4);
    thisDerivResponse = mean(bucketBrick(:,:,:,iThis((end/2+1):end)),4);
%     thisMotionResponse(isnan(thisMotionResponse)) = 0;
    % Plot
    subplot(nRows,nCols,i*2-1);
    Plot3Planes(thisMotionResponse,midVoxel);
    set(gca,'clim',clim,'xtick',{},'ytick',{});
    axis equal
    axis([0 3 0 1]);
    title(motionStrings{i})
    colorbar
    subplot(nRows,nCols,i*2);
    Plot3Planes(thisDerivResponse,midVoxel);
    set(gca,'clim',clim,'xtick',{},'ytick',{});
    axis equal
    axis([0 3 0 1]);
    title(['^d/_d_t ' motionStrings{i}])
    colorbar
    % Record
    isMotionReg = isMotionReg | isThis;
end

rmsMotionResponse = rms(bucketBrick(:,:,:,isMotionReg),4);

subplot(nRows,nCols,numel(motionStrings)*2+1);
Plot3Planes(rmsMotionResponse,midVoxel);
set(gca,'clim',[0 20],'xtick',{},'ytick',{});
axis equal
axis([0 3 0 1]);
title('RMS all motion params')
colorbar

%%
figure(624); clf;
% Plot
Gall = cat(4,Gz,Gy,Gx);
names = {'Gz (dS)','Gy (dL)','Gx (dP)'};
clim = [-1 1]*5e3;
for i=1:3
    subplot(4,1,i);
    Plot3Planes(Gall(:,:,:,i),midVoxel);
    set(gca,'clim',clim,'xtick',{},'ytick',{});
    axis equal
    axis([0 3 0 1]);
    title(names{i})
    colorbar
end

subplot(4,1,4);
Plot3Planes(rms(Gall,4),midVoxel);
set(gca,'clim',[0 5e3],'xtick',{},'ytick',{});
axis equal
axis([0 3 0 1]);
title(names{i})
colorbar
