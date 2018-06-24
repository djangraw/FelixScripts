function [fault, data] = importTextFile(filename)
%IMPORTFILE Import data from a text file .
%   [fault, data] = IMPORTTEXTFILE(FILENAME) Reads data from text file FILENAME for the default
%   selection.
%
% Example:
%   [fault, data] = importTextFile('lp1.data');
%
%    See also TEXTSCAN.

%% Open the text file.
fileID = fopen(filename,'r');

% Preallocating variables
  data = [];
  fault = {};

while( true )
    
    % Read data
    fault1 = textscan(fileID,'%s',1);
    data1 = textscan(fileID,'%f',6*15);
    
    % Check if empty
    if( isempty(data1{1}))
        break;
    end
    
    % Post processing 
    data1 = reshape(data1{1},6,15)';
    avgdata1 = mean(data1);
    
    % Concatenate arrays
    data = [data;avgdata1];
    fault = [fault;fault1{1}];
    
end

%% Close the text file.
fclose(fileID);

end
