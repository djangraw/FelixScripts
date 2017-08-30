function WriteSingingStimTimecourses(data,outFolder,subjName)

% WriteSingingStimTimecourses(data,outFolder,subjName)
%
% INPUTS:
% -data is a struct of singing task behavior
% -outFolder is a string indicating the folder where you'd like to save the
% output files 
% -subjName is a string indicating the subject name (which sometimes
% includes the task type, like SBJ03_task).
%
% Created 4/20/17 by DJ.
% Updated 4/24/17 by DJ - also write _start files for
% non-duration-modulated regressors
% Updated 5/17/17 by DJ - added rest regressors

% Declare constants
TR = 2; % use 1 to keep indices in units of seconds
nFirstTRsRemoved = 3;
if strcmp(subjName,'SBJ03_task')
    nTRsPerSession = 154; % 157 before, 154 after
elseif strcmp(subjName,'SBJ03_baseline') || strcmp(subjName,'SBJ03_improv')
    nTRsPerSession = 47;
elseif strcmp(subjName,'SBJ03_wholesong')
    nTRsPerSession = 222;
end
doRound = true;

% Find conditions
conditions = {};
for i=1:numel(data)
    conditions = [conditions, data(i).params.trialTypes];
end
conditions = unique(conditions);
nCond = numel(conditions);

% Initialize output files for each
clear fid fid_start;
for j=1:nCond
    fid(j) = fopen(fullfile(outFolder,sprintf('%s_%s.1D',subjName,conditions{j})), 'w');
end
for j=1:nCond
    fid_start(j) = fopen(fullfile(outFolder,sprintf('%s_%s_start.1D',subjName,conditions{j})), 'w');
end
% Initialize 'rest' output files
fid(nCond+1) = fopen(fullfile(outFolder,sprintf('%s_%s.1D',subjName,'Rest')), 'w');
fid_start(nCond+1) = fopen(fullfile(outFolder,sprintf('%s_%s_start.1D',subjName,'Rest')), 'w');

% Write stim times to folders
for i=1:numel(data)
    % Get times of triggers
    tTriggers = data(i).events.key.time(strcmp(data(i).events.key.char,'t'));
    tStart = tTriggers(1);
    % Get times of condition end
    if any(ismember(data(i).events.display.name,conditions))
        tOff = data(i).events.display.time(~ismember(data(i).events.display.name,conditions));
    else
        tOff = data(i).events.display.time(strcmp(data(i).events.display.name,'Fixation'));
    end
    
    for j=1:nCond
        % Find times when this condition started
        if any(strcmp(data(i).events.display.name, conditions{j}))
            isCond = strcmp(data(i).events.display.name, conditions{j});
            isCondStart = [0; diff(isCond)]>0;
            tOn = data(i).events.display.time(isCondStart);
        else
            tOn = data(i).events.display.time(strncmp(data(i).events.display.name, [conditions{j} '(1/'],length(conditions{j})+3));
        end
        % Find duration of each block
        duration = nan(1,numel(tOn));
        for k=1:numel(tOn)
            tOff_this = tOff(find(tOff>tOn(k),1));
            duration(k) = tOff_this-tOn(k);
        end
        
        % get indices of start times
        fprintf('Converting to TR indices...\n')
        eventSessions = ones(size(tOn))*i; % all from this session
        iOn_combo = ConvertBoldSessionTimeToComboTime(tOn-tStart,eventSessions,TR,nFirstTRsRemoved,nTRsPerSession,doRound);
        tOn_combo = iOn_combo*TR;
        
        % Write to file
        for k=1:numel(tOn)
            % Write amplitude/duration for this block
%             fprintf(fid(j),'%g*%g:%g',tOn(k)-tStart,1,duration(k));
            fprintf(fid(j),'%g*%g:%g',tOn_combo(k),1,duration(k));
            fprintf(fid_start(j),'%g',tOn_combo(k));
            if k<numel(tOn) % Write space
                fprintf(fid(j),' ');
                fprintf(fid_start(j),' ');
            else % Write newline
                fprintf(fid(j),'\n');
                fprintf(fid_start(j),'\n');
            end
        end
    end
        
    
    % ============================================= 
    % === Make Rest Regressors
    tOff = data(i).events.display.time(strcmp(data(i).events.display.name,'Fixation'));
    tOn_cell = cell(1,nCond);
    for j=1:nCond
        % Find times when this condition started
        if any(strcmp(data(i).events.display.name, conditions{j}))
            isCond = strcmp(data(i).events.display.name, conditions{j});
            isCondStart = [0; diff(isCond)]>0;
            tOn_cell{j} = data(i).events.display.time(isCondStart);
        else
            tOn_cell{j} = data(i).events.display.time(strncmp(data(i).events.display.name, [conditions{j} '(1/'],length(conditions{j})+3));
        end
    end
    tOn = unique([tOn_cell{:}]);
    % Find duration of each block
    duration = nan(1,numel(tOff));
    for k=1:numel(tOff)
        tOn_this = tOn(find(tOn>tOff(k),1));
        if ~isempty(tOn_this)
            duration(k) = tOn_this-tOff(k);
        end
    end
    
    % get indices of start times
    fprintf('Converting to TR indices...\n')
    eventSessions = ones(size(tOff))*i; % all from this session
    iOff_combo = ConvertBoldSessionTimeToComboTime(tOff-tStart,eventSessions,TR,nFirstTRsRemoved,nTRsPerSession,doRound);
    tOff_combo = iOff_combo*TR;

    % Crop
    isNotFound = isnan(duration) | isnan(tOff_combo');
    tOff(isNotFound) = [];
    tOff_combo(isNotFound) = [];
    duration(isNotFound) = [];
    
    % Write to file
    for k=1:numel(tOff)
        % Write amplitude/duration for this block
%             fprintf(fid(nCond+1),'%g*%g:%g',tOn(k)-tStart,1,duration(k));
        fprintf(fid(nCond+1),'%g*%g:%g',tOff_combo(k),1,duration(k));
        fprintf(fid_start(nCond+1),'%g',tOff_combo(k));
        if k<numel(tOff) % Write space
            fprintf(fid(nCond+1),' ');
            fprintf(fid_start(nCond+1),' ');
        else % Write newline
            fprintf(fid(nCond+1),'\n');
            fprintf(fid_start(nCond+1),'\n');
        end
    end
        
        
end

% Clean up
for j=1:nCond
    fclose(fid(j));
    fclose(fid_start(j));
end


