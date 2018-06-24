% Get stim-locked LR weights
% Created 9/19/12 by DJ for one-time use.

%% load
jitterrange = [0 0];
foldername = sprintf('results_%s_noweightprior_10fold_jrange_%d_to_%d',subject,jitterrange(1),jitterrange(2));
JLR = load([foldername '/results_10fold']);
JLP = load([foldername '/params_10fold']);
%% extract
jlrWinOffset = 200;
t = JLP.ALLEEG(1).times(round(JLR.trainingwindowoffset+JLR.trainingwindowlength/2));
vall = mean(cat(3,JLR.vout{:}),3);
iT = find(t>=jlrWinOffset,1);
v = vall(iT,:);
%% plot
figure(1);
topoplot(v,ALLEEG(1).chanlocs);
colorbar