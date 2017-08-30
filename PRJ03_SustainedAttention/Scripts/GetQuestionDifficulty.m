function [uniqueQuizNames,pctCorrect,p,quizName] = GetQuestionDifficulty(subjects)

% GetQuestionDifficulty(subjects)
%
% INPUTS:
% -subjects is a vector of the numbers of the subjects you want to check.
% 
% OUTPUTS:
% -uniqueQuizNames is an n-element cell array of strings indicating the
% names of the quizzes given to subjects.
% -pctCorrect is an nx10 array in which pctCorrect(i,j) is the % of times
% all subjects got question j right on quiz uniqueQuizNames{i}.
% -p is an nx10 array in which p(i,j) is the probability that subjects
% could have gotten at least this many correct by chance for question j on
% quiz uniqueQuizNames{i}.
%
% Created 8/17/16 by DJ.
% Updated 4/6/17 by DJ - added quizName output

%% get accuracy
nSubj = numel(subjects);
questionTypes = {'attendSound','ignoreSound','reading'};
[quizName, qNumber, isCorrect_ordered,iResp,iCorrectResp] = deal(cell(1,nSubj));
for i=1:nSubj
    fprintf('Loading Subject %d/%d...\n',i,nSubj);
    load(sprintf('/data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ%02d/Distraction-SBJ%02d-Behavior.mat',subjects(i),subjects(i)),'data');
    nRuns = numel(data);
    quizName{i} = cell(10,nRuns);
    [isCorrect_ordered{i}, qNumber{i},iResp{i},iCorrectResp{i}] = deal(nan(10,nRuns));
    for j=1:numel(data)
        isReading = strcmp(data(j).question.type,'reading');
        isCorrect = data(j).question.isCorrect;
        quizName{i}(:,j) = repmat({data(j).params.readingQuiz},10,1);
        isCorrect_ordered{i}(data(j).question.number(isReading),j) = isCorrect(isReading);
        qNumber{i}(:,j) = [1:10]';
        [~,iResp{i}(data(j).question.number(isReading),j)] = ismember(data(j).question.resp(isReading),data(j).params.respKeys);
        [~,iCorrectResp{i}(data(j).question.number(isReading),j)] = ismember(data(j).question.correctResp(isReading),data(j).params.respKeys);        
    end
end

%% Assemble
fprintf('Calculating Accuracy...\n');
iResp_all = cat(2,iResp{:});
iResp_all = iResp_all(:);
iCorrectResp_all = cat(2,iCorrectResp{:});
iCorrectResp_all = iCorrectResp_all(:);
isCorrect_ordered_all = cat(2,isCorrect_ordered{:});
isCorrect_ordered_all = isCorrect_ordered_all(:);
qNumber_all = cat(2,qNumber{:});
qNumber_all = qNumber_all(:);
quizName_all = cat(2,quizName{:});
quizName_all = quizName_all(:);
uniqueQuizNames = unique(quizName_all);

[nCorrect,nTotal] = deal(nan(numel(uniqueQuizNames),10));
for i=1:numel(uniqueQuizNames)
    for j=1:10
        isThis = strcmp(quizName_all,uniqueQuizNames{i}) & qNumber_all==j;
        nCorrect(i,j) = sum(isCorrect_ordered_all(isThis));
        nTotal(i,j) = sum(isThis);
    end
end
pctCorrect = nCorrect./nTotal*100;

%% Find questions not significantly above chance using binomial dist
p = nan(size(nCorrect));
for i=1:numel(uniqueQuizNames)
    p(i,:) = 1-binocdf(nCorrect(i,:),nTotal(i,1),1/4);
end
isNotAboveChance = p>=0.05;

%% Plot results
fprintf('Plotting results...\n');
subplot(2,1,1); cla; hold on;
hBar = bar(pctCorrect');
PlotHorizontalLines(25,'k:');
xData = GetBarPositions(hBar);
plot(xData(isNotAboveChance),pctCorrect(isNotAboveChance)+5,'k*');
legend([uniqueQuizNames;{'chance';'not significantly above chance'}],'interpreter','none');
xlabel('question #')
ylabel('% correct')
title('Distraction Accuracy By Question')
subplot(2,1,2);
bar(nTotal');
xlabel('question #')
ylabel('# times asked')

fprintf('Done!\n');

%% Plot confusion matrix for low-accuracy questions.
% iQuiz = 4;
% iQ = 1;
% isThisQ = strcmp(quizName_all,uniqueQuizNames{iQuiz}) & qNumber_all==iQ;
% freq = hist(iResp_all(isThisQ),1:4);
% iCorrect = unique(iCorrectResp_all(isThisQ));
% figure(24);
% bar(freq);
% xlabel('response')
% ylabel('# times selected');
% title(sprintf('quiz %d, q#%d: correct = %d',iQuiz,iQ,iCorrect));