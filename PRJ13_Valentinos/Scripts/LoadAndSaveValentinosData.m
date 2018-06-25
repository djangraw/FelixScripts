% Created 6/5/17 by DJ.

datadir = '/Users/jangrawdc/data44/zachariouv/Faces_Theta_Burst_TMS/AFNI_Data_Analysis/GroupLevel';
subdir = 'MVPA';

% subjects = 1:12;
% subjects = [1:3 5 7:9 11:12 404];
% subjects = [1, 2, 3, 404, 5, 6, 7, 8, 9, 11, 12, 113, 140, 150, 160, 17, 19];
subjects = [1, 2, 3, 404, 5, 6, 7, 8, 9, 12, 113, 140, 150, 160, 17, 19];

nSubj = numel(subjects);
targets = {'RH_PPC','LH_PPC','Vertex'}; % TMS target (LH_PPC is only effective one)
% rois = {'RH_OFA','RH_FFA','RH_AIT'}; % ROI for activity patterns (add left equivs, PPC, PPA?)
% rois = {'RH_OFA','RH_FFA','RH_AIT','RH_PPA','LH_OFA','LH_FFA','LH_AIT','LH_PPA'}; % ROI for activity patterns (add left equivs, PPC, PPA?)
rois = {'RH_PPC','LH_PPC'};
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
% dataInRoi = cell(nSubj,numel(rois));
% nVoxelsInRoi = nan(nSubj,numel(rois));
tic;
for iSubj=1:5%1:nSubj
    fprintf('===Getting data for subject %d/%d...\n',iSubj,nSubj);
    roiMask = cell(1,numel(rois));    
    
    dataInRoi = cell(1,numel(rois));
    nVoxelsInRoi = nan(1,numel(rois));
    
    % Get ROIs for this subject
    for iRoi=1:numel(rois)
        % Get ROI
        if ismember(rois{iRoi}, {'RH_PPC','LH_PPC'})
            roiFilename = sprintf('%s/Location_Localizer/S%02d_%s_%s+tlrc',datadir,subjects(iSubj),rois{iRoi},maskSuffix);
        else
            roiFilename = sprintf('%s/Face_Localizer/S%02d_%s_%s+tlrc',datadir,subjects(iSubj),rois{iRoi},maskSuffix);
        end
        [err,roiMask{iRoi},roiInfo,errMsg] = BrikLoad(roiFilename);
        nVoxelsInRoi(1,iRoi) = sum(roiMask{iRoi}(:)>0);
        dataInRoi{1,iRoi} = nan(nVoxelsInRoi(1,iRoi),nTrials,numel(targets),numel(tasks),numel(scans));
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
                    for iVoxel = 1:nVoxelsInRoi(1,iRoi)
                        dataInRoi{1,iRoi}(iVoxel,:,iTarg,iTask,iScan) = squeeze(V(roiMask_i(iVoxel),roiMask_j(iVoxel),roiMask_k(iVoxel),:));
                    end
                end                    
            end
        end    
    end
    % Save data for this subject\
    filename = sprintf('RoiData_%s_S%02d',maskSuffix,subjects(iSubj));
    fprintf('Saving as %s...\n',filename);
    save(filename,'dataInRoi','nVoxelsInRoi','nTrials','targets','rois','tasks','scans','maskSuffix');
    
end
fprintf('===Done! Took %.1f seconds.\n',toc)

                 
%% Load and extract masks across subjects
% dataInRoi = cell(nSubj,numel(rois));
% nVoxelsInRoi = nan(nSubj,numel(rois));
tic;
roiFilename = sprintf('%s/Face_Localizer/S%02d_%s_%s+tlrc',datadir,subjects(iSubj),rois{iRoi},maskSuffix);
[err,tempBrik,roiInfo,errMsg] = BrikLoad(roiFilename);
roiMask = nan([size(tempBrik),numel(rois),nSubj]);    

for iSubj=1:nSubj
    fprintf('===Getting data for subject %d/%d...\n',iSubj,nSubj);
        
    % Get ROIs for this subject
    for iRoi=1:numel(rois)
        % Get ROI
        roiFilename = sprintf('%s/Face_Localizer/S%02d_%s_%s+tlrc',datadir,subjects(iSubj),rois{iRoi},maskSuffix);
        [err,roiMask(:,:,:,iRoi,iSubj),roiInfo,errMsg] = BrikLoad(roiFilename);
    end
    
end

%% Write results to file
sumRoiMask = sum(roiMask,5);
outInfo = roiInfo;
brickLabs = sprintf('#%d_%s',0,rois{1});
for iRoi=2:numel(rois)
    brickLabs = sprintf('%s~#%d_%s',brickLabs,iRoi-1,rois{iRoi});
end
outInfo.BRICK_LABS = brickLabs;
outInfo.BRICK_TYPES = repmat(3,1,numel(rois));
outInfo.BRICK_STATS = repmat([0 nSubj],1,numel(rois));
outInfo.BRICK_FLOAT_FACS = zeros(1,numel(rois));
Opt = struct('Prefix',sprintf('SumRoiMasks_%dSubjects',nSubj),'OverWrite','y');
WriteBrik(sumRoiMask,outInfo,Opt);