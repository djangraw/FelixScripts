function datastruct = Parse100RunsEventsLog(text_file)

% datastruct = Parse100RunsEventsLog(text_file)
%
% Created 12/20/17 by DJ.

% Set up
start_code = 'INITIAL';
found_start_code = false;
end_code = '~~~';

types = {'block','trial','key'};
    
fid = fopen(text_file);
fseek(fid,0,'eof'); % find end of file
eof = ftell(fid);
fseek(fid,0,'bof'); % rewind to beginning

% Set the parameters for our search
% word: the word we check for to find relevant events
% format: the format we use in sscanf to turn a line of text into values of interest
% values: the values returned by sscanf (we specify the # of columns here)
[words,iInfo,formats,values] = deal(cell(size(types)));
delimiters = {' ','\f','\n','\r','\t','\v','=','[',']'}; % whitespace, = sign, comma
showWholeMsg = false(size(types));
for i=1:numel(types)
    switch types{i}        
        case 'block'
            % 10.0458 	DATA 	[Stim Block 0] starts FRAME TIME = 10.0292010307
            words{i} = 'Block';
            iInfo{i} = [3 5 9];
            formats{i} = '%s %d %f'; % Message format: <time> DATA [<type> Block <block>] starts FRAME TIME = <startTime> 
            values{i} = cell(0,3);
        case 'trial'
            % 13.0362 	DATA 	TASK TRIAL 0  FRAME TIME [3] = 13.0197479725
            words{i} = 'TRIAL';
            iInfo{i} = [1 5 8];
            formats{i} = '%f %d %s'; % Message format: <time> DATA TASK TRIAL <trial> FRAME TIME [<char>] = <startTime> 
            values{i} = cell(0,3);            
        case 'key'
            % 13.9007 	DATA 	Keypress: b
            words{i} = 'Keypress';
            iInfo{i} = [1 4];
            formats{i} = '%f %s';
            values{i} = cell(0,2);
    end
end

while ftell(fid) < eof % if we haven't reached the end of the text file
    str = fgetl(fid); % read in next line of text file
    % Check for start code
    if ~found_start_code 
        if isempty(strfind(str,start_code)) % if we haven't found start code yet
            continue; % skip to next line
        else
            found_start_code = true;
        end
    end        
    % Otherwise, Read in line
    for i=1:numel(types)
        if strfind(str,words{i}) % check for the code-word indicating a message was written
            
            if showWholeMsg(i)
                % Don't parse values, just return whole message
                C = strsplit(str,delimiters);
                iMsg = strfind(str,C{3});
                values{i} = [values{i}; C(1),{str(iMsg(1):end)}]; 
            else            
                % parse values
                C = strsplit(str,delimiters);
                % check for under-sized set values
                if numel(C)<iInfo{i}(end)
                    warning('FindEvents:IncompleteEvent','Unable to decipher the following event fully:\n %s',str); % sometimes sounds are not logged fully                
                else
                    stuff = C(iInfo{i});
        %             stuff = sscanf(str,formats{i})';
                    if size(stuff,2)==size(values{i},2)
                        values{i} = [values{i}; stuff]; % add the info from this line as an additional row                    
                    else
                        warning('FindEvents:IncompleteEvent','Unable to decipher the following event fully:\n %s',str); % sometimes saccades are not logged fully
                    end
                end
            end
            break;
        end        
    end
    % Check for end code
    if ~isempty(strfind(str,end_code))
        break;
    end
end

% Clean up
fclose(fid);

% Produce output
for i=1:numel(types)
    % Rearrange the values into the desired output
    switch types{i}
        case 'block'
            datastruct.block.type = values{i}(:,1); 
            datastruct.block.number = cellfun(@str2num,values{i}(:,2)); 
            datastruct.block.time = cellfun(@str2num,values{i}(:,3)); 
        case 'trial'
            datastruct.trial.time = cellfun(@str2num,values{i}(:,1)); % first output is time
            datastruct.trial.num = cellfun(@str2num,values{i}(:,2)); % next output is num
            datastruct.trial.char = values{i}(:,3); % last output is char displayed
        case 'key'
            datastruct.key.time = cellfun(@str2num,values{i}(:,1)); % first output is timestamp of response 
            datastruct.key.char = values{i}(:,2); % last output is value of response
        otherwise 
%             error('event_type input %s not recognized!',event_type);
            datastruct.(types{i}).time = cellfun(@str2num,values{i}(:,1)); % first output is display time                
            datastruct.(types{i}).name = values{i}(:,2);
    end

end