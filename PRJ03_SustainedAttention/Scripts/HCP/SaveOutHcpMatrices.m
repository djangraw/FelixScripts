% SaveOutHcpMatrices.m
%
% Created 12/13/17 by DJ.

%% Load data (takes a while)
foo = load('/data/NIMH_SFIM/HCP900_mats_allSessions_novols.mat');

%% Save out separate files
tasks = {'emotion','gambling','language','motor','relational','rest2','social','wm'};
HCP900_sub_id = foo.all_subs;
for i=1:numel(tasks)
    fprintf('HCP900_%s_mats = foo.all_data.%s.mats_avg;\n',tasks{i},upper(tasks{i}));
    fprintf('save(''HCP900_%s_mats'',''HCP900_%s_mats'',''HCP900_sub_id'')\n',tasks{i},tasks{i});

    eval(sprintf('HCP900_%s_mats = foo.all_data.%s.mats_avg;',tasks{i},upper(tasks{i})));
    eval(sprintf('save(''HCP900_%s_mats'',''HCP900_%s_mats'',''HCP900_sub_id'')',tasks{i},tasks{i}));
end

%% Load Datasets Using only first 176 TRs for each task
foo = load('/data/NIMH_SFIM/HCP900_mats_allSessions_novols176.mat');

%% Save out separate files
cd /data/jangrawdc/PRJ03_SustainedAttention/Results/FromEmily
tasks = {'emotion','gambling','language','motor','relational','rest','rest2','social','wm'};
HCP900_sub_id = foo.all_subs;
for i=1:numel(tasks)
    fprintf('HCP900_%s_mats = foo.all_data.%s.mats_avg;\n',tasks{i},upper(tasks{i}));
    fprintf('save(''HCP900_%s_mats_176TRs'',''HCP900_%s_mats'',''HCP900_sub_id'')\n',tasks{i},tasks{i});

    eval(sprintf('HCP900_%s_mats = foo.all_data.%s.mats_avg;',tasks{i},upper(tasks{i})));
    eval(sprintf('save(''HCP900_%s_mats_176TRs'',''HCP900_%s_mats'',''HCP900_sub_id'')',tasks{i},tasks{i}));
end

%% Load Motion Data
% Get motion scores
foo = load('/data/NIMH_SFIM/HCPn900_motion_RelativeRMSmean.mat');

%% Save out motion data
cd /data/jangrawdc/PRJ03_SustainedAttention/Results/FromEmily
tasks = {'emotion','gambling','language','motor','relational','rest1','rest2','social','wm'};
all_subj = HCP900_sub_id;
for i=1:numel(tasks)
    % LR
    lrInfo = foo.all_motion.(sprintf('%s_LR',upper(tasks{i})));
    isInList = ismember(all_subj,lrInfo.sub_list);
    lrMot = nan(size(all_subj));
    lrMot(isInList) = lrInfo.sub_motion;
    % RL
    rlInfo = foo.all_motion.(sprintf('%s_RL',upper(tasks{i})));
    isInList = ismember(all_subj,rlInfo.sub_list);
    rlMot = nan(size(all_subj));
    rlMot(isInList) = rlInfo.sub_motion;
    % Place mean into named variable and save
    motBoth = mean([lrMot, rlMot],2);
    fprintf('HCP900_%s_motion = motBoth;\n',tasks{i});
    fprintf('save(''HCP900_%s_motion'',''HCP900_%s_motion'',''HCP900_sub_id'')\n',tasks{i},tasks{i});
    eval(sprintf('HCP900_%s_motion = motBoth;\n',tasks{i}));
    eval(sprintf('save(''HCP900_%s_motion'',''HCP900_%s_motion'',''HCP900_sub_id'')\n',tasks{i},tasks{i}));
end
    