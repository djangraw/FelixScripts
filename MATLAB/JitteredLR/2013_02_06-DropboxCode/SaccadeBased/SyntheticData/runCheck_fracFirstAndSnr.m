function runCheck_fracFirstAndSnr(fracFirst,SNR_parallel,SNR_orthogonal,sigmamultiplier)

% Synthesize data, run it through Jittered LR, and compare results with
% the parameters used to produce the data (use plotCheck_... for this).
%
% runCheck_fracFirstAndSnr(fracFirst,SNR_parallel,SNR_orthogonal)
%
% NOTE: must be in JLR code directory to run properly.
%
% Created 9/22/11 by DJ.
% Updated 9/23/11 by DJ.
% Updated 11/23/11 by DJ - made function, separated out run and plot
% Updated 12/12/11 by DJ - added sigmamultiplier option
% Updated 12/13/11 by DJ - added waitbar

%% Set up
if nargin<1 || isempty(fracFirst)
    fracFirst = 0:0.2:1;
end
if nargin<2 || isempty(SNR_parallel)
    SNR_parallel = [0.01 0.1 1 Inf];
end
if nargin<3 || isempty(SNR_orthogonal)
    SNR_orthogonal = [0.01 0.1 1 Inf];
end
if nargin<4 || isempty(sigmamultiplier)
    sigmamultiplier = [.2 .5 1 2 5];
end

% clear start* res* diff*
[startpost, respost, diffpost, startweights, resweights, resfm, Azloo, weightSubspace, pctPostCorrect, postMeanSqErr] = ...
    deal(cell(numel(fracFirst),numel(SNR_parallel),numel(SNR_orthogonal),numel(sigmamultiplier)));

scope_settings.trainingwindowlength = 13;
scope_settings.trainingwindowinterval = 6;
scope_settings.trainingwindowrange = [0 0];

%% Run everything
% Set up waitbar
iRun = 0;
nRuns = numel(sigmamultiplier)*numel(SNR_orthogonal)*numel(SNR_parallel)*numel(fracFirst);
hWait = waitbar(0,'Running...');
% Run analysis
for l=1:numel(sigmamultiplier)
    for k=1:numel(SNR_orthogonal)
        for j=1:numel(SNR_parallel)
            if isinf(SNR_orthogonal(k)) && isinf(SNR_parallel(j)), continue; end
            for i=1:numel(fracFirst)
                % Update waitbar
                iRun = iRun + 1;
                waitbar(iRun/nRuns,hWait,sprintf('sigmamult = %g, SNR_o = %g, SNR_p = %g, fracFirst = %g',...
                    sigmamultiplier(l),SNR_orthogonal(k),SNR_parallel(j),fracFirst(i)));
                
                % make synthetic data
                [ALLEEG, EEG, a] = SaveSyntheticData(2,fracFirst(i),SNR_parallel(j),SNR_orthogonal(k));
                % Run JLR
                run_logisticregression_jittered_EM_saccades_wrapper('3DS-TAG-2-synth','allToObject_end',0,'10fold',[0 500],sigmamultiplier(l));

                % Posteriors
                pt = GetFinalPosteriors('3DS-TAG-2-synth','noweight','allToObject_end','10fold','jrange_0_to_500');

                % Tease out results of interest
                iTime = 1; %22;
                startpost{i,j,k,l} = [a.posteriors2; a.posteriors1];
                respost{i,j,k,l} = pt{1,iTime};
                diffpost{i,j,k,l} = respost{i,j,k,l} - startpost{i,j,k,l};

                res = load('results_3DS-TAG-2-synth_allToObject_endSaccades_noweightprior_10fold_jrange_0_to_500/results_10fold.mat');            
                startweights{i,j,k,l} = a.weights;
                resweights{i,j,k,l} = res.vout{1}(iTime,1:end-1);
                % fwd model
                resfm{i,j,k,l} = res.fwdmodels{1}(:,iTime);

    %             %%% USE THIS CODE TO APPLY TRUE WEIGHTS TO DATA (A BASELINE)
    %             [Az,post] = applySolution(fliplr(ALLEEG),[a.weights', 0],[a.posteriors2;a.posteriors1],scope_settings);
    %             respost{i,j,k,l} = post;
    %             diffpost{i,j,k,l} = respost{i,j,k,l} - startpost{i,j,k,l};
    %             resweights{i,j,k,l} = a.weights';
    %             Azloo{i,j,k,l} = Az;           
    %             %%% END

                % calculate FOMs
                Azloo{i,j,k,l} = res.Azloo; % 10-fold Az
                weightSubspace{i,j,k,l} = subspace(startweights{i,j,k,l},resweights{i,j,k,l}'); % angle between actual and recovered weights
                if sum(startweights{i,j,k,l}.*resweights{i,j,k,l}')<0 % if the vectors are pointing in opposite directions...
                    weightSubspace{i,j,k,l}  = pi - weightSubspace{i,j,k,l}; % then a small subspace is bad.
                end
                pctPostCorrect{i,j,k,l} = nansum(nansum(abs(diffpost{i,j,k,l}),2)==0)/size(diffpost{i,j,k,l},1)*100; % percent of trials whose posteriors were recovered perfectly

            end
        end
    end
end
try close(hWait); end

%% Get mean squared error of posteriors
saccadeTimes = load('../Data/3DS-TAG-2-synth/3DS-TAG-2-synth-AllSaccadesToObject.mat');
nCols = size(startpost{1},2);
times = (0:nCols-1)*4;
ps.saccadeTimes = saccadeTimes.target_saccades_end;
posteriors1 = computeSaccadeJitterPrior(times,ps);
ps.saccadeTimes = saccadeTimes.distractor_saccades_end;
posteriors0 = computeSaccadeJitterPrior(times,ps);
posteriors = [posteriors0;posteriors1];
for l=1:numel(sigmamultiplier)
    for k=1:numel(SNR_orthogonal)
        for j=1:numel(SNR_parallel)
            if isinf(SNR_orthogonal(k)) && isinf(SNR_parallel(j)), continue; end
            for i=1:numel(fracFirst)
                postMeanSqErr{i,j,k,l} = nansum(diffpost{i,j,k,l}(:).^2)/nansum(posteriors(:)~=0);
            end
        end
    end
end
clear posteriors* ps saccadeTimes n* times

%% SAVE INFO
disp('Saving results...')
params = load('results_3DS-TAG-2-synth_allToObject_endSaccades_noweightprior_10fold_jrange_0_to_500/params_10fold.mat');
params = rmfield(params,{'ALLEEG','setlist','chansubset'});
save fracfirstresults_last *weights *post *fm fracFirst SNR* sigmamultiplier Azloo weightSubspace pctPostCorrect postMeanSqErr params ALLEEG
disp('...Success!')

%% PLOT
disp('Plotting first results...')
plotCheck_fracFirstAndSnr('fracfirstresults_last',fracFirst(1),SNR_parallel(1),SNR_orthogonal(1),sigmamultiplier(1));
disp('...Done!')
