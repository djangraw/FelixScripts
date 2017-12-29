% PlotSrttRoiTimecourses_script.m
%
% Created 12/28/17 by DJ.

% Load ROIs
cd /data/jangrawdc/PRJ16_TaskFcManipulation/RawData/GROUP_TEST
rois = BrikLoad('ttest_uns-str_q01_ClustMask+tlrc.HEAD');
rois_8 = rois;
rois_8(rois>8) = 0;

% Load mean timecourse
cd /data/jangrawdc/PRJ16_TaskFcManipulation/RawData/GROUP_MEAN
nSubj = numel(dir('all_runs*.HEAD'));
brick = BrikLoad('MEAN_all_runs_nonuisance+tlrc');
brick(isnan(brick))=0; % set nans to 0s

% Get mask
mask = any(brick>0,4);

% Get task timecourse
Xmat = Read_1D('/gpfs/gsfs8/users/jangrawdc/PRJ16_TaskFcManipulation/RawData/tb0027/tb0027.srtt_v2/X.stim.xmat.1D');
taskTc = sum(Xmat(:,1:3),2) + 2*sum(Xmat(:,4:6),2);

% Plot
figure(161);
set(gcf,'Position',[41 30 1150 1350]);
PlotRoisAndTimecourses(rois_8,brick,mask,taskTc);
MakeFigureTitle(sprintf('Mean Timecourse across %d SRTT subjects',nSubj));

%% Use Vis/Motor Masks instead
% Load and add masks
rois_afni = zeros(size(rois));
roiNames = {'vis','lMot','rMot'};
for i=1:numel(roiNames)
    newRoi = BrikLoad('');
    rois_afni(newRoi>0) = i;
end
% Plot
figure(162);
set(gcf,'Position',[1200 30 1150 1350]);
PlotRoisAndTimecourses(rois_afni,brick,mask,taskTc);
MakeFigureTitle(sprintf('Mean Timecourse across %d SRTT subjects',nSubj));