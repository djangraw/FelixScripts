% RunWholeBrainSvd_AllSubjects_script.m
%
% Created 2/25/16 by DJ.

% Get and save whole-brain SVD for each subject

subjects = [6:13, 16:27]; % removed 14 & 15

for i=1:numel(subjects)
    fprintf('===SUBJECT %d/%d...\n',i,numel(subjects));
    SBJ=subjects(i);  
    dataDir = sprintf('/spin1/users/jangrawdc/PRJ08_CognitiveStateDetection/PrcsData/SBJ%02d/D02_CTask001',SBJ);
    cd(dataDir)
    datafile=sprintf('pb08.SBJ%02d_CTask001.blur.WL045+orig',SBJ);
    maskfile=sprintf('pb06.SBJ%02d_CTask001.bpf.WL045.mask.lowSigma+orig',SBJ);
    outFilename = sprintf('SBJ%02d_WholeBrainSvd.mat',SBJ);
    if exist(outFilename,'file')
        fprintf('%s already exists!\n',outFilename);
    else
        [U,S,V] = GetWholeBrainSvd(datafile,maskfile);
        save(outFilename,'U','S','V');
    end
    
end

%% Use whole-brain SVD to classify brain state
clear
subjects = [6:13, 16:27]; % removed 14 & 15

for i=1:numel(subjects)
    fprintf('===SUBJECT %d/%d...\n',i,numel(subjects));
    SBJ=subjects(i);  
    dataDir = sprintf('/spin1/users/jangrawdc/PRJ08_CognitiveStateDetection/PrcsData/SBJ%02d/D02_CTask001',SBJ);
    filename = sprintf('%s/SBJ%02d_PCA_NROI0200_WL0030_WS0000_VK070.00_WholeBrainSvd.UNSORTED.mat',dataDir,SBJ);
    if exist(filename,'file')
        fprintf('===SBJ%02d state detection already done.\n',SBJ);
    else
        MATLAB_SSB_CognitiveStateDetection_WholeBrainSvd;
    end
end

%% Get results

% subjects = 6:27;
subjects = [6:13, 16:27]; % removed 14 & 15
ARI = nan(numel(subjects),1);
nComps = nan(numel(subjects),1);

for i=1:numel(subjects)
    SBJ=subjects(i);
    dataDir = sprintf('/spin1/users/jangrawdc/PRJ08_CognitiveStateDetection/PrcsData/SBJ%02d/D02_CTask001',SBJ);
    filename = sprintf('%s/SBJ%02d_PCA_NROI0200_WL0030_WS0000_VK070.00_WholeBrainSvd.UNSORTED.mat',dataDir,SBJ);
    if ~exist(filename,'file')
        fprintf('===SBJ%02d results not available yet.\n',SBJ);
    else
        foo = load(filename,'CB','nPCs');
        ARI(i) = foo.CB.Kmeans.Eval.ARI;
        nComps(i) = foo.nPCs;
    end
end

%% Plot
% Make ARI/nPCs plot
figure(724); clf;
subplot(121);
h = plotyy(1:numel(subjects),ARI,1:numel(subjects),nComps);
xlabel('subject index');
ylabel(h(1),'Accuracy (ARI)');
ylabel(h(2),'# PCs kept')

% Set up ARI boxplot
subplot(122); cla; hold on;
% make patches
xl = [0 1]+0.5;
patch(xl([1 2 2 1 1]), [1 1 .9 .9 1], 'g');
patch(xl([1 2 2 1 1]), [.9 .9 .8 .8 .9], 'y');
patch(xl([1 2 2 1 1]), [.8 .8 .65 .65 .8], [1 .5 0]);
patch(xl([1 2 2 1 1]), [.65 .65 .4 .4 .65], 'r');

% make boxplot
boxplot(ARI,'medianstyle','target','symbol','k+','boxstyle','filled');
% annotate plot
ylim([0.4 1])
ylabel('Accuracy (ARI)');
xlabel('% Var kept')
set(gca,'xticklabel','70');
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