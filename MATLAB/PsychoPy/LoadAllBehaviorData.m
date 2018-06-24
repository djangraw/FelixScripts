function y = LoadAllBehaviorData(experiment,subject,sessions)

% ImportAllSimonData(experiment,subject,sessions)
%
% INPUTS:
% -experiment is a string indicating the name/prefix of the experiment.
% -subject is a scalar indicating the number of the subject whose sessions
% you want to load.
% -sessions is an N-element vector indicating the numbers of the sessions 
% you want to import. If not provided, the function will find all the 
% sessions from this subject.
%
%    The script will look for files called
%    <experiment>-<subject>-<session>.mat.
%
% OUTPUTS:
% -y is a vector of data structs imported by ImportSimonData.mat.
%
% Created 3/13/15 by DJ.

if ~exist('sessions','var')
    % Find all mat files from this subject
    files = dir(sprintf('%s-%d-*.mat',experiment,subject));
    filenames = {files.name};
    if isempty(filenames)
        error('No files found!')
    end
else
    % Construct filenames
    filenames = cell(1,numel(sessions));
    for i=1:numel(sessions)
        filenames{i} = sprintf('%s-%d-%d.mat',experiment,subject,sessions(i));        
    end
end

% Load in files
for i=1:numel(filenames)
    if ~exist(filenames{i},'file')
        warning('File %s not found!',filenames{i})
    else
        foo = load(filenames{i});    
        y(i) = foo.data;
    end
end