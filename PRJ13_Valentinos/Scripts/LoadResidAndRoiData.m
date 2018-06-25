% LoadResidAndRoiData.m
%
% Created 2/14/17 by DJ.

% The ROIs are in
% 
% /misc/data44/zachariouv/Faces_Theta_Burst_TMS/AFNI_Data_Analysis/GroupLevel/Face_Localizer
% They are named:
% 
% S#_RH_OFA_49_Sphere_Mask_CM_SPM+tlrc
% S#_RH_OFA_49_Sphere_Mask_Peak_SPM+tlrc
% S#_RH_OFA_Mask+tlrc
% S#_RH_FFA_49_Sphere_Mask_CM_SPM+tlrc
% S#_RH_FFA_49_Sphere_Mask_Peak_SPM+tlrc
% S#_RH_FFA_Mask+tlrc
% S#_RH_AIT_49_Sphere_Mask_CM_SPM+tlrc
% S#_RH_AIT_49_Sphere_Mask_Peak_SPM+tlrc
% S#_RH_AIT_Mask+tlrc


datadir = '/Users/jangrawdc/data44/zachariouv/Faces_Theta_Burst_TMS/AFNI_Data_Analysis/GroupLevel';
subdir = 'MVPA';

% subjects = 1:12;
% subjects = [1:3 5 7:9 11:12 404];
subjects = [1, 2, 3, 404, 5, 6, 7, 8, 9, 11, 12, 113, 140, 150, 160, 17, 19];
% subjects = 2;
% subjects = 1:17; % get 17 good subjects from VZ
nSubj = numel(subjects);
targets = {'RH_PPC','LH_PPC','Vertex'}; % TMS target (LH_PPC is only effective one)
% rois = {'RH_OFA','RH_FFA','RH_AIT'}; % ROI for activity patterns (add left equivs, PPC, PPA?)
rois = {'RH_OFA','RH_FFA','RH_AIT','RH_PPA','LH_OFA','LH_FFA','LH_AIT','LH_PPA'}; % ROI for activity patterns (add left equivs, PPC, PPA?)
% maskSuffix = 'Mask';
maskSuffix = '49_Sphere_Mask_CM_SPM';
% maskSuffix = '49_Sphere_Mask_Peak_SPM';
tasks = {'FC','FF'}; % task type (face configuration/feature)
scans = {'Pre','Post'}; % before or after TMS

residFilename = sprintf('%s/Functional_Connectivity/%s/S%02d_%s_%s_task_residuals+tlrc',datadir,targets{1},subjects(1),tasks{1},scans{1});
[~,Info] = BrikInfo(residFilename);
nTrials = numel(Info.BRICK_TYPES);
% Get timing
% Every 15 Bricks within those files is a Block of trials for the specified category 
% and every 90 bricks is a run (so four runs per condition, 6 blocks per run)
iBlock = ceil((1:nTrials)/15);
iRun = ceil((1:nTrials)/90);

%% Load and extract data in each ROI
dataInRoi = cell(nSubj,numel(rois));
nVoxelsInRoi = nan(nSubj,numel(rois));
tic;
for iSubj=1:nSubj
    fprintf('===Getting data for subject %d/%d...\n',iSubj,nSubj);
    roiMask = cell(1,numel(rois));    
    % Get ROIs for this subject
    for iRoi=1:numel(rois)
        % Get ROI
        roiFilename = sprintf('%s/Face_Localizer/S%02d_%s_%s+tlrc',datadir,subjects(iSubj),rois{iRoi},maskSuffix);
        [err,roiMask{iRoi},roiInfo,errMsg] = BrikLoad(roiFilename);
        nVoxelsInRoi(iSubj,iRoi) = sum(roiMask{iRoi}(:)>0);
        dataInRoi{iSubj,iRoi} = nan(nVoxelsInRoi(iSubj,iRoi),nTrials,numel(targets),numel(tasks),numel(scans));
    end
    % Get brick for each target/task/scan
    for iTarg=1:numel(targets)           
        for iTask=1:numel(tasks)
            for iScan=1:numel(scans);
                fprintf('Loading Target %d/%d, Task %d/%d, Scan %d/%d (t=%.1f s)...',iTarg,numel(targets),iTask,numel(tasks),iScan,numel(scans),toc);
                % Load file
                residFilename = sprintf('%s/Functional_Connectivity/%s/%s/S%02d_%s_%s_task_residuals.%s+tlrc',datadir,targets{iTarg},subdir,subjects(iSubj),tasks{iTask},scans{iScan},subdir);                
                [err,V,Info,errMsg] = BrikLoad(residFilename);
                fprintf(' Done.\n')

                
                % Extract data from each ROI                
                for iRoi=1:numel(rois)
                    [roiMask_i,roiMask_j,roiMask_k] = ind2sub(size(roiMask{iRoi}),find(roiMask{iRoi}));
                    for iVoxel = 1:nVoxelsInRoi(iSubj,iRoi)
                        dataInRoi{iSubj,iRoi}(iVoxel,:,iTarg,iTask,iScan) = squeeze(V(roiMask_i(iVoxel),roiMask_j(iVoxel),roiMask_k(iVoxel),:));
                    end
                end                    
            end
        end    
    end
