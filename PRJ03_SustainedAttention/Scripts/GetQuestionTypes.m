function questionType = GetQuestionTypes(data)

% questionType = GetQuestionTypes(data)
%
% Created 9/23/16 by DJ.

[isAttend_cell,isWhiteNoise_cell,questionType] = deal(cell(1,numel(data)));
    for j=1:numel(data)
        isReading_this = strcmp(data(j).question.type,'reading');
        isAttendStart = strncmp(data(j).params.promptType,'AttendBoth',length('AttendBoth'));
        if isAttendStart % first half of reading questions will be "reading_attendSpeech" questions
            isAttend_cell{j} = (data(j).question.number<=5 & isReading_this);
        else % second half of reading questions will be "reading_attendSpeech" questions
            isAttend_cell{j} = (data(j).question.number>5 & isReading_this);
        end
        % is each page white noise?
        [~,~, pageNum] = GetPageTimes(data(j).events);
        isPageSound = ismember(data(j).events.soundstart.name,{'attendSound','ignoreSound','whiteNoiseSound'});
        isPageWhiteNoise = strcmp(data(j).events.soundstart.name(isPageSound),'whiteNoiseSound');
        % is each question white noise?
        qFirstPage = cellfun(@min,data(j).question.pages(isReading_this)); % is MIN correct? Should they ALL have to be WN?
        [~,iQFirstPage] = ismember(qFirstPage,pageNum);
        %
        isWhiteNoise_cell{j} = false(size(isReading_this));        
        isWhiteNoise_cell{j}(isReading_this) = isPageWhiteNoise(iQFirstPage);
        questionType_cell{j} = data(j).question.type;
    end
    isAttend = cat(1,isAttend_cell{:});
    isWhiteNoise = cat(1,isWhiteNoise_cell{:});
    % Assign Question Types
    questionType = cat(1,questionType_cell{:});
    isReading = strcmp(questionType,'reading');
    questionType(isReading & ~isWhiteNoise & isAttend) = {'reading_attendSpeech'};
    questionType(isReading & ~isWhiteNoise & ~isAttend) = {'reading_ignoreSpeech'};
    questionType(isReading & isWhiteNoise & isAttend) = {'reading_attendNoise'};
    questionType(isReading & isWhiteNoise & ~isAttend) = {'reading_ignoreNoise'};
    questionType(strcmp(questionType,'attendSound')) = {'attendSpeech'};
    questionType(strcmp(questionType,'ignoreSound')) = {'ignoreSpeech'};
end