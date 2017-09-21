function trialBehTable = ReadSrttTrialByTrialBeh(filename)

% trialBehTable = ReadSrttTrialByTrialBeh(filename)
%
% Created 9/20/17 by DJ.

% Declare options
options = {'filetype','spreadsheet', ...
           'ReadVariableNames',true, ...
           'ReadRowNames',false, ...
           'TreatAsEmpty','.', ...
           'Sheet','SRTTrawdata'};
       
% Read in table
trialBehTable = readtable(filename,options{:});

%% Get Target in numeric form
targets = {'* _ _ _','_ * _ _','_ _ * _','_ _ _ *'};
[~,iTarget] = ismember(trialBehTable.Target,targets); 
% Add to table as new column
trialBehTable.TargetNum = iTarget;

