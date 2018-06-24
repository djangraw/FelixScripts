% TEMP_AdjustMse
% Adjust MSE so it's /N and not /(N-P), to put models with different P's on
% equal footing.

%% Set up
models = {'Square-v3pt6-randfold', 'TargDis-v3pt6-randfold', 'SqNum-v3pt6-randfold', 'Type-v3pt6-randfold'};
suffixes_in = {'Square-v3pt6-Matrices', 'TargDis-v3pt6-Matrices', 'SqNum-v3pt6-Matrices', 'Type-v3pt6-Matrices'};

if ~exist('sigmasq_foldmean0','var')
    sigmasq_foldmean0 = sigmasq_foldmean;
end
if  ~exist('sigmasq_mean0','var')
    sigmasq_mean0 = sigmasq_mean;
end
sigmasq_mean = zeros(size(sigmasq_mean0));
sigmasq_foldmean = cell(size(sigmasq_foldmean0));

%% Recalculate MSE
% Adjust MSE so it's /N and not /(N-P), to put models with different P's on
% equal footing.
for iExp = 1:numel(experiments)
    experiment = experiments{iExp};
    sigmasq_foldmean{iExp} = zeros(size(sigmasq_foldmean0{iExp}));
    for iModel = 1:numel(models)        
        model = models{iModel};
        fprintf('%s, %s:\n',experiment,model);        
        subjects = GetSquaresSubjects(experiments{iExp});        
        for iSubj = 1:numel(subjects)
            fprintf('%d/%d...\n',iSubj,numel(subjects));
            R = load(sprintf('%s-%d-%s.mat',experiment,subjects(iSubj),suffixes_in{iModel}));
            [n,p] = size(R.X);
%             D = numel(R.Ymean);
            sigmasq_foldmean{iExp}(iSubj,:,iModel) = sigmasq_foldmean0{iExp}(iSubj,:,iModel)*(n-p)/n; % KEY LINE!
        end
        sigmasq_mean(iExp,:,iModel) = mean(sigmasq_foldmean{iExp}(:,:,iModel),1);
    end
end