function vars = GetMusicVariables(varargin)

% vars = GetDistractionVariables()
%
% OUTPUTS:
% -vars is a struct with information about the music project.
%
% Created 4/24/17 by DJ based on GetDistractionVariables.

% Find out if this is local or cluster machine
hostname = char( getHostName( java.net.InetAddress.getLocalHost ) );
if strcmp(hostname,'MH01971391MACLT') % Dave's local machine
    vars.homedir = '/Volumes/data/PRJ11_Music';
else % Helix/Felix/Biowulf
    vars.homedir = '/data/jangrawdc/PRJ11_Music';
end
% Subject/session constants
vars.subject = 3;
vars.sessions = 1:14;
vars.sessionTypes = cell(size(vars.sessions));
vars.sessionTypes([1 3]) = repmat({'none'},1,2);
vars.sessionTypes([2 12]) = repmat({'baseline'},1,2);
vars.sessionTypes(4:11) = repmat({'task'},1,8);
vars.sessionTypes(13) = repmat({'improvise'},1,1);
vars.sessionTypes(14) = repmat({'wholesong'},1,1);

% Preprocessing constants
vars.nFirstRemoved = 3;
vars.TR = 2;
vars.hrfOffset = 6;
vars.nSlices = 34; % for retroTS.py

% Directory/file constants
vars.audioDir = [vars.homedir '/RawData/SBJ03/audio'];
vars.physioDir = [vars.homedir '/RawData/SBJ03/physio'];
vars.behaviorDir = [vars.homedir '/RawData/SBJ03/behavior'];
vars.biopacFilenames = {'DJ_test_sub_032017-04-15T16_55_08.mat' ...
    'DJ_test_sub_032017-04-15T16_58_43.mat' ...
    'DJ_test_sub_032017-04-15T17_01_24.mat' ...
    'DJ_test_sub_032017-04-15T17_07_18.mat' ...
    'DJ_test_sub_032017-04-15T17_14_10.mat' ...
    'DJ_test_sub_032017-04-15T17_20_20.mat' ...
    'DJ_test_sub_032017-04-15T17_26_21.mat' ...
    'DJ_test_sub_032017-04-15T17_32_42.mat' ...
    'DJ_test_sub_032017-04-15T17_38_42.mat' ...
    'DJ_test_sub_032017-04-15T17_45_51.mat' ...
    'DJ_test_sub_032017-04-15T17_53_19.mat' ...
    'DJ_test_sub_032017-04-15T17_59_36.mat' ...
    'DJ_test_sub_032017-04-15T18_04_16.mat' ...
    'DJ_test_sub_032017-04-15T18_09_27.mat'};