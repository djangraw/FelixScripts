% Created 5/23/17 by DJ.

load('SBJ03_task_behavior.mat'); % load data
% get HR
[HR, HRrest] = GetHeartRateDuringSinging(data);

%% check stats
conditions = data(1).params.trialTypes;
sizeHR = size(HR);
HR_vec = reshape(HR,[sizeHR(1)*sizeHR(2),sizeHR(3)]);
% Ranksum Tests
fprintf('---Ranksum tests:\n');

[p,h,stats] = ranksum(HR_vec(:,1),HR_vec(:,2));
fprintf('%s vs. %s: p=%.3g\n',conditions{1},conditions{2},p);
[p,h,stats] = ranksum(HR_vec(:,1),HR_vec(:,3));
fprintf('%s vs. %s: p=%.3g\n',conditions{1},conditions{3},p);
[p,h,stats] = ranksum(HR_vec(:,1),HRrest(:));
fprintf('%s vs. %s: p=%.3g\n',conditions{1},'rest',p);

[p,h,stats] = ranksum(HR_vec(:,2),HR_vec(:,3));
fprintf('%s vs. %s: p=%.3g\n',conditions{2},conditions{3},p);
[p,h,stats] = ranksum(HR_vec(:,2),HRrest(:));
fprintf('%s vs. %s: p=%.3g\n',conditions{2},'rest',p);

[p,h,stats] = ranksum(HR_vec(:,3),HRrest(:));
fprintf('%s vs. %s: p=%.3g\n',conditions{3},'rest',p);
