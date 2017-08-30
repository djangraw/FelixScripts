% ExploreGlmsAndNetworks.m
%
% Created 1/13/17 by DJ.

%% Plot GLM Results in each region

shenAtlas_regions = MapValuesOntoAtlas(shenAtlas,shenLabels_hem);
[groupResults,groupInfo] = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/GROUP_2017-01-12/ttest_stimOnly+tlrc');
[~,info] = BrikInfo('/data/jangrawdc/PRJ03_SustainedAttention/Results/GROUP_2017-01-12/coef_stimOnly.SBJ36.blur_fwhm4p0.scale+tlrc');
brickLabels=strsplit(info.BRICK_LABS,'~');
% goodLabels = {'ignoredNoise#0_Coef','attendedNoise#0_Coef','ignoredSpeech#0_Coef','attendedSpeech#0_Coef'};
% goodLabels = {'Reading_GLT#0_Coef'}; % Just one
goodLabels = {'ReadingVsFixation_GLT#0_Coef'}; % Just one
iBrick = find(ismember(brickLabels,goodLabels));
meanInRegion = nan(1,numel(shenLabelNames_hem));
for i=1:numel(shenLabelNames_hem)
    meanGroupResults = mean(groupResults(:,:,:,iBrick*2),4);
    meanInRegion(i) = mean(meanGroupResults(shenAtlas_regions==i));
end
meanInRegion_norm = normalise(meanInRegion-mean(meanInRegion));
FC_grouped = GroupFcByRegion(read_comboMask,shenLabels_hem,'sum');
FC_grouped_norm = normalise(sum(FC_grouped)-mean(sum(FC_grouped)));

figure(278); clf;
subplot(221);
[~,~,~,FC_grouped,hRect] = PlotFcMatrix(read_comboMask,[-1 1]*clim(3),shenAtlas,shenLabels_hem,true,shenColors_hem,'sum');
set(gca,'xtick',1:numel(shenLabelNames_hem),'xticklabel',show_symbols(shenLabelNames_hem))
set(gca,'ytick',1:numel(shenLabelNames_hem),'yticklabel',show_symbols(shenLabelNames_hem))
xticklabel_rotate;
title('Reading Networks')
delete(hRect);

