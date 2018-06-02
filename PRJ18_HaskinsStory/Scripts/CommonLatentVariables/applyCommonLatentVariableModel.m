%
% apply a common source model to one or more datasets
%
% input:
%
% - model (learned with learnCommonSourceModel)
% - datasets (cell array, same order as in the training data)
%   - if only a few subjects are available, the others can be empty
%
% output:
%
% - matrix with common S
% - cell array with S estimates for subjects
% - cell array of reconstructed datasets from mixing matrix
%

function [Scommon,Sestimates,inputDatasetsReconstructed] = applyCommonLatentVariableModel(varargin)

%
% process arguments
%

Sestimates = {};

if nargin < 2
    fprintf('syntax:applyCommonSourceModel(<model>,<input data>\n');return;
end

model         = varargin{1};
inputDatasets = varargin{2}; nDatasets = length(inputDatasets);


% optional arguments (and defaults)

% if there is a common source derived from all subjects, use it
useCommonSource = 1;

% for methods that use a dataset mean
useMeanFromTrainingSet = 1;

idx = 3;
while idx <= nargin
    argval = varargin{idx}; idx = idx + 1;
    
    switch argval
      case {'useCommonSource'}
        useCommonSource = varargin{idx}; idx = idx + 1;
      case {'useMeanFromTrainingSet'}
        useMeanFromTrainingSet = varargin{idx}; idx = idx + 1;
      otherwise
        fprintf('error: unknown argument %s\n',argval);return;
    end 
end


%% pull out information from trained model

method                 = model.method;
methodParameters       = model.methodParameters;
datasetTransformationsUnmixing = model.datasetTransformationsUnmixing;
datasetTransformationsMixing   = model.datasetTransformationsMixing;
datasetTransformationsExtra    = model.datasetTransformationsExtra;
formulation            = model.formulation;

fprintf('applying model (%s)\n',formulation);

%% figure out other things

% mask for whether datasets are present
nPerDataset = zeros(1,nDatasets); mPerDataset = zeros(1,nDatasets);
for id = 1:nDatasets
    [nPerDataset(id),mPerDataset(id)] = size(inputDatasets{id});
end
    
% check that lengths match
tmp = nPerDataset(find(nPerDataset>0));
if sum(diff(tmp))~=0
    n = 0; % different sizes, can't compute average
else
    n = tmp(1);
end

%
% generate representations
%

