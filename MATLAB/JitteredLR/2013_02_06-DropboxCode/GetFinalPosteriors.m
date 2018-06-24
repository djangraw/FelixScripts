function pt = GetFinalPosteriors(subject, weightornoweight, startorend, crossval, suffix)

% Put the posterior distributions of jittered logistic regression results
% into a cell array.
%
% pt = GetFinalPosteriors(subject, resultsfile, startorend)
%
% INPUTS:
% -subject is a string indicating the name of the folder containing the 
% data, up through the subject number (the data folder, the data filenames,
% and the results folders must share this string in the formats described
% in the code).
% -weightornoweight is a string indicating whether priors should be 
% weighted by the number of trials in each set ('weight' or 'noweight').
% -startorend is a string indicating whether you want the results using the
% saccade start time ('start') or the saccade end time ('end') as time t=0.
% -crossval is a string indicating the type of cross validation used ('loo'
% or 'xxfold', where xx is an integer).
% -suffix is a string indicating other information included in the folder
% name, such as 'jrange_0_to_500'.
%
% OUTPUTS:
% -pt is a cell array of matrices containing the posterior distributions
% over time.  Indices of pt are {LOOtrial, time}, indices of pt{i,j} are 
% [trial, TrainingWindowOffset].
%
% Created 6/15/11 by DJ - incomplete.
% Updated 6/20/11 by DJ - comments.
% Updated 8/31/11 by DJ - new inputs for new filenames
% Updated 9/12/11 by DJ - added removeBaselineYVal option
% Updated 9/14/11 by DJ - added forceOneWinner option
% Updated 9/21/11 by DJ - get options from pop_settings struct in results file
% Updated 10/4/11 by DJ - added useSymmetricLikelihood option
% Updated 10/7/11 by DJ - debugged, disabled removeBaselineYVal option

% load results
load(['results_' subject '_' startorend 'Saccades_' weightornoweight 'prior_' crossval '_' suffix '/results_' crossval]); % Azloo, jitterrange, p, testsample, trainingwindowlength, trainingwindowoffset, truth, vout, pop_settings_out
if strfind(startorend,'allToObject')
    saccadeTimes = load(['../Data/' subject '/' subject '-AllSaccadesToObject.mat']); % saccadeTimes.distractor_saccades_start/_end, target_saccades_start/_end
elseif strfind(startorend,'toObject')
    saccadeTimes = load(['../Data/' subject '/' subject '-SaccadeToObject.mat']); % saccadeTimes.distractor_saccades_start/_end, target_saccades_start/_end
else
    saccadeTimes = load(['../Data/' subject '/' subject '-SaccadeTimes.mat']); % saccadeTimes.distractor_saccades_start/_end, target_saccades_start/_end
end
% load eeglab structs
ALLEEG(1) = pop_loadset('filepath',['../Data/',subject],'filename',[subject,'-distractorappear.set'],'loadmode','all');
ALLEEG(2) = pop_loadset('filepath',['../Data/',subject],'filename',[subject,'-targetappear.set'],'loadmode','all');

% convert to variables used by run_ and pop_ so that we can use our copied/pasted code
truth_trials = truth;
global weightprior;
weightprior = strcmp(weightornoweight,'weight');
setlist = [1 2];
chansubset = 1:ALLEEG(1).nbchan;
ntrials1 = ALLEEG(setlist(1)).trials;
ntrials2 = ALLEEG(setlist(2)).trials;
jitterrange = pop_settings_out(1).jitterrange;
truth=[zeros((diff(jitterrange)+trainingwindowlength)*ntrials1,1); ...
    ones((diff(jitterrange)+trainingwindowlength)*ntrials2,1)];

% compute priors
if strfind(startorend,'start')    
        saccadeTimes1 = saccadeTimes.distractor_saccades_start; % or use end times
        saccadeTimes2 = saccadeTimes.target_saccades_start;
elseif strfind(startorend,'end')
        saccadeTimes1 = saccadeTimes.distractor_saccades_end; % or use end times
        saccadeTimes2 = saccadeTimes.target_saccades_end;
else
    error('startorend must contain ''start'' or ''end''!');
end

% Ensure the saccadeTime cell arrays are row vectors
if size(saccadeTimes1,1) ~= 1; saccadeTimes1 = saccadeTimes1'; end;
if size(saccadeTimes2,1) ~= 1; saccadeTimes2 = saccadeTimes2'; end;
saccadeTimes = [saccadeTimes1,saccadeTimes2];

% Set up JitterPrior struct
jitterPrior = [];
    jitterPrior.fn = @computeSaccadeJitterPrior;
    jitterPrior.params = [];
    jitterPrior.params.saccadeTimes = saccadeTimes;

