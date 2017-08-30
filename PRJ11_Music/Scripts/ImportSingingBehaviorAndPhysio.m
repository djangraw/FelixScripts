function data = ImportSingingBehaviorAndPhysio(subject, sessions, biopacFilenames)

% data = ImportSingingBehaviorAndPhysio(subject, sessions, biopacFilenames)
%
% Created 3/31/17 by DJ.
% Updated 4/24/17 by DJ - added GetMusicVariables to work on local machine

% Declare Constants
vars = GetMusicVariables;
homedir = vars.homedir;

% Load data
for i=1:numel(sessions)
    fprintf('subject %d, session %d...\n',subject,sessions(i));
    % import behavior
    dir_output = dir(sprintf('%s/RawData/SBJ%02d/behavior/Singing-%d-%d-*',homedir,subject,subject,sessions(i)));
    if numel(dir_output)==1
        data{i} = ImportSingingData(fullfile(sprintf('%s/RawData/SBJ%02d/behavior/',homedir,subject),dir_output(1).name));
    end
    data{i}.physio = ImportBiopacData(sprintf('%s/RawData/SBJ%02d/physio/%s',homedir,subject,biopacFilenames{i}));
    
end
% Clean up
fprintf('Appending...\n');
data = [data{:}];
fprintf('Done!\n');