subplot(222);
bar([meanInRegion_norm; FC_grouped_norm]')
set(gca,'xtick',1:numel(shenLabelNames_hem),'xticklabel',show_symbols(shenLabelNames_hem))
xticklabel_rotate;
legend('mean response to reading (norm)','edges in high network - edges in low network (norm)');

subplot(223);
nLabels = numel(shenLabelNames_hem);
foo = repmat(meanInRegion_norm',1,nLabels)+repmat(meanInRegion_norm,nLabels,1);
imagesc(foo);
set(gca,'clim',[-1 1]*.5)
% imagesc(meanInRegion_norm'*meanInRegion_norm);
title('meanInRegion_norm & meanInRegion_norm','interpreter','none')
xlabel('Cluster')
ylabel('Cluster')
set(gca,'xtick',1:numel(shenLabelNames_hem),'xticklabel',show_symbols(shenLabelNames_hem))
set(gca,'ytick',1:numel(shenLabelNames_hem),'yticklabel',show_symbols(shenLabelNames_hem))
xticklabel_rotate;
axis square;
colorbar;

subplot(224);
lm = fitlm(meanInRegion, sum(FC_grouped),'Linear'); % least squares
lm.plot();
[r,p] = corr(meanInRegion',sum(FC_grouped)');
xlabel('mean response to reading')
ylabel('edges in high network - edges in low network')
title(sprintf('r = %.3g, p = %.3g',r,p));
legend('region','linear fit','95% confidence')

%% Try at the ROI level
% Get reading CR
foo = load('ReadingCpCr_19subj_2016-12-19');
read_cp = foo.cp_all;
read_cr = foo.cr_all;
% Get mean activation by reading in each ROI
nROIs = numel(shenLabels_hem);
meanInRoi = nan(1,nRois);
for i=1:nROIs
    meanGroupResults = mean(groupResults(:,:,:,iBrick*2-1),4);
    meanInRoi(i) = mean(meanGroupResults(shenAtlas==i));
end
% Compare to mean CR across LOSO iterations and partner ROIs
meanCr = mean(mean(read_cr,3),2);
figure(473); clf;
lm = fitlm(meanInRoi, meanCr,'Linear'); % least squares
lm.plot();
[r,p] = corr(meanInRoi',meanCr);
xlabel('mean response to reading')
ylabel('mean CR with all other ROIs')
title(sprintf('r = %.3g, p = %.3g',r,p));
legend('ROI','linear fit','95% confidence')

%% Try using meanInRoi to predict performance

% get meanInRoi for each subject
nSubj=numel(subjects);
meanInRoi_subj = nan(nROIs, nSubj);
goodLabels = {'ReadingVsFixation_GLT#0_Coef'}; % Just one
iBrick = find(ismember(brickLabels,goodLabels));
for i=1:nSubj
    fprintf('Loading subj %d/%d...\n',i,nSubj);
    cd(sprintf('/data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ%02d/AfniProc_MultiEcho_2016-09-22',subjects(i)));
    foo = BrikLoad(sprintf('coef_stimOnly.SBJ%02d.blur_fwhm4p0.scale+tlrc',subjects(i)));
    foo = foo(:,:,:,iBrick);
    for j=1:nROIs
        meanInRoi_subj(j,i) = mean(foo(shenAtlas==j));
    end
end
fprintf('Done!\n');

%% Use to predict behavior
[activityScore,networks,cp,cr] = RunLeaveOneOutRegressionWithActivity(activity,behav,thresh);

% Plot results
isPosExpected = true;
[p,Rsq,lm] = Run1tailedRegression(fracCorrect*100,activityScore,isPosExpected);
% r = sqrt(lm.Rsquared.Ordinary);
r = corr(fracCorrect*100,activityScore);
% Plot and annotate
figure(445); clf;
h = lm.plot;
xlabel('% correct');
ylabel(sprintf('GLM Region score'));
title(sprintf('GLM-based Prediction, thresh=%.3g\nr=%.3g, p=%.3g',thresh,r,p));
legend('Subject','Linear Fit','95% Confidence bounds');%,'Location','Northwest')

figure(446); clf;
iSlices = round(linspace(4,46,16));
clim = .5;%1;%.25;
% iSlices = round(linspace(1,size(shenAtlas,1),9));
shenTemp = MapValuesOntoAtlas(shenAtlas,mean(cr,2));
DisplaySlices(shenTemp,1,iSlices,[],[-1 1],true);
colorbar off
title(sprintf('Reading Network Activity'),'interpreter','none')

figure(447); clf;
% group by region
meanCr = mean(cr,2);
nReg = numel(shenLabelNames_hem);
meanCrInRegion = nan(1,nReg);
% meanFcCr = mean(mean(read_cr,3),2);
% meanFcCrInRegion = nan(1,nReg);
for i=1:nReg
    meanCrInRegion(i) = mean(meanCr(shenLabels_hem==i));
%     meanFcCrInRegion(i) = mean(meanFcCr(shenLabels_hem==i));
end
hBar = bar(meanCrInRegion);
% bar([meanCrInRegion; meanFcCrInRegion*10]');
xlim([0 nReg+1]);
set(gca,'xtick',1:nReg,'xticklabel',show_symbols(shenLabelNames_hem));
xticklabel_rotate;
ylabel(sprintf('mean correlation between ROIs in this region\nand reading comprehension'))

%% Sweep threshold
threshes = 0.01:0.01:1;
[p,r] = deal(nan(numel(threshes),1));
for iThresh = 1:numel(threshes)
    thresh = threshes(iThresh);
    for i=1:nSubj
        isPos(:,i) = cp(:,i)<thresh & cr(:,i)>0;
        isNeg(:,i) = cp(:,i)<thresh & cr(:,i)<0;
        score(i) = meanInRoi_subj(:,i)'*(isPos(:,i)-isNeg(:,i));
    end
    isPosExpected = true;
    [p(iThresh),Rsq,lm] = Run1tailedRegression(fracCorrect*100,score,isPosExpected);
    % r = sqrt(lm.Rsquared.Ordinary);
    r(iThresh) = corr(fracCorrect*100,score);
end
% Plot results
figure(446); clf;
plot(threshes,[r,p]);
xlabel('threshold')
ylabel('correlation with behavior')
legend('r','p');
grid on
title('GLM-based performance predictions at varying thresholds')