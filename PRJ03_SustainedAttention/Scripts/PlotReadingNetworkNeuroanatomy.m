% PlotReadingNetworkNeuroanatomy.m
%
% Created 1/5/17 by DJ.

% subjects = [9:11 13:19 22 24:25 28 30:33 36];
subjects = [9:11 13:19 22 24:25 28 30:34 36];

afniProcFolder = 'AfniProc_MultiEcho_2016-09-22'; % 9-22 = MNI
tsFilePrefix = 'shen268_withSegTc'; % 'withSegTc' means with BPFs
tsFilePrefix2 = 'shen268_withSegTc2'; % 'withSegTc2' means with BPFs
% tsFilePrefix = 'shen268_withSegTc_Rose'; % _Rose means with motion squares regressed out and gaussian filter
runComboMethod = 'avgRead'; % average of run-wise FC, limited to reading samples
doPlot = false;

%% Get FC
[FC,isMissingRoi,FC_runs] = GetFc_AllSubjects(subjects,afniProcFolder,tsFilePrefix,runComboMethod);
[FC2,~,~] = GetFc_AllSubjects(subjects,afniProcFolder,tsFilePrefix2,runComboMethod);

%% Get performance
[fracCorrect, RT] = GetFracCorrect_AllSubjects(subjects);

%% Get Reading Network and predictions
thresh = 0.01;
corr_method = 'robustfit';
mask_method = 'one';
[read_pos, read_neg, read_glm,read_posMask_all,read_negMask_all] = RunLeave1outBehaviorRegression(FC,fracCorrect,thresh,corr_method,mask_method);
[read_pos2, read_neg2, read_glm2,read_posMask_all2,read_negMask_all2] = RunLeave1outBehaviorRegression(FC2,fracCorrect,thresh,corr_method,mask_method);

%% Get cpcr
corr_method = 'robustfit';
mask_method = 'cpcr';
thresh = 0;
[~,~,~,read_cp,read_cr] = RunLeave1outBehaviorRegression(FC,fracCorrect,thresh,corr_method,mask_method);
[~,~,~,read_cp2,read_cr2] = RunLeave1outBehaviorRegression(FC2,fracCorrect,thresh,corr_method,mask_method);

%% Compare reading networks with/without GSR

read_comboMask = all(read_posMask_all>0,3)-all(read_negMask_all>0,3);
read_comboMask2 = all(read_posMask_all2>0,3)-all(read_negMask_all2>0,3);
clim = 22;

figure(278);
subplot(121);
PlotFcMatrix(read_comboMask,[-1 1]*clim,shenAtlas,shenLabels,true,shenColors,'sum');
title('Networks without GSR')
subplot(122);
PlotFcMatrix(read_comboMask2,[-1 1]*clim,shenAtlas,shenLabels,true,shenColors,'sum');
title('Networks with GSR')

%% Get Shen Atlas
fprintf('Loading attention network matrices...\n')
[shenAtlas,shenInfo] = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_2mm_268_parcellation.nii.gz');
[shenLabels,shenLabelNames,shenColors] = GetAttnNetLabels(false);
[shenLabels_hem,shenLabelNames_hem,shenColors_hem] = GetAttnNetLabels(true); % with hemispheres separated


%% List  Get most connected ROIs in order
foo = UnvectorizeFc(VectorizeFc(read_comboMask),0,true);
nCxns = sum(abs(foo));
nCxns_pos = sum(foo>0);
nCxns_neg = sum(foo<0);
[~,order] = sort(nCxns,'descend');
nTop = 20;
fprintf('---Top %d---\n',nTop);
for i=1:nTop
    iRoi = order(i);
    fprintf('%d. ROI %d (%s): %d cxns (%d+, %d-)\n',i, iRoi,shenLabelNames_hem{shenLabels_hem(iRoi)},nCxns(iRoi),nCxns_pos(iRoi),nCxns_neg(iRoi));
end

