function y = pvoc(x, r, n, hop)
% y = pvoc(x, r, n)  Time-scale a signal to r times faster with phase vocoder
%      x is an input sound. n is the FFT size, defaults to 1024.  
%      Calculate the STFT (with step size hop, default = 25%-overlapped), 
%      squeeze it by a factor of r, take inverse spegram.
%
% 2000-12-05, 2002-02-13 dpwe@ee.columbia.edu.  Uses pvsample, stft, istft
% Downloaded 9/28/17 by DJ.
% Updated 9/29/17 by DJ - added optional hop input.
%
% $Header: /home/empire6/dpwe/public_html/resources/matlab/pvoc/RCS/pvoc.m,v 1.3 2011/02/08 21:08:39 dpwe Exp $

if nargin < 3
  n = 1024;
end
if nargin < 4
    % With hann windowing on both input and output, 
    % we need 25% window overlap for smooth reconstruction
    hop = n/4;
end

% Effect of hanns at both ends is a cumulated cos^2 window (for
% r = 1 anyway); need to scale magnitudes by 2/3 for
% identity input/output
%scf = 2/3;
% 2011-02-07: this factor is now included in istft.m
scf = 1.0;

% Calculate the basic STFT, magnitude scaled
X = scf * stft(x', n, n, hop);

% Calculate the new timebase samples
[rows, cols] = size(X);
t = 0:r:(cols-2);
% Have to stay two cols off end because (a) counting from zero, and 
% (b) need col n AND col n+1 to interpolate

% Generate the new spectrogram
X2 = pvsample(X, t, hop);

% Invert to a waveform
y = istft(X2, n, n, hop)';