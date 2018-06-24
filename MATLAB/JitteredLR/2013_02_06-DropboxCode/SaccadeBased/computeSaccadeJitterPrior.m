function [pdf,extended_t] = computeSaccadeJitterPrior(t, params)

% This function returns the prior matrix using saccade times selected with
% the given parameters.
%
% pdf = computeSaccadeJitterPrior(t, params)
% 
% If any saccades are within the time range t, they are each weighted 
% equally.  If there are no saccades in this range, the first saccade after
% this range is given weight 1.
%
% INPUTS:
% - t is a T-element vector indicating the times of EEG data available
%   (i.e the acceptable jitter times).
% - params is a struct (currently created in run_logisticregression_jittered_EM_saccades.m)
%   with field:
%    > saccadeTimes, an N-element vector of cells (N = # trials).  Each cell
%    contains all the saccade times on that trial.
%
% OUTPUTS:
% - pdf is an MxT matrix (where M>=N), in which pdf(i,j) is the prior 
% probability that the discriminating activity in trial i is locked to time 
% extended_t(j).  Each row of pdf will therefore sum to 1.
% - extended_t is an M-element vector that takes the t input vector and
% extends it just enough to include every 'first saccade after this range'
% as described above.
%
% Created 5/12/11 by BC.
% Updated 8/3/11 by DJ - extend pdf for trials with no saccades in t range
% Updated 9/24/12 by DJ - only extend pdf, don't crop it
% Updated 9/25/12 by DJ - special case for length(t)==1

% special case
if length(t)==1    
    warning('JLR:computeSaccadeJitterPrior','input t is only one value long!')
    pdf = ones(length(params.saccadeTimes),1);
    extended_t = t;
    return
end
    

% Extract info
saccadeTimes = params.saccadeTimes;
min_t = min(t);
max_t = max(t);

% create extended pdf matrix
maxSaccadeTime = max([saccadeTimes{:}]);
diff_t = t(2)-t(1); % assume constant sampling rate
extended_t = [t, (max_t+diff_t):diff_t:maxSaccadeTime];
pdf = zeros(length(saccadeTimes),length(extended_t)); % make it big - we'll crop it down at the end

for j=1:length(saccadeTimes) % for each trial
    currSaccades = saccadeTimes{j}; % saccades in this trial

    % First off, remove saccades that fall outside the range of timepoints
    locsremove = union(find(currSaccades<min_t),find(currSaccades>max_t));
    currSaccades(locsremove) = [];
    % how many acceptable saccades were found?
    numsaccades = length(currSaccades);
    
    if numsaccades==0 % if there are no saccades in the acceptable window, use the first saccade after that window.
        currSaccades = saccadeTimes{j};
        currSaccades = currSaccades(find(currSaccades>max_t,1));
        numsaccades = 1;
    end
    
    
    % Assign prior weights equally among the saccades in the acceptable range
    pdfwts = repmat(1/numsaccades,numsaccades,1);
    
    % Now for each saccade time, we need to find the closest timepoint in
    % the time vector and assign it the proper weight
    for k=1:numsaccades
        [~,pdfpt] = min(abs(extended_t-currSaccades(k))); % find closest time point
        pdf(j,pdfpt) = pdfwts(k); % assign it the proper weight
    end
end

% crop pdf back down as much as possible
iLast = max([find(sum(pdf,1)>0,1,'last'), length(t)]); % only extend, don't crop
pdf = pdf(:,1:iLast); % delete all columns after last non-zero column
extended_t = extended_t(1:size(pdf,2)); % crop to fit size of pdf
