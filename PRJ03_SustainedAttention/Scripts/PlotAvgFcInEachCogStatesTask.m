% PlotAvgFcInEachCogStatesTask.m
%
% Created 7/11/17 by DJ

%% Get FC matrices
% Set up
subjects = [6:13,16:27];
demeanTs = true;%true;
separateTasks = true;
nSubj = numel(subjects);
% Get FC
FCtmp = GetFcForCogStateData(subjects(1),separateTasks,demeanTs); % already Fisher-normalized in function
FC = nan([size(FCtmp),nSubj]);
winInfo_cell = cell(1,nSubj);
for i=1:nSubj
    [FC(:,:,:,i),winInfo_cell{i}] = GetFcForCogStateData(subjects(i),separateTasks,demeanTs); % already Fisher-normalized in function
end
taskNames = winInfo_cell{1}.winNames;

%% Get atlas & attention networks
[shenAtlas,shenInfo] = BrikLoad('/data/jangrawdc/PRJ03_SustainedAttention/Results/Shen_2013_atlas/shen_1mm_268_parcellation+tlrc');
[shenLabels,shenLabelNames,shenLabelColors] = GetAttnNetLabels(false);
% Get Rosenberg Hi/Low-Attn matrices
attnNets = load('/data/jangrawdc/PRJ03_SustainedAttention/Collaborations/MonicaRosenberg/attn_model_268.mat');

%% Plot each task's FC with visual regions

% Get mean FC for each task
tasks = {'REST','BACK','VIDE','MATH'};
nTasks = numel(tasks);
nRoi = size(FC,1);
FC_task = nan(nRoi,nRoi,nTasks);
for i=1:numel(tasks)
    isThisTask = strncmp(taskNames,tasks{i},length(tasks{i}));
    FC_task(:,:,i) = nanmean(nanmean(FC(:,:,isThisTask,:),4),3);
end
% remove nans
FC_task(isnan(FC_task)) = 0;

% Get occipital ROIs
isOccipitalRoi = strcmp(shenLabelNames(shenLabels),'Occipital');

% Show FC matrices
figure(61); clf;
clim = [-1 1]*0.3;
isRest = strcmp(tasks,'REST');
FC_rest = FC_task(:,:,isRest);
for i=1:nTasks
    FC_this = FC_task(:,:,i);
%     FC_this(abs(FC_this)<thresh) = 0; % threshold
    % Crop to occipital ROIs
    % plot 
    subplot(2,nTasks,i);
    PlotFcMatrix(FC_this,[-1 1],shenAtlas,shenLabels,true,shenLabelColors,false);
    title(tasks{i});
%     legend(shenLabelNames);
    % plot 
    subplot(2,nTasks,nTasks+i);
    PlotFcMatrix(FC_this - FC_rest,clim,shenAtlas,shenLabels,true,shenLabelColors,false);
    title([tasks{i} ' - REST']);
%     legend(shenLabelNames);
end


%% Plot in 2D
% Declare threshold
thresh = 0.3;
% Plot in 2D
figure(62); clf;
for i=1:nTasks
    FC_this = zeros(nRoi);
    FC_this(isOccipitalRoi,:) = FC_task(isOccipitalRoi,:,i);
    FC_this(:,isOccipitalRoi) = FC_task(:,isOccipitalRoi,i);   
    FC_this(isOccipitalRoi,isOccipitalRoi) = 0; % boring   
    FC_this(FC_this<0) = 0;
    %     FC_this = FC_task(:,:,i);
    FC_this(isnan(FC_this)) = 0; % threshold
    FC_this(abs(FC_this)<thresh) = 0; % threshold
    % Crop to occipital ROIs
    % plot 
    subplot(2,nTasks,i);
    VisualizeFcIn2d(FC_this,shenAtlas,shenLabels,shenLabelColors,shenLabelNames,shenInfo.Orientation,'top');
    title(tasks{i});
    drawnow;
%     legend('');
    subplot(2,nTasks,nTasks+i);
    VisualizeFcIn2d(FC_this,shenAtlas,shenLabels,shenLabelColors,shenLabelNames,shenInfo.Orientation,'left');
    title(tasks{i});
    drawnow;
%     legend('');

end
MakeFigureTitle(sprintf('threshold = %.3g',thresh));


%% Use Stats Threshold
% Declare threshold
thresh = 0.3;

% get stats
p_task = nan(nRoi,nRoi,nTasks);
isRest = strncmp(taskNames,'REST',length('REST'));
FC_rest = reshape(FC(:,:,isRest,:),[nRoi,nRoi,sum(isRest)*nSubj]);  
for i=1:nTasks
    fprintf('Task %d/%d...\n',i,nTasks)
    isThisTask = strncmp(taskNames,tasks{i},length(tasks{i}));
    FC_this = reshape(FC(:,:,isThisTask,:),[nRoi,nRoi,sum(isThisTask)*nSubj]);
    for j=1:nRoi
        for k=j+1:nRoi
            if any(~isnan(FC_this(j,k,:)))
                p_task(j,k,i) = signrank(squeeze(FC_this(j,k,:)),squeeze(FC_rest(j,k,:)));
                p_task(k,j,i) = p_task(j,k,i);
            end
        end
    end
end
fprintf('Plotting...\n');
%% Plot in 2D
p_thresh = 0.05;
figure(64); clf;
for i=1:nTasks
    FC_this = zeros(nRoi);
    FC_this(isOccipitalRoi,:) = FC_task(isOccipitalRoi,:,i) - FC_task(isOccipitalRoi,:,1);
    FC_this(:,isOccipitalRoi) = FC_task(:,isOccipitalRoi,i) - FC_task(:,isOccipitalRoi,1);   
    FC_this(isOccipitalRoi,isOccipitalRoi) = 0; % within-occipital FC is boring  
%     FC_this(FC_this<0) = 0; % positive only
    FC_this(p_task(:,:,i)>p_thresh) = 0; % significant only
    %     FC_this = FC_task(:,:,i);
    FC_this(isnan(FC_this)) = 0; % threshold
    FC_this(abs(FC_this)<thresh) = 0; % threshold
    % Crop to occipital ROIs
    % plot 
    subplot(2,nTasks,i);
    VisualizeFcIn2d(FC_this,shenAtlas,shenLabels,shenLabelColors,shenLabelNames,shenInfo.Orientation,'top');
    title([tasks{i} ' - REST']);
    drawnow;
%     legend('');
    subplot(2,nTasks,nTasks+i);
    VisualizeFcIn2d(FC_this,shenAtlas,shenLabels,shenLabelColors,shenLabelNames,shenInfo.Orientation,'left');
    title([tasks{i} ' - REST']);
    drawnow;
%     legend('');

end
MakeFigureTitle(sprintf('p-val Vs. REST: threshold = %.3g',p_thresh));

fprintf('Done!\n');