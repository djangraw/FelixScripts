function [pt, truth_trials, times, jitter] = GetFinalPosteriors_gaussian(foldername,cvmode,subject)

% Put the posterior distributions of jittered logistic regression results
% into a cell array.
%
% pt = GetFinalPosteriors_gaussian(foldername,cvmode,subject)
%
% INPUTS:
% -foldername is a string indicating the folder in which the JLR results
% reside.
% -cvmode is a string indicating the cross-validation mode you used (e.g.,
% '10fold','loo').
% -subject is a string indicating the subject id name/number.
%
% OUTPUTS:
% -pt is a cell array of matrices containing the posterior distributions
% over time.  Indices of pt are {LOOtrial, time}, indices of pt{i,j} are 
% [trial, TrainingWindowOffset].
%
% Created 8/16/12 by DJ based on GetFinalPosteriors.mat
% Updated 8/20/12 by DJ - made specific to facecar data

% load results
load([foldername '/results_' cvmode '.mat']); % Azloo, jitterrange, p, testsample, trainingwindowlength, trainingwindowoffset, truth, vout, pop_settings_out

% Load data for given subject
% [ALLEEG,~,setlist] = loadSubjectData_oddball(subject); % eeg info and saccade info
[ALLEEG,~,setlist] = loadSubjectData_facecar(subject); % eeg info and saccade info

% Response-lock data
RT1 = getRT(ALLEEG(setlist(1)),'RT');%,200);
RT2 = getRT(ALLEEG(setlist(2)),'RT');%,150);
tWindow(1) = (ALLEEG(setlist(1)).times(1) - min([RT1 RT2]))/1000;
tWindow(2) = (ALLEEG(setlist(1)).times(end) - max([RT1 RT2]))/1000;
ALLEEG(setlist(1)) = pop_epoch(ALLEEG(setlist(1)),{'RT'},tWindow);
ALLEEG(setlist(2)) = pop_epoch(ALLEEG(setlist(2)),{'RT'},tWindow);
jitter = -[RT1 RT2] + mean([RT1 RT2]);

% convert to variables used by run_ and pop_ so that we can use our copied/pasted code
truth_trials = truth;
global weightprior;
weightprior = strcmp(pop_settings_out(1).weightprior,'weight');
setlist = [1 2];
chansubset = 1:ALLEEG(1).nbchan;
ntrials1 = ALLEEG(setlist(1)).trials;
ntrials2 = ALLEEG(setlist(2)).trials;
jitterrange = pop_settings_out(1).jitterrange;
truth=[zeros((diff(jitterrange)+trainingwindowlength)*ntrials1,1); ...
    ones((diff(jitterrange)+trainingwindowlength)*ntrials2,1)];
times = (1000/ALLEEG(setlist(1)).srate)*(jitterrange(1):jitterrange(2));

% Set up JitterPrior struct
jitterPrior = [];
    jitterPrior.fn = @computeJitterPrior_gaussian;
    jitterPrior.params = [];
    jitterPrior.params.mu = 0;
    jitterPrior.params.sigma = std([RT1 RT2]);
    jitterPrior.params.nTrials = ALLEEG(setlist(1)).trials + ALLEEG(setlist(2)).trials;

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
%         v = evalin('base','v')'; % TEMP!\

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