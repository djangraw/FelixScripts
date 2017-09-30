% TestRawSoundPlayer.m
%
% Created 9/28/17 by DJ.

[rawBrick,brickInfo] = BrikLoad('SBJ09_Run01_e2+orig');

nT = size(rawBrick,4);
nVox = numel(rawBrick)/nT;
TR = 2;

rawBrick2d = reshape(rawBrick,[nVox,nT]);

%% Play as sound
% Fs_play = nVox/TR;
% dur = 10;
% sound(rawBrick2d(1:Fs_play*dur),Fs_play);

%% Plot along with event times
Fs_play = nVox/TR; % for real-time playback
dur = 10; % time to play
figure(511); clf;
PlaySoundWithBar(rawBrick2d,Fs_play,dur)
