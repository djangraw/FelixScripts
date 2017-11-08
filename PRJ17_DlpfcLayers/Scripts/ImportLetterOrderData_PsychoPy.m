function data = ImportLetterOrderData_PsychoPy(logFilename)

% data = ImportLetterOrderData_PsychoPy(logFilename)
%
% Created 10/24/17 by DJ.

% Import parameters and events
params = PsychoPy_ParseParams(logFilename,'---START PARAMETERS---','---END PARAMETERS---');
events = PsychoPy_ParseEvents(logFilename,{'display','key','trial'},'WaitingForScanner');%'---START EXPERIMENT---');

%% Convert string arrays to number arrays
fields = fieldnames(params);
for i=1:numel(fields)
    if iscell(params.(fields{i})) && ~any(cellfun(@(x) isnan(str2double(x)),params.(fields{i}))) && ~ismember(fields{i},{'respKeys','triggerKey'})
        params.(fields{i}) = cellfun(@str2num,params.(fields{i}));
    end
end

%% Parse trial strings
for i=1:numel(events.trial.time)
    foo = strsplit(events.trial.name{i},{' ', ', '});
    for j=1:numel(foo)-2
        if strcmp(foo{j+1}, '=')
            if ~isnan(str2double(foo{j+2}))
                events.trial.(foo{j})(i,:) = str2double(foo{j+2});
            else
                events.trial.(foo{j}){i,:} = foo{j+2};
            end
        end
    end
        
end

%% Construct output
data.params = params;
data.events = events;