%% Plot one ROI (click on it to map it
% Pos ROIs
% iRoi = 212; % L Occipital Pole (11+, 0-)
% iRoi = 78; % R Occipital Pole (7+, 1-)
% iRoi = 104; % R Cerebellum (8+, 2-)
% Neg ROIs
iRoi = 244; % L Cerebellar peak? (2+, 14-)
% iRoi = 49; %R Parietal (1+, 11-)
% iRoi = 36; %R Insula (2+, 9-)
% iRoi = 8; %R Prefrontal (0+, 9-);

thresh = 0.5;
read_cr_mean = mean(read_cr,3);
read_cp_max = max(read_cp,[],3);
read_cr_mean(read_cp_max>thresh) = 0;
figure(376);clf;
PlotFcMatrix(read_cr_mean,[-1 1],shenAtlas,[],true,[],false);
% PlotFcMatrix(read_comboMask,[-1 1],shenAtlas,[],true,[],false);
ylim([-1 1]+iRoi);

%% Combine across all of a region (nInNetwork version)
nClusters = numel(shenLabelNames_hem);
foo = UnvectorizeFc(VectorizeFc(read_comboMask),0,true);
foo2 = nan(size(foo));
foo3 = nan(nClusters,size(foo,2));
for i=1:nClusters
    isInNetwk = shenLabels_hem==i;
    foo2(isInNetwk,:) = repmat(sum(foo(isInNetwk,:),1),sum(isInNetwk),1);
    foo3(i,:) = sum(foo(isInNetwk,:),1);
end
figure(111); clf;
PlotFcMatrix(foo2,[-1 1]*2,shenAtlas,shenLabels_hem,true,shenColors_hem,false);
% set(gca,'ytick',1:nClusters,'yticklabel',show_symbols(shenLabelNames_hem));
% ylim('auto')

%% Combine across all of a region (mean CR version)
foo = UnvectorizeFc(VectorizeFc(read_cr_mean),0,true);
nClusters = numel(shenLabelNames_hem);
foo2 = nan(size(foo));
foo3 = nan(nClusters,size(foo,2));
for i=1:nClusters
    isInNetwk = shenLabels_hem==i;
    foo2(isInNetwk,:) = repmat(mean(foo(isInNetwk,:),1),sum(isInNetwk),1);
    foo3(i,:) = mean(foo(isInNetwk,:),1);
end


%%
figure(112); clf;
% for iCluster = 1:20
iCluster = 2;
iSlices = round(linspace(12,80,16));
clim = .5;%1;%.25;
% iSlices = round(linspace(1,size(shenAtlas,1),9));
pos = (foo3(iCluster,:).*(foo3(iCluster,:)>0))/clim;
neg = -(foo3(iCluster,:).*(foo3(iCluster,:)<0))/clim;
mask = repmat(0.4,size(foo,2),1);
mask(shenLabels_hem==iCluster) = 1;
shenTemp = MapColorsOntoAtlas(shenAtlas,[pos', mask, neg']);
DisplaySlices(shenTemp,1,iSlices,[],[-1 1],true);
colorbar off
title(sprintf('%s region: Reading Network Connectivity (clim=%g)',shenLabelNames_hem{iCluster},clim),'interpreter','none')
% pause;
% end

%% Save cluster cxns as AFNI brick
clusterName_Short = 'rPre';%'rCer';
shenTemp = MapValuesOntoAtlas(shenAtlas,pos-neg);
WriteBrik(shenTemp,shenInfo,struct('Prefix',sprintf('Distraction-Shen%sRegion-ReadingNetworkCxns',clusterName_short)));

%% Save ROI cxns as AFNI brick
iRoi = 212;
foo = UnvectorizeFc(VectorizeFc(read_comboMask),0,true);
shenTemp = MapValuesOntoAtlas(shenAtlas,foo(iRoi,:));
cd /data/jangrawdc/PRJ03_SustainedAttention/Results
WriteBrik(shenTemp,shenInfo,struct('Prefix',sprintf('Distraction-ShenRoi%03d-ReadingNetworkCxns',iRoi)));

%% Save cluster CR as AFNI brick
iRois = [212 244 78 42 117];
for iRoi = iRois
    read_cr_mean = mean(read_cr,3);
    read_cr_mean_full = UnvectorizeFc(VectorizeFc(read_cr_mean),0,true);
    read_cp_max = max(read_cp,[],3);
    read_cp_max_full = UnvectorizeFc(VectorizeFc(read_cp_max),0,true);
    read_cz_max_full = abs(norminv(read_cp_max_full));% .* -sign(read_cr_mean_full);
    shenTemp = cat(4, MapValuesOntoAtlas(shenAtlas,read_cr_mean_full(iRoi,:)), MapValuesOntoAtlas(shenAtlas,read_cz_max_full(iRoi,:)));
    cd /data/jangrawdc/PRJ03_SustainedAttention/Results
    newInfo = shenInfo;
    newInfo.BRICK_LABS='CR~CP-to-z';
    newInfo.BRICK_TYPES=[3 3];
    WriteBrik(shenTemp,shenInfo,...
        struct('Prefix',sprintf('Distraction-ShenRoi%03d-ReadingNetworkMeanCr',iRoi),...
        'OverWrite','y'));
end