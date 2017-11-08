function [rt,isCorrect] = GetLetterOrderReactionTimes(data,doPlot)

% Created 10/24/17 by DJ.

% Extract trial data
tTest = data.events.display.time(strcmp(data.events.display.name,'test'));
tButton = data.events.key.time(ismember(data.events.key.char,data.params.respKeys));
cButton = data.events.key.char(ismember(data.events.key.char,data.params.respKeys));
[~,iButton] = ismember(cButton,data.params.respKeys);
isTrueResp = iButton==1; % was response the first button?
isTrueTrial = data.events.trial.isTrueTrial;

% Calculate RT and isCorrect for each trial
[rt] = deal(nan(1,numel(tTest)));
isCorrect = false(1,numel(tTest));
for i=1:numel(tTest)
    % find response index
    if i<numel(tTest)
        iThisRt = find(tButton>tTest(i) & tButton<tTest(i+1),1);
    else
        iThisRt = find(tButton>tTest(i),1);
    end
    % use to fill in RT and isCorrect
    if ~isempty(iThisRt)
        rt(i) = tButton(iThisRt)-tTest(i); % relative to resp period start
        isCorrect(i) = isTrueResp(iThisRt)==isTrueTrial(i); % correct if it matches            
    end
end

% Plot
if doPlot
    % trial-by-trial
    subplot(2,1,1); cla; hold on;
    plot(rt,'.-');
    iErr = find(~isCorrect);
    plot(iErr,rt(iErr),'ro');
    xlabel('trial');
    ylabel('RT (s)');
    legend('all','error');
    
    % histogram
    subplot(2,1,2); cla; hold on;
    [nAll,xAll] = hist(rt);
    nCorr = hist(rt(isCorrect),xAll);
    nErr = hist(rt(~isCorrect),xAll);
    plot(xAll,[nCorr;nErr;nAll]','.-');
    xlabel('RT (s)');
    ylabel('# trials');
    legend('correct','error','all');
end