% function MakeBopItChirps()
% Create, play, and write 
% Created 12/30/14 by DJ.

fs = 44100; % in Hz
T = 0.2; % duration in s
t = 0:1/fs:T;
if mod(length(t),2) == 1
    t = t(1:end-1);
    T = t(end);
end
f1 = 880; % bottom freq
f2 = f1*2; % top freq

%% chirp up
sound1 = chirp(t,f1,T,f2);
% sound(sound1,fs);
% pause(2*T)

%% up-down
sound2 = [chirp(t(1:end/2),f1,T/2,f2), chirp(t(1:end/2),f2,T/2,f1)];
% sound(sound2,fs);
% pause(2*T)

%% up-down-up
sound3 = [chirp(t(1:end/3),f1,T/3,f2), chirp(t(1:end/3),f2,T/3,f1), chirp(t(1:end/3),f1,T/3,f2)];
% sound(sound3,fs);
% pause(2*T)

%% play all
sound(sound1,fs);
pause(2*T);
sound(sound2,fs);
pause(2*T);
sound(sound3,fs);

%% save all
audiowrite('up.wav',sound1,fs);
audiowrite('updown.wav',sound2,fs);
audiowrite('updownup.wav',sound3,fs);
