% PlotSimonComponentsOnBehavior.m
%
% Created 4/16/15 by DJ.

% load in the components for two different runs
subject = 'SBJ03';
runs = 1:6;

%% Load Anatomical
dir = sprintf('/spin1/users/jangrawdc/PRJ04_Simon/PrcsData/%s/D01_Anatomical/',subject);
[err,Anat,AnatInfo,ErrMessage] = BrikLoad(sprintf('%s%s_Anat+orig',dir,subject));

%% Load MEICA output
fprintf('===Loading Data...\n')
for i=1:numel(runs)
    fprintf('Loading run %d/%d...\n',i,numel(runs));
%     dir = sprintf('/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/%s_S%02d/D01_MeicaAnalysis/Video%02d/meica.%s_S%02d_Video%02d_e1/TED/',subject,sessions(i),runs(i),subject,sessions(i),runs(i));
    dir = sprintf('/data/jangrawdc/PRJ04_Simon/PrcsData/%s/D02_Preprocessing/TED.%s_Run%02d/',subject,subject,runs(i));
    [err, betas{i}, BetaInfo, ErrMessage] = BrikLoad([dir 'betas_OC.nii']);
    kappas{i} = csvread([dir 'Kappas.txt']);
    rhos{i} = csvread([dir 'Rhos.txt']);
    varex{i} = csvread([dir 'varex.txt']);
    iAccepted{i} = csvread([dir 'accepted.txt'])+1;
    TC{i} = load([dir 'meica_mix.1D']);
    nComponents(i) = size(TC{i},2);
    nT(i) = size(TC{i},1);
end
fprintf('===Done!\n')

%% Plot Component Timecourses on top of behavior
iRun = 1;
TR = 2;
behaviorFilename = sprintf('Simon-%s-%d.mat',subject(end),runs(iRun));
load(behaviorFilename); % loads data

[varex_sorted, order] = sort(varex{iRun}(iAccepted{iRun}),'descend');
TC_sorted = TC{iRun}(:,iAccepted{iRun}(order));
t = (1:nT(iRun))*TR;
figure(12); clf;
for j=1:12
    subplot(4,3,j); cla;
    PlotSimonTimecourse(data.events,data.performance);
    plot(t,TC_sorted(:,j)*2+5,'m');
    xlabel('t (s)')
    ylabel('BOLD activation (A.U.)')
    title(sprintf('Component %d: %.2f%% var. explained',order(j),varex_sorted(j)));
    MakeFigureTitle(behaviorFilename);
    MakeLegend({'b','g','r','m'},{'blocks','playback','responses','BOLD'},[],[0.88,0.9]);
end

%% Plot Component Weights
iComp = 11;
iSlices = round(linspace(16,50,12));
figure(13); clf;
weights = betas{iRun}(:,:,:,iComp);
mask = any(betas{iRun}>0,4);
for i=1:numel(iSlices)
    subplot(4,3,i);
    underlay = squeeze(mask(iSlices(i),:,:))'*0.1;
    overlay = squeeze(weights(iSlices(i),:,:));
    overlay_sc = overlay' / max(abs(weights(:)))*0.9;
    
    weightimage = cat(3,underlay + overlay_sc.*(overlay_sc>0), underlay, underlay - overlay_sc.*(overlay_sc<0));
    imagesc(weightimage);
    set(gca,'ydir','normal');
    title(sprintf('slice = %d',iSlices(i)));
    MakeFigureTitle(sprintf('Simon %s run %d component %d',subject,iRun,iComp));

end
    