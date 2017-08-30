% GetVideoArousalTimecourses_script.m
%
% Created 7/6/17 by DJ.


sessions = [1 1 2 2 3 3 4 5 5 6 6 7 7 8 9 9];
runs =     [1 2 1 2 1 2 1 1 2 1 2 1 2 1 1 2];
subjects = ones(size(runs));

sessions = [sessions, 1 1 2 2 3 3 4 5 5 6 6 7 7 8 8 9 9];
runs =     [runs, 1 2 1 2 1 2 1 1 2 1 2 1 2 1 2 1 2];
subjects = [subjects, ones(size(runs))*2];

% Get filenames
nFiles = numel(runs);
[filenames,maskNames,templateNames] = deal(cell(1,nFiles));
for i=1:nFiles
    folder = sprintf('/data/jangrawdc/PRJ05_100RUNS_3Tmultiecho/PrcsData/SBJ%02d',subjects(i));
    filenames{i} = sprintf('%s/SBJ%02d_S%02d_R%02d_Video_Echo2_blur6+orig',folder,subjects(i),sessions(i),runs(i));
    maskNames{i} = sprintf('%s/SBJ%02d_FullBrain_EPIRes+orig',folder,subjects(i));
    templateNames{i} = sprintf('/data/jangrawdc/PRJ14_ArousalIsc/ArousalTemplate_SBJ%02d_EPI+orig.HEAD',subjects(i));
end

% Get arousal template match for each subject/run
fprintf('Run %d/%d...\n',1,nFiles)
foo = GetSpatialTemplateMatch(filenames{1},templateNames{1},maskNames{1});
nT = numel(foo);
match = nan(nT,nFiles);
match(:,1) = foo;
tic;
for i=2:nFiles
    fprintf('Run %d/%d...\n',i,nFiles)
    match(:,i) = GetSpatialTemplateMatch(filenames{i},templateNames{i},maskNames{i});
end
fprintf('Done! Took %.1f seconds.\n',toc);
% Correlate across runs
matchCorr = corr(match);

%% Plot
TR = 2;
fprintf('Plotting match timecourses...\n')
t = (1:nT)*TR;
figure(3); clf;
subplot(2,1,1);
plot(t,match);
xlabel('time (s)');
ylabel('match strength (correlation coeff)')
title(sprintf('Arousal template match for subject %d', subjects(1)))
subplot(2,1,2);
plot(t,match-repmat(mean(match,1),nT,1));
xlabel('time (s)');
ylabel('match strength (demeaned)')

% 
figure(4);
imagesc(matchCorr);
colorbar;
xlabel('run')
ylabel('run')
set(gca,'clim',[0 1]);
title(sprintf('Arousal template match for subject %d', subjects(1)))

%% Compare to permutations
nPerms = 10000;

tic;
matchPerm = nan(nT,nFiles,nPerms);
for i=1:nFiles
    fprintf('===Run %d/%d...\n',i,nFiles)
    data = BrikLoad(filenames{i});
    template = BrikLoad(templateNames{i});
    mask = BrikLoad(maskNames{i});    
    for iPerm=1:nPerms
        fprintf('Perm %d/%d...\n',iPerm,nPerms);        
        matchPerm(:,i,iPerm) = GetSpatialTemplateMatch(data,template,mask,true);    
    end
end

fprintf('Correlating results...\n');
matchCorr_perm = nan(nFiles,nFiles,nPerms);
for iPerm=1:nPerms
    matchCorr_perm(:,:,iPerm) = corr(matchPerm(:,:,iPerm));
end
fprintf('Done! Took %.1f seconds.\n',toc);

%% Get p values

p = nan(size(matchCorr));
for i=1:size(matchCorr,1)
    for j=1:size(matchCorr,2)
        p(i,j) = mean(matchCorr(i,j)<matchCorr_perm(i,j,:));
    end
end

% save results
save('Video100Runs_ArousalTimecourseCorrelations','p','match','matchCorr','matchCorr_perm','sessions','runs','subjects');

%% Get p value for mean across all pairs

meanMatchCorr = mean(matchCorr(matchCorr<1));
meanMatchCorr_perm = nan(nPerms,1);
for iPerm = 1:nPerms
    this = matchCorr_perm(:,:,iPerm);
    meanMatchCorr_perm(iPerm) = mean(this(this<1));
end

p_mean = mean(meanMatchCorr<meanMatchCorr_perm);
fprintf('p = %0.3g\n',p_mean);