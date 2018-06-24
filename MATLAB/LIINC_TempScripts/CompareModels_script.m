% CompareModels_script
%
% Compare the 10-fold MSE (and # params and # events) across models, 
% as calculated with RunRidgeTrace_script.
%
% Created 1/28/15 by DJ.


% Set parameters
lambdas = 0:0.04:1;
nFolds = 10;
experiments = {'sf'};%{'sq','sf','sf3'};

% models = {'Square-v3pt6','TargDis-v3pt6','SqNum-v3pt6','Type-v3pt6','Type-v3pt6-RampUp','Type-v3pt6-Peak'};
% models = {'Square-v3pt6-randfold', 'TargDis-v3pt6-randfold', 'SqNum-v3pt6-randfold', 'Type-v3pt6-randfold'};
models = {'TargDis-v3pt6-randfold', 'Type-v3pt6-randfold'};
matrixFiles = {'TargDis-v3pt6-Matrices', 'Type-v3pt6-Matrices'};
% models = {'TargDis-v3pt6-randfold_500ms', 'Type-v3pt6-randfold_500ms'};
% matrixFiles = {'TargDis-v3pt6-Matrices_500ms', 'Type-v3pt6-Matrices_500ms'};
modelShortNames={'TargDis','Type'};

%% Get results
lambda_best = zeros(1,numel(experiments),numel(models));
sigmasq_best = zeros(1,numel(experiments),numel(models));
sigmasq_mean = zeros(numel(experiments),numel(lambdas),numel(models));
sigmasq_std = zeros(numel(experiments),numel(lambdas),numel(models));
sigmasq_foldmean = cell(1,numel(experiments));
sigmasq_foldstd = cell(1,numel(experiments));

for i=1:numel(experiments)
    experiment = experiments{i};
    [subjects,basedir,folders] = GetSquaresSubjects(experiment);  %subjects_cell{i};
    N = numel(subjects);
    sigmasq_foldmean{i} = zeros(N,numel(lambdas),numel(models));
    sigmasq_foldstd{i} = zeros(N,numel(lambdas),numel(models));
    for iModel = 1:numel(models)
        model = models{iModel};
        fprintf('--- %s, %s ---\n',experiment,model);
        for iSubj=1:N
            cd([basedir '/' folders{iSubj}]);
            fprintf('%d/%d...\n',iSubj,N);
            file_out = sprintf('%s-%d-%s-%dfold',experiment,subjects(iSubj),model,nFolds);
            R = load(file_out);
            sigmasq_foldmean{i}(iSubj,:,iModel) = mean(mean(R.sigmasq_all,3),4);
            sigmasq_foldstd{i}(iSubj,:,iModel) = std(mean(R.sigmasq_all,3),[],4);
        end
        sigmasq_mean(i,:,iModel) = mean(sigmasq_foldmean{i}(:,:,iModel),1);
        sigmasq_std(i,:,iModel) = mean(sigmasq_foldstd{i}(:,:,iModel),1);
%         sigmasq_std(i,:,iModel) = std(sigmasq_foldmean{i}(:,:,iModel),[],1);
        [~,iMin] = min(sigmasq_mean(i,:,iModel));
        lambda_best(i,iModel) = lambdas(iMin);
        sigmasq_best(i,iModel) = sigmasq_mean(i,iMin,iModel);
        fprintf('%s, %s: lambda=%.2f, sigmasq=%.2g\n',experiment,model,lambda_best(i,iModel),sigmasq_best(i,iModel));    
    end
end 


%% Plot results
% colors = 'rgb';
colors = get(groot,'defaultAxesColorOrder');
figure;
for i=1:numel(experiments) 
    subjects = GetSquaresSubjects(experiment);  %subjects_cell{i};
    N = numel(subjects);
    % set up plot
    subplot(1,numel(experiments),i);
    cla; hold on;
    for iModel = 1:numel(models)
        % plot
        plot(lambdas,sigmasq_mean(i,:,iModel),'color',colors(iModel,:));        
    end
    for iModel = 1:numel(models)
        ErrorPatch(lambdas,sigmasq_mean(i,:,iModel),sigmasq_std(i,:,iModel),colors(iModel,:),colors(iModel,:));
    end
    for iModel = 1:numel(models)
        plot(lambda_best(i,iModel),sigmasq_best(i,iModel),'*','color',colors(iModel,:));    
    end
    % annotate
    ylim([min(min(sigmasq_mean(i,:,:))),max(max(sigmasq_mean(i,2:end,:)))])
    title(experiments{i})
    xlabel('bias param')
    ylabel(sprintf('%d-fold MSE',nFolds))
    legend(models,'interpreter','none')
end
MakeFigureTitle('cross-validated error across models');

%% Examine # parameters and # events for each model.

% experiments = {'sq','sf','sf3'};
% models = {'Square-v3pt6','TargDis-v3pt6','SqNum-v3pt6','Type-v3pt6','Type-v3pt6-RampUp','Type-v3pt6-Peak'};
% modelShortNames = {'Square','TargDis','SqNum','Type','RampUp','Peak'};
nParams = zeros(numel(experiments),numel(models));
nEvents = cell(numel(experiments),numel(models));
for iMod = 1:numel(models)
    fprintf('=== Model %d/%d ===\n',iMod,numel(models));
    for iExp = 1:numel(experiments)
        [subjects,basedir,folders] = GetSquaresSubjects(experiments{iExp});

        for i=1:numel(subjects)
            fprintf('---%s subject %d/%d\n',experiments{iExp},i,numel(subjects));
            cd(basedir)
            cd(folders{i})
            R=load(sprintf('%s-%d-%s.mat',experiments{iExp},subjects(i),matrixFiles{iMod}));
            nEvents{iExp,iMod}(i,:) = sum(R.X~=0,1);
        end
        nParams(iExp,iMod) = size(R.X,2);
    end
end

%% Make a boxplot of the error across folds for the various models.

figure(234); clf;
for iExp = 1:numel(experiments)
    subplot(1,numel(experiments),iExp); 
    hold on
    for iMod = 1:numel(models)        
%         plot(nEvents{iExp,iMod}')
        boxplot(full(nEvents{iExp,iMod}(:)),'positions',iMod,'whisker',inf)        
    end
    plot(nParams(iExp,:),'g.-')
    ylim([0 2500])
    xlim([0 numel(models)+1])
    grid on
    xlabel('model');
    set(gca,'xtick',1:numel(models),'xticklabel',modelShortNames)
    ylabel('# of occurrences');
    title(experiments{iExp})
    legend('# of parameters','Location','NorthWest')
end
MakeFigureTitle('Range of nEvents for v3pt6 Analyses')
% linkaxes(GetSubplots(gcf));
