function behTable = ReadSrttBehXlsFile(filename)

% behTable = ReadSrttBehXlsFile(filename)
%
% Created 8/28/17 by DJ.

% Declare options
options = {'filetype','spreadsheet', ...
           'ReadVariableNames',true, ...
           'ReadRowNames',true, ...
           'TreatAsEmpty','.', ...
           'Sheet','BehavioralScores'};
       
% Read in table
scoreTable = readtable(filename,options{:});

%% Get RT scores
options{end} = 'RT';
rtTable = readtable(filename,options{:});
conds = {'Uns','Str'};
for i=1:numel(rtTable.Properties.VariableNames)
    if ~isnan(rtTable{1,i})
        run = rtTable{1,i};
    end
    if ~isnan(rtTable{2,i})
        block = rtTable{2,i};
    end
    if ~isnan(rtTable{3,i})
        cond = conds{rtTable{3,i}};
        rtTable.Properties.VariableNames{i} = sprintf('RT_R%dB%d_%s',run,block,cond);
    end
end
rtTable.Properties.VariableNames{end} = 'RT_Final_UnsMinusStr';
rtTable = rtTable(4:end,:);
rtTable.Properties.DimensionNames{1} = 'MRI_ID';

%% Add to table
behTable = join(rtTable,scoreTable,'Keys','RowNames');
% Reorder
behTable = behTable(:, [22:end, 1:21]);


