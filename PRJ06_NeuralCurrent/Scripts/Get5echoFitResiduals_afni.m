% Get5echoFitResiduals_afni
% Created 8/26/15 by DJ.
% Updated 9/3/15 by DJ - converted to AFNI version.

subject = 1;
session = 9;
run = 10;
fitType = 'exp';

for i=1:5
    filenames{i} = sprintf('SBJ%02d_S%02d_R%02d_Task_Echo%dof5_detrended+orig.BRIK',subject,session,run,i);
end
S0filename =  sprintf('SBJ%02d_S%02d_R%02d_Task_All_S0+orig.BRIK',subject,session,run);
R2filename =  sprintf('SBJ%02d_S%02d_R%02d_Task_All_R2+orig.BRIK',subject,session,run);

echoTimes = 15.4:14.3:(15.4+14.3*4);

disp('Getting residuals...')
residuals = GetFitResiduals_afni(filenames,echoTimes,S0filename,R2filename);
sse = sum(residuals.^2,5);
disp('Done!')
%% Save
fprintf('Saving...\n')
outName = sprintf('SBJ%02d_S%02d_R%02d_Task_%sResid_afni',subject,session,run,fitType);
save(outName,'subject','session','run','fitType',...
    'echoTimes','sse','residuals');
fprintf('Done!\n')


%% Load data
for i=1:numel(filenames)
    [V(:,:,:,:,i),Info] = BrikLoad(filenames{i});
end
% Get amplitudes and decay constants
S0 = BrikLoad(S0filename);
R2 = BrikLoad(R2filename);

%% Plot
% plot mean residuals
legendstr = cell(1,5);
for i=1:5
    legendstr{i} = sprintf('echo %d',i);
end
figure(32); clf;
% plot S0 and R2 histograms
subplot(3,2,1); cla;
hist(S0(S0~=0),100);
xlabel('S0 (A.U.)')
ylabel('# voxels')
title('S0 histogram')
subplot(3,2,2); cla;
hist(R2(R2~=0),100);
xlabel('-1/T2 (1/ms)')
ylabel('# voxels')
title('-R2 histogram')

% plot mean fit across echoes
nVoxels = size(S0,1)*size(S0,2)*size(S0,3);
nT = size(S0,4);
subplot(3,1,2); cla; hold on;
S0norm = reshape(S0,nVoxels,nT);
S0norm(S0==0)=NaN;
S0norm = nanmean(S0norm,1);
S0norm = (S0norm - nanmean(S0norm))/nanstd(S0norm);
R2norm = reshape(R2,nVoxels,nT);
R2norm(R2==0)=NaN;
R2norm = nanmean(R2norm,1);
R2norm = (R2norm - nanmean(R2norm))/nanstd(R2norm);
ssenorm = reshape(sse,nVoxels,nT);
ssenorm(R2==0)=NaN;
ssenorm = nanmean(ssenorm,1);
ssenorm = (ssenorm - nanmean(ssenorm))/nanstd(ssenorm);
plot([S0norm; R2norm; ssenorm]');
title([outName, ' fit parameters'],'interpreter','none')
xlabel('time (samples)');
ylabel('fit parameter (normalized)');
legend('S0','-R2','SSE');

% plot mean residuals over time
meanres = squeeze(nanmean(nanmean(nanmean(residuals,3),2),1));
subplot(3,1,3); cla;
plot(meanres);
xlabel('time (samples)')
ylabel('mean residual across all voxels')
legend(legendstr)
title([outName, ' residuals for each echo'],'interpreter','none')



%%
% plot mean fit and actual values for a voxel
coords = [10 47 5; 21 48 6; 16 16 16];
meanR2 = nanmean(R2,4);
figure(457); clf;
MakeFigureTitle(outName);
for i=1:size(coords,1)
    ijk = coords(i,:);
    t = (echoTimes(1)-1):.01:(echoTimes(5)+1);
    v = mean(S0(ijk(1),ijk(2),ijk(3),:),4) * exp(mean(R2(ijk(1),ijk(2),ijk(3),:),4)*t);
    vE = mean(S0(ijk(1),ijk(2),ijk(3),:),4) * exp(mean(R2(ijk(1),ijk(2),ijk(3),:),4)*echoTimes);
    % upper plot
    subplot(3,size(coords,1),i); colormap gray; hold on;
    imagesc(meanR2(:,:,ijk(3)));
    PlotHorizontalLines(ijk(1),'g');
    PlotVerticalLines(ijk(2),'g');
    title(sprintf('mean -R2 fit at ijk = (%d, %d, %d)',ijk))
    % middle plot
    subplot(3,size(coords,1),size(coords,1)+i); cla; hold on;
    plot(t,v);
    plot(echoTimes,vE,'.');
    xlabel('time (ms)');
    ylabel('signal (A.U.)');
    title(sprintf('fit at ijk = (%d, %d, %d)',ijk))
    plot(echoTimes,squeeze(nanmean(V(ijk(1),ijk(2),ijk(3),:,:),4)), 'r.-');
    legend('mean fit across samples','mean fit at echo times','mean data')
    % lower plot
    sse_this = squeeze(sse(ijk(1),ijk(2),ijk(3),:));
    sse_this_norm = (sse_this-mean(sse_this))/std(sse_this);
    R2_this = squeeze(R2(ijk(1),ijk(2),ijk(3),:));
    R2_this_norm = (R2_this-mean(R2_this))/std(R2_this);
    subplot(3,size(coords,1),size(coords,1)*2+i); cla; hold on;
    hold on
    plot(sse_this_norm);
    plot(R2_this_norm);
    legend('sum squared residuals','-R2')
    
    xlabel('time (samples)');
    ylabel('see legend (normalized)');

    title(sprintf('residuals at ijk = (%d, %d, %d)',ijk))
end

%% Write mean abs residuals to file
residBrick = nanmean(abs(residuals),5);
residBrick(isnan(residBrick)) = 0;
outFilename = sprintf('SBJ%02d_S%02d_R%02d_Task_%sFit_MeanResid',subject,session,run,fitType);
Opt = struct('Prefix',outFilename,'OverWrite','y');
WriteBrik(residBrick,Info,Opt);