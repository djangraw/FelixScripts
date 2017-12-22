% Prep100RunsDataForSound.m
%
% Created 12/20/17 by DJ.

% Copy betas from each task
subjects = 1:2;
sessions = 1:3; % 1:9 would be more complete
tasks = 1:13;

for i=1:numel(subjects)
    for j=1:numel(sessions)
        for k=1:numel(tasks)
            fprintf('%d, %d, %d\n',i,j,k);
            try
                Copy100RunsIcsToFmriToSoundDir(subjects(i),sessions(j),tasks(k));
            catch
                fprintf('...not found.\n');
            end
        end
    end
end
%% Load timecourses and betas
[icTcs_accepted,betas_accepted,iAccepted,taskTc] = deal(cell(numel(subjects),numel(sessions),numel(tasks)));

for i=1:numel(subjects)
    for j=1:numel(sessions)
        for k=1:numel(tasks)            
            if exist(sprintf('SBJ%02d_S%02d_Task%02d_accepted.txt',subjects(i),sessions(j),tasks(k)),'file')
                fprintf('%d, %d, %d...\n',i,j,k);            
                [icTcs_accepted{i,j,k},betas_accepted{i,j,k},iAccepted{i,j,k}] = Get100RunsAcceptedCompTcs(subjects(i),sessions(j),tasks(k));
                betas_accepted{i,j,k} = betas_accepted{i,j,k}.img;
                [taskTc{i,j,k}, tTask] = Get100RunsTaskTimecourse(subjects(i),sessions(j),tasks(k));

            end
        end
    end
end
fprintf('Done!\n');
%% Get matches

% [iBest,match] = MatchAllComponents(comps1,comps2);

%% Select components from one run
i=1;j=1;k=1;
icTcs_this = icTcs_accepted{i,j,k};
betas_this = betas_accepted{i,j,k};
taskTc_this = taskTc{i,j,k};
tTask_this = tTask;

save TestData100RunsSound *this

%% Load data from each run, get timecourses in given components
for i=1:numel(subjects)
    for j=1:numel(sessions)
        for k=1:numel(tasks)            
            if exist(sprintf('SBJ%02d_S%02d_Task%02d_accepted.txt',subjects(i),sessions(j),tasks(k)),'file')
                fprintf('%d, %d, %d...\n',i,j,k);            
                [icTcs_accepted{i,j,k},betas_accepted{i,j,k},iAccepted{i,j,k}] = Get100RunsAcceptedCompTcs(subjects(i),sessions(j),tasks(k));
                betas_accepted{i,j,k} = betas_accepted{i,j,k}.img;
                [taskTc{i,j,k}, tTask] = Get100RunsTaskTimecourse(subjects(i),sessions(j),tasks(k));

            end
        end
    end
end