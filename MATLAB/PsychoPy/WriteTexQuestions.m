function WriteTexQuestions(questionsFile,outFile,randomizeQuestions,randomizeAnswers)

% WriteTexQuestions(questionsFile,outFile,randomizeQuestions,randomizeAnswers)
%
% Created 3/2/15 by DJ.

% Declare defaults
if ~exist('randomizeQuestions')
    randomizeQuestions = False;
end
if ~exist('randomizeAnswers')
    randomizeAnswers = False;
end

% set up read/write
[questions,options,answers] = PsychoPy_ParseQuestions(questionsFile);
fid = fopen(outFile,'w');

if randomizeQuestions
end
if randomizeAnswers
end
    

% Write file
fprintf(fid,'\\begin{enumerate}\n');
n = numel(questions);
for i=1:n
    fprintf(fid,'\t\\item \\textbf{%s}\n',questions{i});
    fprintf(fid,'\t\\begin{enumerate}\n');
    for j=1:numel(options{i})
        fprintf(fid,'\t\t\\item %s\n',options{i}{j});
    end
    fprintf(fid,'\t\\end{enumerate}\n');
    fprintf(fid,'\t\\likert\n\n');
end
fprintf(fid,'\\end{enumerate}\n');

% Clean up
fclose(fid);
disp('Success!');