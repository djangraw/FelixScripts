% function fmriSound = ConvertFmriToSound(fmriFile,maskFile,TR,fmriFreqRange,soundFreqRange)
%
% fmriSound = ConvertFmriToSound(fmriFile,maskFile,fmriFreqRange,soundFreqRange)
%
% Created 9/28/17 by DJ.
% Updated 9/29/17 by DJ - converted to script.

%% Load
fmriFile = BrikLoad('pb08.SBJ06_CTask001.blur.WL045+orig.HEAD');
maskFile = BrikLoad('pb03.SBJ06_CTask001.volreg.REF.mask.FBrain+orig.HEAD');
TR = 1.5;
fmriFreqRange = [0.023 .18]; % Javier's CogStates bandpass limits
soundFreqRange = [230 1800]; % speed up 10000x

%% Set up
% Declare options
opt.window = 256;
opt.nOverlap = opt.window-1;
opt.fFft = linspace(fmriFreqRange(1),fmriFreqRange(2),20);
opt.Fs = 1/TR;

% Load files
if ischar(fmriFile)
    fmriFile = BrikLoad(fmriFile);
end
if ischar(maskFile)
    maskFile = BrikLoad(maskFile);
end
nVox = size(fmriFile,1)*size(fmriFile,2)*size(fmriFile,3);
nT = size(fmriFile,4);

% Mask and get spectrogram
maskVec = maskFile(:);
fmri2D = reshape(fmriFile,[nVox,nT]);
fmriMasked = fmri2D(maskVec>0,:);
nVoxInMask = size(fmriMasked,1);

%% Method 1: Speed up global signal
% filter
% get global signal
globalSig = mean(fmriMasked);

% convert to sound
speedFactor = mean(soundFreqRange)/mean(fmriFreqRange); % how much faster is sound than fmri
sound(globalSig,opt.Fs*speedFactor);

%% Method 2: Play Raw Sound
Fs_play = nVox/TR; % for real-time playback
dur = 10; % time to play
figure(511); clf;
PlaySoundWithBar(fmri2D,Fs_play,dur);

%% Method 3: spectrogram
% Get spectrogram and power density spectrum
% fprintf('Taking spectrogram of global signal...\n');
% tic;
% [S,F,T,P,Fc,Tc] = spectrogram(globalSig,opt.window,opt.nOverlap,opt.fFft,opt.Fs);
% fprintf('Done! Took %.1f seconds.\n',toc);
% 
% % Convert to sound
% F_sound = interp1(fmriFreqRange,soundFreqRange,F);
% T_sound = T; % speed up?
% 
% speedFactor = mean(soundFreqRange)/mean(fmriFreqRange); % how much faster is sound than fmri
% iopt.window = round(opt.window*speedFactor);
% iopt.nOverlap = round(opt.nOverlap*speedFactor);
% iopt.fFft = opt.fFft*10;
% iopt.Fs = opt.Fs*speedFactor;
% % Convert spectrogram to sound
% [x_istft, t_istft] = istft(S, iopt.window, iopt.window-iopt.nOverlap, numel(T_sound), iopt.Fs);
% 
% % Play sound
% PlaySoundWithBar(x_istft,iopt.Fs,dur);

%% Method 4: Phase vocoder

% sr = 16000;
% 1024 samples is about 60 ms at 16kHz, a good window 
speedFactor = 0.0001;
dur = 5;
winSize = opt.window;
hopSize = 1;
globalSignal_shifted=pvoc(globalSig,speedFactor,winSize,hopSize); 
Fs_shifted = opt.Fs/speedFactor;

% Compare original and resynthesis 
% sound(globalSig(1:(dur/TR)),opt.Fs); % Fs Too low... upsample first?
% sound(globalSignal_shifted(1:round(dur/TR/speedFactor)),Fs_shifted);

%% Plot results
tSig = (1:length(globalSig))/opt.Fs;
tSig_shifted = (1:length(globalSignal_shifted))/Fs_shifted + winSize/2*TR;
figure(513); clf;
% plot events
% For Javier's data
wlTR=120;
wsTR=0;
[err, errMsg, winInfo] = func_CSD_GetWinInfo_Experiment01(wlTR, wsTR);
cla;hold on;
for i=1:numel(winInfo.onsetTRs)
    plot([winInfo.onsetTRs(i), winInfo.offsetTRs(i)]*TR,[1 1]*max(globalSignal_shifted)*1.1,'-','color',winInfo.color(i,:),'linewidth',2);
end
% plot data and play it as sound
PlaySoundWithBar(globalSignal_shifted,tSig_shifted);

%% Same for win32
% sound32 = load('SBJ06_CTask001_globalShifted_win32.mat');
tSig_shifted = (1:length(sound32.globalSignal_shifted))/sound32.Fs_shifted + sound32.winSize/2*TR;
figure(513); clf;
% plot events
% For Javier's data
wlTR=120;
wsTR=0;
[err, errMsg, winInfo] = func_CSD_GetWinInfo_Experiment01(wlTR, wsTR);
cla;hold on;
for i=1:numel(winInfo.onsetTRs)
    plot([winInfo.onsetTRs(i), winInfo.offsetTRs(i)]*TR,[1 1]*max(sound32.globalSignal_shifted)*1.1,'-','color',winInfo.color(i,:),'linewidth',2);
end
% plot data and play it as sound
PlaySoundWithBar(sound32.globalSignal_shifted,tSig_shifted);