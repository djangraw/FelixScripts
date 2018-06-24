voice = 'Karen';
wpm_talk = 60;
outFile = 'TEMP.aiff';
% text = 'Hello everyone, how are you today? Im doing great, thanks for asking.';
% cmd = sprintf('say -v %s -r %d -o %s %s',voice,wpm_talk,outFile,text);
txtFile = 'ReluctantDragon_short.txt';
cmd = sprintf('say -v %s -r %d -o %s %s',voice,wpm_talk,outFile,txtFile);
system(cmd);


%% Get ideal number of steps

wpm_min = 120;
wpm_max = 2000;

nSteps_vec = 1:1:20;
tEnd = nan(1,numel(nSteps_vec));
for i=1:numel(nSteps_vec)
    step = linspace(wpm_min/wpm_talk,wpm_max/wpm_talk,nSteps_vec(i));
    t = cumsum(step);
    tEnd(i) = t(end);
end

plot(nSteps_vec,tEnd,'.-');

% get m/b
m = median(diff(tEnd))./median(diff(nSteps_vec));
b = median(tEnd./m-nSteps_vec);

tEnd_desired = cols-2;
nSteps_calc = floor(tEnd_desired/m-b)

%% Load and do weird pvoc hack

[x, fs] = audioread(outFile);
r = 1;
n = 1024;
hop = n/4;


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
% t = 0;
% i = 1;
% while t(end)<(cols-2-i)
%     t = [t, t(end)+i];
%     i = i+0.005;
% end
step = linspace(wpm_min/wpm_talk,wpm_max/wpm_talk,nSteps_calc);
t = cumsum(step);

% Have to stay two cols off end because (a) counting from zero, and 
% (b) need col n AND col n+1 to interpolate

% Generate the new spectrogram
X2 = pvsample(X, t, hop);

% Invert to a waveform
y = istft(X2, n, n, hop)';

%% play result
sound(y,fs);