% TEMP_TestCraddockFft
%
% Created 6/17/16 by DJ.

%% Take FFT
fprintf('Taking FFT...\n');
N = [];
tc_interp = tc;
for i=1:nROIs
    isOk = ~isnan(tc(i,:));
    tc_interp(i,~isOk) = interp1(find(isOk),tc(i,isOk),find(~isOk));
end
MagFft = fft(tc_interp',N,1); % along dimension 1 (time)

N = size(MagFft,1);
MagFftPwr = abs(MagFft(1:floor(N/2),:)).^2;
% Get vector of corresponding frequencies 
nyquist = 1/TR/2;
freq = (1:N/2)/(N/2)*nyquist;

% Plot
figure(14); clf;
subplot(2,1,1);
imagesc(freq,1:nROIs,MagFftPwr');
xlabel('freq (Hz)')
ylabel('ROI')
title('ROI-wise FFT for SBJ09 Craddock data')
subplot(2,1,2);
plot(freq,mean(MagFftPwr,2));
xlabel('freq (Hz)')
ylabel('power')
title('mean FFT across ROIs')