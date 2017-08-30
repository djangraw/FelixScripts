function WriteAfniDmblockTimingFile(filename,startTimes,amplitudes,durations)

% WriteAfniDmblockTimingFile(filename,startTimes,amplitudes,durations)
%
% INPUTS:
% -filename is a string indicating the file you'd like to write to.
% -startTimes is an N-element vector of the event start times.
% -amplitudes is an N-element vector of the corresponding amplitude
% factors. [default: ones]
% -durations is an N-element vector of the corresponding event durations.
% [default: ones]
%
% Created 3/14/16 by DJ.

% Declare defaults
if ~exist('amplitudes','var') || isempty(amplitudes)
    amplitudes = ones(size(startTimes));
end
if ~exist('durations','var') || isempty(durations)
    durations = ones(size(startTimes));
end

% Check on size/nan value of parameters
if any(isnan(startTimes)) || any(startTimes>=1e6) || any(isnan(amplitudes)) || any(abs(amplitudes)>=1e6) || any(isnan(durations)) || any(durations>=1e6)
    error('startTimes, amplitudes, and durations must all be real numbers below 1e6!');
end

% Open file for writing
fid = fopen(filename,'w');
% Write each event's time*amp:duration
for i=1:numel(startTimes)
    fprintf(fid,'%g*%g:%g',startTimes(i),amplitudes(i),durations(i));
    if i<numel(startTimes)
        fprintf(fid,' ');
    end
end

% clean up
fclose(fid);