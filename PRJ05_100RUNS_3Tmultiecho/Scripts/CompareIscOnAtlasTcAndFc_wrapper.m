% Created 12/16/15 by DJ.

subject = 'SBJ01';
sessions = [1 1 2 2 3 3 4 5 5 6 6 7 7 8 9 9 ];
runs = [1 2 1 2 1 2 1 1 2 1 2 1 2 1 1 2];
% suffix = 'MeicaDenoised.nii'; % include suffix
atlasdir= '/spin1/users/jangrawdc/PRJ05_100RUNS_3Tmultiecho/PrcsData/SBJ01';
datadir = '/spin1/users/jangrawdc/PRJ05_100RUNS_3Tmultiecho/PrcsData/SBJ01/ICAtest/Perms';

cd(atlasdir)
fprintf('=== %s - Loading Atlas ===\n',datestr(now,0))
[atlasErr,atlas,atlasInfo,ErrMsg] = BrikLoad(sprintf('CraddockAtlas_200Rois_%s_EPI_masked+orig.BRIK',subject));
nPerms = 100;

%% Get regular results
suffix = 'MeicaDenoised.nii'; % include suffix
[Rval_fc_avg, avgcoeff_tc, avgcoeff_fc] = CompareIscOnAtlasTcAndFc(subject,sessions,runs,suffix,atlas);

%% Save regular results
save(sprintf('%s_%druns_IscOnAtlasTcAndFc.mat',subject,numel(runs)),'subject','sessions','runs','suffix','atlasdir','datadir','Rval_fc_avg','avgcoeff_tc','avgcoeff_fc')

%% Make permutations
nRuns = numel(runs);
filenames = cell(1,nRuns);
for i=1:nRuns
    filenames{i} = sprintf('%s_S%02d_R%02d_Video_%s',subject,sessions(i),runs(i),suffix);
end
fileout = TimeShiftAllFiles(filenames,nPerms);

%% Run analysis on permutations
cd(datadir);
[Rval_fc_avg, avgcoeff_tc, avgcoeff_fc] = deal(cell(1,nPerms));
for iPerm = 1:nPerms
    fprintf('====== PERMUTATION %d/%d...\n',iPerm,nPerms);
    suffix = sprintf('MeicaDenoised_perm%03d+orig.BRIK',iPerm); % include suffix
    [Rval_fc_avg{iPerm}, avgcoeff_tc{iPerm}, avgcoeff_fc{iPerm}] = CompareIscOnAtlasTcAndFc(subject,sessions,runs,suffix,atlas);
end

%% Save permutation results
save(sprintf('%s_%druns_IscOnAtlasTcAndFc_perms.mat',subject,numel(runs)),'subject','sessions','runs','suffix','atlasdir','datadir','Rval_fc_avg','avgcoeff_tc','avgcoeff_fc')



%% Load permutation and regular results
perms = load(sprintf('%s_%druns_IscOnAtlasTcAndFc_perms.mat',subject,numel(runs)));
regular = load(sprintf('%s_%druns_IscOnAtlasTcAndFc.mat',subject,numel(runs))); 

%% Plot results
figure(624); clf;
% Plot histograms of TC and FC R values for each ROI
xHist = -0.03:0.005:0.2;
cutoff_TC = GetValueAtPercentile(cat(1,perms.avgcoeff_tc{:}),95);
cutoff_FC = GetValueAtPercentile(cat(1,perms.Rval_fc_avg{:}),95);

subplot(2,1,1); cla; hold on;
nReg_TC = hist(regular.avgcoeff_tc,xHist);
nPerm_TC = hist(cat(1,perms.avgcoeff_tc{:}),xHist);
plot(xHist,[nPerm_TC/sum(nPerm_TC); nReg_TC/sum(nReg_TC)]'*100);
PlotVerticalLines(cutoff_TC,'g');
xlabel('Mean R_{TC} value');
ylabel('% ROIs')
legend('permutations','true data','p=0.05 (1-tailed)');
title(sprintf('%s (%d runs)',subject,nRuns))
subplot(2,1,2); hold on;
nReg_FC = hist(regular.Rval_fc_avg,xHist);
nPerm_FC = hist(cat(1,perms.Rval_fc_avg{:}),xHist);
plot(xHist,[nPerm_FC/sum(nPerm_FC); nReg_FC/sum(nReg_FC)]'*100);
PlotVerticalLines(cutoff_FC,'g');
xlabel('Mean R_{FC} value');
ylabel('% ROIs')
legend('permutations','true data','p=0.05 (1-tailed)');
drawnow;

% Plot significant ROIs on brick
Rval_fc_avg_brick = zeros(size(atlas));
avgcoeff_tc_brick = zeros(size(atlas));
for i=1:max(atlas(:))
    Rval_fc_avg_brick(atlas==i) = regular.Rval_fc_avg(i);
    avgcoeff_tc_brick(atlas==i) = regular.avgcoeff_tc(i);
end

GUI_3View(double(cat(4,Rval_fc_avg_brick>cutoff_FC,atlas>0,avgcoeff_tc_brick>cutoff_TC)),round(size(atlas)/2));