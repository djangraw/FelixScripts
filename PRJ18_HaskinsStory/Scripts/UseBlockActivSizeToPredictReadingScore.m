% UseBlockActivSizeToPredictReadingScore.m
%
% Created 5/23/18 by DJ.

info = GetStoryConstants();

[subj_sorted,readScore_sorted] = GetStoryReadingScores();
isOkSubj = ismember(subj_sorted,info.okReadSubj);
subj_sorted = subj_sorted(isOkSubj);
readScore_sorted = readScore_sorted(isOkSubj);

%% Get size of p<0.05 activation for each subject
% pThr = 0.05;
pThr = [0.05 0.01 1e-3 1e-4 1e-5 1e-6 1e-7 1e-8];
thresh = norminv(1-pThr/2); % z corresponding to given 2-sided p value
iBricks = 3:3:12;
activSize = nan(numel(subj_sorted),numel(thresh),numel(iBricks));
for i=1:numel(subj_sorted)
    fprintf('subj %d/%d...\n',i,numel(subj_sorted))
    subj = subj_sorted{i};
    filename = sprintf('%s/%s/%s.storyISC_d2/stats.block.%s_REML+tlrc',info.dataDir,subj,subj,subj);
%     V = BrikLoad(filename,struct('Frames',3)); % 12: #2 aud in AFNI
%     V = BrikLoad(filename,struct('Frames',6)); % 12: #5 vis in AFNI
%     V = BrikLoad(filename,struct('Frames',9)); % 12: #8 aud+vis in AFNI
    V = BrikLoad(filename,struct('Frames',iBricks)); % 12: #11 aud-vis in AFNI
    for j=1:numel(thresh)
        for k=1:size(V,4)
            activSize(i,j,k) = sum(sum(sum(abs(V(:,:,:,k))>thresh(j))));
        end
    end
end
fprintf('Done!\n');

%% Correlate with reading score
figure(246);
[r,p] = deal(nan(size(thresh)));
brickNames = {'aud','vis','aud+vis','aud-vis'};
for k=1:numel(iBricks)
    fprintf('brick %d (%s):\n',k,brickNames{k});
    for j=1:numel(thresh)
        [r(j),p(j)] = corr(activSize(:,j,k),readScore_sorted');
        fprintf('pThr = %.2g: r=%.3g, p=%.3g\n',pThr(j),r(j),p(j));
    end
    subplot(2,2,k)
    plot(thresh,[r;p]','.-');
    xlabel(sprintf('z threshold (%s)',brickNames{k}))
    ylabel(sprintf('correlation btw activation size\n and reading score'))
    legend('r','p')
end