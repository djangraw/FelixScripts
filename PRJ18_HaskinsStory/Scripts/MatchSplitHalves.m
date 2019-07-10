function MatchSplitHalves(splitFactor,matchFactor,match_binEdges)

% Created 7/9/18 by DJ.

figure(561); clf;

splitFactor_orig = splitFactor;
matchFactor_orig = matchFactor;
match_xBins = match_binEdges(1:end-1)+diff(match_binEdges)/2;
nBins = numel(match_xBins);

isDone = false;
while ~isDone
    % get histograms
    isTop = splitFactor>median(splitFactor);
    nTop = histcounts(matchFactor(isTop),match_binEdges);
    nBot = histcounts(matchFactor(~isTop),match_binEdges);
    % plot and annotate
    plot(match_xBins,[nTop;nBot]','.-');
    xlabel('match factor')
    ylabel('# participants')
    legend('top','bottom')
    pause();

    % check for done condition
    if isequal(nTop,nBot)
        isDone = true;
    else
        for i=1:nBins
            nToRemove = abs(nTop(i)-nBot(i));
            if nTop(i)>nBot(i)
                iRemovable = find(matchFactor>match_binEdges(i) & matchFactor<=match_binEdges(i+1) & isTop);                
            else
                iRemovable = find(matchFactor>match_binEdges(i) & matchFactor<=match_binEdges(i+1) & ~isTop);                
            end                
            iRemove = randsample(iRemovable,nToRemove);
            splitFactor(iRemove) = [];
            matchFactor(iRemove) = [];
            isTop(iRemove) = [];
        end
    end
    
end
    
