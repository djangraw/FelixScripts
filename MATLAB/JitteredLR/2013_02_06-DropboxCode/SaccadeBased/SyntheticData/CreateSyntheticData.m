function [data1,data2,weights,posteriors1,posteriors2] = CreateSyntheticData(saccadeTimes,jitterrange,EEGtimes,nElectrodes,fracFirstSaccade,halfWidth,SNR_parallel,SNR_orthogonal)

% Creates a synthetic dataset 
%
% [data,weights,posteriors] =
% CreateSyntheticData(saccadeTimes,jitterrange,EEGtimes,nElectrodes,fracFirstSaccade)
%
% INPUTS:
% -saccadeTimes is a struct...
% -jitterrange is a 2-element vector...
% -EEGtimes is a vector...
% -nElectrodes is a scalar...
% -fracFirstSaccade (optional) is a scalar...
% -halfWidth (optional) is a scalar...
% -SNR (optional) is a scalar...
%
% OUTPUTS:
% - data1 is the synthetic dataset for EEG dataset 1 (as defined in
% BigSaccade).
% - data2 is the synthetic dataset for EEG dataset 2.
% - weights is the set of spatial weights used to create the synthetic
% data.
% - posteriors1 is the set of posterior weights used to create data1.
% - posteriors2 is the set of posterior weights used to create data2.
%
% Created 8/30/11 by DJ.
% Updated 9/6/11 by DJ - added option to make first saccades dominate prior
% Updated 9/7/11 by DJ - bug fix
% Updated 9/22/11 by DJ - added SNR option
% Updated 9/23/11 by DJ - SNR_parallel and SNR_orthogonal
% Updated 10/18/11 by DJ - cleanup, each elec independent in orthog noise

if nargin<5 || isempty(fracFirstSaccade)
    usePeakyPriors = false;
else
    usePeakyPriors = true;
end
if nargin<6
    halfWidth = 6;
end
if nargin<7
    SNR_parallel = Inf;
end
if nargin<8
    SNR_orthogonal = Inf;
end


% Set up
nSamples = numel(EEGtimes);
sampletime = EEGtimes(2)-EEGtimes(1); % duration of each sample (ms)
t = sampletime*(jitterrange(1):jitterrange(2)); % vector of times in jitter range
nTrials1 = numel(saccadeTimes.target_saccades_end); % number of target trials
nTrials2 = numel(saccadeTimes.distractor_saccades_end); % number of distractor trials
% Find standard priors
params.saccadeTimes = saccadeTimes.target_saccades_end;
posteriors1 = computeSaccadeJitterPrior(t,params);
params.saccadeTimes = saccadeTimes.distractor_saccades_end;
posteriors2 = computeSaccadeJitterPrior(t,params);


%% POSTERIORS

if usePeakyPriors
    % Randomly choose posteriors
    nTrials = size(posteriors1,1);
    nFirst = floor(nTrials*fracFirstSaccade);
    useFirst = [ones(1,nFirst), zeros(1,nTrials-nFirst)];
    useFirst = useFirst(randperm(length(useFirst))); % scramble
    for i=1:nTrials
        trialSaccades = find(posteriors1(i,:)); % find saccades
        posteriors1(i,trialSaccades) = 0;
        if useFirst(i) || numel(trialSaccades)==1 % choose first saccade
            posteriors1(i,trialSaccades(1)) = 1;
        else % choose some other saccade
            posteriors1(i,trialSaccades(1+randi(numel(trialSaccades)-1))) = 1;
        end
    end
    
    % Do same for distractors
    nTrials = size(posteriors2,1);
    nFirst = floor(nTrials*fracFirstSaccade);
    useFirst = [ones(1,nFirst), zeros(1,nTrials-nFirst)];
    useFirst = useFirst(randperm(length(useFirst))); % scramble
    for i=1:nTrials
        trialSaccades = find(posteriors2(i,:)); % find saccades
        posteriors2(i,trialSaccades) = 0;
        if useFirst(i) || numel(trialSaccades)==1 % choose first saccade
            posteriors2(i,trialSaccades(1)) = 1;
        else % choose some other saccade
            posteriors2(i,trialSaccades(1+randi(numel(trialSaccades)-1))) = 1;
        end
    end
    
    
else    
    % Create random posteriors
    for i=1:size(posteriors1,1) % for each trial
        trialSaccades = find(posteriors1(i,:)); % find saccades
        randPost = rand(1,numel(trialSaccades)); % select posteriors randomly
        posteriors1(i,trialSaccades) = randPost/sum(randPost); % normalize to 1    
    end
    for i=1:size(posteriors2,1) % for each trial
        trialSaccades = find(posteriors2(i,:)); % find saccades
        randPost = rand(1,numel(trialSaccades)); % select posteriors randomly
        posteriors2(i,trialSaccades) = randPost/sum(randPost); % normalize to 1
    end
