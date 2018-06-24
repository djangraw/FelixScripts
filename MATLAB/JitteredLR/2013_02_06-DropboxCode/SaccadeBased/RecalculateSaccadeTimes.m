function RecalculateSaccadeTimes(subjects)

% Load each EEG file, extract the saccade times, and save them in the
% appropriate directories.
%
% RecalculateSaccadeTimes(subjects)
%
% Navigate to the Dropbox data folder before calling this function.  Data
% must be in cd/3DS-TAG-<subject>/3DS-TAG-<subject>-target/distractorappear
% .set and resutls will be saved to cd/3DS-TAG-<subject>/3DS-TAG-<subject>
% -SaccadeTimes.mat and -SaccadeToObject.mat.
%
% INPUTS:
% -subjects is a cell array of strings or a vector of integers indicating 
% the names or numbers of the subjects whose saccade data should be 
% recalculated.
%
% Created 8/10/11 by DJ.
% Updated 8/16/11 by DJ - added AllSaccadesToObject stuff, but commented it
% out until the BigSaccade data is available.
% Updated 9/1/11 by DJ - allow string inputs for subjects.

% convert from string to cell if necessary
if ischar(subjects)
    subjects = {subjects};
end

% Convert from numbers to cells of strings if necessary
if isnumeric(subjects)
    subnum = subjects;
    subjects = cell(1,numel(subnum));
    for i=1:numel(subnum)
        subjects{i} = sprintf('3DS-TAG-%d',subnum(i));
    end
end

for i=1:numel(subjects)        
    % Set up
    subject = subjects{i};
    ALLEEG = []; EEG = [];
    % Load subject data
    fprintf('Loading data for Subject %s...\n',subject);
    EEG = pop_loadset(sprintf('%s-targetappear.set',subject),subject);
    [ALLEEG,EEG] = eeg_store(ALLEEG,EEG);
    EEG = pop_loadset(sprintf('%s-distractorappear.set',subject),subject);
    [ALLEEG,EEG] = eeg_store(ALLEEG,EEG);
    % Update SaccadeTimes
    disp('Recalculating SaccadeTimes...')
    target_saccades_end = GetEpochSaccades(ALLEEG(1),'SACCADE_END'); % Get all saccade_end events in each target epoch
    target_saccades_start = GetEpochSaccades(ALLEEG(1),'SACCADE_START');
    distractor_saccades_end = GetEpochSaccades(ALLEEG(2),'SACCADE_END');
    distractor_saccades_start = GetEpochSaccades(ALLEEG(2),'SACCADE_START');    
    % save results
    save(sprintf('%s/%s-SaccadeTimes',subject,subject),'distractor_saccades_end', ...
        'target_saccades_end', 'distractor_saccades_start', 'target_saccades_start');
    
    % Update SaccadeToObject
%     disp('Recalculating SaccadeToObject...')
%     target_saccades_end = GetEpochSaccades(ALLEEG(1),'TARGET'); % Get SaccadeToTarget event as determined previously
%     distractor_saccades_end = GetEpochSaccades(ALLEEG(2),'DISTRACTOR'); % Get SaccadeToDistractor event as determined previously
%     % get saccade start times
%     for j=1:numel(target_saccades_start)
%         allstarts = target_saccades_start{j};
%         target_saccades_start{j} = allstarts(find(allstarts<target_saccades_end{j},1,'last')); % the last saccade start before desired saccade end is the start of that saccade
%     end
%     for j=1:numel(distractor_saccades_start)
%         allstarts = distractor_saccades_start{j};
%         distractor_saccades_start{j} = allstarts(find(allstarts<distractor_saccades_end{j},1,'last')); % the last saccade start before desired saccade end is the start of that saccade
%     end
%     % save results
%     save(sprintf('3DS-TAG-%d/3DS-TAG-%d-SaccadeToObject',subject,subject),'distractor_saccades_end', ...
%         'target_saccades_end', 'distractor_saccades_start', 'target_saccades_start');
    
    % Update AllSaccadesToObject
    disp('Recalculating AllSaccadesToObject...')
    load(sprintf('%s/%s-BigSaccade',subject,subject));
    [target_saccades_start target_saccades_end] = GetEpochSaccadesToObject(BigSaccade,ALLEEG(1),100); 
    [distractor_saccades_start distractor_saccades_end] = GetEpochSaccadesToObject(BigSaccade,ALLEEG(2),100); 
    % save results
    save(sprintf('%s/%s-AllSaccadesToObject',subject,subject),'distractor_saccades_end', ...
        'target_saccades_end', 'distractor_saccades_start', 'target_saccades_start');
    
    
    % Update SaccadeToObject
    % (first saccade to object after t=0)
    disp('Recalculating SaccadeToObject...')
    % get saccade start times
    for j=1:numel(target_saccades_start)
        allstarts = target_saccades_start{j};
        target_saccades_start{j} = target_saccades_start{j}(find(allstarts>0,1)); % the first saccade start after t=0 is the start of that saccade
        target_saccades_end{j} = target_saccades_end{j}(find(allstarts>0,1)); % the last saccade start before desired saccade end is the start of that saccade
    end
    for j=1:numel(distractor_saccades_start)
        allstarts = distractor_saccades_start{j};
        distractor_saccades_start{j} = distractor_saccades_start{j}(find(allstarts>0,1)); % the first saccade start after t=0 is the start of that saccade
        distractor_saccades_end{j} = distractor_saccades_end{j}(find(allstarts>0,1)); % the last saccade start before desired saccade end is the start of that saccade
    end
    % save results
    save(sprintf('%s/%s-SaccadeToObject',subject,subject),'distractor_saccades_end', ...
        'target_saccades_end', 'distractor_saccades_start','target_saccades_start');

    disp('Success!')
end