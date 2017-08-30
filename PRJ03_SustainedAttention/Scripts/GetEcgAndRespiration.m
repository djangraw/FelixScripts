function [rawEcg, rawResp, data] = GetEcgAndRespiration(subject)

% Created 7/15/16 by DJ.

% handle inputs
if isnumeric(subject)
    subjStr = sprintf('SBJ%02d',subject);
else
    subjStr = subject;
    subject = str2double(subjStr(4:end));
end

% Load behavior
load(sprintf('/data/jangrawdc/PRJ03_SustainedAttention/Results/%s/Distraction-%d-QuickRun.mat',subjStr,subject));

% navigate to folder
cd(sprintf('/data/jangrawdc/PRJ03_SustainedAttention/RawData/%s',subjStr));

% load traces
nRuns=numel(data);
[rawEcg, rawResp] = deal(cell(1,nRuns));
for i=1:nRuns
    rawEcg{i} = Read_1D(sprintf('%s_ECG_Run%02d',subjStr,i));
    rawResp{i} = Read_1D(sprintf('%s_Resp_Run%02d',subjStr,i));
end