function [template, data] = GetEegTemplate(ALLEEG,channels,tWin,smoothwidth)

% Created 11/25/12 by DJ.
% Updated 11/30/12 by DJ - defined defaults
% Updated 1/7/12 by DJ - added data output

if nargin<2 || isempty(channels)
    channels = 1:ALLEEG(1).nbchan;
end
if nargin<3 || isempty(tWin)
    tWin = [ALLEEG(1).times(1) ALLEEG(1).times(end)];
end
if nargin<4 || isempty(smoothwidth)
    smoothwidth = 1;
end

% Handle inputs
if iscell(channels)
    iChan = zeros(1,numel(channels));
    for i=1:numel(channels)
        iChan(i) = find(strcmpi(channels{i},{ALLEEG(1).chanlocs.labels}));
    end
elseif ischar(channels)
    iChan = find(strcmpi(channels,{ALLEEG(1).chanlocs.labels}));
else
    iChan = channels;
end


% Extract data
raweeg = cat(3,ALLEEG.data);
% Smooth data
smootheeg = nan(size(raweeg));
for i=1:size(raweeg,3)
     smootheeg(:,:,i) = conv2(raweeg(:,:,i),ones(1,smoothwidth)/smoothwidth,'same'); % same means output will be same size as input
end


% Set up
data = smootheeg;
ntrials = size(data,3);
isInWin = ALLEEG(1).times>=tWin(1) & ALLEEG(1).times<=tWin(2);
windowSize = sum(isInWin);

% Calculate template
template = mean(data(iChan,isInWin,:),3);
