% CompareRosenbergAndReadingCpCr.m
%
% Created 10/18/16 by DJ.


%% Get atlas & attention networks
shenAtlas = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_2mm_268_parcellation.nii.gz');
attnNets = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/attn_nets_268.mat');
uppertri = triu(ones(size(attnNets.pos_overlap,1)),1);
attnNets.pos_overlap(~uppertri) = 0;
attnNets.neg_overlap(~uppertri) = 0;
[attnNetLabels,labelNames,colors] = GetAttnNetLabels(false);

%% Load cp/cr matrices
readCpCr = load('/data/jangrawdc/PRJ03_SustainedAttention/Results/ReadingCpCr_25subj.mat');
roseCpCr_cell = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/Rosenberg2016_weights.mat');

% convert Rosenberg version to match reading version
n_node = size(readCpCr.cp_all,1);
uppertri = triu(ones(n_node),1)==1;
n_sub_rose = numel(roseCpCr_cell.cp);
roseCpCr.cp_all = nan(n_node,n_node,n_sub_rose);
roseCpCr.cr_all = nan(n_node,n_node,n_sub_rose);
for j=1:n_sub_rose
    tmp = zeros(n_node);
    tmp(uppertri) = roseCpCr_cell.cp{j};
    roseCpCr.cp_all(:,:,j) = tmp;
    tmp(uppertri) = roseCpCr_cell.cr{j};
    roseCpCr.cr_all(:,:,j) = tmp;
end

