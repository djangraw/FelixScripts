function matchStrength = LineUpTrials(ALLEEG,channels,tWin,smoothwidth)

% Created 11/27/12 by DJ.

if nargin<3 || isempty(tWin)
    tWin = [-50 50];
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
raweeg = cat(3,ALLEEG(1).data(iChan,:,:), ALLEEG(2).data(iChan,:,:));
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

template = mean(data(:,isInWin,:),3);
% tempstd = std(data(:,isInWin,:),0,3);
% colors = 'brgcymk';
% figure(112); 
% for i=1:numel(iChan)
%     subplot(numel(iChan),1,i);
%     JackKnife(ALLEEG(1).times(isInWin),template(i,:), tempstd(i,:), colors(i), colors(i));
% end

% Find matching times
matchStrength = UpdateTemplateMatchStrength(data,template);

% Get truth data
jitter = GetJitter(ALLEEG,'facecar');

% Plot
cla;
t = ALLEEG(1).times(1:end-windowSize)+round(windowSize/2);
n1 = ALLEEG(1).trials;
ImageSortedData(matchStrength(1:n1,:),t,1:n1,jitter(1:n1)+mean(tWin));
ImageSortedData(matchStrength(n1+1:ntrials,:),t,n1+1:ntrials,jitter(n1+1:end)+mean(tWin));
axis([t(1) t(end) 1 ntrials]);
chancell = {ALLEEG(1).chanlocs(iChan).labels};
chanstr = sprintf('%s, ',chancell{:});
chanstr = chanstr(1:end-2);
title(show_symbols(sprintf('%s and %s\n%d to %d ms, chans %s ',ALLEEG(1).setname, ALLEEG(2).setname,tWin(1),tWin(2),chanstr)));
xlabel('time (ms)')
ylabel('<-- dataset 0    |    dataset 1 -->');
colorbar
