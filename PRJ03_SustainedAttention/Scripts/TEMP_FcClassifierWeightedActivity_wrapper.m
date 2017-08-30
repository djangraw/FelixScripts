% TEMP_FcClassifierWeightedActivity_wrapper.m
%
% Created 4/5/16 by DJ.
homedir = '/data/jangrawdc/PRJ03_SustainedAttention/Results';
subjects = 9:20;
% Declare params
fcWinLength = 10;
TR = 2;
nFirstRemoved = 3;
fracFcVarToKeep = 0.5;
HrfOffset = 0;

[D,C,B,Y,AzLoo] = deal(cell(1,numel(subjects)));
for i=1%:numel(subjects)
    % load fMRI data
    cd(sprintf('%s/SBJ%02d',homedir,subjects(i)));    
    [~,tc] = Read_1D(sprintf('SBJ%02d_CraddockAtlas_200Rois_ts.1D',subjects(i)));
    tc = tc';
    [~,censorM] = Read_1D(sprintf('censor_SBJ%02d_combined_2.1D',subjects(i)));    
    isNotCensoredSample = censorM'>0;
    tc(:,~isNotCensoredSample) = nan;
    % Load experimental timing data
    load(sprintf('Distraction-%d-QuickRun.mat',subjects(i))); % data, stats,question
    % Get constants
    nSessions = numel(data);
    nTR = size(tc,2)/nSessions + nFirstRemoved; % # TRs per session before removal
    
    %% get samples & truth
    [iTcEventSample,iFcEventSample,event_names] = GetEventSamples(data, fcWinLength, TR, nFirstRemoved, nTR, HrfOffset);

    %% crop to events
    isSpeechEvent = ismember(event_names,{'attendedSpeech','ignoredSpeech'});
    iFcEventSample_crop = iFcEventSample(isSpeechEvent);
    truth = strcmp(event_names(isSpeechEvent),'ignoredSpeech');
    
    %% Get weights
    X = tc;
    [D{i},C{i},B{i},Y{i},AzLoo{i}] = GetFcClassifierWeightedActivity(X,fracFcVarToKeep,iFcEventSample_crop,truth);

end

%% Write results to AFNI bricks

cd /data/jangrawdc/PRJ03_SustainedAttention/Results/craddock_2011_parcellations
[bigAtlas,Info] = BrikLoad('CraddockAtlas_200Rois_tta+tlrc.BRIK.gz');
cd /data/jangrawdc/PRJ03_SustainedAttention/Results

iSubj=1;
nT = size(D{iSubj},2);
weightedActivity_atlas = zeros([size(bigAtlas), nT]);
for j=1:nT
    weightedActivity_atlas(:,:,:,j) = MapValuesOntoAtlas(bigAtlas,D{iSubj}(:,j));
    weightedActivity_atlas(isnan(weightedActivity_atlas)) = 0;
end
Info.BRICK_TYPES = repmat(3,1,nT);
Info.BRICK_STATS = repmat([min(weightedActivity_atlas(:)), max(weightedActivity_atlas(:))],nT,1);
Info.BRICK_LABS = '';
for j=1:nT
    Info.BRICK_LABS = strcat(Info.BRICK_LABS, sprintf('WtdSignal(t=%d)~',j));
end
Info.BRICK_LABS(end) = [];
Opt = struct('Prefix',sprintf('SBJ%02d_Craddock_FcWeightedActivity2_TTA',subjects(iSubj)),'OverWrite','y');
% WriteBrik(meanMeanFwdModel_atlas,Info,Opt);
WriteBrik(weightedActivity_atlas ,Info,Opt);



%% Plot results
cd(homedir)
atlas = BrikLoad('craddock_2011_parcellations/CraddockAtlas_200Rois_tta+tlrc.BRIK');
iSubj = 1;
clim = [-1 1]*.008;
iSample = 1;
atlasMapped = MapValuesOntoAtlas(atlas,D{iSubj}(:,iSample));
iSlices = round(linspace(10,size(atlas,1)-10,9));
clf;
[hAxes,hPlot] = DisplaySlices(atlasMapped,1,iSlices,[3 3],clim);
    
hTimecourse = axes('Position',[0.2 0.01 0.6 0.05]);
imagesc(D{iSubj});
xlim(hTimecourse,[0 size(D{iSubj},2)])
ylim(hTimecourse,[0 size(D{iSubj},1)]);
hold on;
PlotVerticalLines(iFcEventSample_crop(truth==0),'m');
PlotVerticalLines(iFcEventSample_crop(truth==1),'y');
PlotVerticalLines(iFcEventSample(~isSpeechEvent),'c');
hBar = plot([1 1],get(gca,'ylim'),'k','linewidth',2);
MakeLegend({'m','y','c','k'},{'attendedSpeech','ignoredSpeech','whiteNoise','current time'},[1 1 1 2])
set(hTimecourse,'clim',clim);
xlabel('time (TR)')
ylabel('ROI')
colormap jet;
%
atlasSlices = permute(atlas(iSlices,:,:),[3 2 1]);
%
for iSample = 1:size(D{iSubj},2)    
    atlasMapped = MapValuesOntoAtlas(atlasSlices,D{iSubj}(:,iSample));
    for i=1:numel(hPlot)
        set(hPlot(i),'cdata',atlasMapped(:,:,i));
    end
    set(hBar,'xdata',[iSample iSample]);
    drawnow;
    
end