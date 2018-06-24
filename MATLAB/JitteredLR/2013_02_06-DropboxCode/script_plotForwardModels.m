% script_plotForwardModels
%
% Plots the forward models of the 2 best classifiers in a new window.
%
% Created 5/21/11 by DJ for one-time use.
% Updated 2/6/13 by DJ - comments.

% Load results
fullm = load('results/results_fullmodel2.mat');
loom = load('results/results_new.mat');

% sort by forward model
[~,sortinds] = sort(loom.Azloo,'descend');

% Get top 2 fwd models
a1 = fullm.ALLEEG(1).icawinv(:,sortinds(1));
a2 = fullm.ALLEEG(1).icawinv(:,sortinds(2));

% Plot these fwd models in a new figure
figure;
topoplot(a1,fullm.ALLEEG(1).chanlocs);colorbar;
title(['t=',num2str(fullm.ALLEEG(1).times(fullm.trainingwindowoffset(sortinds(1))))]);
figure;
topoplot(a2,fullm.ALLEEG(1).chanlocs);colorbar;
title(['t=',num2str(fullm.ALLEEG(1).times(fullm.trainingwindowoffset(sortinds(2))))]);


