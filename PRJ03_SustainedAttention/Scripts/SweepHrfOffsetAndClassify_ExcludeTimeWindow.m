% SweepHrfOffsetAndClassify_ExcludeTimeWindow.m
%
% Created 8/18/16 by DJ based on c.m

% subjects = [9:22 24:30];
subjects = [9:11,13:19,22,24:25,28,30:34,36];
separationTimes = 60;% 0:20:100; %0:5:125;%0:20:260;
nSubj = numel(subjects);
nSepTim = numel(separationTimes);
clear newParams*
inputParams = struct('label1','ignoredSpeech','label0','attendedSpeech');
% inputParams = struct('label1','whiteNoise','label0','other');
% inputParams = struct('label1','ignoredSpeech','label0','other');
inputParams.fracMagVarToKeep = 0.9;
inputParams.fracFcVarToKeep = 0.7;
inputParams.nPerms = 0;%100;
inputParams.doPlot=false;
hrfOffsets = -15:5:20;
nHrf = numel(hrfOffsets);
% declare output variables
[AzCv_FC, AzCv_mag] = deal(nan(nSepTim,nSubj,nHrf));
[fwdModelCv_FC, fwdModelCv_mag] = deal([]);
[statsCv_FC, statsCv_mag,statsCv_FC_perms, statsCv_mag_perms] = deal(cell(1,nSubj));
% declare perms variables
[AzCv_FC_perms, AzCv_mag_perms] = deal(nan(nSepTim,inputParams.nPerms,nSubj));
[fwdModelCv_FC_perms, fwdModelCv_mag_perms] = deal([]);
%% Classify
for j=1:nHrf
    fprintf('===HRF offset %d/%d...\n',j,nHrf);
    inputParams.HrfOffset = hrfOffsets(j);
    for i=1:nSubj
        fprintf('===subject %d/%d...\n',i,nSubj);
        [AzCv_mag(:,i,j), fwdModelCv_mag(:,:,i), statsCv_mag{i}, newParams_mag(i), AzCv_mag_perms(:,:,i), fwdModelCv_mag_perms(:,:,:,i), statsCv_mag_perms{i}] = ClassifySubject_Mag_ExcludeTimeWindow(subjects(i),separationTimes,inputParams);
        [AzCv_FC(:,i,j), fwdModelCv_FC(:,:,i), statsCv_FC{i}, newParams_FC(i), AzCv_FC_perms(:,:,i), fwdModelCv_FC_perms(:,:,:,i), statsCv_FC_perms{i}] = ClassifySubject_FC_ExcludeTimeWindow(subjects(i),separationTimes,inputParams);
    end
end

%% Compile results
subjStr = cell(1,nSubj);
for i=1:nSubj
    subjStr{i} = sprintf('SBJ%02d',subjects(i));
end
badSubj = [12, 20, 21, 26, 27, 29, 35];
iOkSubj = find(~ismember(subjects,badSubj));

%% Select best separation time and extract it.
AzCv_mag_okSubj = AzCv_mag(:,iOkSubj,:);
AzCv_FC_okSubj = AzCv_FC(:,iOkSubj,:);
nOkSubj = numel(iOkSubj);
AzCv_mag_okSubj_perms = AzCv_mag_perms(:,:,iOkSubj);
AzCv_FC_okSubj_perms = AzCv_FC_perms(:,:,iOkSubj);

% declare a "best" separation time
iBestSepTime = 1;
AzCv_mag_okSubj_best = AzCv_mag_okSubj(iBestSepTime,:,:);
AzCv_FC_okSubj_best = AzCv_FC_okSubj(iBestSepTime,:,:);
[iBestSepTime_mag, iBestSepTime_FC] = deal(repmat(iBestSepTime,1,nOkSubj,nHrf));

% Do same with permutations
AzCv_mag_okSubj_perms_best = AzCv_mag_okSubj_perms(iBestSepTime,:,:);
AzCv_FC_okSubj_perms_best = AzCv_FC_okSubj_perms(iBestSepTime,:,:);
AzCv_mag_okSubj_perms_best_mean = mean(AzCv_mag_okSubj_perms_best,3);
AzCv_FC_okSubj_perms_best_mean = mean(AzCv_FC_okSubj_perms_best,3);

AzCv_mag_okSubj_best_mean = mean(AzCv_mag_okSubj_best,2);
AzCv_mag_okSubj_best_ste = std(AzCv_mag_okSubj_best,[],2)/sqrt(nOkSubj);
AzCv_FC_okSubj_best_mean = mean(AzCv_FC_okSubj_best,2);
AzCv_FC_okSubj_best_ste = std(AzCv_FC_okSubj_best,[],2)/sqrt(nOkSubj);

