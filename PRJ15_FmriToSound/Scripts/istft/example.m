clear, clc, close all

% music program (stochastic non-stationary signal)
[x, fs] = audioread('track.wav');     
x = x(:, 1);                                  

% signal parameters
xlen = length(x);                   
t = (0:xlen-1)/fs;                  

% define the analysis and synthesis parameters
wlen = 1024;
hop = wlen/4;
nfft = 10*wlen;

% perform time-frequency analysis and resynthesis of the original signal
[stft, f, t_stft] = stft(x, wlen, hop, nfft, fs);
[x_istft, t_istft] = istft(stft, wlen, hop, nfft, fs);

% plot the original signal
figure(1)
plot(t, x, 'b')
grid on
xlim([0 max(t)])
set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)
xlabel('Time, s')
ylabel('Signal amplitude')
title('Original and reconstructed signal')

% plot the resynthesized signal 
hold on
plot(t_istft, x_istft, '-.r')
legend('Original signal', 'Reconstructed signal')