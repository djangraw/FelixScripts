% PlotQuestionResults_script
%
% Created 2/19/16 by DJ.
% Updated 11/9/16 by DJ to work on Felix.

% subjects = 9:36;
subjects = [9:11, 13:19,22,24:25,28,30:34,36];

for i=1:numel(subjects)
    subject=subjects(i);

    cd(sprintf('/data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ%02d',subject));
    load(sprintf('Distraction-SBJ%02d-Behavior.mat',subject));

    question.subject = repmat(subject,size(question.type));
%     qTypes = unique(question_all.type);

    % Separate out reading Q's into attend or ignore periods
    isReading = strcmp(question.type,'reading');
    [isAttend_cell,isWhiteNoise_cell] = deal(cell(1,numel(data)));
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
    end
    isAttend = cat(1,isAttend_cell{:});
    isWhiteNoise = cat(1,isWhiteNoise_cell{:});
    question.type(isReading & isAttend) = {'reading_attendSpeech'};
    question.type(isReading & ~isAttend) = {'reading_ignoreSpeech'};
    question.type(isReading & isWhiteNoise) = {'reading_whiteNoise'};
    question.type(strcmp(question.type,'attendSound')) = {'attendSpeech'};
    question.type(strcmp(question.type,'ignoreSound')) = {'ignoreSpeech'};
    qTypes = {'attendSpeech','ignoreSpeech','reading_attendSpeech','reading_ignoreSpeech','reading_whiteNoise'};
    
    % Set up cross-subject variables
    if i==1
        question_all = question;
        [acc,rt,nTrials] = deal(nan(numel(subjects),numel(qTypes)));
    else
        question_all = AppendStructs({question_all,question},1);
    end
    
    % calculate and display behavioral results  
    fprintf('SUBJECT %d:\n',subject);
    for j=1:numel(qTypes)
        isThis = strcmp(question.type,qTypes{j});        
        acc(i,j) = mean(question.isCorrect(isThis));
        rt(i,j) = median(question.RT(isThis));
        nTrials(i,j) = sum(isThis);
        fprintf('%s: %d/%d=%.1f%% correct\n',qTypes{j},sum(question.isCorrect(isThis)),sum(isThis),acc(i,j)*100)
    end
    
end

%% get accuracy
% qTypes = unique(question_all.type);
% [acc_all, rt_all, acc_all_SD, rt_all_SD]= deal(nan(1,numel(qTypes)));
% for j=1:numel(qTypes)
%     isThis = strcmp(question_all.type,qTypes{j});    
%     acc_all(j) = mean(question_all.isCorrect(isThis));
%     rt_all(j) = median(question_all.RT(isThis));
% %     acc_all_SD(j) = std(question_all.isCorrect(isThis));
% %     rt_all_SD(j) = std(question_all.RT(isThis));
%     fprintf('%s: %d/%d=%.1f%% correct\n',qTypes{j},sum(question_all.isCorrect(isThis)),sum(isThis),acc_all(j)*100)
% end
acc_all = median(acc);
rt_all = median(rt);
acc_all_SD = std(acc)/sqrt(numel(subjects));
rt_all_SD = std(rt)/sqrt(numel(subjects));
%% Plot results
labelstr = cell(1,numel(subjects)+1);
for i=1:numel(subjects)
    labelstr{i} = sprintf('SBJ%02d',subjects(i));
end
labelstr{end} = 'Subject Median';

figure(23); clf;
% subplot(211); 
hold on;
hBar = bar([acc; acc_all]*100);
xData = GetBarPositions(hBar);
PlotHorizontalLines(25,'k:');
errorbar(xData(:,end), acc_all*100, acc_all_SD*100,'k.');
set(gca,'xtick',1:(numel(subjects)+1),'xticklabel',labelstr);
ylabel('Accuracy (%)')
set(gca,'YGrid','on')
legend([qTypes,{'chance'}],'interpreter','none','Location','SouthEast')
set(gcf,'Position',[63 497 1139 379])
ylim([0 100])

figure(24); clf;
% subplot(212); 
hold on;
hBar = bar([rt; rt_all]);
xData = GetBarPositions(hBar);
errorbar(xData(:,end), rt_all, rt_all_SD,'k.');
set(gca,'xtick',1:(numel(subjects)+1),'xticklabel',labelstr);
ylabel('RT (s)')
set(gca,'YGrid','on')
legend(qTypes,'interpreter','none','Location','SouthEast')
set(gcf,'Position',[63 100 1139 379])

% Do compilation plots
figure(25); clf;
subplot(121);
hold on;
acc_all_block = [acc_all(1:2),NaN; acc_all(3:5)];
acc_all_SD_block = [acc_all_SD(1:2),NaN; acc_all_SD(3:5)];
hBar = bar(acc_all_block*100);
xData = GetBarPositions(hBar);
errorbar(xData(:,1), acc_all_block(1,:)*100, acc_all_SD_block(1,:)*100,'k.');
errorbar(xData(:,2), acc_all_block(2,:)*100, acc_all_SD_block(2,:)*100,'k.');
PlotHorizontalLines(25,'k:');
% plot([.6 2.6],[25 25],'k:');
% Annotate plot
ylabel('Accuracy (%)')
set(gca,'YGrid','on')
legend('Attend Speech','Ignore Speech','White Noise','Location','NorthWest');
set(gca,'xtick',1:2,'xticklabel',{'Speech','Reading'});
ylim([0 100])
title('Subject Median Comprehension Accuracy')

subplot(122); 
hold on;
rt_all_block = [rt_all(1:2),NaN; rt_all(3:5)];
rt_all_SD_block = [rt_all_SD(1:2),NaN; rt_all_SD(3:5)];
hBar = bar(rt_all_block);
xData = GetBarPositions(hBar);
errorbar(xData(:,1), rt_all_block(1,:), rt_all_SD_block(1,:),'k.');
errorbar(xData(:,2), rt_all_block(2,:), rt_all_SD_block(2,:),'k.');
% Annotate plot
ylabel('RT (s)')
set(gca,'YGrid','on')
legend('Attend Speech','Ignore Speech','White Noise','Location','NorthEast');
set(gca,'xtick',1:2,'xticklabel',{'Speech','Reading'});
title('Subject Median Comprehension Question Reaction Time')

% Move figure
set(gcf,'Position',[63   591   845   285])

%% Run ANOVA to look at relative effects of subject and question type

[type,subj] = meshgrid(1:size(acc,2),1:numel(subjects));
[p,tbl,stats] = anovan(acc(:),[subj(:),type(:)]);