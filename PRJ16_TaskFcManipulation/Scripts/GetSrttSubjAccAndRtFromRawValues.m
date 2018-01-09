function [RT_block,ACC_block,RT_subj,ACC_subj,RT_lastRun_UnsMinusStr] = GetSrttSubjAccAndRtFromRawValues(trialBehTable)

% [RT_block,ACC_block,RT_subj,ACC_subj,RT_lastRun_UnsMinusStr] = GetSrttSubjAccAndRtFromRawValues(trialBehTable)
%
% Created 1/8/18 by DJ.


% Set up
subjects = unique(trialBehTable.Subject);
nSessions = max(trialBehTable.Session);
nBlocks = max(trialBehTable.Block);
nSubj = numel(subjects);
[RT_block,ACC_block] = deal(nan(nSubj,nSessions*nBlocks));
[RT_subj,ACC_subj] = deal(nan(nSubj,1));
RT_lastRun_UnsMinusStr = deal(nan(nSubj,1));
% Extract data
for i=1:nSubj
    fprintf('Subject %d/%d...\n',i,nSubj)
    % Crop to this subject's data
    subj = subjects(i);
    tableThis = trialBehTable(trialBehTable.Subject==subj,:);
    % Block level
    for j=1:nSessions
        for k=1:nBlocks
            iBlock = (j-1)*nBlocks + k;
            isThisBlock = tableThis.Block==k & tableThis.Session==j;
            RT_block(i,iBlock) = nanmean(tableThis.RTclean(isThisBlock));
            ACC_block(i,iBlock) = mean(tableThis.Target_ACC(isThisBlock));
        end
    end
    % Subject level
    RT_subj(i) = nanmean(tableThis.RTclean);
    ACC_subj(i) = nanmean(tableThis.Target_ACC);
    RT_lastRun_Uns = nanmean(tableThis.RTclean(tableThis.Session==nSessions & ...
        tableThis.Cond==1)); 
    RT_lastRun_Str = nanmean(tableThis.RTclean(tableThis.Session==nSessions & ...
        tableThis.Cond==2)); 
    RT_lastRun_UnsMinusStr(i) = RT_lastRun_Uns-RT_lastRun_Str;
end
fprintf('Done!\n');
        
        