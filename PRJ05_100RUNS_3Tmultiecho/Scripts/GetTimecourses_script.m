% GetTimecourses_script
%
% Wrapper for GetTimecourseInRoi.m and plotter of normalized "non-specific"
% baseline activity.
%
% Created 4/22/15 by DJ.
% Updated 4/27/15 by DJ - added all 16 sessions

%% Get timecourses
subject = 'SBJ01';
sessions = [1 1 2 2 3 3 4 5 5 6 6 7 7 8 9 9];
runs = [1 2 1 2 1 2 1 1 2 1 2 1 2 1 1 2];
dir = '';
filenames = cell(1,numel(runs));
for i=1:numel(sessions)
    filenames{i} = sprintf('/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/%s_S%02d/D01_Version02.AlignByAnat.Cubic/Video%02d/TED/dn_ts_OC.nii',subject,sessions(i),runs(i));
%     filenames{i} = sprintf('/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/%s_S%02d/D01_Version02.AlignByAnat.Cubic/Video%02d/p04.%s_S%02d_Video%02d_e2.align_clp+orig.BRIK',subject,sessions(i),runs(i),subject,sessions(i),runs(i));
%     filenames{i} = sprintf('/data/jangrawdc/PRJ05_100RUNS_3Tmultiecho/PrcsData/%s/%s_S%02d_R%02d_Video_MeicaDenoised_blur6.nii',subject,subject,sessions(i),runs(i));
%     filenames{i} = sprintf('/data/jangrawdc/PRJ05_100RUNS_3Tmultiecho/PrcsData/%s/%s_S%02d_R%02d_Video_Echo2_blur6+orig.BRIK',subject,subject,sessions(i),runs(i));
end
% GetTimecourseInRoi(filenames,mask,dir,baselinemask);
% maskdir = sprintf('/spin1/users/jangrawdc/PRJ05_100RUNS_3Tmultiecho/PrcsData/%s',subject);
maskdir = sprintf('/spin1/users/jangrawdc/PRJ05_100RUNS_3Tmultiecho/Results/%s/ISC',subject);

%% Get timecourses

% masks = {'TestSphere+orig', 'TestSphere2+orig', 'TestSphereVis+orig'};
% masks = {'TestSphere_olap+orig', 'TestSphere2_olap+orig', 'TestSphereVis_olap+orig'};
% masks = {'LAmygdalaSphere_byte+orig','RAmygdalaSphere_byte+orig','LFfaSphere_byte+orig'};
% masks = {'LPutamenSphere_byte+orig','LFfaSphere_byte+orig','LAmygdalaSphere_byte+orig'};
% masks = {'RInsula_byte+orig', 'SBJ01_FullBrain_EPIRes+orig'};
masks = {'SBJ01_LPutamen_5mm+orig','SBJ01_FullBrain_EPIRes+orig'};
baselinemask = [];
% baselinemask = 'SBJ01_FullBrain_EPIRes+orig';

thisdir = cd;
cd(maskdir)
Vroi_debased = cell(1,numel(masks));
for i=1:numel(masks)
    mask = masks{i};
    subplot(numel(masks),1,i); cla;
    [Vroi_debased{i},t,Vbase] = GetTimecourseInRoi(filenames,mask,dir,baselinemask);
    title(masks{i},'Interpreter','none');
end
cd(thisdir);
% ADJUST TIMING TO ACCOUNT FOR 4 VOLUMES REMOVED (movie starts after 5)
fprintf('Adjusting timing so that t0=-2...\n');
t=t-2;
fprintf('Done!\n')

%% Plot non-specific 'Vbase' timecourses
Vbase_norm = nan(size(Vbase));
legendstr = cell(1,size(Vbase,1));
for i=1:size(Vbase,1)
    Vbase_norm(i,:) = (Vbase(i,:) - mean(Vbase(i,:)))/std(Vbase(i,:)-mean(Vbase(i,:)));
    legendstr{i} = sprintf('run %d',i);
end
cla;
plot(t,Vbase_norm(1,:),'m','linewidth',2);
hold on
plot(t,Vbase_norm(2:end,:)');
plot(t,mean(Vbase_norm,1),'k','linewidth',2);
PlotHorizontalLines(0,'k--')
xlabel('time (samples)')
ylabel('Whole-brain Average BOLD signal (A.U.)')
title('SBJ01 "non-specific" timecourse');
legend([legendstr, {'Mean'}]);


%% Plot timecourses as mean +/- stddevl
iMask = 1;
nFramesToPlot=3;
% mean +/- stderr
[hTC,hLines,hFrames] = PlotMaskTimecoursesForMovie(Vroi_debased,t,masks,iMask,nFramesToPlot);
legend(masks,'interpreter','none');

% mean / stddev
% PlotMaskTimecoursesForMovie_cvar(Vroi_debased,t,masks,iMask);

%% GET TC's FROM DIFFERENT PREPROC

[filenames] = cell(2,numel(runs));
for i=1:numel(sessions)
    filenames{1,i} = sprintf('/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/%s_S%02d/D01_Version02.AlignByAnat.Cubic/Video%02d/p04.%s_S%02d_Video%02d_e2.align_clp+orig.BRIK',subject,sessions(i),runs(i),subject,sessions(i),runs(i));
    filenames{2,i} = sprintf('/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/%s_S%02d/D01_Version02.AlignByAnat.Cubic/Video%02d/TED/ts_OC.nii',subject,sessions(i),runs(i));
    filenames{3,i} = sprintf('/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/%s_S%02d/D01_Version02.AlignByAnat.Cubic/Video%02d/TED/dn_ts_OC.nii',subject,sessions(i),runs(i));
%     filenames{i} = sprintf('/data/jangrawdc/PRJ05_100RUNS_3Tmultiecho/PrcsData/%s/%s_S%02d_R%02d_Video_MeicaDenoised_blur6.nii',subject,subject,sessions(i),runs(i));
%     filenames{i} = sprintf('/data/jangrawdc/PRJ05_100RUNS_3Tmultiecho/PrcsData/%s/%s_S%02d_R%02d_Video_Echo2_blur6+orig.BRIK',subject,subject,sessions(i),runs(i));
end
procs = {'Echo2','OptCom','MEICA'};

for i=1:size(filenames,1)
    mask = masks{1};
    subplot(size(filenames,1),1,i); cla;
    [Vroi_new{i},t,Vbase] = GetTimecourseInRoi(filenames(i,:),mask,dir,baselinemask);
    title(procs{i},'Interpreter','none');
end
% ADJUST TIMING TO ACCOUNT FOR 4 VOLUMES REMOVED (movie starts after 5)
fprintf('Adjusting timing so that t0=-2...\n');
t=t-2;
fprintf('Done!\n')

%%
iProc = 3;
nFramesToPlot=3;
% mean +/- stderr
[hTC,hLines,hFrames] = PlotMaskTimecoursesForMovie(Vroi_new,t,procs,iProc,nFramesToPlot);
legend(procs,'interpreter','none');
xlim([0 t(end)])
ylim([-.5 .5])
grid on