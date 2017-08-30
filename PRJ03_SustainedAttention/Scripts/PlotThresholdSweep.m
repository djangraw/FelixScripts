% PlotThresholdSweep.m
% 
% - Sweeps the threshold for inclusion across many values, and plots the 
% size of the mask against the performance of the prediction.
% - ***Define variables cp, cr, FC, behav before running this script.
%
% Created 2/9/17 by DJ.


%% Sweep threshold and record mask size/performance

% P value thresholds for including an edge in the network
thresholds = .0001:.0001:.06;
% Sweep threshold and calculate mask size and predictive ability for each
[maskSizePos,maskSizeNeg,Rsq,p,r] = SweepRosenbergThresholds(cp,cr,FC,behav,thresholds,false);

%% Produce figure
figure(63); clf;
set(gcf,'Position',[997   912   732   423]);
% Plot mask size against score-vs-behavior correlation
plot(maskSizePos+maskSizeNeg,r(:,4));
hold on;
% Annotate plot
xlabel('# edges included in network')
ylabel('LOSO correlation with behavior')
xlim([0 500]);
% Add lines
lineThresholds = [0.0001, 0.0005, 0.001, 0.005, 0.01];
for i=1:numel(lineThresholds)
    iThresh = find(thresholds==lineThresholds(i));
    plot([1 1]*(maskSizePos(iThresh)+maskSizeNeg(iThresh)), [0 r(iThresh,4)],'k--');
    plot((maskSizePos(iThresh)+maskSizeNeg(iThresh)), r(iThresh,4),'ko');
    text((maskSizePos(iThresh)+maskSizeNeg(iThresh))+5, r(iThresh,4)-.03,sprintf('p=%.1g',lineThresholds(i)));
end