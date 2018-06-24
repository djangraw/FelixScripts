function script_runEverything

% This script uses getSubjects to get the file prefixes we want to use,
% then calls run_logisticregression_jittered_EM_saccades_wrapper for each
% one with each possible set of start/end and weighted/unweighted options. 
% Results will be saved to appropriate folders.
%
% script_runEverything
%
% Navigate to the 'code' folder of the JitteredLogisticRegression dropbox
% folder before running this script.
%
% Created 6/24/11 by BC.
% Updated 8/3/11 by DJ - comments.
% Updated 8/29/11 by DJ - commented out toObject stuff, temporarily

subjects = getSubjects; % cell array of strings, one for each subject

for j=1:length(subjects)
%    run_logisticregression_jittered_EM_saccades_wrapper(subjects{j},'start',1,'loo'); % saccade start, weighted priors
    run_logisticregression_jittered_EM_saccades_wrapper(subjects{j},'allToObject_start',0,'loo'); % saccade start, unweighted priors
%    run_logisticregression_jittered_EM_saccades_wrapper(subjects{j},'end',1,'loo'); % saccade end, weighted priors
    run_logisticregression_jittered_EM_saccades_wrapper(subjects{j},'allToObject_end',0,'loo'); % saccade end, unweighted priors
end
return;

% for j=1:3;%length(subjects)
%     run_logisticregression_jittered_EM_saccades_wrapper(subjects{j},'toObject_end',0,'10fold'); % saccade end, unweighted priors
% end    
% 
% for j=1:3;%length(subjects)    
%     run_logisticregression_jittered_EM_saccades_wrapper(subjects{j},'toObject_start',0,'10fold'); % saccade start, unweighted priors
% end
