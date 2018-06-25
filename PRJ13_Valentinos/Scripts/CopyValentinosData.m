% CopyValentinosData.m
%
% Created 5/31/17 by DJ.

newDataDir = '/Users/jangrawdc/Documents/PRJ12_Valentinos/PrcsData';
tic
for iSubj=1:nSubj
    fprintf('===Getting data for subject %d/%d...\n',iSubj,nSubj);
    roiMask = cell(1,numel(rois));    
    % Get ROIs for this subject
    for iRoi=1:numel(rois)
        % Get ROI
        roiFilename = sprintf('%s/Face_Localizer/S%02d_%s_%s+tlrc*',datadir,subjects(iSubj),rois{iRoi},maskSuffix);
        targetFolder = sprintf('%s/Face_Localizer/',newDataDir);
        copyfile(roiFilename,targetFolder);
    end
end
%%
for iTarg=1:numel(targets)           
    mkdir([newDataDir '/Functional_Connectivity/'],targets{iTarg})
    mkdir([newDataDir '/Functional_Connectivity/',targets{iTarg}],subdir)
end
%%
tic;
for iSubj=1:nSubj
    fprintf('===Subject %d/%d...\n',iSubj,nSubj);
    % Get brick for each target/task/scan
    for iTarg=1:numel(targets)           
        for iTask=1:numel(tasks)
            for iScan=1:numel(scans);
                fprintf('Copying Target %d/%d, Task %d/%d, Scan %d/%d (t=%.1f s)...',iTarg,numel(targets),iTask,numel(tasks),iScan,numel(scans),toc);
                % Load file
                residFilename = sprintf('%s/Functional_Connectivity/%s/%s/S%02d_%s_%s_task_residuals.%s+tlrc*',datadir,targets{iTarg},subdir,subjects(iSubj),tasks{iTask},scans{iScan},subdir);                
                targetFolder = sprintf('%s/Functional_Connectivity/%s/%s/',newDataDir,targets{iTarg},subdir);
                copyfile(residFilename,targetFolder);
                fprintf(' Done.\n')                
            end
        end    
    end
end