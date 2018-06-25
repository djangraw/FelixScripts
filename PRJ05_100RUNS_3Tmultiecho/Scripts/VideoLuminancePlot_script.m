% VideoLuminancePlot_script
%
% Created 4/1/15 by DJ.

iClipStart = find(abs(diff(lum))>20)+1;

dt = median(diff(t));
% smooth by convolving with an HRF
hrf = spm_hrf(dt);
smoothLum = conv(lum,[zeros(size(hrf)); hrf],'same');
% smoothLum = SmoothData(lum,2/dt,'full');
% Plot results
cla; hold on;
plot(t,[lum;smoothLum]);
PlotVerticalLines(t(iClipStart),'g:')
% Annotate plot
xlabel('time (s)')
ylabel('luminance from RGB (A.U.)');
legend('raw','convolved with HRF','new clip')
% legend('raw','smoothed (Gaussian, sigma=2s)')
title(movieFilename,'Interpreter','none');
