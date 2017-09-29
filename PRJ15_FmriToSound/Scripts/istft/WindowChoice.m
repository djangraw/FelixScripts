clear, clc, close all

% define analysis/synthesis parameters
wlen = 64;                         % window length (recomended to be power of 2)    (Put your value here!)
h = wlen/4;                        % hop size (recomended to be power of 2)         (Put your value here!)
win = hamming(wlen, 'periodic');   % analysis/synthesis window                      (Put your value here!)
                                   % (recommended to be one and the same)

% plot the sliding windows
figure(1)
hold on

s = zeros(5*wlen, 1);              % OLA empty matrix

for n = 0:h:4*wlen
    indx = n+1:n+wlen;             % current window location
    s(indx) = s(indx) + win.^2;    % window overlap-add (OLA)
    plot(indx, win, '-ok')         % plot the current window
end

% scale the OLA result
W0 = sum(win.^2);                 
s = s*h/W0;                        

% plot the OLA result
stem(s, 'r');                      
grid on
xlim([0 length(s)])
ylim([0 1.2])
set(gca, 'FontName', 'Times New Roman', 'FontSize', 14)
xlabel('Index')
ylabel('Level')