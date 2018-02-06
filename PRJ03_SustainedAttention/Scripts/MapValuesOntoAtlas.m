function valOnAtlas = MapValuesOntoAtlas(atlas,values,indices,outFile,outInfo)

% valOnAtlas = MapValuesOntoAtlas(atlas,values,indices,outFile,outInfo)
% 
% USAGE:
% Simplest usage to output brick without loading or saving:
%  valOnAtlas = MapValuesOntoAtlas(atlas,values)
% Simplest usage to load and save within function: 
%  MapValuesOntoAtlas(atlasFile,values,[],outFile)
%
% INPUTS:
% -atlas is an XxYxZ matrix in which each ROI is marked by a certain index,
% or a string indicating an AFNI brick matching this description.
% -values is an n-element vector of values you'd like to assign to certin
% ROIs.
% -indices is an n-element vector of the indices you'd like to map the
% values to (that is: valOnAtlas(atlas==indices(i)) = values(i)). 
% [default = 1:n]
% -outFile is a string indicating where you want to save the resulting afni
% brick. If it is empty, no file is saved.
% -outInfo is the info struct used to write the output. It is usually the
% atlas info struct, and if atlas is a string and nothing is input here, it
% will default to using the atlas info.
%
% OUTPUTS:
% -valOnAtlas is an XxYxZ matrix in which the ROI indices are replaced by
% the given values. Any index not assigned a value will be set to 0.
%
% Created 12/22/15 by DJ.
% Updated 2/6/18 by DJ - added loading & saving abilities, outFile/outInfo
% inputs.

% Declare defaults
if ~exist('indices','var') || isempty(indices)
    indices = 1:numel(values);
end
if ~exist('outFile','var')
    outFile = '';
end

% Load atlas
if ischar(atlas)
    fprintf('Loading atlas %s...\n',atlas);
    [atlas, atlasInfo] = BrikLoad(atlas);
    if ~exist('outInfo','var')
        outInfo = atlasInfo;
    end
end

% Map values onto atlas
valOnAtlas = nan(size(atlas));
for i=1:numel(indices)
    valOnAtlas(atlas==indices(i)) = values(i);
end

% Write file
if ~isempty(outFile)
    fprintf('Writing atlas %s...\n',outFile);
    outOpt = struct('Prefix',outFile,'OverWrite',true);
    WriteBrik(valOnAtlas,outInfo,outOpt);
end
