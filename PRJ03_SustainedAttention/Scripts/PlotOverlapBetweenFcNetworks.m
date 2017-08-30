function PlotOverlapBetweenFcNetworks(FcNet1,FcNet2,atlas,atlasLabels,atlasLabelColors,atlasLabelNames,networkNames)

% PlotOverlapBetweenFcNetworks(FcNet1,FcNet2,atlas,atlasLabels,atlasLabelColors,atlasLabelNames,networkNames) 
%
% Created 12/1/16 by DJ

if ~exist('networkNames','var') || isempty(networkNames);
    networkNames = {'Network 1', 'Network 2'};
end
% Enforce upper triangular matrix constraint
nRoi = size(FcNet1,1);
uppertri = triu(ones(nRoi),1);
nEdge = sum(uppertri(:)); % total number of edges 
FcNet1(~uppertri) = 0;
FcNet2(~uppertri) = 0;

% Extract info
isPos1 = FcNet1>0;
isNeg1 = FcNet1<0;
isPos2 = FcNet2>0;
isNeg2 = FcNet2<0;

% Plot overlap as bars
%% Get overlap matrices
figure(111); clf; set(gcf,'Position',[40 30 566 420]);
% Get Rosenberg matrices
nIn1(1) = sum(isPos1(:)); % pos
nIn1(2) = sum(isNeg1(:));
nIn2(1) = sum(isPos2(:)); % pos
nIn2(2) = sum(isNeg2(:));

% print sizes
nOverlap_pospos = sum(isPos1(:) & isPos2(:));
nOverlap_posneg = sum(isPos1(:) & isNeg2(:));
nOverlap_negpos = sum(isNeg1(:) & isPos2(:));
nOverlap_negneg = sum(isNeg1(:) & isNeg2(:));
fprintf('%s: %d pos edges, %d neg edges\n',networkNames{1},nIn1(1),nIn1(2));
fprintf('%s: %d pos edges, %d neg edges\n',networkNames{2},nIn2(1),nIn2(2));

nOverlap = [nOverlap_pospos, nOverlap_posneg; nOverlap_negpos, nOverlap_negneg];
pctOverlap = cat(1,[nOverlap_pospos, nOverlap_posneg]/nIn1(1), ...
    [nOverlap_negpos, nOverlap_negneg]/nIn1(2))*100;

% hBar = bar(readThreshes,[nInBoth_pospos; nInBoth_posneg]'/nIn1_pos*100,'o-');
hBar = bar(pctOverlap);
% color to match Rosenberg JNeuro paper
set(hBar(1),'facecolor',[1 .5 0]);
set(hBar(2),'facecolor',[0 .65 .65]);
% Annotate plot
% ylim([0 60])
set(gca,'xticklabel',{'High-Attention','Low-Attention'});
xlabel(networkNames{1});
ylabel('% edges overlapping');
legend(sprintf('%s High-Attention',networkNames{2}),...
    sprintf('%s Low-Attention',networkNames{2}),'Location','NorthWest');
title(sprintf('%s Overlap with %s',networkNames{:}));
grid on

%% Get stats
% Calculate level of overlap and odds of getting that much my chance:
% p = 1-hygecdf(x, 35778, k, n), where
% x = # overlapping edges
% k = # edges in network 2
% n = # edges in network 1
names = {'pos','neg'};
pOverlap = nan(2);
for i=1:2
    for j=1:2
        pOverlap(i,j) = 1-hygecdf(nOverlap(i,j), nEdge, nIn1(i), nIn2(j));
        if i~=j
            pOverlap(i,j) = (1-pOverlap(i,j));
        end
        fprintf('%s %s vs. %s %s: %d edges, p=%.3g\n',networkNames{1}, names{i},networkNames{2},names{j},nOverlap(i,j),pOverlap(i,j));
    end
end


%% Plot networks
clusterClim1 = [];%[-1 1] * 82;%55;%*.1;
clusterClim2 = [];%[-1 1] * 90;
clusterAvgMethod = 'sum'; %'mean';
figure(3);
clf;
subplot(2,2,1);
PlotFcMatrix(FcNet1,[-1 1],atlas,atlasLabels,true,atlasLabelColors,false);
title(sprintf('%s data, pos - neg overlap',networkNames{1}));
subplot(2,2,2);
PlotFcMatrix(FcNet1,clusterClim1,atlas,atlasLabels,true,atlasLabelColors,clusterAvgMethod);
title(sprintf('%s data, pos - neg overlap',networkNames{1}));
% See how this compares to Rosenberg networks
subplot(2,2,3);
PlotFcMatrix(FcNet2,[-1 1],atlas,atlasLabels,true,atlasLabelColors,false);
title(sprintf('%s data, pos - neg overlap',networkNames{2}));
subplot(2,2,4);
PlotFcMatrix(FcNet2,clusterClim2,atlas,atlasLabels,true,atlasLabelColors,clusterAvgMethod);
title(sprintf('%s data, pos - neg overlap',networkNames{2}));

MakeLegend(atlasLabelColors,atlasLabelNames,2,[.55 .6]);
set(gcf,'Position', [3 329 1023 728]);


%% End 
stopNow = true;
if stopNow
    return;
end

%% Show regions of overlap and disagreement
clusterClimOverlap = [-1 1]*14;
clusterClimRead = [-1 1]*80;
clusterClimRos = [-1 1]*100;

figure(66);
clf;
subplot(3,2,1);
PlotFcMatrix((pos_overlap & attnNets.pos_overlap) - (neg_overlap & attnNets.neg_overlap),...
    [-1 1],shenAtlas,attnNetLabels,true,colors,false);
title(sprintf('Reading & Rosenberg data, pos - neg overlap, thresh = %s',num2str(thresh)))
subplot(3,2,2);
PlotFcMatrix((pos_overlap & attnNets.pos_overlap) - (neg_overlap & attnNets.neg_overlap),...
    clusterClimOverlap,shenAtlas,attnNetLabels,true,colors,clusterAvgMethod);
title('Reading & Rosenberg data, pos - neg overlap')
% See how this compares to Rosenberg networks
subplot(3,2,3);
PlotFcMatrix((pos_overlap & ~attnNets.pos_overlap) - (neg_overlap & ~attnNets.neg_overlap),...
    [-1 1],shenAtlas,attnNetLabels,true,colors,false);
title('Reading & NOT Rosenberg data, pos - neg overlap')
subplot(3,2,4);
PlotFcMatrix((pos_overlap & ~attnNets.pos_overlap) - (neg_overlap & ~attnNets.neg_overlap),...
    clusterClimRead,shenAtlas,attnNetLabels,true,colors,clusterAvgMethod);
title('Reading & NOT Rosenberg data, pos - neg overlap')
subplot(3,2,5);
PlotFcMatrix((~pos_overlap & attnNets.pos_overlap) - (~neg_overlap & attnNets.neg_overlap),...
    [-1 1],shenAtlas,attnNetLabels,true,colors,false);
title('Rosenberg & NOT Reading data, pos - neg overlap')
subplot(3,2,6);
PlotFcMatrix((~pos_overlap & attnNets.pos_overlap) - (~neg_overlap & attnNets.neg_overlap),...
    clusterClimRos,shenAtlas,attnNetLabels,true,colors,clusterAvgMethod);
title('Rosenberg & NOT Reading data, pos - neg overlap')


MakeLegend(colors,labelNames,2,[.55 .6]);
set(gcf,'Position', [3 30 1023 1028]);
MakeFigureTitle(sprintf('threshold: %s\noverlap mask sizes: [%d %d]',num2str(thresh), sum(pos_overlap(:)), sum(neg_overlap(:))));
