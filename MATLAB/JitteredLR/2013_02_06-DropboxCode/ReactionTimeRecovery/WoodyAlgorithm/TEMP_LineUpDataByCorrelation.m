function TEMP_LineUpDataByCorrelation(subject,iElec,windowSize)
% 
% Created 11/14/12 by DJ.
%
% Try to line up trials without discriminating.

if nargin<2 || isempty(iElec)
    iElec = 1:60; %all
%     iElec = 29 %=O1
end
if nargin<3 || isempty(windowSize)
    windowSize = 1000;
end

% Load dataset
ALLEEG = loadSubjectData_facecar(subject); % eeg info and saccade info
RT1 = getRT(ALLEEG((1)),'RT');
RT2 = getRT(ALLEEG((2)),'RT');

% Jitter data (for Response-locked Analysis)
tWindow(1) = (ALLEEG((1)).times(1) - min([RT1 RT2]))/1000;
tWindow(2) = (ALLEEG((1)).times(end) - max([RT1 RT2]))/1000;
EEG = pop_epoch(ALLEEG((1)),{'RT'},tWindow);
ALLEEG = eeg_store(ALLEEG,EEG,3);
EEG = pop_epoch(ALLEEG((2)),{'RT'},tWindow);
ALLEEG = eeg_store(ALLEEG,EEG,4); 

%%
avgStim = mean(ALLEEG(1).data(iElec,:,:),3);
avgResp = mean(ALLEEG(3).data(iElec,:,:),3);

t0 = find(ALLEEG(3).times>=0,1);
correlation = nan(ALLEEG(3).trials, ALLEEG(3).pnts-windowSize);
for i=1:ALLEEG(3).trials
    for j=1:ALLEEG(3).pnts-windowSize
        correlation(i,j) = sum(ALLEEG(3).data(iElec,j+(0:windowSize),i)*avgResp(t0-round(windowSize/2)+(0:windowSize))');
    end
end

%% Plot results
% cla; hold on;
% imagesc(ALLEEG(3).times(1:end-windowSize)+round(windowSize/2),1:ALLEEG(3).trials,correlation)
% hold on
% 
% scatter(mean(RT1)-RT1,1:ALLEEG(3).trials,'k.')
% [~,iMax] = max(correlation,[],2);
% scatter(ALLEEG(3).times(iMax+round(windowSize/2)),1:ALLEEG(3).trials,'m.')
ImageSortedData(correlation,ALLEEG(3).times(1:end-windowSize)+round(windowSize/2),1:ALLEEG(3).trials,mean(RT1)-RT1);
colorbar