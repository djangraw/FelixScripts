% DistractionNestedCv_wrapper.m
%
% Created 3/17-18 by DJ.

%% Run nested CV to find best params
subjects=[21,22,24:30];

label1 = 'ignoredSpeech';
label0 = 'attendedSpeech';
DistractionNestedCv_script;

label1 = 'whiteNoise';
label0 = 'other';
DistractionNestedCv_script;

%% Load and plot results

% subjects=9:16;
homedir = '/data/jangrawdc/PRJ03_SustainedAttention/Results';
cd(homedir);
label1 = {'whiteNoise','ignoredSpeech'};
label0 = {'other','attendedSpeech'};
type = {'Mag','FC'};
subjects_cell = {9:16, 17:20, [21 22 24:30]};
[Az_best_alltypes,bestTcFrac_alltypes,bestFcFrac_alltypes] = deal(cell(numel(label1),numel(type)));
for k=1:numel(subjects_cell)
    subjects = subjects_cell{k};
    for i=1:numel(label1)
        for j=1:numel(type)
            filename = sprintf('SBJ%02d-%02d_%s-%s_%s_nestedLooCv',...
                subjects(1),subjects(end),label1{i},label0{i},type{j});
            fprintf('Loading %s...\n',filename);
            foo = load(filename);
            Az_best_alltypes{i,j} = cat(2,Az_best_alltypes{i,j}, foo.Az_best);
            bestTcFrac_alltypes{i,j} = cat(2,bestTcFrac_alltypes{i,j}, foo.bestTcFrac);
            if isfield(foo,'bestFcFrac')
                bestFcFrac_alltypes{i,j} = cat(2, bestFcFrac_alltypes{i,j}, foo.bestFcFrac);
            end
        end
    end
end
fprintf('Done!\n')

%% Plot AUC results
subjects = [9:22, 24:30];%9:16;
labelstr=cell(1,numel(subjects)+1);
for i=1:numel(subjects)
    labelstr{i} = sprintf('SBJ%02d',subjects(i));
end
labelstr{end} = 'Mean';

figure(523); clf;
foo1 = cat(1,Az_best_alltypes{1,:});
subplot(2,1,1); cla; hold on;
bar([foo1'; mean(foo1',1)]);
errorbar(numel(subjects)+1+[-.15 .15],mean(foo1',1),std(foo1',1),'k.');
PlotHorizontalLines(0.5,'k:');
legend(type)
xlabel('subject')
ylabel('AUC')
ylim([0 1]);
grid on
title(sprintf('%s-%s classifier: LOO, Nested CV',label1{1},label0{1}));
set(gca,'xtick',1:numel(subjects)+1,'xticklabel',labelstr);

foo2 = cat(1,Az_best_alltypes{2,:});
subplot(2,1,2); cla; hold on;
bar([foo2'; mean(foo2',1)]);
errorbar(numel(subjects)+1+[-.15 .15],mean(foo2',1),std(foo2',1),'k.');
PlotHorizontalLines(0.5,'k:');
legend(type)
xlabel('subject')
ylabel('AUC')
ylim([0 1]);
grid on
title(sprintf('%s-%s classifier: LOO, Nested CV',label1{2},label0{2}));
set(gca,'xtick',1:numel(subjects)+1,'xticklabel',labelstr);

%% Print best frac of var to keep

for i=1:numel(label1)
    for j=1:numel(type)
        for k=1:numel(subjects)
            if strcmp(type{j},'Mag')
                fprintf('%s vs. %s, %s feats, subj %d: fracTcVar = [%s]\n',label1{i},label0{i},type{j},subjects(k),num2str(unique(bestTcFrac_alltypes{i,j}{k})'));
            else
                fprintf('%s vs. %s, %s feats, subj %d: fracFcVar = [%s]\n',label1{i},label0{i},type{j},subjects(k),num2str(unique(bestFcFrac_alltypes{i,j}{k})'));
            end
        end
    end
end
% Plot
figure(293); clf;
xHistFc = .2:.05:.7;
xHistTc = .6:.05:1;
for i=1:numel(label1)
    for j=1:numel(type)
        for k=1:numel(subjects)
            nHistTc(:,i,j,k) = hist(bestTcFrac_alltypes{i,j}{k},xHistTc)/numel(bestTcFrac_alltypes{i,j}{k});
            if ~isempty(bestFcFrac_alltypes{i,j})
                nHistFc(:,i,j,k) = hist(bestFcFrac_alltypes{i,j}{k},xHistFc)/numel(bestFcFrac_alltypes{i,j}{k});
            end
        end
    end
end
%%
legendstr = cell(1,numel(label1));
for i=1:numel(label1)
    legendstr{i} = sprintf('%s-%s',label1{i},label0{i});
end
for i=1:numel(type)
    subplot(numel(type),1,i);
    if i==1
        bar(xHistTc'*100,squeeze(mean(nHistTc(:,:,i,:),4))*100);
    else
        bar(xHistFc'*100,squeeze(mean(nHistFc(:,:,i,:),4))*100);
    end
    legend(legendstr);
    xlabel(sprintf('%% of %s Variance Kept',type{i}))
    ylabel('% of trials')
    title(sprintf('Nested CV, %s Features',type{i}))
end


%% Get weights from best classifier

[Az_best_alltypes,bestTcFrac_alltypes,bestFcFrac_alltypes] = deal(cell(numel(label1),numel(type)));
for i=1:numel(label1)
    for j=1:numel(type)
        foo = load(sprintf('SBJ%02d-%02d_%s-%s_%s_nestedLooCv',...
            subjects(1),subjects(end),label1{i},label0{i},type{j}));
        Az_best_alltypes{i,j} = foo.Az_best;
        bestTcFrac_alltypes{i,j} = foo.bestTcFrac;
        if isfield(foo,'bestFcFrac')
            bestFcFrac_alltypes{i,j} = foo.bestFcFrac;
        end
        % Get weights and features from best classifiers
        for k=1:numel(subjects)
            for l=1:size(foo.AzLoo_all{k},3)
                [maxes,iMax] = max(foo.AzLoo_all{k}(:,:,l),[],1);
                [~,jMax] = max(maxes,[],2);
                wts_best{i,j,k}(j) = foo.LRstats_all{k}{iMax(jMax),jMax,l}.wts;
            end
        end
    end
end
