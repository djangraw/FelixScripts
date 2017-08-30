% CompareIscOnAtlasTcAndFc.m
%
% Created 12/15/15 by DJ.

% Load atlas
subject = 'SBJ01';
sessions = [1 1 2 2 3 3 4 5 5 6 6 7 7 8 9 9 ];
runs = [1 2 1 2 1 2 1 1 2 1 2 1 2 1 1 2];
% suffix = 'MeicaDenoised.nii'; % include suffix
suffix = 'MeicaDenoised_perm001+orig.BRIK'; % include suffix
atlasdir= '/spin1/users/jangrawdc/PRJ05_100RUNS_3Tmultiecho/PrcsData/SBJ01';
datadir = '/spin1/users/jangrawdc/PRJ05_100RUNS_3Tmultiecho/PrcsData/SBJ01/ICAtest/Perms';

cd(atlasdir)
fprintf('=== %s - Loading Atlas ===\n',datestr(now,0))
[atlasErr,atlas,atlasInfo,ErrMsg] = BrikLoad(sprintf('CraddockAtlas_200Rois_%s_EPI_masked+orig.BRIK',subject));

%% Get timecourses in ROIs
fprintf('=== %s - Getting ROI Timecourses ===\n',datestr(now,0));
cd(datadir);
nRuns = numel(runs);
tc = cell(1,nRuns);
for i=1:nRuns
    fprintf('%s - run %d/%d...\n',datestr(now,0),i,nRuns);
    tc{i} = GetAtlasTimecourses(sprintf('%s_S%02d_R%02d_Video_%s',subject,sessions(i),runs(i),suffix),atlas);
end
tcAll = cat(3,tc{:});


%% Get dynamic FC in each run
fprintf('=== %s - Calculating Dynamic FC ===\n',datestr(now,0));
winLength = 15;
FC = cell(1,50);
for i=1:nRuns
    fprintf('%s - run %d/%d...\n',datestr(now,0),i,nRuns);
    FCmat = GetFcMatrices(tc{i},'sw',winLength);
    % save just the unique (above the diagonal) elements of FCmat
    for j=1:size(FCmat,3)
        thisFC = FCmat(:,:,j);
        FC{i}(:,j) = thisFC(triu(ones(size(thisFC)),1)~=0);
    end
end
fcAll = cat(3,FC{:});
% Get size constants 
[nROIs,nT,nRuns] = size(tcAll);
nFCs = size(fcAll,1);


%% find correlations btw each pair of runs
nPairs = nRuns*(nRuns-1)/2;
coeff_tc = zeros(nROIs,nPairs);
coeff_fc = zeros(nFCs,nPairs);
fprintf('=== %s - Calculating Correlation Coefficients ===\n',datestr(now,0));
iPair = 0;
for i=1:nRuns
    for j=(i+1):nRuns
        iPair = iPair+1;
        fprintf('%s - TC run %d vs. %d/%d...\n',datestr(now,0),i,j,nRuns);
        for k=1:nROIs
            r = corrcoef(tcAll(k,:,i),tcAll(k,:,j)); 
            coeff_tc(k,iPair) = r(1,2);               
        end
        fprintf('%s - TC run %d vs. %d/%d...\n',datestr(now,0),i,j,nRuns);
        for k=1:nFCs
            r = corrcoef(fcAll(k,:,i),fcAll(k,:,j)); 
            coeff_fc(k,iPair) = r(1,2);               
        end
    end
end


%% Get average across run pairs (columns)
avgcoeff_tc = mean(coeff_tc,2);
avgcoeff_fc = mean(coeff_fc,2);

%% Plot results
fprintf('=== %s - Plotting Results ===\n',datestr(now,0));
% map back onto atlas locations
Rval_tc_brick = zeros(size(atlas));
for i=1:nROIs
    Rval_tc_brick(atlas==i) = avgcoeff_tc(i);
end
GUI_3View(Rval_tc_brick);
% GUI_3View(double(cat(4,zval_tc_brick>norminv(0.95),atlas>0,atlas<norminv(.05))));

% Map FC back to matrix
Rval_fc_mat = nan(nROIs,nROIs);
Rval_fc_mat(triu(ones(nROIs),1)==1) = avgcoeff_fc;
% plot as matrix
figure(253); clf;
imagesc(Rval_fc_mat);
colormap jet
xlabel('ROI')
ylabel('ROI')
title(sprintf('%s movie data (%d runs): Z-scored p values from ISC of FC matrix',subject,nRuns))
colorbar
% plot on circle
figure(254); clf;
PlotConnectivityOnCircle(atlas,10,Rval_fc_mat,0.05);
xlabel('<--L----R--->')
ylabel('<--A----P--->')

%% see which ROIs have reliable connectivity with any other
pval_FcDist= nan(nROIs,1);
Rval_fc_avg= nan(nROIs,1);
for i=1:nROIs
    Rval_fc_list = [Rval_fc_mat(i,~isnan(Rval_fc_mat(i,:))), Rval_fc_mat(~isnan(Rval_fc_mat(:,i)),i)'];
    [~,pval_FcDist(i)] = ttest(Rval_fc_list,0); 
    Rval_fc_avg(i) = mean(Rval_fc_list);
%     hist(zval_fc_list);
%     pause;
end
% convert to z score
zval_FcDist = norminv(1-pval_FcDist);
% compare histograms
figure(255);
% hist([zval_tc, zval_FcDist])
% xlabel('Z score')
% legend('timecourse ISC','FC ISC');
subplot(2,1,1);
hist([avgcoeff_tc, Rval_fc_avg]);
legend('timecourse ISC','FC ISC');
xlabel('mean R value')
ylabel('# ROIs')
title(sprintf('%s Movie data (%d runs):\nFC-ISC shows greater correlation across runs than standard ISC',subject,nRuns))
subplot(2,1,2);
hist(zval_FcDist);
xlabel('Z score')
ylabel('# ROIs')
title(sprintf('%s Movie data (%d runs):\nFC-ISC shows greater correlation across runs than standard ISC',subject,nRuns))

fprintf('=== %s - Done! ===\n',datestr(now,0));

%% Compare TC and FC results using GUI_3View
zval_FcDist_brick = zeros(size(atlas));
for i=1:nROIs
    zval_FcDist_brick(atlas==i) = zval_FcDist(i);
end
GUI_3View(cat(4,Rval_tc_brick>norminv(1-1/nROIs),Rval_tc_brick*0,zval_FcDist_brick>norminv(1-1/nROIs)));



