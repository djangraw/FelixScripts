function fmriSound = ConvertFmriToSound(fmriFile,maskFile,TR,fmriFreqRange,soundFreqRange)

% fmriSound = ConvertFmriToSound(fmriFile,maskFile,fmriFreqRange,soundFreqRange)
%
% Created 9/28/17 by DJ.

%% Set up
% Declare options
opt.window = 32;
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

%% Method 1: Speed up global signal
% filter
% get global signal
globalSig = mean(fmriMasked);

% convert to sound
% speedFactor = mean(soundFreqRange)/mean(fmriFreqRange); % how much faster is sound than fmri
% sound(globalSig,opt.Fs*speedFactor);


%% Method 2: spectrogram
% Get spectrogram and power density spectrum
fprintf('Taking spectrogram of global signal...\n');
tic;
[S,F,T,P,Fc,Tc] = spectrogram(globalSig,opt.window,opt.nOverlap,opt.fFft,opt.Fs);
fprintf('Done! Took %.1f seconds.\n',toc);

% Convert to sound
F_sound = interp1(fmriFreqRange,soundFreqRange,F);
T_sound = T; % speed up?

speedFactor = mean(soundFreqRange)/mean(fmriFreqRange); % how much faster is sound than fmri
iopt.window = round(opt.window*speedFactor);
iopt.nOverlap = round(opt.nOverlap*speedFactor);
iopt.fFft = opt.fFft*10;
iopt.Fs = opt.Fs*speedFactor;
% Convert spectrogram to sound
[x_istft, t_istft] = istft(S, iopt.window, iopt.window-iopt.nOverlap, numel(T_sound), iopt.Fs);

%% Method 3: Phase vocoder
% [d,sr]=audioread('handel.wav'); 
% % sr = 16000;
% % 1024 samples is about 60 ms at 16kHz, a good window 
% y=pvoc(d,.75,1024); 
% % Compare original and resynthesis 
% sound(d,sr) 
% sound(y,sr)



