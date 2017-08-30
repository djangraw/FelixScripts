function [rawEcg_all,rawResp_all,HR_all,RR_all] = PlotHrAndRr(subject)

% PlotHrAndRr(subject)
%
% Created 10/25/16 by DJ.

%%
[rawEcg,rawResp,data] = GetEcgAndRespiration(subject);
Fs = 50; % standard for 3TC
t = (1:length(rawEcg{1}))'/Fs;

nRuns = numel(rawEcg);
[tEcgPeaks,tRespPeaks,HR,RR,tEcgPeaks_adj,tRespPeaks_adj] = deal(cell(1,nRuns));
for i=1:nRuns
    fprintf('   Run %d/%d...\n',i,nRuns);
    % De-mean for later plotting
    rawEcg{i} = rawEcg{i}-mean(rawEcg{i});
    rawResp{i} = rawResp{i}-mean(rawResp{i});
    % Get peaks
    tEcgPeaks{i} = GetEcgPeaks(rawEcg{i},Fs);
    tRespPeaks{i} = GetRespPeaks(rawResp{i},Fs);
    % Calculate HR
    [HR{i},RR{i}] = deal(nan(size(t)));
    for j=1:numel(tEcgPeaks{i})-1
        tMidPeak = mean(tEcgPeaks{i}(j:j+1));
        [~,iMidPeak] = min(abs(t-tMidPeak));
        HR{i}(iMidPeak) = 60/diff(tEcgPeaks{i}(j:j+1)); % in bpm
    end
    % Interpolate NaNs
    isOk = ~isnan(HR{i}); 
    HR{i}(~isOk) = interp1(t(isOk),HR{i}(isOk),t(~isOk),'linear','extrap');
    % adjust peak times
    tEcgPeaks_adj{i} = tEcgPeaks{i} + (i-1)*t(end);
    
    % Calculate RR
    for j=1:numel(tRespPeaks{i})-1
        tMidPeak = mean(tRespPeaks{i}(j:j+1));
        [~,iMidPeak] = min(abs(t-tMidPeak));
        RR{i}(iMidPeak) = 60/diff(tRespPeaks{i}(j:j+1)); % in bpm
    end
    % Interpolate NaNs
    isOk = ~isnan(RR{i}); 
    RR{i}(~isOk) = interp1(t(isOk),RR{i}(isOk),t(~isOk),'linear','extrap');
    % adjust peak times
    tRespPeaks_adj{i} = tRespPeaks{i} + (i-1)*t(end);

end

%% Plot results
% Compile results
rawEcg_all = cat(1,rawEcg{:});
rawResp_all = cat(1,rawResp{:});
HR_all = cat(1,HR{:});
RR_all = cat(1,RR{:});
t_all = (1:length(rawEcg_all))'/Fs;
tEcgPeaks_all = cat(2,tEcgPeaks_adj{:});
tRespPeaks_all = cat(2,tRespPeaks_adj{:});
tSession = (1:nRuns-1)*t(end);

% Plot
clf;
subplot(2,1,1); cla; hold on
hEcg = plotyy(t_all,rawEcg_all,t_all,HR_all);
plot(hEcg(1),tEcgPeaks_all,zeros(size(tEcgPeaks_all)),'*');
PlotVerticalLines(tSession,'k--',true);
xlabel('time (s)');
ylabel(hEcg(1),'pulseOx');
ylabel(hEcg(2),'Heart Rate (beats/min)');
legend(hEcg(1),'pulseOx trace','peaks','sessions');
title(sprintf('SBJ%02d Physio Traces',subject));

subplot(2,1,2); cla; hold on
hResp = plotyy(t_all,rawResp_all,t_all, RR_all);
plot(hResp(1),tRespPeaks_all,zeros(size(tRespPeaks_all)),'*');
PlotVerticalLines(tSession,'k--',true);
xlabel('time (s)');
ylabel(hResp(1),'resp belt');
ylabel(hResp(2),'Respiration Rate (breaths/min)');
legend(hResp(1),'resp trace','peaks','sessions');
linkaxes([hEcg hResp],'x');
