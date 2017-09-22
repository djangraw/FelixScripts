function PlotSrttTrialByTrialBeh(trialBehTable)

% PlotSrttTrialByTrialBeh(trialBehTable)
%
% Created 9/20/17 by DJ.

% Make Gaussian Smoothing Kernel h
N = 40;
sigma = 10;
ind = -floor(N/2) : floor(N/2);

% Create Gaussian Mask
kernel = exp(-(ind.^2) / (2*sigma*sigma));
kernel(ind<0) = 0; % convert to half-gaussian (causal)

% Normalize so that total area (sum of all weights) is 1
kernel = kernel / sum(kernel(:));

% Set up
subjects = unique(trialBehTable.Subject);
nSubj = numel(subjects);
nFigs = ceil(nSubj/16);
if nFigs==1
    nRows = ceil(sqrt(nSubj));
    nCols = ceil(nSubj/nRows);
else
    [nRows,nCols] = deal(4);
end
[rollingPc, rollingRt] = deal(cell(1,nSubj));
for i=1:nSubj
    % Get figure and plot index
    iFig = ceil(i/16);
    iPlot = i-(iFig-1)*16;
    if iPlot==1 % set up new figure
        figure(100+iFig);
        clf;
        MakeFigureTitle(sprintf('Figure %d: Subjects %d-%d',100+iFig,i,min(nSubj,iFig*16)));
    end
    % Get behavior for this subject
    isThisSubj = trialBehTable.Subject == subjects(i);
    behThis = trialBehTable(isThisSubj,:);
    % Extract PC and RT
    rtThis = behThis.Target_RT;
    rtThis(rtThis==0) = NaN;
    isNoResp = (isnan(rtThis));
    isError = (behThis.Target_ACC==0 & ~isnan(rtThis));
    isCorrect = (behThis.Target_ACC==1);
    rollingPc{i} = conv(isCorrect,kernel,'same')*100;
    rollingRt{i} = conv(rtThis,kernel,'same');
    nTrials = size(behThis,1);
    iRun = (312:312:nTrials-1)+0.5;

    % Plot corrects, errors, and no-responses
    subplot(nRows,nCols,iPlot); cla; hold on;
    [ax,h1,h2] = plotyy(1:nTrials,rtThis,1:nTrials,rollingPc{i});
    set(h1,'marker','.');
    plot(find(isError),behThis.Target_RT(isError),'rx')
    plot(find(isNoResp),zeros(1,sum(isNoResp)),'m.');
    % Annotate plot
    PlotVerticalLines(find(diff(behThis.Cond)~=0)+0.5,'k--');
    PlotVerticalLines(iRun, 'r-');
    ylabel(ax(1),sprintf('subj %d RT',subjects(i)))
    ylabel(ax(2),sprintf('subj %d PC',subjects(i)))
    xlabel('trial')
end


