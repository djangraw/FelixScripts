cla; hold on;
for i=1:222
    if i<100
        iThis = find(strcmp(sprintf('S %d',i),{EEG.event.type}));
    else
        iThis = find(strcmp(sprintf('S%d',i),{EEG.event.type}));
    end
    plot([EEG.event(iThis).latency]/EEG.srate,repmat(i,1,numel(iThis)),'b.');
end
    