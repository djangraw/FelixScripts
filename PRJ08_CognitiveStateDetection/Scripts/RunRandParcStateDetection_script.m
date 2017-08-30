% RunRandParcStateDetection_script.m
%
% Created ~2/25/16 by DJ.
% Updated 4/22/16 by DJ - added iRand=-1, code for real (non-random) atlas

subjects = [6:13, 16:27]; % removed 14 & 15
nRand = 10;

for i=1:numel(subjects)
    SBJ=subjects(i);  
    dataDir = sprintf('/spin1/users/jangrawdc/PRJ08_CognitiveStateDetection/PrcsData/SBJ%02d/D02_CTask001',SBJ);
    for j=1:nRand
        clear CB IB PCARes SB winInfo
%         SBJ=subjects(i);
        iRand = j-1;
        
        if exist(sprintf('%s/SBJ%02d_PCA_NROI0200_WL0030_WS0000_VK097.50_RandParc%d.UNSORTED.mat',dataDir,SBJ,iRand),'file');
            fprintf('===(SBJ%02d, rand %d) already done.\n',SBJ,iRand);
            continue;
        end
        try
            MATLAB_SSB_CognitiveStateDetection_RandParc;
        catch
            fprintf('===\n===(SBJ%02d, rand %d) not ready yet.\n',SBJ,iRand);
        end
    end
end

%% Do same for Craddock atlas (code-named iRand=-1)
for i=1:numel(subjects)
    SBJ=subjects(i);  
    dataDir = sprintf('/spin1/users/jangrawdc/PRJ08_CognitiveStateDetection/PrcsData/SBJ%02d/D02_CTask001',SBJ);
    clear CB IB PCARes SB winInfo
    iRand = -1;

    if exist(sprintf('%s/SBJ%02d_PCA_NROI0200_WL0030_WS0000_VK097.50_RandParc%d.UNSORTED.mat',dataDir,SBJ,iRand),'file');
        fprintf('===(SBJ%02d, rand %d) already done.\n',SBJ,iRand);
    else
        try
            MATLAB_SSB_CognitiveStateDetection_RandParc;
        catch
            fprintf('===\n===(SBJ%02d, rand %d) not ready yet.\n',SBJ,iRand);
        end
    end
end



%% Get results

% subjects = 6:27;
subjects = [6:13, 16:27]; % removed 14 & 15
nRand = 10;
ARI = nan(numel(subjects),nRand);
iRand_all = -1:9;

for i=1:numel(subjects)
    SBJ=subjects(i);
    dataDir = sprintf('/spin1/users/jangrawdc/PRJ08_CognitiveStateDetection/PrcsData/SBJ%02d/D02_CTask001',SBJ);
    for j=1:numel(iRand_all)
        SBJ=subjects(i);
        iRand = iRand_all(j);
        filename = sprintf('%s/SBJ%02d_PCA_NROI0200_WL0030_WS0000_VK097.50_RandParc%d.UNSORTED.mat',dataDir,SBJ,iRand);
        if ~exist(filename,'file')
            fprintf('===(SBJ%02d, rand %d) not available yet.\n',SBJ,iRand);
        else
            foo = load(filename,'CB');
            ARI(i,j) = foo.CB.Kmeans.Eval.ARI;
        end
    end
end

%% Plot
figure(724); clf;
subplot(121);
imagesc(iRand_all,1:numel(subjects),ARI);
ylabel('subject index');
xlabel('Randomization number');
title('Accuracy (ARI)');
colorbar
subplot(122); cla; hold on;
% make patches
xl = [0 nRand+1]+0.5;
patch(xl([1 2 2 1 1]), [1 1 .9 .9 1], 'g');
patch(xl([1 2 2 1 1]), [.9 .9 .8 .8 .9], 'y');
patch(xl([1 2 2 1 1]), [.8 .8 .65 .65 .8], [1 .5 0]);
patch(xl([1 2 2 1 1]), [.65 .65 .4 .4 .65], 'r');

% make boxplot
boxplot(ARI,iRand_all,'medianstyle','target','symbol','k+');%,'boxstyle','filled');
% annotate plot
ylim([0.4 1])
ylabel('Accuracy (ARI)');
xlabel('Randomization number');
% Label outliers with subject number
h = findobj(gca,'tag','Outliers'); % Get handles for outlier lines.
xc = get(h,'XData');
yc = get(h,'YData');
xc = [xc{:}];
yc = [yc{:}];
isUsed = false(numel(subjects),nRand);
for i=1:numel(xc)
    if ~isnan(xc(i))
        iRand = round(xc(i));
        iSubj = find(ARI(:,iRand)==yc(i));
        for j=1:numel(iSubj)
            text(xc(i),yc(i)+j*.02,sprintf('S%02d',iSubj(j)),'HorizontalAlignment','center');
        end
    end
end

% annotate
hLine = PlotVerticalLines(1.5,'b--');
set(hLine,'linewidth',2);

tickstring = cell(1,numel(iRand_all));
for j=1:numel(iRand_all)
    if iRand_all(j)<0
        tickstring{j} = 'Atlas';
    else
        tickstring{j} = num2str(iRand_all(j)+1);
    end
end
set(gca,'xticklabel',tickstring);