% Plot results
for j=1:nHrf
    % Make barplot
    figure(100+j); clf; hold on;
    bar([AzCv_mag_okSubj_best(:,:,j),AzCv_mag_okSubj_best_mean(:,:,j); AzCv_FC_okSubj_best(:,:,j),AzCv_FC_okSubj_best_mean(:,:,j)]')
    set(gca,'xtick',1:(nOkSubj+1),'xticklabel',[subjStr(iOkSubj), {'Mean'}])
    errorbar(nOkSubj+0.875,AzCv_mag_okSubj_best_mean(:,:,j),AzCv_mag_okSubj_best_ste(:,:,j),'k.');
    errorbar(nOkSubj+1.125,AzCv_FC_okSubj_best_mean(:,:,j),AzCv_FC_okSubj_best_ste(:,:,j),'k.');
    PlotHorizontalLines(0.5,'k:');
    xlim([0 nSubj+2]);
    % add stars
    fracPermsToExceed = 1.0;
    for i=1:nOkSubj
        if mean(AzCv_mag_okSubj_best(i)>AzCv_mag_okSubj_perms_best(:,:,i))>=fracPermsToExceed
            plot(i-.125,AzCv_mag_okSubj_best(i)+0.03,'k*');
        end
        if mean(AzCv_FC_okSubj_best(i)>AzCv_FC_okSubj_perms_best(:,:,i))>=fracPermsToExceed
            plot(i+.125,AzCv_FC_okSubj_best(i)+0.03,'k*');
        end
    end
    if mean(AzCv_mag_okSubj_best_mean(:,:,j)>AzCv_mag_okSubj_perms_best_mean)>=fracPermsToExceed
        plot(nOkSubj+0.875,AzCv_mag_okSubj_best_mean+0.075,'k*');
    end
    if mean(AzCv_FC_okSubj_best_mean(:,:,j)>AzCv_FC_okSubj_perms_best_mean)>=fracPermsToExceed
        plot(nOkSubj+1.125,AzCv_FC_okSubj_best_mean+0.075,'k*');
    end
    % Annotate plot
    xlabel('subject');
    ylabel('Cross-validated AUC');
    legend('Mag feats','FC feats');
    grid on;
    title(sprintf('%s > %s, VarKept=(%.2f,%.2f), hrfOffset=%ds',newParams_mag(1).label1,newParams_mag(1).label0,newParams_mag(1).fracMagVarToKeep,newParams_mag(1).fracFcVarToKeep,hrfOffsets(j)));
    set(gcf,'Position',[63 497 1139 379])
    ylim([0 1])
    
end


%% Plot compilation

figure(100+nHrf+1); clf; hold on;
plot(hrfOffsets,[squeeze(AzCv_mag_okSubj_best_mean), squeeze(AzCv_FC_okSubj_best_mean)]);
errorbar(hrfOffsets,squeeze(AzCv_mag_okSubj_best_mean),squeeze(AzCv_mag_okSubj_best_ste),'k.');
errorbar(hrfOffsets,squeeze(AzCv_FC_okSubj_best_mean),squeeze(AzCv_FC_okSubj_best_ste),'k.');
PlotHorizontalLines(0.5,'k:');
xlabel('Window middle time - Page middle time');
ylabel(sprintf('Cross-validated AUC\n(mean +/- stderr across %d subjects)',nSubj));
legend('Mag feats','FC feats');
grid on;
title(sprintf('%s > %s, VarKept=(%.2f,%.2f)',newParams_mag(1).label1,newParams_mag(1).label0,newParams_mag(1).fracMagVarToKeep,newParams_mag(1).fracFcVarToKeep));
set(gcf,'Position',[63 497 1139 379])
ylim([0 1])

%% Plot single-subject comparisons together

% Make barplot
figure(201); clf; hold on;
hBar = bar([squeeze(AzCv_FC_okSubj_best);squeeze(AzCv_FC_okSubj_best_mean)']);
set(gca,'xtick',1:(nOkSubj+1),'xticklabel',[subjStr(iOkSubj), {'Mean'}])
xBar = GetBarPositions(hBar);
errorbar(xBar(:,end),squeeze(AzCv_FC_okSubj_best_mean),squeeze(AzCv_FC_okSubj_best_ste),'k.');
PlotHorizontalLines(0.5,'k:');
xlim([0 nSubj+2]);
% add stars
% fracPermsToExceed = 1.0;
% for i=1:nOkSubj
%     if mean(AzCv_mag_okSubj_best(i)>AzCv_mag_okSubj_perms_best(:,:,i))>=fracPermsToExceed
%         plot(i-.125,AzCv_mag_okSubj_best(i)+0.03,'k*');
%     end
%     if mean(AzCv_FC_okSubj_best(i)>AzCv_FC_okSubj_perms_best(:,:,i))>=fracPermsToExceed
%         plot(i+.125,AzCv_FC_okSubj_best(i)+0.03,'k*');
%     end
% end
% if mean(AzCv_mag_okSubj_best_mean(:,:,j)>AzCv_mag_okSubj_perms_best_mean)>=fracPermsToExceed
%     plot(nOkSubj+0.875,AzCv_mag_okSubj_best_mean+0.075,'k*');
% end
% if mean(AzCv_FC_okSubj_best_mean(:,:,j)>AzCv_FC_okSubj_perms_best_mean)>=fracPermsToExceed
%     plot(nOkSubj+1.125,AzCv_FC_okSubj_best_mean+0.075,'k*');
% end
% Annotate plot
xlabel('subject');
ylabel('Cross-validated AUC');
for i=1:numel(hrfOffsets)
    legendstr{i} = sprintf('winOffset = %d s',hrfOffsets(i));
end
legend(legendstr);
grid on;
title(sprintf('%s > %s, VarKept=(%.2f,%.2f)',newParams_mag(1).label1,newParams_mag(1).label0,newParams_mag(1).fracMagVarToKeep,newParams_mag(1).fracFcVarToKeep));
set(gcf,'Position',[63 497 1600 379])
ylim([0 1])

