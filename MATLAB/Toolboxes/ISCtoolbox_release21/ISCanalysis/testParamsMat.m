function Params = testParamsMat(Params)
% function tests if all fields exits in the Params struct
% This function maintains the backward compatibility of ISCToolbox
% In the case of older analysis the setup file Params struct does not 
% contain all requested fields of the newer version
%
% Changes in Params-struct over versions:
%
% Version 1.2 (2012), added field for gridComputing and two removal fields
% Version 1.1 (2011), original struct 
% Version 1.0 (2010), original struct 

%Priv = Params.PrivateParams;
Pub = Params.PublicParams;

disp('Testing the compatibility of the loaded Parameters...')

if(~isfield(Pub,'disableGrid'))
    disp('Field disableGrid not found: adding the field...')
    Params.PublicParams.disableGrid = ispc; %If Windows, the grid is disabled
end

if(~isfield(Pub,'gridParams'))
    disp('Field gridParams not found: adding the field...')
    Params.PublicParams.gridParams = '--partition=normal --mem=10096 --time=2-0'; %If Windows, the grid is disabled
end

if(~isfield(Pub,'removeMemmaps'))
    disp('Field removeMemmaps not found: adding the field...')
    Params.PublicParams.removeMemmaps = false;
end

if(~isfield(Pub,'removeFiltermaps'))
        disp('Field removeFiltermaps not found: adding the field...')
    Params.PublicParams.removeFiltermaps = false;
end

if(~isfield(Pub,'permutSessionComp'))
        disp('Field permutSessionComp not found: adding the field...')
    Params.PublicParams.permutSessionComp = 25000;
end

if(~isfield(Pub,'sessionCompOn'))
        disp('Field sessionCompOn not found: adding the field...')
    Params.PublicParams.sessionCompOn = false;
end

if(~isfield(Pub,'permutFreqComp'))
        disp('Field permutFreqComp not found: adding the field...')
    Params.PublicParams.permutFreqComp = 25000;
end

%is the following field the same as earlier nrPermutationsZPF?
if(~isfield(Pub,'freqCompOn'))
        disp('Field freqCompOn not found: adding the field...')
    Params.PublicParams.freqCompOn = false;
end