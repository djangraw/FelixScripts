function [JLR, JLP] = LoadJlrResults(subject,weightprior,cvmode,jitterrange,suffix)

% [JLR, JLP] = LoadJlrResults
% [JLR, JLP] = LoadJlrResults(foldername)
% [JLR, JLP] = LoadJlrResults(subject,weightprior,cvmode,jitterrange,suffix)
%
% INPUTS:
% - foldername is a string indicating the name of the folder where the
% results and parameters are saved.
% - subject is a string (e.g. 'an02apr04')
% - weightprior is a binary value (e.g. false)
% - cvmode is a string (e.g. '10fold')
% - jitterrange is a 2-element vector (e.g. [0 0])
% - suffix is a string (e.g. '_sigma5')
%
% OUTPUTS:
% - JLR is a struct of the JLR results.
% - JLP is a struct of the JLP parameters.
%
% Created 9/27/12 by DJ.
% Updated 12/18/12 by DJ - edit to work with multiwin results

if nargin==0
    foldername = uigetdir(cd,'Choose folder');
    iUnderscores = strfind(foldername,'_');        
    if foldername(1)=='r'
        cvmode = foldername(iUnderscores(3)+1:iUnderscores(4)-1);    
    else
        cvmode = foldername(iUnderscores(2)+1:iUnderscores(3)-1);    
    end
elseif nargin==1
    foldername = subject;
    iUnderscores = strfind(foldername,'_');
    if foldername(1)=='r'
        cvmode = foldername(iUnderscores(3)+1:iUnderscores(4)-1);    
    else
        cvmode = foldername(iUnderscores(2)+1:iUnderscores(3)-1);    
    end
else
    if ~exist('weightprior','var') || isempty(weightprior)
        weightprior = false;
    end
    if ~exist('cvmode','var') || isempty(cvmode)
        cvmode = '10fold';
    end
    if ~exist('jitterrange','var') || isempty(jitterrange)
        jitterrange = [0 0];
    end
    if ~exist('suffix','var')
        suffix = '';
    end
    
    % convert weightprior to string
    if weightprior
        wpstring = 'weightprior';
    else
        wpstring = 'noweightprior';
    end

    foldername = sprintf('results_%s_%s_%s_jrange_%d_to_%d%s',subject,...
        wpstring,cvmode,jitterrange(1),jitterrange(2),suffix);
end

JLR = load([foldername '/results_' cvmode]);
JLP = load([foldername '/params_' cvmode]);