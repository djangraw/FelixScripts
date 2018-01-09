function WriteAfniCovarFile(outFile,covariates,covarNames)

% function WriteAfniCovarFile(outFile,covariates,covarNames)
%
% INPUTS:
% -outFile is a string indicating the filename where you want to save the
% text file.
% -covariates is an NxM table or cell array of strings with covariate
% values, where N is the # of subjects and M is the # of covariates. 
% -covarNames is an M-element cell array of strings indicating the name of
% each covariate. If empty, it will default to the varaible names in
% covariates (if it's a table) or {'var1','var2',...,'var<M>'}.
%
% OUTPUTS:
% -a file called <outFile> will be written to the specified path or current
% directory.
%
% Created 1/8/18 by DJ.

% Declare defaults
if ~exist('covarNames','var') || isempty(covarNames)
    if istable(covariates)
        covarNames = covariates.Properties.VariableNames;
    else
        nVar = size(covariates,2);
        covarNames = cell(1,nVar);
        for i=1:nVar
            covarNames{i} = sprintf('var%d',i);
        end
    end
end

% Turn into table if it's not already
if ~istable(covariates)
    covariates = cell2table(covariates,'VariableNames',covarNames);
end

% Replace table variable names with specified ones
covariates.Properties.VariableNames = covarNames;

% Write table to file
writetable(covariates,outFile,'Delimiter','\t');
