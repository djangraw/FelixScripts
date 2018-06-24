%% Automate importing data for multiple files  

%% Pick a Folder of Data
folderName = fullfile(pwd,'FaultData');
allFileNames = dir(fullfile(folderName,'*.data'));

% Preallocating variables
  data = [];
  fault = {};
  
% Looping through all Text Files
for ii = 1:length(allFileNames)
    % Create full file name and extract name of data file
    fileName= fullfile(folderName,allFileNames(ii).name);
    
    % Run Import Function
    [fault1 data1] = importTextFile(fileName); 
    
    % Concatenate table
    data = [data;data1];
    fault = [fault;fault1];  
end

% Convert to a table format
varnames = [{'Fx'}, {'Fy'}, {'Fz'}, {'Tx'}, {'Ty'}, {'Tz'}];
faultData = array2table(data, 'VariableNames', varnames);
faultData.Fault = fault; 

%% Reduce the fault classes 
faultData.Fault = categorical(faultData.Fault);

dataFinal = faultData ;
idx1 = dataFinal.Fault == 'bottom_obstruction';
faultData.Fault (idx1) = 'obstruction';

idx2 = dataFinal.Fault == 'slightly_moved';
faultData.Fault (idx2) = 'moved';

idx3 = dataFinal.Fault == 'ok';
faultData.Fault (idx3) = 'normal';

idx4 = dataFinal.Fault == 'back_col' | dataFinal.Fault == 'bottom_collision' | dataFinal.Fault =='collision_in_part' |dataFinal.Fault == 'collision_in_tool'....
    | dataFinal.Fault =='fr_collision' | dataFinal.Fault =='front_col' | dataFinal.Fault =='left_col' |dataFinal.Fault == 'right_col';
faultData.Fault (idx4) = 'collision';

faultData.Fault = removecats(faultData.Fault);

%% Remove categories with less than n samples 
% n = 20;
% faults= categories(faultData.Fault);
% idx  = (countcats(faultData.Fault)) < n;
% faultData(ismember(faultData.Fault,faults(idx)),:)=[];
% faultData.Fault = removecats(faultData.Fault);

%% Write data to Excel 
%writetable(faultData, 'FaultData.xlsx');
