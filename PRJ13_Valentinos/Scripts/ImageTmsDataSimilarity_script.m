% ImageTmsDataSimilarity_script.m
% Created 6/5/17 by DJ.

%% Set up

datadir = '/Users/jangrawdc/data44/zachariouv/Faces_Theta_Burst_TMS/AFNI_Data_Analysis/GroupLevel';
subdir = 'MVPA';

% subjects = [1, 2, 3, 404, 5, 6, 7, 8, 9, 11, 12, 113, 140, 150, 160, 17, 19];
subjects = [1, 2, 3, 404, 5, 6, 7, 8, 9, 12, 113, 140, 150, 160, 17, 19];

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

% residFilename = sprintf('%s/Functional_Connectivity/%s/S%02d_%s_%s_task_residuals+tlrc',datadir,targets{1},subjects(1),tasks{1},scans{1});
% [~,Info] = BrikInfo(residFilename);
% nTrials = numel(Info.BRICK_TYPES);
nTrials=360;
% Get timing
% Every 15 Bricks within those files is a Block of trials for the specified category 
% and every 90 bricks is a run (so four runs per condition, 6 blocks per run)
iBlock = ceil((1:nTrials)/15);
iRun = ceil((1:nTrials)/90);


%% Load it all in

% We talked about producing a sort of similarity matrix with these 4 categories of trials (FC/FF x pre-/post-TMS).
iFC = find(strcmp('FC',tasks));
iFF = find(strcmp('FF',tasks));
iPre = find(strcmp('Pre',scans));
iPost = find(strcmp('Post',scans));
ticklabels = {'FC/Pre','FC/Post','FF/Pre','FF/Post'};
% Set up
corrmat = nan(4,4,numel(targets),numel(rois),nSubj);
corrmat_block = nan(4,4,numel(targets),numel(rois),nSubj);
nBlocks = max(iBlock);
for iSubj = 1:nSubj
    % Load
    filename = sprintf('RoiData_%s_S%02d',maskSuffix,subjects(iSubj));
    load(filename);
    for iRoi = 1:numel(rois)
        % Get 
        for iTarg = 1:numel(targets)
            dataInFfa{1} = dataInRoi{1,iRoi}(:,:,iTarg,iFC,iPre);
            dataInFfa{2} = dataInRoi{1,iRoi}(:,:,iTarg,iFC,iPost);
            dataInFfa{3} = dataInRoi{1,iRoi}(:,:,iTarg,iFF,iPre);
            dataInFfa{4} = dataInRoi{1,iRoi}(:,:,iTarg,iFF,iPost);
            % get mean in each block
            dataInFfa_block = repmat({nan(size(dataInFfa{1},1),nBlocks)},1,4);
            for k = 1:nBlocks
                for l=1:4
                    dataInFfa_block{l}(:,k) = mean(dataInFfa{l}(:,iBlock==k),2);
                end
            end
            % Correlate
            for i=1:4
                for j=1:4
                    if numel(dataInFfa{1}>0) % make sure data exists
                        corr_this = corr(dataInFfa{i},dataInFfa{j});
                        corr_this_block = corr(dataInFfa_block{i},dataInFfa_block{j});
                        if i==j
                            corrmat(i,j,iTarg,iRoi,iSubj) = mean(VectorizeFc(corr_this));
                            corrmat_block(i,j,iTarg,iRoi,iSubj) = mean(VectorizeFc(corr_this_block));
                        else
                            corrmat(i,j,iTarg,iRoi,iSubj) = mean(mean(corr_this));
                            corrmat_block(i,j,iTarg,iRoi,iSubj) = mean(mean(corr_this_block));
                        end
                    end
                end
            end
        end
    end
end

%% Analyze
% What we decided on is to find the correlation in a subject?s FFA ROI (determined with a localizer scan) between all pairs of trials. 
% Is a FC pre-TMS trial more like another FC pre-TMS trial than it is like a post-TMS trial? And is the same true for FF trials?
% We?d hypothesize that this is true for FC but not FF trials, in a similar way to how the magnitude was affected.
% This is better than an ML approach because now we can tell which trial type?s pattern is degrading.
% We talked about producing a sort of similarity matrix with these 4 categories of trials (FC/FF x pre-/post-TMS).

% Plot Correaltion Matrices
corrmat_plot = corrmat_block;
clim = 0.35;

figure(600); clf;
clear h;
pVs0 = nan(4,4,numel(targets),numel(rois));
pVsVertex = nan(4,4,numel(targets),numel(rois));
for iRoi = 1:numel(rois)
    for iTarg = 1:numel(targets)
        h(iTarg,iRoi) = subplot(numel(targets),numel(rois), (iTarg-1)*numel(rois)+iRoi);
        hold on;
        meancorr = nanmean(corrmat_plot(:,:,iTarg,iRoi,:),5);
        imagesc(meancorr);
        %Add stars
        for i=1:4
            for j=1:4
                pVs0(i,j,iTarg,iRoi) = signrank(squeeze(corrmat_plot(i,j,iTarg,iRoi,:)));
                pVsVertex(i,j,iTarg,iRoi) = signrank(squeeze(corrmat_plot(i,j,iTarg,iRoi,:)),squeeze(corrmat_plot(i,j,end,iRoi,:)));
            end
        end
        % make stars
        [iStars,jStars] = find(pVs0(:,:,iTarg,iRoi)<0.05);
        plot(iStars,jStars,'k*');      
        [iStars,jStars] = find(pVsVertex(:,:,iTarg,iRoi)<0.05);
        plot(iStars,jStars,'ro');      

        % Annotate axes
        axis([.5 4.5 .5 4.5]);
        set(gca,'xtick',1:4,'xticklabel',ticklabels,'ytick',1:4,'yticklabels',ticklabels,'ydir','reverse');
        set(gca,'clim',[0 1]*clim);
        axis square;
        xticklabel_rotate;
        colorbar
        title(sprintf('%s %s ROI\nTMS target: %s',rois{iRoi},maskName,targets{iTarg}),'interpreter','none');
        drawnow;
    end
end

%% Fix clim
clim = 0.05;
set(GetSubplots(600),'clim',[0 1]*clim);

%%
set(GetSubplots(600),'CLimMode','auto');