end
fprintf('===Done! Took %.1g seconds.\n',toc)

                  
%% Save
if numel(subjects)==1
    filename = sprintf('RoiData_%s_S%02d',maskSuffix,subjects(1));
else
    filename = sprintf('RoiData_%s_S%02d-S%02d_%s',maskSuffix,subjects(1),subjects(end),maskSuffix);
end
save(filename,'dataInRoi','nVoxelsInRoi','nTrials','targets','rois','tasks','scans','maskSuffix');

%% Analyze
% What we decided on is to find the correlation in a subject?s FFA ROI (determined with a localizer scan) between all pairs of trials. 
% Is a FC pre-TMS trial more like another FC pre-TMS trial than it is like a post-TMS trial? And is the same true for FF trials?
% We?d hypothesize that this is true for FC but not FF trials, in a similar way to how the magnitude was affected.
% This is better than an ML approach because now we can tell which trial type?s pattern is degrading.
% We talked about producing a sort of similarity matrix with these 4 categories of trials (FC/FF x pre-/post-TMS).

iSubj = 1;
iRoi = find(strcmp('RH_OFA',rois));
maskName = 'Mask';%'CM Sphere';

dataInRoi_2d = reshape(dataInRoi{iSubj,iRoi},size(dataInRoi{iSubj,iRoi},1),nTrials*numel(targets)*numel(tasks)*numel(scans));
corrmat = corr(dataInRoi_2d);

% Plot confusion matrix
figure(562); clf;
subplot(211);
imagesc(corrmat); hold on;
% Make grid
nPerTarget = nTrials;
nPerTask = nPerTarget*numel(targets);
nPerScan = nPerTask*numel(tasks);
for iScan=1:numel(scans)
    for iTask=1:numel(tasks)
        for iTarg=1:numel(targets)
            iRect = ((iScan-1)*numel(tasks)+iTask-1)*numel(targets)+iTarg-1;
            rectangle('Position',([iRect iRect 1 1])*nPerTarget,'EdgeColor','m','LineStyle','-');
        end
        iRect = (iScan-1)*numel(tasks)+iTask-1;
        rectangle('Position',([iRect iRect 1 1])*nPerTask,'EdgeColor','g','LineStyle','-');
    end
    iRect = iScan-1;
    rectangle('Position',([iRect iRect 1 1])*nPerScan,'EdgeColor','r','LineStyle','-');
end
axis square
title(sprintf('S%02d, all trials',subjects(iSubj)));
xlabel('trial/condition')
ylabel('trial/condition')
colorbar

% Plot Lower Matrices
% clim = 0.02;
clim = 0.1; % 0.06; 
% clim = 0.003;

% We talked about producing a sort of similarity matrix with these 4 categories of trials (FC/FF x pre-/post-TMS).
iFC = find(strcmp('FC',tasks));
iFF = find(strcmp('FF',tasks));
iPre = find(strcmp('Pre',scans));
iPost = find(strcmp('Post',scans));
ticklabels = {'FC/Pre','FC/Post','FF/Pre','FF/Post'};
dataInFfa = cell(1,4);
for iTarg = 1:numel(targets)
    dataInFfa{1} = dataInRoi{iSubj,iRoi}(:,:,iTarg,iFC,iPre);
    dataInFfa{2} = dataInRoi{iSubj,iRoi}(:,:,iTarg,iFC,iPost);
    dataInFfa{3} = dataInRoi{iSubj,iRoi}(:,:,iTarg,iFF,iPre);
    dataInFfa{4} = dataInRoi{iSubj,iRoi}(:,:,iTarg,iFF,iPost);
    corrmat = nan(4);
    for i=1:4
        for j=1:4
            corr_this = corr(dataInFfa{i},dataInFfa{j});
            if i==j
                corrmat(i,j) = mean(VectorizeFc(corr_this));
            else
                corrmat(i,j) = mean(mean(corr_this));
            end
        end
    end
    subplot(2,numel(targets),numel(targets)+iTarg);
    imagesc(corrmat);
    set(gca,'xtick',1:4,'xticklabel',ticklabels,'ytick',1:4,'yticklabels',ticklabels);
    set(gca,'clim',[0 1]*clim);
    colorbar
    title(sprintf('%s %s ROI\nTMS target: %s',rois{iRoi},maskName,targets{iTarg}),'interpreter','none');
end