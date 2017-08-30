% GetRosenbergComprehensionHalves.m
%
% Created 7/20/16 by DJ based on GetClassifierComprehensionAucs.m.

% subjects = 9:36;
subjects = [9:11, 13:19,22,24:25,28,30:34,36];

AzCv = nan(1,numel(subjects));
for i=1:numel(subjects)
    subject=subjects(i);

    cd(sprintf('/data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ%02d',subject));
    load(sprintf('Distraction-%d-QuickRun.mat',subject));

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
        [acc, rt, auc, accTop,accBot,rtTop,rtBot,nOkTrials,yCorrect,yIncorrect,medianY] = deal(nan(numel(subjects),numel(qTypes)));
    else
        question_all = AppendStructs({question_all,question},1);
    end
    
    % Load fMRI results
    foo = dir('AfniProc*');
    cd(foo(1).name);
    filename = sprintf('shen268_withSegTc_SBJ%02d_ROI_TS.1D',subject);
    winLength = 10; % in TRs
    TR = 2; % in seconds
    nFirstRemoved = 3;
    HrfOffset = 6;
    
    % Load data
    fprintf('Loading data...\n')
    attnNets = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/attn_nets_268.mat');
    [err,M,Info,Com] = Read_1D(filename);
    nTR = (size(M,1)/numel(data))+nFirstRemoved;
    % Get template match for each trial
    [~,iFcEventSample,eventNames] = GetEventSamples(data, winLength, TR, nFirstRemoved, nTR, HrfOffset,'end');

    posMatch = GetFcTemplateMatch(M',attnNets.pos_overlap,winLength);
%     negMatch = GetFcTemplateMatch(M',attnNets.neg_overlap,winLength);
    posMatch_trials = nan(1,numel(iFcEventSample));
    isOk = ~isnan(iFcEventSample);
    posMatch_trials(isOk) = posMatch(iFcEventSample(isOk));

    qPages = cellfun(@min,question.pages_adj(isReading));
    question.y = nan(size(question.RT));
    posMatch_trials_norm = posMatch_trials/nanstd(posMatch_trials);
    question.y(isReading) = posMatch_trials_norm(qPages);
    isOkY = ~isnan(question.y);
    
    %% calculate and display behavioral results  
    fprintf('SUBJECT %d:\n',subject);
    for j=1:numel(qTypes)
        isThis = strcmp(question.type,qTypes{j});        
        acc(i,j) = mean(question.isCorrect(isThis));
        rt(i,j) = median(question.RT(isThis));  
        medianY(i,j) = median(question.y(isThis & isOkY));
        fprintf('%s: %d/%d=%.1f%% correct\n',qTypes{j},sum(question.isCorrect(isThis)),sum(isThis),acc(i,j)*100)
        % get AUC
        nOkTrials(i,j) = sum(isThis & isOkY);
        if nOkTrials(i,j)>=3
            auc(i,j) = rocarea(question.y(isThis & isOkY),question.isCorrect(isThis & isOkY));
%             y33 = prctile(question.y(isThis),100/3);
%             y67 = prctile(question.y(isThis),200/3);
            isTopY = question.y >= medianY(i,j);%y67;
            isBotY = question.y <= medianY(i,j);%y33;
            accTop(i,j) = mean(question.isCorrect(isThis & isOkY & isTopY));
            accBot(i,j) = mean(question.isCorrect(isThis & isOkY & isBotY));
            rtTop(i,j) = median(question.RT(isThis & isOkY & isTopY));
            rtBot(i,j) = median(question.RT(isThis & isOkY & isBotY));
            yCorrect(i,j) = nanmean(question.y(question.isCorrect & isThis & isOkY));
            yIncorrect(i,j) = nanmean(question.y(~question.isCorrect & isThis & isOkY));

        end
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

%%
% Do compilation plots
figure(26); clf;

iCols = 3:5;
topBot_all_block = [nanmedian(accBot(:,iCols));nanmedian(accTop(:,iCols))]';
topBot_all_SD_block = [nanstd(accBot(:,iCols));nanstd(accTop(:,iCols))]'/sqrt(numel(subjects));
topBotRt_all_block = [nanmedian(rtBot(:,iCols));nanmedian(rtTop(:,iCols))]';
topBotRt_all_SD_block = [nanstd(rtBot(:,iCols));nanstd(rtTop(:,iCols))]'/sqrt(numel(subjects));

subplot(121);
hold on;
hBar = bar(topBot_all_block*100);
xData = GetBarPositions(hBar);
for i=1:3
    errorbar(xData(:,i), topBot_all_block(i,:)*100, topBot_all_SD_block(i,:)*100,'k.');
end
PlotHorizontalLines(25,'k:');
% plot([.6 2.6],[25 25],'k:');
% Annotate plot
xlabel('Classifier output');
ylabel('Accuracy (%)')
set(gca,'YGrid','on')
% legend('Attend Speech','Ignore Speech','Location','SouthEast');
% set(gca,'xtick',1:2,'xticklabel',{'Bottom 1/3','Top 1/3'});
legend('Bottom 1/2','Top 1/2','Location','SouthEast');
set(gca,'xtick',1:3,'xticklabel',{'Attend Speech','Ignore Speech','White Noise'});
xlim([0.5 3.5]);
ylim([0 100])
title('Subject Median Comprehension Accuracy')


subplot(122); 
hold on;
hBar = bar(topBotRt_all_block);
xData = GetBarPositions(hBar);
for i=1:3
    errorbar(xData(:,i), topBotRt_all_block(i,:), topBotRt_all_SD_block(i,:),'k.');
end
% Annotate plot
xlabel('Classifier output');
ylabel('RT (s)')
set(gca,'YGrid','on')
% legend('Attend Speech','Ignore Speech','Location','SouthEast');
% set(gca,'xtick',1:2,'xticklabel',{'Bottom 1/3','Top 1/3'});
legend('Bottom 1/2','Top 1/2','Location','SouthEast');
set(gca,'xtick',1:3,'xticklabel',{'Attend Speech','Ignore Speech','White Noise'});
ylim([0 14]);
xlim([0.5 3.5]);
title('Subject Median Comprehension Question Reaction Time')

% Move figure
set(gcf,'Position',[63   591   845   285])


%%
% Do compilation plots
figure(27); clf;

yDiff = yCorrect(:,3:5)-yIncorrect(:,3:5);
isOkSubj = ~any(isnan(yDiff),2);
yDiff_all = nanmedian(yDiff);
yDiff_all_SD = nanstd(yDiff)/sqrt(numel(subjects));
hold on;
hBar = bar(yDiff_all);
xData = GetBarPositions(hBar);
errorbar(xData, yDiff_all, yDiff_all_SD,'k.');
% Annotate plot
xlabel('Condition');
ylabel(sprintf('High Attention Score Difference\n(correct - incorrect)'))
set(gca,'YGrid','on')
set(gca,'xtick',1:3,'xticklabel',{'Attend Speech','Ignore Speech','White Noise'});
% ylim([0 100])
title('Subject Median High Attention Score Difference')
