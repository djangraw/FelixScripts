function [JLR, JLP] = LoadJlrResults_AcrossSubjects(subjects,tags)

% Created 12/6/12 by DJ.
% Updated 12/18/12 by DJ - edit to work with multiwinresults.

% Handle inputs
if ischar(tags)
    tags = {tags};
end
if ischar(subjects)
    subjects = {subjects};
end

% Set up
nSubjects = numel(subjects);
[JLR,JLP] = deal(cell(1,nSubjects));

% Load results
for i=1:nSubjects
    % Build up search strings
    fprintf('Subject %s: Finding... ',subjects{i})
    tag_string = sprintf('*results_%s_*',subjects{i});
    for j=1:numel(tags)
        tag_string = strcat(tag_string,tags{j},'*');
    end

    % Search with dir
    jlrfolder = dir(strcat(tag_string));

    % Ensure that exactly one matching folder was found
    if length(jlrfolder)~=1
        error('Search did not yield one unique folder.');
    end

    % Load
    fprintf('Loading... ')
    [JLR{i} JLP{i}] = LoadJlrResults(jlrfolder.name);
    disp('Success!')
end