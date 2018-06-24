% Created 9/18/12 by DJ for one-time use.

subjects = {'an02apr04', 'jeremy15jul04','paul21apr04','robin30jun04','vivek23jun04'};
jitterrange = [0 0];
tAz = cell(1,numel(subjects));
Az = tAz;
for i=1:numel(subjects)
    foldername = sprintf('results_%s_noweightprior_10fold_jrange_%d_to_%d',subjects{i},jitterrange(1),jitterrange(2));
    JLR = load([foldername '/results_10fold']);
    JLP = load([foldername '/params_10fold']);
    tAz{i} = JLP.ALLEEG(1).times(JLR.trainingwindowoffset);
    Az{i} = JLR.Azloo;
end
%%
colors = 'brgcmyk';
figure(12); cla; hold on;
% for i=1:numel(subjects)
%     plot(tAz{i},Az{i},[colors(i) '.-']);
% end
tAll = tAz{5};
for i=1:numel(subjects)
    AzAll(i,:) = Az{i}(1:numel(tAll));
end
plot(tAll,AzAll','.-')
plot(tAll,mean(AzAll,1),'k.-','linewidth',2)
plot([0 0],get(gca,'ylim'),'r--')
plot(get(gca,'xlim'),[0.5 0.5],'k--');
plot(get(gca,'xlim'),[0.75 0.75],'k:');
xlabel('time in epoch (ms)');
ylabel('10-fold Az');
legend([subjects {'mean'}])
title('Standard LR, response-locked')