end


%% SIGNAL

% create random set of weights
weights = rand(nElectrodes,1);
weights = weights/norm(weights); % normalize to have a norm of 1

% create resulting data
data1 = single(zeros(nElectrodes,nSamples,nTrials1));
iTimes1 = find(EEGtimes>=t(1),1)-1 + (1:size(posteriors1,2));
for i=1:nTrials1
    sacSpots1 = find(posteriors1(i,:)~=0);
    for j=1:numel(sacSpots1)
        data1(:,iTimes1(sacSpots1(j))+(-halfWidth:halfWidth),i) = repmat(weights*posteriors1(i,sacSpots1(j)),1,2*halfWidth+1);
    end
%     data1(:,iTimes1,i) = weights*posteriors1(i,:);
end
data2 = single(zeros(nElectrodes,nSamples,nTrials2));
iTimes2 = find(EEGtimes>=t(1),1)-1 + (1:size(posteriors2,2));
for i=1:nTrials2
    sacSpots2 = find(posteriors2(i,:)~=0);
    for j=1:numel(sacSpots2)
        data2(:,iTimes2(sacSpots2(j))+(-halfWidth:halfWidth),i) = repmat(-weights*posteriors2(i,sacSpots2(j)),1,2*halfWidth+1);
    end
%     data2(:,iTimes2,i) = -weights*posteriors2(i,:);
end

%% NOISE

% orthogonal noise
% onoise1 = single(zeros(nElectrodes,nSamples,nTrials1));
% onoise2 = single(zeros(nElectrodes,nSamples,nTrials2));
% nNoises = nElectrodes; % number of randomly-chosen noise sources
% noiseweights = cell(1,nNoises);
% for i=1:nNoises
%     noise_orig = rand(nElectrodes,1); % start with randomly selected weights
%     noise_orthog = noise_orig - weights*(weights'*noise_orig)/(weights'*weights); % project out component parallel to signal
%     noiseweights{i} = noise_orthog/norm(noise_orthog); % make a component with a norm of 1    
%     for j=1:nTrials1
%         timecourse = randn(1,nSamples);
%         onoise1(:,:,j) = onoise1(:,:,j) + noiseweights{i}*timecourse;
%     end
%     for j=1:nTrials2
%         timecourse = randn(1,nSamples);
%         onoise2(:,:,j) = onoise2(:,:,j) + noiseweights{i}*timecourse;
%     end
% end
% 
% % scale to proper SNR
% onoise1 = onoise1/sqrt(mean(onoise1(:).^2)/mean(data1(data1(:)~=0).^2)*SNR_orthogonal);
% onoise2 = onoise2/sqrt(mean(onoise2(:).^2)/mean(data2(data2(:)~=0).^2)*SNR_orthogonal);

% Create random noise timecourses
onoise1 = single(randn(size(data1)));
onoise2 = single(randn(size(data2)));
% Scale each electrode to proper SNR
for i=1:nElectrodes
    onoise1(i,:,:) = onoise1(i,:,:)/sqrt(mean(mean(onoise1(i,:,:).^2))/mean(mean(data1(i,:,:).^2))*SNR_orthogonal);
    onoise2(i,:,:) = onoise2(i,:,:)/sqrt(mean(mean(onoise2(i,:,:).^2))/mean(mean(data2(i,:,:).^2))*SNR_orthogonal);
end

% parallel noise
pnoise1 = single(zeros(nElectrodes,nSamples,nTrials1));
pnoise2 = single(zeros(nElectrodes,nSamples,nTrials2));
for j=1:nTrials1
    timecourse = randn(1,nSamples);
    pnoise1(:,:,j) = pnoise1(:,:,j) + weights*timecourse;
end
for j=1:nTrials2
    timecourse = randn(1,nSamples);
    pnoise2(:,:,j) = pnoise2(:,:,j) + weights*timecourse;
end
% scale to proper SNR
pnoise1 = pnoise1/sqrt(mean(pnoise1(:).^2)/mean(data1(data1(:)~=0).^2)*SNR_parallel);
pnoise2 = pnoise2/sqrt(mean(pnoise2(:).^2)/mean(data2(data2(:)~=0).^2)*SNR_parallel);

% add noise to signaL
data1 = data1 + onoise1 + pnoise1;
data2 = data2 + onoise2 + pnoise2;
  
% % Add Gaussian Noise
% data1 = data1 + randn(size(data1));
% data2 = data2 + randn(size(data2));


