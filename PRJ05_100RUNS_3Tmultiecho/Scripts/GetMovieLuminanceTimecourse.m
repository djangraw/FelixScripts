function [lum,t,smoothLum] = GetMovieLuminanceTimecourse(movieFilename)

% [lum,t] = GetMovieLuminanceTimecourse(movieFilename)
%
% INPUTS:
% -movieFilename is a string indicating the movie file you want to process.
%
% OUTPUTS:
% -lum is a vector of luminance values for each frame in the movie.
% -t is a vector of the corresponding times of the frames.
%
% Created 3/30/15 by DJ.
% Updated 3/31/15 by DJ - added smoothing via HRF convolution


% open movie
movObj = VideoReader(movieFilename);
% movSize = [movObj.Height, movObj.Width];

% set up
set(movObj,'CurrentTime',1);
fprintf('Getting frame luminance...\n');
k=0;
while hasFrame(movObj)
    k=k+1;
    fprintf('.')
    if mod(k,100)==0
        fprintf('%d\n',k)
    end
    % read in frame
    t(k) = movObj.CurrentTime;
    cdata = readFrame(movObj);    
    % get luminance
    lum(k) = mean2(rgb2gray(cdata));    
end
fprintf('DONE!\n')
    
%% plot results
try
    dt = median(diff(t));
    % smooth by convolving with an HRF
    hrf = spm_hrf(dt);
    smoothLum = conv(lum,[zeros(size(hrf)); hrf],'same');
    % smoothLum = SmoothData(lum,2/dt,'full');
    % Plot results
    cla;
    plot(t,[lum;smoothLum]);
    % Annotate plot
    xlabel('time (s)')
    ylabel('luminance from RGB (A.U.)');
    legend('raw','convolved with HRF')
    % legend('raw','smoothed (Gaussian, sigma=2s)')
    title(movieFilename,'Interpreter','none');
catch
    warning('Could not smooth & plot... Returning raw results only.')
    smoothLum = nan(size(lum));
end