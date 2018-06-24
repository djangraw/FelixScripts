% TEMP_TestWithTrueWeights.m
function TEMP_TestWithTrueWeights(x,ptprior,truth,pop_settings,ALLEEG,nully)

plotbinolike = 1;

    convergencethreshold = 0.0100;
             jitterrange = [-500 500];
             weightprior = 0;
          forceOneWinner = 0;
          conditionPrior = 0;
    null_sigmamultiplier = 1;
            binomialLike = 0;
priortimes = jitterrange(1):jitterrange(2);

UnpackStruct(pop_settings) %weightprior,forceOneWinner,conditionPrior,binomialLike
if nargin<6
    nully = [];
end


% Retrieve weights
subject = ALLEEG(1).setname(1:find(ALLEEG(1).setname=='_',1)-1);
[LRstim LPstim] = LoadJlrResults(subject,0,'10fold',[0 0],'_stimlocked_lambda1e+00_v2p3_condoff2');
LRavg = AverageJlrResults(LRstim,LPstim);
v = LRavg.vout;
tStim = LPstim.ALLEEG(1).times(LPstim.trainingwindowoffset + round(LPstim.scope_settings.trainingwindowlength/2));

% Apply weights
y = x*v(1:end-1) + v(end); % calculate y values given these weights
[pt,lkhd] = ComputePosterior(ptprior,y,truth,weightprior,forceOneWinner,conditionPrior,nully,binomialLike);

if plotbinolike
            
    % Get the true jitter (for plotting)
    [jitter,fooTruth] = GetJitter(ALLEEG,'facecar');
    faces = find(fooTruth==1);
    cars = find(fooTruth==0);
    ntrials = length(fooTruth);
    clear fooTruth

    % PLOT!
    figure(199); clf;
    ymat = reshape(y,length(y)/ntrials,ntrials)';
    subplot(2,2,1);
    ImageSortedData(ymat(cars,:),priortimes,1:numel(cars),jitter(cars));
    ImageSortedData(ymat(faces,:),priortimes,numel(cars)+(1:numel(faces)),jitter(faces));
    title('y values')
    xlabel('time (ms)')
    ylabel('<-- cars    |    faces -->')
    axis([-500 500 0 ntrials])
    colorbar;

    subplot(2,2,2);
    ImageSortedData(lkhd(cars,:),priortimes,1:numel(cars),jitter(cars));
    ImageSortedData(lkhd(faces,:),priortimes,numel(cars)+(1:numel(faces)),jitter(faces));
    title('likelihood')
    xlabel('time (ms)')
    ylabel('<-- cars    |    faces -->')
    axis([-500 500 0 ntrials])
    colorbar;

    subplot(2,2,3)
    topoplot(v(1:end-1),ALLEEG(2).chanlocs);
    title(sprintf('Stim-locked weight vector (raw)\n (bias = %0.2g)(t=%gs)',v(end),tStim))
    colorbar;

    subplot(2,2,4);
    ImageSortedData(pt(cars,:),priortimes,1:numel(cars),jitter(cars));
    ImageSortedData(pt(faces,:),priortimes,numel(cars)+(1:numel(faces)),jitter(faces));
    set(gca,'clim',[0 0.05])
    title('posterior')
    xlabel('time (ms)')
    ylabel('<-- cars    |    faces -->')
    axis([-500 500 0 ntrials])
    colorbar;
    pause(0.1);
end





%%%%%%%%% SUB-FUNCTIONS! %%%%%%%%%%%%%%


function [posterior,likelihood] = ComputePosterior(prior, y, truth,weightprior,forceOneWinner,conditionPrior,nully,binomialLike)
    % Put y and truth into matrix form 
    ntrials = size(prior,1);
    ymat = reshape(y,length(y)/ntrials,ntrials)';
    truthmat = reshape(truth,length(truth)/ntrials,ntrials)';
    truthsign = (truthmat-0.5)*2;
    % Calculate likelihood
    likelihood = bernoull(truthmat,ymat);
    
    % Binomial-based likelihod calculation
%     binomialLike = true;
    if binomialLike
        [L2, L3] = deal(zeros(size(likelihood)));
        for j=1:size(likelihood,2)% for each time point
%             [~,order] = sort(ymat(:,j).*truthsign(:,j),'descend');    
% %             [~,order] = sort(likelihood(:,j),'descend');    
%             L2(order,j) = 1:ntrials; % Rank of each trial within likelihood(:,j)
%             L3(:,j) = 1-binocdf(L2(:,j)-1,ntrials,50*prior(1,j));        
            L3(:,j) = 1-binocdf(ceil((1-likelihood(:,j))*ntrials-1),ntrials,50*prior(1,j)); % New Likelihood based on binomial distribution
        end   
        likelihood = L3;
    end
        
    % Condition prior on y value: more extreme y values indicate more informative time points
    if conditionPrior % (NOTE: normalization not required, since we normalize later)
%         condprior = (1-normpdf(ymat,nully.mu,nully.sigma*nully.sigmamultiplier)/normpdf(0,0,nully.sigma*nully.sigmamultiplier)).*prior; % prior conditioned on y (p(t|y))    
        condprior = (1-normpdf(ymat,nully.mu,nully.sigma*nully.sigmamultiplier)/normpdf(0,0,nully.sigma*nully.sigmamultiplier)).*prior; % prior conditioned on y (p(t|y))    
%         additiveConst = 1.5;
%         condprior = additiveConst-exp(-(ymat-nully.mu).^2./(2*nully.sigma*nully.sigmamultiplier^2));
    else
        condprior = prior;
    end
    condprior = condprior./repmat(sum(condprior,2),1,size(condprior,2));
    
    % Calculate posterior
    posterior = likelihood.*condprior;
    % If requested, make all posteriors 0 except max
    if forceOneWinner
        [~,iMax] = max(posterior,[],2); % finds max posterior on each trial (takes first one if there's a tie)
        posterior = full(sparse(1:size(posterior,1),iMax,1,size(posterior,1),size(posterior,2))); % zeros matrix with 1's at the iMax points in each row
    end
    % Normalize rows
    posterior = posterior./repmat(sum(posterior,2),1,size(posterior,2));
    % Re-weight priors according to the number of trials in each class
    if weightprior
        posterior(truthmat(:,1)==1,:) = posterior(truthmat(:,1)==1,:) / sum(truthmat(:,1)==1);
        posterior(truthmat(:,1)==0,:) = posterior(truthmat(:,1)==0,:) / sum(truthmat(:,1)==0);
    end

end % function ComputePosterior

end