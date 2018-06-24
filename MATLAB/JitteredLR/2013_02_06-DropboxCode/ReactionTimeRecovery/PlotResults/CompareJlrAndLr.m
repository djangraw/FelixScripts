function [LRstim LPstim LRresp LPresp JLR JLP] = CompareJlrAndLr(subject,commontags,stimtags,resptags,jlrtags)

% Created 11/29/12 by DJ.

% Handle inputs
if ischar(commontags)
    commontags = {commontags};
end
if ischar(stimtags)
    stimtags = {stimtags};
end
if ischar(resptags)
    resptags = {resptags};
end
if ischar(jlrtags)
    jlrtags = {jlrtags};
end

% Build up search strings
disp('Finding...')
common_string = sprintf('results_%s_*',subject);
for i=1:numel(commontags)
    common_string = strcat(common_string,commontags{i},'*');
end

stim_string = '';
for i=1:numel(stimtags)
    stim_string = strcat(stim_string,stimtags{i},'*');
end

resp_string = '';
for i=1:numel(resptags)
    resp_string = strcat(resp_string,resptags{i},'*');
end

jlr_string = '';
for i=1:numel(jlrtags)
    jlr_string = strcat(jlr_string,jlrtags{i},'*');
end

% Search with dir
stimfolder = dir(strcat(common_string,stim_string));
respfolder = dir(strcat(common_string,resp_string));
jlrfolder = dir(strcat(common_string,jlr_string));

if length(stimfolder)~=1 || length(respfolder)~=1 || length(jlrfolder)~=1
    error('try again.');
end

% Load
disp('Loading...')
[LRstim LPstim] = LoadJlrResults(stimfolder.name);
[LRresp LPresp] = LoadJlrResults(respfolder.name);
[JLR JLP] = LoadJlrResults(jlrfolder.name);

% disp('Plotting...')
% PlotJlrAcrossOffsets_Compare(LRstim,LPstim,LRresp,LPresp,JLR,JLP,[],'vout','post_avg');

disp('Done!')

