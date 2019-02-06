function PrintStorySubjects()

% PrintStorySubjects()
%
% Created 2/4/19 by DJ.

directories = dir('h*');
subjects = {directories.name};
fprintf('subjects="')
for i=1:numel(subjects)
    fprintf('%s ',subjects{i})
    if mod(i,8)==7
        fprintf('" \\ \n"')
    end
end
fprintf('"\n')