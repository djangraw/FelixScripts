function physio = ImportBiopacData(filename)

% physio = ImportBiopacData(filename)
% 
% INPUTS:
% -filename is a string indicating the .mat file exported by BIOPAC.
% 
% OUTPUTS:
% -physio is a struct with subfields 'time', 'resp', 'pulseox', 'trigger',
% 'ecg', and 'startsample'.
%
% Created 3/30/17 by DJ.
% Updated 3/31/17 by DJ - fixed isi_units bug

% Load file
foo = load(filename);
% Extract time vector
dt = foo.isi;
if strcmp(foo.isi_units,'ms')
    dt = dt/1000;
end
physio.time = (1:size(foo.data,1))*dt;
% Parse data
for i=1:size(foo.data,2)
    % Infer name from labels
    if strncmp(foo.labels(i,:),'Respiratory',length('Respiratory'));
        name = 'resp';
    elseif strncmp(foo.labels(i,:),'Pulse',length('Pulse'));
        name = 'pulseox';
    elseif strncmp(foo.labels(i,:),'MR trigger',length('MR trigger'));
        name = 'trigger';
    elseif strncmp(foo.labels(i,:),'ECG',length('ECG'));
        name = 'ecg';
    end
    % Add to physio struct
    physio.(name).data = foo.data(:,i);
    physio.(name).units = strtrim(foo.units(i,:));
    physio.(name).fullname = strtrim(foo.labels(i,:));
end
% transfer start_sample field
physio.start_sample = foo.start_sample;