% PlotSimonRegressors_script.m
%
% Created 4/22/15 by DJ.


iRun = 2;
behaviorFilename = sprintf('Simon-%s-%d.mat',subject(end),runs(iRun));
load(behaviorFilename); % loads data


[tReg,regressors,regressornames] = GetSimonRegressors(data.events,data.performance);
figure(13);
subplot(2,1,1); cla;
PlotSimonTimecourse(data.events,data.performance);
hold on
plot(tReg,regressors(1,:),'c')
plot(tReg,regressors(2,:),'m')
plot(tReg,regressors(3,:),'y')
plot(tReg,regressors(4,:),'k')
title(sprintf('Simon-%d-%d behavior + raw regressors',data.params.subject,data.params.session));

%% convolve with HRF

dt = median(diff(tReg));
% smooth by convolving with an HRF
hrf = spm_hrf(dt);
reg_smooth = regressors;
for i=1:size(reg_smooth,1)
    reg_smooth(i,:) = conv(regressors(i,:),[zeros(size(hrf)); hrf],'same');
end
subplot(2,1,2); cla;
% PlotSimonTimecourse(data.events,data.performance);
hold on
plot(tReg,reg_smooth(1,:),'c')
plot(tReg,reg_smooth(2,:),'m')
plot(tReg,reg_smooth(3,:),'y')
plot(tReg,reg_smooth(4,:),'k')
legend(regressornames);
xlabel('time on task (s)')
ylabel('Regressor value (A.U.)');
title('regressors convolved with HRF')

%% Plot with timecourses
[varex_sorted, order] = sort(varex{iRun}(iAccepted{iRun}),'descend');
TC_sorted = TC{iRun}(:,iAccepted{iRun}(order));
TR = 2;
t = (1:nT(iRun))*TR;
for j=1:12
    subplot(4,3,j); cla; hold on;
    plot(tReg,reg_smooth(1,:),'c')
    plot(tReg,reg_smooth(2,:),'m')
    plot(tReg,reg_smooth(3,:),'g')
    plot(tReg,reg_smooth(4,:),'k')
%     PlotSimonTimecourse(data.events,data.performance);
    plot(t,TC_sorted(:,j)*2+5,'r');
    xlabel('t (s)')
    ylabel('BOLD activation (A.U.)')
    title(sprintf('Component %d: %.2f%% var. explained',order(j),varex_sorted(j)));
end
legend([regressornames, {'BOLD'}]);

%% Run GLM

figure(14); cla;
% Downsample regressors
iRegSamples = interp1(tReg,1:length(tReg),t,'nearest');
reg_ds = reg_smooth(:,iRegSamples);
% normalize regressors
reg_norm = zeros(size(reg_ds));
for i=1:size(reg_ds,1)
    reg_norm(i,:) = (reg_ds(i,:) - mean(reg_ds(i,:)))/std(reg_ds(i,:));
end
% Regress 

reg_betas = zeros(4,12);
for i=1:12
    X = reg_norm';
    y = TC_sorted(:,i);
    reg_betas(:,i) = (X'*X)\(X'*y);
end

plot(reg_betas');
hold on;
PlotHorizontalLines(0,'k--');
xlabel('component')
ylabel('beta')
legend(regressornames);
title('Simon-3-1 component matching regressors');