% Calculate prior    
ptprior = jitterPrior.fn((1000/ALLEEG(setlist(1)).srate)*(jitterrange(1):jitterrange(2)),jitterPrior.params);
if size(ptprior,1) == 1
    % Then the prior does not depend on the trial
    ptprior = ptprior/sum(ptprior);
    ptprior = repmat(ptprior,ntrials1+ntrials2,1);
else
    % Ensure the rows sum to 1
    ptprior = ptprior./repmat(sum(ptprior,2),1,size(ptprior,2));
end

% Re-weight priors according to the number of trials in each class
if weightprior
    ptprior(truth_trials==1,:) = ptprior(truth_trials==1,:) / sum(truth_trials==1);
    ptprior(truth_trials==0,:) = ptprior(truth_trials==0,:) / sum(truth_trials==0);
end
  
% Extract data
raweeg1 = ALLEEG(setlist(1)).data(chansubset,:,:);
raweeg2 = ALLEEG(setlist(2)).data(chansubset,:,:);

pt = cell(length(testsample),length(trainingwindowoffset)); % initialize
for i=1:length(testsample)
    fprintf('Sample %d of %d...\n',i,length(testsample));
    for j=1:length(trainingwindowoffset) % For each training window   
        v = vout{i}(j,:);
        % Put de-jittered data into [D x (N*T] matrix for input into logist
        x = AssembleData(raweeg1,raweeg2,trainingwindowoffset(j),trainingwindowlength,jitterrange);

        % Get y values
        y = x*v(1:end-1)' + v(end); % calculate y values given these weights 
        
        % Remove baseline y-value by de-meaning
        if pop_settings_out(1).removeBaselineYVal
            y2 = y - mean(y);
            null_mu2 = pop_settings_out(1).null_mu-mean(y);
        else
            y2 = y; 
            null_mu2 = pop_settings_out(1).null_mu;
        end
        
        % Get posterior
        pt{i,j} = ComputePosterior(ptprior,y2,truth,trainingwindowlength,...
            pop_settings_out(1).forceOneWinner,pop_settings_out(1).conditionPrior,null_mu2, pop_settings_out(1).null_sigma);
    end
end
disp('Success!')

end % function GetFinalPosteriors
    
    
% FUNCTION AssembleData:
% Put de-jittered data into [(N*T) x D] matrix for input into logist
function x = AssembleData(data1,data2,thistrainingwindowoffset,trainingwindowlength,jitterrange) 
    % Declare constants
    iwindow = (thistrainingwindowoffset+jitterrange(1)) : (thistrainingwindowoffset+jitterrange(2)+trainingwindowlength-1);
    
    x = cat(3,data1(:,iwindow,:),data2(:,iwindow,:));
    x = reshape(x,[size(x,1),size(x,3)*length(iwindow)])';

end % function AssembleData

% FUNCTION ComputePosterior:
% Use the priors, y's and truth values to calculate the posteriors
function [posterior,likelihood] = ComputePosterior(prior, y, truth, trainingwindowlength,forceOneWinner,conditionPrior,null_mu,null_sigma)
    % put y and truth into matrix form 
    ntrials = size(prior,1);
    ymat = reshape(y,length(y)/ntrials,ntrials)';
    truthmat = reshape(truth,length(truth)/ntrials,ntrials)';
    
    % calculate likelihood
    yavg = zeros(size(prior));
    likelihood = ones(size(prior));
    for i=1:size(prior,2)
        iwindow = (1:trainingwindowlength)+i-1;
        yavg(:,i) = mean(ymat(:,iwindow),2);
        likelihood(:,i) = bernoull(truthmat(:,i),yavg(:,i));    
    end
    
    if conditionPrior
        condprior = (1-normpdf(yavg,null_mu,null_sigma)/normpdf(0,0,null_sigma)).*prior; % prior conditioned on y (p(t|y))
        condprior = condprior./repmat(sum(condprior,2),1,size(condprior,2)); % normalize so each trial sums to 1
    else
        condprior = prior;
    end
       
    % calculate posterior
    posterior = likelihood.*condprior;
%     end

    % If requested, make all posteriors 0 except max
    if forceOneWinner
        [~,iMax] = max(posterior,[],2); % finds max posterior on each trial (takes first one if there's a tie)
        posterior = full(sparse(1:size(posterior,1),iMax,1,size(posterior,1),size(posterior,2))); % zeros matrix with 1's at the iMax points in each row
    else    
        % normalize rows
        posterior = posterior./repmat(sum(posterior,2),1,size(posterior,2));
    end
    
    % Re-weight priors according to the number of trials in each class
    global weightprior;
    if weightprior
        posterior(truthmat(:,1)==1,:) = posterior(truthmat(:,1)==1,:) / sum(truthmat(:,1)==1);
        posterior(truthmat(:,1)==0,:) = posterior(truthmat(:,1)==0,:) / sum(truthmat(:,1)==0);
    end
    
    
end % function ComputePosterior