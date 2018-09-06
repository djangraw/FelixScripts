function tableout = importXlsToTable(workbookFile,sheetName,startRow,endRow)
%% Import data from spreadsheet
% Script for importing data from the following spreadsheet:
%
%    Workbook: /Users/jangrawdc/Documents/MATLAB/MlCourse/faultData.xlsx
%    Worksheet: Sheet1
%
% To extend the code for use with different selected data or a different
% spreadsheet, generate a function instead of a script.

% Auto-generated by MATLAB on 2016/05/09 13:33:23

%% Import the data
[~, ~, raw] = xlsread(workbookFile,sheetName);
if ~exist('startRow','var') || isempty(startRow)
    startRow = 2;
end
if ~exist('endRow','var') || isempty(endRow)
    endRow = size(raw,1);
end
raw = raw(startRow:endRow,:);
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
cellVectors = raw(:,7);
raw = raw(:,1:6);

%% Create output variable
data = reshape([raw{:}],size(raw));

%% Create table
tableout = table;

%% Allocate imported array to column variable names
tableout.Fx = data(:,1);
tableout.Fy = data(:,2);
tableout.Fz = data(:,3);
tableout.Tx = data(:,4);
tableout.Ty = data(:,5);
tableout.Tz = data(:,6);
tableout.Fault = cellVectors(:,1);

%% Clear temporary variables
% clearvars data raw cellVectors;