function ImportAllSimonData(subject,sessions)

% ImportAllSimonData(subject,sessions)
%
% INPUTS:
% -subject is a scalar indicating the number of the subject whose sessions
% you want to import.
% -sessions is an N-element vector indicating the numbers of the sessions 
% you want to import. If not provided, the function will find all the 
% sessions from this subject.
%
% OUTPUTS:
% -files will be saved for each sesssion (Simon-<subject>-<session>.mat) 
% and one across all sessions (Simon-<subject>-all.mat).
%
% Created 3/13/15 by DJ.

if isempty(sessions)
    files = dir(sprintf('Simon-%d-*',subject));
    filenames = {files.name};
    nSessions = numel(filenames);
    sessions = nan(1,nSessions);
    for i=1:nSessions
        iDashes = find(filenames{i}=='-');
        sessions(i) = str2double((iDashes(2)+1):iDashes(3)-1);
    end
else
    nSessions = numel(sessions);
    filenames = cell(1,nSessions);
    for i=1:nSessions
        file = dir(sprintf('Simon-%d-%d-*',subject,sessions(i)));
        filenames{i} = file.name;
    end
end

for i=1:nSessions
    fprintf('===Importing file %d/%d ===\n',i,nSessions);
    figure(100+i);
    data = ImportSimonData(filenames{i});
    save(sprintf('Simon-%d-%d.mat',subject,sessions(i)),'data');
    pause(2)
end

fprintf('=== Combining files... ===\n')
y = LoadAllBehaviorData('Simon',subject,sessions);
save(sprintf('Simon-%d-all.mat',subject),'y');
fprintf('Done!\n')