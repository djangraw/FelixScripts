function CompareToSquaresTruePosteriors(subject, weightornoweight, startorend, crossval, suffix, pt)

% CompareToSquaresTruePosteriors(foldername,cvmode)
%
% Created 11/23/11 by DJ (TO DO: TEST!!!)
% Updated 12/4/11 by DJ - time vector starts from 0 now

if nargin<6
    pt = GetFinalPosteriors(subject, weightornoweight, startorend, crossval, suffix);
end

%% Load
foldername = ['results_' subject '_' startorend 'Saccades_' weightornoweight 'prior_' crossval '_' suffix];
par = load([foldername '/params_' crossval]);
res = load([foldername '/results_' crossval]);

%% Set up
ALLEEG = par.ALLEEG(par.setlist);
dt = 1/ALLEEG(1).srate;
t = dt*(0:size(pt{1},2)-1)*1000;

%% Get posteriors
truepost = zeros(size(pt{1}));
for i=1:ALLEEG(2).trials
    iEvent = find(strcmp('152',ALLEEG(2).epoch(i).eventtype(:))); % 152 = completion
    if ~isempty(iEvent)
        eventTime = ALLEEG(2).epoch(i).eventlatency{iEvent};
        [~,iT] = min(abs(eventTime-t));
        truepost(ALLEEG(1).trials+i,iT) = 1;    
    else
        fprintf('trial %d has no completion saccade\n',i);
    end
end

[Az,iTime] = max(res.Azloo);
respost = pt{1,iTime};
diffpost = respost-truepost;

%% Plot posteriors
figure(122);
clear c
[nRows, nCols] = size(truepost);
times = (0:nCols-1)*4;

c(1) = subplot(2,2,1);
imagesc(times,1:nRows,truepost)
xlabel('time (ms)')
ylabel('trial')
title(sprintf('subject %s posteriors - truth',subject))
colorbar;

c(2) = subplot(2,2,2);
imagesc(times,1:nRows,respost);
xlabel('time (ms)')
ylabel('trial')
title(sprintf('subject %s posteriors - JLR results',subject))
colorbar;

c(3) = subplot(2,2,3);
imagesc(times,1:nRows,diffpost);
xlabel('time (ms)')
ylabel('trial')
title(sprintf('subject %s posteriors - (results-truth)',subject))
colorbar;

subplot(2,2,4);
saccadeTimes = load('../Data/SQ-6/SQ-6-AllSaccadesToObject.mat');
ps.saccadeTimes = saccadeTimes.target_saccades_end;
posteriors1 = computeSaccadeJitterPrior(times,ps);
ps.saccadeTimes = saccadeTimes.distractor_saccades_end;
posteriors0 = computeSaccadeJitterPrior(times,ps);
if size(posteriors1,2)<size(posteriors0,2)
    posteriors0 = posteriors0(:,1:size(posteriors1,2));
elseif size(posteriors1,2)>size(posteriors0,2)
    posteriors1 = posteriors1(:,1:size(posteriors0,2));
end
posteriors = [posteriors0;posteriors1];
diffpost_saccades = nan(size(posteriors));
for l=1:nRows
    iNon0 = find(posteriors(l,:)~=0);
    diffpost_saccades(l,1:numel(iNon0)) = diffpost(l,iNon0);    
end
% crop out zero columns
diffpost_saccades = diffpost_saccades(:,1:find(sum(~isnan(diffpost_saccades)),1,'last'));
imagesc(diffpost_saccades);
xlabel('saccade #')
ylabel('trial')
nCorrect = nansum(nansum(abs(diffpost_saccades),2)==0);
title(sprintf('results-truth at saccade times (%d/%d=%.1f%% trials perfect)',nCorrect,nRows,nCorrect/nRows*100))
colorbar
clear posteriors* ps saccadeTimes l iNon0
    
linkaxes(c)