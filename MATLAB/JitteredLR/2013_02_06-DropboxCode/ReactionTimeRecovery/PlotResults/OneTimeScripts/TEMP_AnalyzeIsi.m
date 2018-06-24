% TEMP_AnalyzeIsi.m
%
% Add the folder containing the facecar_<subject>_events.mat files to your
% path before running this program.
%
% Created 10/3/12 by DJ for one-time use.

% subject = 'an02apr04';
cla; hold on;
[rts ISI waittimes] = deal(cell(1,numel(subjects)));
for i=1:numel(subjects)
    % Load info for this subject
    subject = subjects{i};
    filename = sprintf('facecar_%s_events.mat',subject);
    foo = load(filename);    
    [StimOffsets_all RTs_all CorrectResp_all]=readevent(filename,'FC',foo.coh_values);
    % Get times for this subject
    stimtimes = sort([StimOffsets_all{:}]);
    rts{i} = sort([RTs_all{:}]);
    ISI{i} = diff(stimtimes);
    waittimes{i} = ISI{i}-rts{i}(1:end-1);

end
% Get histograms
rts = [rts{:}];
ISI = [ISI{:}];
waittimes = [waittimes{:}];
xISI = 0:100:3000;
yISI = hist(ISI(ISI<3000),xISI);
xRT = 0:100:3000;
yRT = hist(rts,xRT);
yWT = hist(waittimes(waittimes<3000),xRT);
% Plot and annotate
plot(xRT,yRT,'b.-')
plot(xRT,yWT,'g.-')
plot(xISI,yISI,'r.-')
title(sprintf('%d subjects, all trials',numel(subjects)));
xlabel('time')
ylabel('# trials')
legend('RT','WaitTime','ISI')