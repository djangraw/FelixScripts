% FindMatchedGroups.m
%
% Created 4/1/15 by DJ.

%% Load what's been done so far
load SBJ01_IcMatching

%% Get components

nRuns = size(match_cell,1);
nComps = size(iMatches,1);

for i=3:nComps
    fprintf('=== Starting Component %d/%d ===\n',i,nComps);
    %% Get all potential combos
    fprintf('%s finding potential combinations...\n',datestr(now,16));
    combos = i;
    for j=2:nRuns
        iThis = find(iMatches{i}(:,1)==j);
        newCombos = cell(1,numel(iThis));
        for k=1:numel(iThis)
            newCombos{k} = [combos, repmat(iThis(k),size(combos,1),1)];
        end
        combos = cat(1,newCombos{:});
    end
    

    %% get good combinations
    % iGoodCombos{i} = [];
    goodCombos{i} = [];
    fprintf('%s trying %d combos...\n',datestr(now,16),size(combos,1));
    for j=1:size(combos,1)
        if mod(j,10000)==0 
            fprintf('%d/%d...\n',j,size(combos,1)); 
        end
        % see if they're connected
        if areConnected(iMatches{i}(combos(j,:),2),match_cell,0.15)
            fprintf('Found one! [%s]\n',num2str(combos(j,:)))
    %         iGoodCombos{i} = [iGoodCombos{i}, j];
            goodCombos{i} = [goodCombos{i}; combos(j,:)];
        end
    end
    fprintf('%s DONE!\n',datestr(now,16));
    
end


%% METHOD 2: CONNECTIVITY MATRIX

i=1;
runs = iMatches{i}(:,1);
comps = iMatches{i}(:,2);
connMat = MakeConnMatrix(runs,comps,match_cell,0.15);
nComps = size(connMat,1);

isGoodComp = false(1,nComps);
for iComp = 1:nComps
    connMat(iComp,iComp)=true;
    if isequal(unique(runs(connMat(iComp,:))), (1:nRuns)')
        isGoodComp(iComp) = true;
    end
end

%% Get timecourse

thisCombo = [1     6    10    16    19    25    33    38    41    48];
TC_combo = zeros(size(TC{1},1),nRuns);
for i=1:nRuns
    if i==1 || match_cell{1,i}(thisCombo(1),thisCombo(i))>0
        TC_combo(:,i) = TC{i}(:,thisCombo(i));
    else
        TC_combo(:,i) = -TC{i}(:,thisCombo(i));
    end
end
meanTC = mean(TC_combo,2);
steTC = std(TC_combo,[],2)/sqrt(nRuns);
[h,p] = ttest(TC_combo');
[fdr,q] = mafdr(p);

close(3);
figure(3); clf;
subplot(2,1,1); hold on;
plot(TC_combo);
PlotHorizontalLines(0,'k--');
xlabel('time (TR)')
ylabel('BOLD signal (AU)')
title('timecourse of IC group (individual runs)');
xlim([0 length(meanTC)])

subplot(2,1,2);
ErrorPatch((1:length(meanTC)),meanTC',steTC','b','b');
PlotHorizontalLines(0,'k--');
xlabel('time (TR)')
ylabel('BOLD signal (AU)')
title('timecourse of IC group (mean +/- stderr)');
xlim([0 length(meanTC)])


%% Save results
save SBJ01_IcMatching goodCombos match_cell p_match_cell iMatches subject sessions runs