%% Test effectiveness
readThreshes = [0.01 0.05 0.1 0.5 1];
n_sub = size(readCpCr.cr_all,3);
[readSum_pos, readSum_neg] = deal(nan(numel(readThreshes),n_sub));
for i=1:numel(readThreshes)
    for j=1:n_sub
        % Get reading matrices
        readMask_pos = readCpCr.cr_all(:,:,j)>0 & readCpCr.cp_all(:,:,j)<readThreshes(i);
        readMask_pos(~uppertri) = 0;
        readMask_neg = readCpCr.cr_all(:,:,j)<0 & readCpCr.cp_all(:,:,j)<readThreshes(i);
        readMask_neg(~uppertri) = 0;
        readSum_pos(i,j) = sum(sum(train_mats(:,:,j).*readMask_pos))/sum(readMask_pos(:));
        readSum_neg(i,j) = sum(sum(train_mats(:,:,j).*readMask_neg))/sum(readMask_neg(:));
    end
    % Test significance of trends
    [r_pos,p_pos] = corr(readCpCr.behav, readSum_pos(i,:)');
    [r_neg,p_neg] = corr(readCpCr.behav, readSum_neg(i,:)');    

    % Plot results
    subplot(numel(readThreshes),2,i*2-1); cla;
    scatter(readCpCr.behav,readSum_pos(i,:));
    xlabel('reading comprehension accuracy (%)');
    ylabel('mean pos mask strength')
    title(sprintf('Pos mask, p<%.2f threshold\nr=%.2g, p=%.2g',readThreshes(i),r_pos,p_pos))
    subplot(numel(readThreshes),2,i*2); cla;
    scatter(readCpCr.behav,readSum_neg(i,:));
    xlabel('reading comprehension accuracy (%)');
    ylabel('mean neg edge strength')
    title(sprintf('Neg mask, p<%.2f threshold\nr=%.2g, p=%.2g',readThreshes(i),r_neg,p_neg))
    
end



%% Get overlap matrices
readThreshes = 0.05;%[0.01 0.05 0.1 0.5 1];
roseThreshes = [0.01 0.05 0.1 0.5 1];

[nInBoth_pospos,nInBoth_posneg,nInBoth_negpos,nInBoth_negneg] = deal(nan(numel(readThreshes,numel(roseThreshes))));
legendstr = cell(1,numel(roseThreshes));
figure(111); clf; set(gcf,'Position',[40 30 1062 1043]);
for i=1:numel(roseThreshes)
    % Get Rosenberg matrices
    roseOverlap_pos = all(roseCpCr.cr_all>0 & roseCpCr.cp_all<roseThreshes(i),3);
    roseOverlap_pos(~uppertri) = 0;
    roseOverlap_neg = all(roseCpCr.cr_all<0 & roseCpCr.cp_all<roseThreshes(i),3);
    roseOverlap_neg(~uppertri) = 0;
    nInRose_pos = sum(roseOverlap_pos(:));
    nInRose_neg = sum(roseOverlap_neg(:));
    legendstr{i} = sprintf('Rosenberg thresh p<%.2f',roseThreshes(i));
    for j=1:numel(readThreshes)
        % Get reading matrices
        readOverlap_pos = all(readCpCr.cr_all>0 & readCpCr.cp_all<readThreshes(j),3);
        readOverlap_pos(~uppertri) = 0;
        readOverlap_neg = all(readCpCr.cr_all<0 & readCpCr.cp_all<readThreshes(j),3);
        readOverlap_neg(~uppertri) = 0;
        nInRead_pos = sum(readOverlap_pos(:));
        nInRead_neg = sum(readOverlap_neg(:));

        % print sizes
        nInBoth_pospos(i,j) = sum(roseOverlap_pos(:) & readOverlap_pos(:));
        nInBoth_posneg(i,j) = sum(roseOverlap_pos(:) & readOverlap_neg(:));
        nInBoth_negpos(i,j) = sum(roseOverlap_neg(:) & readOverlap_pos(:));
        nInBoth_negneg(i,j) = sum(roseOverlap_neg(:) & readOverlap_neg(:));
        fprintf('Rosenberg thresh=%.2f: %d pos edges, %d neg edges\n',roseThreshes(i),nInRose_pos,nInRose_neg);
        fprintf('Reading thresh=%.2f: %d pos edges, %d neg edges\n',readThreshes(j),nInRead_pos,nInRead_neg);
%         n_edge = n_node*(n_node-1)/2;
%         fprintf('   %d overlapping edges (p=%.3f)\n',nInBoth_pospos(i,j), 1-hygecdf(nInBoth, n_edge, nInRose, nInRead));
        
    end
    subplot(numel(roseThreshes),2,i*2-1); cla;
%     hBar = bar(readThreshes,[nInBoth_pospos(i,:); nInBoth_posneg(i,:)]'/nInRose_pos*100);
    hLine = plot(readThreshes,[nInBoth_pospos(i,:); nInBoth_posneg(i,:)]'/nInRose_pos*100,'o-');
    % color to match Rosenberg JNeuro paper
%     set(hBar(1),'facecolor',[1 .5 0]);
%     set(hBar(2),'facecolor',[0 .65 .65]);
    set(hLine(1),'color',[1 .5 0],'linewidth',2);
    set(hLine(2),'color',[0 .65 .65],'linewidth',2);
    % Annotate plot
%     set(gca,'xtick',readThreshes)
    ylim([0 60])
    ylabel('% edges overlapping');
    xlabel('Reading Network Threshold');
    legend('Reading pos (High-Attention)','Reading neg (Low-Attention)','Location','NorthWest');
    title(sprintf('Rosenberg Pos Network Overlap with Reading Networks\nthreshold p<%.3f',roseThreshes(i)));
    grid on
    
    subplot(numel(roseThreshes),2,i*2); cla;
%     hBar = bar(readThreshes,[nInBoth_negpos(i,:); nInBoth_negneg(i,:)]'/nInRose_neg*100);
    hLine = plot(readThreshes,[nInBoth_negpos(i,:); nInBoth_negneg(i,:)]'/nInRose_neg*100,'o-');

    % color to match Rosenberg JNeuro paper
%     set(hBar(1),'facecolor',[1 .5 0]);
%     set(hBar(2),'facecolor',[0 .65 .65]);
    set(hLine(1),'color',[1 .5 0],'linewidth',2);
    set(hLine(2),'color',[0 .65 .65],'linewidth',2);

    % Annotate plot
%     set(gca,'xtick',readThreshes)
    ylim([0 60])
    ylabel('% edges overlapping');
    xlabel('Reading Network Threshold');
    legend('Reading pos (High-Attention)','Reading neg (Low-Attention)','Location','NorthWest');
    title(sprintf('Rosenberg Neg Network Overlap with Reading Networks\nthreshold p<%.3f',roseThreshes(i)));
    grid on
end

%%
figure(112); clf;
subplot(1,2,1);
plot(readThreshes',nInBoth_pospos'./nInBoth_posneg','.-');
xlabel('reading task threshold')
ylabel('ratio of pos-pos to pos-neg overlap')
legend(legendstr)
grid on

subplot(1,2,2);
plot(readThreshes',nInBoth_negneg'./nInBoth_negpos','.-');
legend(legendstr)
xlabel('reading task threshold')
ylabel('ratio of neg-neg to neg-pos overlap')
grid on

%% How do the p and r distributions differ between the two tasks?
pHist = 0:0.002:1;
rHist = -1:.002:1;

crRead = VectorizeFc(readCpCr.cr_all);
cpRead = VectorizeFc(readCpCr.cp_all);
crRose = VectorizeFc(roseCpCr.cr_all);
cpRose = VectorizeFc(roseCpCr.cp_all);

figure(692); clf;
subplot(221);
fooRead = hist(cpRead,pHist);
fooRose = hist(cpRose,pHist);
plot(pHist,[cumsum(fooRead)/sum(fooRead), cumsum(fooRose)/sum(fooRose)]);
xlabel('p')
ylabel('fraction of edges below p')
legend('Reading data','Rosenberg data');
grid on

subplot(222);
fooRead = hist(crRead,rHist);
fooRose = hist(crRose,rHist);
plot(rHist,[cumsum(fooRead)/sum(fooRead), cumsum(fooRose)/sum(fooRose)]);
xlabel('r')
ylabel('fraction of edges below r')
legend('Reading data','Rosenberg data');
grid on

subplot(223);
plot(crRead(:), cpRead(:),'b.');
hold on;
plot(crRose(:),cpRose(:),'r.');
xlabel('r')
ylabel('p')
title('r to p mapping')
legend(sprintf('Reading data (n=%d)',size(crRead,2)),sprintf('Rosenberg data (n=%d)',size(crRose,2)));
grid on

%% Can edge usage be explained by ROI size or TSNR?
okSubj = readCpCr.subjects(readCpCr.isOkSubj);
fcMask = mean(readCpCr.cr_all,3);
figure(262);
CompareRoiInfoToMaskEdges(okSubj,fcMask);
MakeFigureTitle(sprintf('All Edges, %d subjects',numel(okSubj)));
set(gcf,'Position',[680   700   768   298]);
ylabel(subplot(121),sprintf('sum r (w/behavior) for \nall edges with this ROI'));
ylabel(subplot(122),sprintf('sum r (w/behavior) for \nall edges with this ROI'));

fcMask = mean(readCpCr.cr_all,3);
fcMask(fcMask<0) = 0;
figure(263);
CompareRoiInfoToMaskEdges(okSubj,fcMask);
MakeFigureTitle(sprintf('Positive Edges, %d subjects',numel(okSubj)));
set(gcf,'Position',[680   350   768   298]);
ylabel(subplot(121),sprintf('sum r (w/behavior) for \nall edges with this ROI'));
ylabel(subplot(122),sprintf('sum r (w/behavior) for \nall edges with this ROI'));

fcMask = mean(readCpCr.cr_all,3);
fcMask(fcMask>0) = 0;
figure(264);
CompareRoiInfoToMaskEdges(okSubj,fcMask);
MakeFigureTitle(sprintf('Negative Edges, %d subjects',numel(okSubj)));
set(gcf,'Position',[680   30   768   298]);
ylabel(subplot(121),sprintf('sum r (w/behavior) for \nall edges with this ROI'));
ylabel(subplot(122),sprintf('sum r (w/behavior) for \nall edges with this ROI'));

%% When a reading edge's ROIs are very close (but not equal) to a Rosenberg 
%% edges', is the overlapping edge likely to have a similar cp/cr?

readThresh = 0.05;
roseThresh = 0.01;

readOverlap_pos = all(readCpCr.cr_all>0 & readCpCr.cp_all<readThresh,3);
readOverlap_pos(~uppertri) = 0;
readOverlap_neg = all(readCpCr.cr_all<0 & readCpCr.cp_all<readThresh,3);
readOverlap_neg(~uppertri) = 0;
roseOverlap_pos = all(roseCpCr.cr_all>0 & roseCpCr.cp_all<roseThresh,3);
roseOverlap_pos(~uppertri) = 0;
roseOverlap_neg = all(roseCpCr.cr_all<0 & roseCpCr.cp_all<roseThresh,3);
roseOverlap_neg(~uppertri) = 0;

bothOverlap_pos = readOverlap_pos & roseOverlap_pos;
bothOverlap_neg = readOverlap_neg & roseOverlap_neg;

roiPairDistances_pos = CompareRoiPairPositions(readOverlap_pos,(roseOverlap_pos & ~readOverlap_pos),shenAtlas);
% roiPairDistances_neg = CompareRoiPairPositions(readOverlap_neg,(roseOverlap_neg & ~readOverlap_neg),shenAtlas);

% find near but not overlapping
iRead = find(readOverlap_pos);
iRose = find(roseOverlap_pos & ~readOverlap_pos);
[minRoiDist,iMin] = min(roiPairDistances_pos,[],2);
iClose = find(minRoiDist>0 & minRoiDist<12);
% compare CR of neighboring edge
minCr = min(readCpCr.cr_all,[],3);
crCloseRose = nan(1,numel(iClose));
for i=1:numel(iClose)    
    crCloseRose(i) = minCr(iRose(iMin(iClose(i))));
end

% get all close-but-not-in-reading edges
roiPairDistances_readToOther = CompareRoiPairPositions(readOverlap_pos,(~roseOverlap_pos & ~readOverlap_pos),shenAtlas);
iOther = find(~roseOverlap_pos & ~readOverlap_pos & uppertri);
[minRoiDist,iMin] = min(roiPairDistances_readToOther,[],2);
iClose = find(minRoiDist>0 & minRoiDist<12);
% compare CR of neighboring edge
% minCr = mean(readCpCr.cr_all,3);
crCloseOther = nan(1,numel(iClose));
for i=1:numel(iClose)    
    crCloseOther(i) = minCr(iOther(iMin(iClose(i))));
end

% Plot results
xHist =-1:.03:1;
nAll = hist(minCr(iRose),xHist);
nCloseRose = hist(crCloseRose,xHist);
nCloseOther = hist(crCloseOther,xHist);
%
figure(788); clf;
plot(xHist,cumsum([nAll/sum(nAll); nCloseRose/sum(nCloseRose); nCloseOther/sum(nCloseOther)]')*100);
xlabel(sprintf('edge r in Reading task (w/behavior)\n(min across LOSO iters)'));
ylabel('% edges below this r')
legend('Rosenberg Edges that are not Reading Edges','Rosenberg edges near Reading edges','Other edges near Reading edges','Location','NorthWest');
ylim([0 100]);
grid on

%%
p1 = ranksum(crCloseRose,crCloseOther);
p2 = ranksum(crCloseRose,minCr(iRose));
fprintf('--- 2-tailed ranksum tests:\n');
fprintf('p(close rose - close other) = %.3g\n',p1);
fprintf('p(close rose - other rose) = %.3g\n',p2);

%% How much do spatially-neighboring edges' cp/cr's look like each other?



