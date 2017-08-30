function TestIscPValueTrends_afni(subject,nRuns,maskFilename)

% TestIscPValueTrends_afni(subject,nRuns)
%
% INPUTS: 
% -subject is a string, e.g., 'SBJ01', indicating the subject in your
% filenames.
% -nRuns is a vector of the number of runs included in various analyses.
% 
% The function expects filenames of the form
% 'ISC_<subject>_<nRuns>Runs.mat'.
%
% Created 3/20/15 by DJ.
% Updated 3/24/15 by DJ.

if ~exist('subject','var') || isempty(subject)
    subject = 'SBJ01';
end
if ~exist('nRuns','var') || isempty(nRuns)
    nRuns = [5 10 20 40 60 80 100];
end
if ~exist('maskFilename','var') || isempty(maskFilename)
%     maskFilename = sprintf('c%s_GM_Mask_v02+tlrc',subject); useMask=true;
    useMask = false;
else
    useMask = true;
end

resultsFile = sprintf('ISC_ttest%dfiles+orig',nRuns(1));
[err,foo,Info,ErrMessage] = BrikLoad(resultsFile);
p = zeros([size(foo,1), size(foo,2), size(foo,3), numel(nRuns)]);
for i=1:numel(nRuns)
    fprintf('loading %d/%d...\n',i,numel(nRuns));
    resultsFile = sprintf('ISC_ttest%dfiles+orig',nRuns(i));
    [err,foo,Info,ErrMessage] = BrikLoad(resultsFile);
    pval = normcdf(-abs(foo(:,:,:,2)),0,1)*2;
    p(:,:,:,i) = pval;
end

% load in mask
if useMask
    if ischar(maskFilename)
        [err,mask,Info,ErrMessage] = BrikLoad(maskFilename);    
    else
        mask = maskFilename;
    end
else
    mask = ones(size(foo.pval));
end

iCheckRuns = 5;
iTruePos = find(p(:,:,:,end)<0.05 & p(:,:,:,iCheckRuns)>=0.05 & mask>0); % limit to samples above 0.05 at nRuns=40
iTrueNeg = find(p(:,:,:,end)>=0.05 & p(:,:,:,iCheckRuns)>=0.05 & mask>0); % limit to samples above 0.05 at nRuns=40
fprintf('%d TP, %d TN\n',numel(iTruePos),numel(iTrueNeg));

%%
%pick a few TP's & TN's at random
[iTP,jTP,kTP] = ind2sub(size(foo.pval),iTruePos(ceil(rand(20,1)*numel(iTruePos))));
[iTN,jTN,kTN] = ind2sub(size(foo.pval),iTrueNeg(ceil(rand(20,1)*numel(iTrueNeg))));

figure(1); clf; hold on;
for i=1:numel(iTP)    
    %plot their p value trajectories
    plot(nRuns,squeeze(p(iTP(i),jTP(i),kTP(i),:)),'r.-');
end
for i=1:numel(iTN)    
    %plot their p value trajectories
    plot(nRuns,squeeze(p(iTN(i),jTN(i),kTN(i),:)),'b.-');
end

PlotHorizontalLines(0.05,'k--');
set(gca,'ydir','normal')
xlabel('nRuns')
ylabel('ISC p value')
MakeLegend({'r.-','b.-','k--'},{'true positives','true negatives','p=0.05'},[1 1 1],[0.87 0.9]);
title(sprintf('%s, GM voxels with p>0.05 at nRuns=%d (truth: p<0.05 at nRuns=%d)',subject,nRuns(iCheckRuns),nRuns(end)))
%% OR get all TPs/TNs and make hists
pHist = 0.025:0.05:1;
histoPos = zeros(numel(nRuns),numel(pHist));
histoNeg = zeros(numel(nRuns),numel(pHist));
for i=1:numel(nRuns)
    p_temp = p(:,:,:,i);
    histoPos(i,:) = hist(p_temp(iTruePos),pHist)/numel(iTruePos);
    histoNeg(i,:) = hist(p_temp(iTrueNeg),pHist)/numel(iTrueNeg);
end
figure(2); clf;
subplot(1,3,1); cla;
uimagesc(nRuns,pHist,histoPos');
% imagesc(nRuns,pHist,histoPos');
set(gca,'ydir','normal','clim',[0 0.5])
xlabel('nRuns'); ylabel('ISC p value'); 
title('true positives');
colorbar
subplot(1,3,2); cla;
uimagesc(nRuns,pHist,histoNeg');
% imagesc(nRuns,pHist,histoNeg');
set(gca,'ydir','normal','clim',[0 0.5])
xlabel('nRuns'); ylabel('ISC p value'); 
title('true negatives');
colorbar
subplot(1,3,3); cla;
uimagesc(nRuns,pHist,(histoPos./(histoPos+histoNeg))');
% imagesc(nRuns,pHist,histoNeg');
set(gca,'ydir','normal','clim',[0 1])
xlabel('nRuns'); ylabel('ISC p value'); 
title('TP/(TP+TN)');
colormap(gca,'jet')
colorbar
MakeFigureTitle(sprintf('%s, GM voxels with p>=0.05 at %d runs',subject,nRuns(iCheckRuns)));