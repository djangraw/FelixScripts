function info = GetSrttConstants()

% GetSrttConstants()
%
% Created 1/26/18 by DJ.
% Updated 2/1/18 by DJ - detect local machine and adjust PRJDIR

% Find out if this is local or cluster machine
hostname = char( getHostName( java.net.InetAddress.getLocalHost ) );
if strcmp(hostname,'MH01971391MACLT') % Dave's local machine
    info.PRJDIR = '/Volumes/data/PRJ16_TaskFcManipulation';
else % Helix/Felix/Biowulf
    info.PRJDIR = '/data/jangrawdc/PRJ16_TaskFcManipulation';
end

% Get all subjects
foo = dir(sprintf('%s/RawData/tb*',info.PRJDIR));
info.subjNames = {foo.name};
info.subjects =  str2double(regexprep(info.subjNames,'\D',''));

% Get list of ok subjects
info.okSubjNames = {'tb0065' 'tb0093' 'tb0094' 'tb0137' 'tb0169' 'tb0170' 'tb0275' 'tb0312' 'tb0313' ...
'tb0349' 'tb0456' 'tb0498' 'tb0543' 'tb0716' 'tb0782' 'tb1063' 'tb1147' 'tb1208' 'tb1313' ...
'tb1524' 'tb5762' 'tb5833' 'tb5868' 'tb5914' 'tb5976' 'tb5985' 'tb6048' 'tb6082' 'tb6150' ...
'tb6162' 'tb6199' 'tb6301' 'tb6366' 'tb6487' 'tb6562' 'tb6563' 'tb6601' 'tb6631' 'tb6704' ...
'tb6813' 'tb6842' 'tb6843' 'tb6874' 'tb6899' 'tb6930' 'tb7065' 'tb7153' 'tb7428' 'tb7763' ...
'tb7764' 'tb8068' 'tb8135' 'tb8159' 'tb8403' 'tb8461' 'tb8462' 'tb8503' 'tb8561' 'tb8562' ...
'tb8630' 'tb8632' 'tb8748' 'tb8818' 'tb8883' 'tb8965' 'tb9026' 'tb9027' 'tb9065' 'tb9148' ...
'tb9149' 'tb9158' 'tb9331' 'tb9354' 'tb9369' 'tb9392' 'tb9405' 'tb9425' 'tb9512' 'tb9614' ...
'tb9639' 'tb9660' 'tb9661' 'tb9692' 'tb9727' 'tb9728' 'tb9769' 'tb9804' 'tb9841' 'tb9881' 'tb9941'};
info.okSubjects =  str2double(regexprep(info.okSubjNames,'\D',''));
