% Get5echoFitResiduals
% Created 8/26/15 by DJ.

subject = 1;
session = 9;
run = 11;
fitType = 'exp';

for i=1:5
    filenames{i} = sprintf('SBJ%02d_S%02d_R%02d_Task_Echo%dof5+orig.BRIK',subject,session,run,i);
end

echoTimes = 15.4:14.3:(15.4+14.3*4);
[fits,offsets,sse,residuals] = FitCurveToEchoes(filenames,echoTimes,fitType);
% residuals = GetFitResiduals(filenames,echoTimes,fits,offsets);

%% Save
fprintf('Saving...\n')
outName = sprintf('SBJ%02d_S%02d_R%02d_Task_%sFit',subject,session,run,fitType);
save(outName,'subject','session','run','fitType',...
    'echoTimes','fits','offsets','sse','residuals');
fprintf('Done!\n')

%% Plot
% plot mean residuals
legendstr = cell(1,5);
for i=1:5
    legendstr{i} = sprintf('echo %d',i);
end
% plot mean residuals over time
meanres = squeeze(nanmean(nanmean(nanmean(residuals,3),2),1));
figure(32); clf;
subplot(3,1,1); cla;
plot(meanres);
xlabel('time (samples)')
ylabel('mean residual across all voxels')
legend(legendstr)
title([outName, ' residuals for each echo'],'interpreter','none')


%% Load data
for i=1:numel(filenames)
    [V(:,:,:,:,i),Info] = BrikLoad(filenames{i});
end
%%
% plot mean fit and actual values for a voxel
coords = [18 46 6; 16 16 16; 8 44 6];
for i=1:size(coords,1)
    ijk = coords(i,:);
    t = (echoTimes(1)-1):.01:(echoTimes(5)+1);
    v = exp(mean(-fits(ijk(1),ijk(2),ijk(3),:),4)*t + mean(offsets(ijk(1),ijk(2),ijk(3),:),4));
    vE = exp(mean(-fits(ijk(1),ijk(2),ijk(3),:),4)*echoTimes + mean(offsets(ijk(1),ijk(2),ijk(3),:),4));
    subplot(3,size(coords,1),size(coords,1)+i); cla; hold on;
    plot(t,v);
    plot(echoTimes,vE,'.');
    xlabel('time (ms)');
    ylabel('signal (A.U.)');
    title(sprintf('ijk = (%d, %d, %d)',ijk))
    plot(echoTimes,squeeze(nanmean(V(ijk(1),ijk(2),ijk(3),:,:),4)), 'r.-');
    legend('fit','mean fit to echo times','mean data')
end

%% Write mean abs residuals to file
residBrick = nanmean(abs(residuals),5);
residBrick(isnan(residBrick)) = 0;
outFilename = sprintf('SBJ%02d_S%02d_R%02d_Task_%sFit_MeanResid',subject,session,run,fitType);
Opt = struct('Prefix',outFilename,'OverWrite','y');
WriteBrik(residBrick,Info,Opt);