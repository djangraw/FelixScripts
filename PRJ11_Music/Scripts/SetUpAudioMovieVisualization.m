function [h,wavData,tWavData,VFinal,tFinal] = SetUpAudioMovieVisualization(fmriFile,audioFile,motionFile,data)

% Created 4/21/17 by DJ.

%% Declare constants

vars = GetMusicVariables();
trThreshold = 0.15;
audioDir = [vars.homedir '/RawData/SBJ03/audio'];
fmriDir = [vars.homedir '/Results/SBJ03_task/AfniProc_MultiEcho'];
finalDt = 0.01;

%% Load audio file
[wavData, Fs] = audioread(fullfile(audioDir,audioFile));
tWavData = (1:numel(wavData))/Fs;
% Find first TR in audio file
iFirstTr = find(wavData>trThreshold,1);
tWavData = tWavData-tWavData(iFirstTr);

%% Load fMRI file
[V, Info] = BrikLoad(fullfile(fmriDir,fmriFile));
[~,TR] = system(sprintf('3dinfo -TR %s',fullfile(fmriDir,fmriFile)));
TR = str2double(TR);
if isnan(TR)
    TR = vars.TR;
end
tFmri = (0:(size(V,4)-1))*TR;

%% Extract physio & blocks
iPhysioStart = find(data.physio.trigger.data>2,1);
tPhysioStart = data.physio.time(iPhysioStart);
tPhysio = data.physio.time-tPhysioStart;
respData = data.physio.resp.data;
pulseData = data.physio.pulseox.data;
[tParadigm,blockData] = PlotPhysioAndMotion(data,fullfile(fmriDir,motionFile),TR);

%% Interpolate all
sliceType = 'sagittal';
iSlice = 30;
switch sliceType
    case 'sagittal'
        Vslice = flipud(permute(V(iSlice,:,:,:),[3 2 4 1]));
    case 'coronal'
        Vslice = flipud(permute(V(:,iSlice,:,:),[3 1 4 2]));
    case 'axial'
        Vslice = flipud(permute(V(:,:,iSlice,:),[2 1 4 3]));
end
% interpolate fMRI
tFinal = 0:finalDt:tFmri(end);
nT = numel(tFinal);
VFinal = nan([size(Vslice,1),size(Vslice,2),nT]);
for i=1:size(Vslice,1)
    fprintf('row %d/%d...\n',i,size(Vslice,1));
    for j=1:size(Vslice,2)
        VFinal(i,j,:) = interp1(tFmri,squeeze(Vslice(i,j,:)),tFinal,'spline');
    end
end
% subtract 100
VFinal = VFinal - 100;
VFinal(VFinal==-100) = NaN;
fprintf('Done!\n');
%% interpolate data to make it easier to plot
% interpolate audio
% wavFinal = interp1(tWavData,wavData,tFinal,'spline');
% interpolate physio
respFinal = interp1(tPhysio,respData,tFinal,'spline');
pulseFinal = interp1(tPhysio,pulseData,tFinal,'spline');
% interpolate blocks
blockFinal = interp1(tParadigm,blockData,tFinal,'nearest');

%% Plot everything
clf;
% xLimits = [5 40];%xLimits = [110 145];
% iPos = find(tFinal>=xLimits(1),1);
iPos = 1;
h.Block = subplot(6,1,1); cla; hold on;
plot(tFinal,blockFinal);
set(gca,'ytick',1:3,'yticklabel',data.params.trialTypes);
h.Bar(1) = PlotVerticalLines(tFinal(iPos),'k');
h.Wav = subplot(6,1,2); cla; hold on;
% plot(tFinal,wavFinal);
plot(tWavData,wavData);
h.Bar(2) = PlotVerticalLines(tFinal(iPos),'k');
ylabel('audio')
h.Resp = subplot(6,1,3); cla; hold on;
plot(tFinal,respFinal);
h.Bar(3) = PlotVerticalLines(tFinal(iPos),'k');
ylabel('breathing')
h.Pulse = subplot(6,1,4); cla; hold on;
plot(tFinal,pulseFinal);
h.Bar(4) = PlotVerticalLines(tFinal(iPos),'k');
ylabel('heartbeat')

h.Fmri = subplot(3,1,3);
h.Img = imagesc(VFinal(:,:,iPos));
colorbar;
axis image
set(gca,'xtick',[],'ytick',[]);

% link axes and set limits
linkaxes([h.Block,h.Resp,h.Pulse,h.Wav],'x');
% xlim(h.Block,xLimits);
drawnow;