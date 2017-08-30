function [fracCorrect, medRT, pCorrect] = GetFracCorrect_AllSubjects(subjects,questionType)

% [fracCorrect, medRT, pCorrect] = GetFracCorrect_AllSubjects(subjects,questionType)
%
% Created 11/16/16 by DJ.
% Updated 12/16/16 by DJ - added questionType input
% Updated 2/22/17 by DJ - added /Results to homedir
% Updated 8/29/17 by DJ - added output pCorrect

% Declare inputs
if ~exist('questionType','var') || isempty(questionType)
    questionType = 'reading';
end
% Declare constants
nSubj = numel(subjects);
vars = GetDistractionVariables;
homedir = vars.homedir;

% Set up
[fracCorrect, medRT, pCorrect] = deal(nan(nSubj,1));
% Load & calculate
fprintf('===Loading data for %d subjects...\n',nSubj);
for i=1:nSubj
    % load behavior data
    beh = load(sprintf('%s/Results/SBJ%02d/Distraction-SBJ%02d-Behavior.mat',homedir,subjects(i),subjects(i)));
    % calculate performance on reading questions
    switch questionType
        case 'audio'
            isRelevant = ~strcmp('reading',beh.question.type);
        case 'all'
            isRelevant = true(size(beh.question.type));
        otherwise % reading, attendSound, ignoreSound
            isRelevant = strcmp(questionType,beh.question.type);
    end
    fracCorrect(i) = mean(beh.question.isCorrect(isRelevant));
    medRT(i) = median(beh.question.RT(isRelevant));
    % Check that it's greater than chance
    pCorrect(i) = 1-binocdf(fracCorrect(i)*sum(isRelevant),sum(isRelevant),0.25);
end
fprintf('===Done!\n');