switch method
  case {'SRM','SRME','SSRM'}
    % transformations are just projection matrices to be applied to input data
    k = size(model.S,2);
    
    for id = 1:nDatasets
        if nPerDataset(id)
            Sestimates{id} = inputDatasets{id} * datasetTransformationsUnmixing{id};
        else
            Sestimates{id} = [];
        end
    end
    
    if n
        % all datasets have the same number of examples, average representations
        Scommon = zeros(n,k); count = 0;
        for id = 1:nDatasets
            if nPerDataset(id)
                Scommon = Scommon + Sestimates{id};
                count = count + 1;
            end
        end
        Scommon = Scommon / count;
    end
    
    %% some formulations add other things

    switch formulation
      case {'deterministicMinusResiduals'}
        % re-compute the individual S_i using the residual basis
        
        for id = 1:nDatasets
            
            if nPerDataset(id)
                
                residualBasis = datasetTransformationsExtra{id};
                m = size(inputDatasets{id},2);
                
                % regress the residual basis out of the dataset
                tmp = [residualBasis',ones(m,1)];
                newDataset = zeros(size(inputDatasets{id}));
                
                for e = 1:n
                    [b] = regress(inputDatasets{id}(e,:)',tmp);
                    newDataset(e,:) = inputDatasets{id}(e,:) - (tmp*b)';
                end
        
                % recompute the S_i
                Sestimates{id} = newDataset * datasetTransformationsUnmixing{id};
            end
            
        end
      otherwise
    end; % of formulation-specific behaviour
    
    % reconstruct data
    
    inputDatasetsReconstructed = inputDatasets; %clear inputDatasets;
    
    for id = 1:nDatasets
        if nPerDataset(id)
    
            % if n, there is a common S to use, otherwise subject specific
            if (n & useCommonSource)
                fprintf('\treconstruction with common S\n');
                Shere = Scommon;
            else;
                fprintf('\treconstruction with subject-specific S\n');
                Shere = Sestimates{id};
            end
                
            switch formulation
              case {'deterministic','ADMM','SSRMnobias','SSRMwithbias'}
                inputDatasetsReconstructed{id} = Shere * datasetTransformationsMixing{id};
              case {'EM'}
                fprintf('WARNING: not implemented yet\n');pause;return;
            end
        end
    end
 
  case {'gCCA'}

    % Ahmet, if you need to get something you packed while learning
    % the model you can unpack it here
    
    % unpack, learned on the training set
    for id = 1:nDatasets
        Us{id}                       = datasetTransformationsExtra{id,1};
        % means from training set
        datasetMeans{id}             = datasetTransformationsExtra{id,2};
        transformations{id}          = datasetTransformationsExtra{id,3};
        expansionTransformations{id} = datasetTransformationsExtra{id,4};
    end
    
    % transformations are just projection matrices to be applied to input data
    k = size(model.S,2);
    
    for id = 1:nDatasets
        if nPerDataset(id)
            tmp = inputDatasets{id};
            tmp = tmp * Us{id};
            if useMeanFromTrainingSet
                % it's there already
            else
                % recalculate from test set and update
                datasetMeans{id} = mean(tmp,1);
            end    
            tmp = tmp - repmat(datasetMeans{id},size(tmp,1),1);
            Sestimates{id}    = tmp * transformations{id};            
        else
            Sestimates{id} = [];
        end
    end
    
    if n
        % all datasets have the same number of examples, average representations
        Scommon = zeros(n,k); count = 0;
        for id = 1:nDatasets
            if nPerDataset(id)
                Scommon = Scommon + Sestimates{id};
                count = count + 1;
            end
        end
        Scommon = Scommon / count;
    end
        
    % reconstruct data
    
    for id = 1:nDatasets
        if nPerDataset(id)
    
            % if n, there is a common S to use, otherwise subject specific
            if (n & useCommonSource)
                fprintf('\treconstruction with common S\n');
                Shere = Scommon;
            else;
                fprintf('\treconstruction with subject-specific S\n');
                Shere = Sestimates{id};
            end

            %            size(transformations{id})
            %            size(datasetMeans{id})
            %            size(Us{id})
            %            pause;clf;
            %imagesc(transformations{id}*transformations{id}',[-1,1]);colorbar('vert');fprintf('trans\n');pause
            %imagesc(Us{id}'*Us{id},[-1,1]);fprintf('Us\n');colorbar('vert');pause
            
            % more steps than SRM
            if 1
                inputDatasetsReconstructed{id} = (Shere * transformations{id}' + repmat(datasetMeans{id},size(Shere,1),1))*Us{id}';
                %inputDatasetsReconstructed{id} = (Shere * pinv(transformations{id}) + repmat(datasetMeans{id},size(Shere,1),1))*Us{id}';
            else
                % Ahmet, edit here!
                % (and then set "if 1" above to "if 0")
                inputDatasetsReconstructed{id} = (Shere *  expansionTransformations{id} + repmat(datasetMeans{id},size(Shere,1),1))*Us{id}';
                % end of edit
            end
                
            %clf;subplot(1,2,1);imagesc(inputDatasets{id},[-20,50]);
            %subplot(1,2,2);imagesc(inputDatasetsReconstructed{id},[-20,50]);
            %pause
        end
    end
    
  case {'gCCA2','gCCA2_then_NPICA'}
    % transformations are just projection matrices to be applied to input data
    k = size(model.S,2);
    
    % unpack, learned on the training set 
    for id = 1:nDatasets
        % means are (1 x #voxels)
        if useMeanFromTrainingSet | (nPerDataset(id)==0)
            % means from training set
            datasetMeans{id} = datasetTransformationsExtra{id,1};
        else
            datasetMeans{id} = mean(inputDatasets{id},1);
        end
    end
    
    for id = 1:nDatasets
        if nPerDataset(id)
            inputDatasets{id} = inputDatasets{id} - repmat(datasetMeans{id},size(inputDatasets{id},1),1);
            Sestimates{id}    = inputDatasets{id} * datasetTransformationsUnmixing{id};
        else
            Sestimates{id} = [];
        end
    end
           
    if n
        % all datasets have the same number of examples, average representations
        Scommon = zeros(n,k); count = 0;
        for id = 1:nDatasets
            if nPerDataset(id)
                Scommon = Scommon + Sestimates{id};
                count = count + 1;
            end
        end
        Scommon = Scommon / count;
    end
    
    % copy to subjects without data
    for id = 1:nDatasets
        if (nPerDataset(id) == 0); Sestimates{id} = Scommon; end
    end
    
    % reconstruct dataset
    
    inputDatasetsReconstructed = inputDatasets; %clear inputDatasets;
    
    for id = 1:nDatasets
        if nPerDataset(id)
    
            % if n, there is a common S to use, otherwise subject specific
            if (n & useCommonSource) 
                fprintf('\treconstruction with common S\n');
                Shere = Scommon;
            else;
                fprintf('\treconstruction with subject-specific S\n');
                Shere = Sestimates{id};
            end 
        else
            fprintf('\treconstruction with common S (no dataset)\n');
            Shere = Scommon; 
        end
        
        
        inputDatasetsReconstructed{id} = Shere * datasetTransformationsMixing{id};
        inputDatasetsReconstructed{id} = inputDatasetsReconstructed{id} + repmat(datasetMeans{id},size(inputDatasetsReconstructed{id},1),1);
    end
    
    %% methods that require
    %% 1) all  subjects used in training
    %% 2) generate a single S from all subjects 
    %%    (this gets assigned as the subjec-specific S)
    
  case {'FastICA','NPICA','SVD_then_NPICA'}
    % transformations are just projection matrices to be applied to input data
    k = size(model.S,2);

    if 0
        % original code, needs to have *all* datasets
    
        % aggregate all datasets and transformations
        if ~isempty(find(nPerDataset == 0))
            fprintf('ERROR: need datasets for all subjects\n');return;
        end
        
        m = sum(mPerDataset);
        ensembleDataset = zeros(n,m);
        ensembleDatasetTransformationUnmixing = zeros(m,k);
        ensembleDatasetTransformationMixing   = zeros(k,m);
        
        idx = 1;
        for id = 1:nDatasets
            vrange = idx:(idx+mPerDataset(id)-1);
            
            ensembleDataset(:,vrange)                       = inputDatasets{id};
            ensembleDatasetTransformationUnmixing(vrange,:) = datasetTransformationsUnmixing{id};
            ensembleDatasetTransformationMixing(:,vrange)   = datasetTransformationsMixing{id};
            
            idx = idx + mPerDataset(id);
        end
        
        % generate the S
        Scommon = ensembleDataset * ensembleDatasetTransformationUnmixing;
        
        % copy to all datasets
        for id = 1:nDatasets
            Sestimates{id} = Scommon;
        end
        
        % reconstruct data
        tmp = Scommon * ensembleDatasetTransformationMixing;
        
        idx = 1;
        for id = 1:nDatasets
            vrange = idx:(idx+mPerDataset(id)-1);
            
            inputDatasetsReconstructed{id} = tmp(:,vrange);
            
            idx = idx + mPerDataset(id);
        end

    else
        % hack to get around missing datasets (more like gCCA2 methods)
        % basic idea:
        % - the estimated sources are an average of per-subject estimates (with # of subjects baked in implicitly)
        % - you can do without subjects by re-weighing
        
        count = 0;
        for id = 1:nDatasets
            if nPerDataset(id)
                Sestimates{id}    = inputDatasets{id} * datasetTransformationsUnmixing{id};
                count = count + 1;
            else
                fprintf('\twarning: dataset %d is empty\n',id);
                Sestimates{id} = [];
            end
        end

        if count < nDatasets; smulti = nDatasets/count; else; smulti = 1; end

        % average weighted matrices for available subjects
        Scommon = zeros(n,k);
        for id = 1:nDatasets
            if nPerDataset(id)
                Scommon = Scommon + smulti*Sestimates{id};
            end
        end
        
        % copy to subjects without data
        for id = 1:nDatasets
            if (nPerDataset(id) == 0); Sestimates{id} = Scommon; end
        end
        
        % reconstruct dataset
        inputDatasetsReconstructed = inputDatasets; %clear inputDatasets;
        
        for id = 1:nDatasets
            if nPerDataset(id)
                % if n, there is a common S to use, otherwise subject specific
                if (n & useCommonSource)
                    fprintf('\treconstruction with common S\n');
                    Shere = Scommon;
                else;
                    fprintf('\treconstruction with subject-specific S\n');
                    Shere = Sestimates{id};
                end
            else
                % no dataset, have to use common
                fprintf('\treconstruction with common S (no dataset)\n');
                Shere = Scommon;
            end

            inputDatasetsReconstructed{id} = Shere * datasetTransformationsMixing{id};
        end
        
    end
     
  case {'SVD'}

    %% use this as the default case
    
    % transformations are just projection matrices to be applied to input data
    k = size(model.S,2);

    % original code, needs to have *all* datasets
    
    % aggregate all datasets and transformations
    if ~isempty(find(nPerDataset == 0))
        fprintf('ERROR: need datasets for all subjects\n');return;
    end
    
    m = sum(mPerDataset);
    ensembleDataset = zeros(n,m);
    ensembleDatasetTransformationUnmixing = zeros(m,k);
    ensembleDatasetTransformationMixing   = zeros(k,m);
    
    idx = 1;
    for id = 1:nDatasets
        vrange = idx:(idx+mPerDataset(id)-1);
        
        ensembleDataset(:,vrange)                       = inputDatasets{id};
        ensembleDatasetTransformationUnmixing(vrange,:) = datasetTransformationsUnmixing{id};
        ensembleDatasetTransformationMixing(:,vrange)   = datasetTransformationsMixing{id};
        
        idx = idx + mPerDataset(id);
    end
    
    % generate the S
    Scommon = ensembleDataset * ensembleDatasetTransformationUnmixing;
    
    % copy to all datasets
    for id = 1:nDatasets
        Sestimates{id} = Scommon;
    end
    
    % reconstruct data
    tmp = Scommon * ensembleDatasetTransformationMixing;
    
    idx = 1;
    for id = 1:nDatasets
        vrange = idx:(idx+mPerDataset(id)-1);
        
        inputDatasetsReconstructed{id} = tmp(:,vrange);
        
        idx = idx + mPerDataset(id);
    end

end

% hack to test the effect of using SRM
% derived from the data of one subject
%Scommon = Sestimates{5};

%
% debug:
% 

if 0
    clf; nrows = nDatasets; ncols = 4; idx = 1;
    Xscale = [-20 60]; Uscale = [-0.05 0.05]; Sscale = [-50 100];
    Cscale = [-1 1];
    
    for id = 1:nDatasets
        subplot(nrows,ncols,idx);
        imagesc(inputDatasets{id},Xscale);
        title('X');
        colorbar('vert');
        idx = idx + 1;
        subplot(nrows,ncols,idx);
        imagesc(inputDatasetsReconstructed{id},Xscale);
        title('reconstructed X');
        colorbar('vert');
        idx = idx + 1;
        subplot(nrows,ncols,idx);
        imagesc(Sestimates{id},Sscale);
        title('S_i');
        colorbar('vert');
        idx = idx + 1;
        subplot(nrows,ncols,idx);
        tmp = corr(Scommon,Sestimates{id});
        imagesc(tmp,Cscale);
        title('corr(S,S_i)');
        axis square; set(gca,'XTick',[]);set(gca,'YTick',[]);
        xlabel(sprintf('%1.2f',median(diag(tmp))));
        idx = idx + 1;
    end
    fprintf('done with plot 1\n');pause

    % similarity of representations for each subject
    clf; nrows = nDatasets; ncols = nDatasets; idx = 1;
    for id1 = 1:nDatasets
        for id2 = 1:nDatasets
            tmp = corr(Sestimates{id1},Sestimates{id2});
            if id1 ~= id2
                subplot(nrows,ncols,idx);
                imagesc(tmp,[-1 1]); axis square;
                set(gca,'XTick',[]);set(gca,'YTick',[]);
                xlabel(sprintf('%1.2f',median(diag(tmp))));
            else
                subplot(nrows,ncols,idx);
                imagesc(Scommon,Sscale);
                colorbar('vert');                
            end
                
            idx = idx + 1;
        end
    end
    fprintf('done with plot 2\n');pause
    
end