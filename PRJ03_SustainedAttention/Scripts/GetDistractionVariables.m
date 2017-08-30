function vars = GetDistractionVariables(varargin)

% vars = GetDistractionVariables()
%
% OUTPUTS:
% -vars is a struct with information about the sustained attention project.
%
% Created 11/16/16 by DJ.
% Updated 12/19/16 by DJ - adapted to work on local machine too
% Updated 2/22/17 by DJ - remove SBJ34 from okSubjects, removed /Results/
%   folder from homedir, added comments

% Find out if this is local or cluster machine
hostname = char( getHostName( java.net.InetAddress.getLocalHost ) );
if strcmp(hostname,'MH01971391MACLT') % Dave's local machine
    vars.homedir = '/Volumes/data/PRJ03_SustainedAttention';
else % Helix/Felix/Biowulf
    vars.homedir = '/data/jangrawdc/PRJ03_SustainedAttention';
end
vars.subjects = 9:36;
vars.okSubjects = [9:11 13:19 22 24:25 28 30:33 36];
% Preprocessing constants
vars.nFirstRemoved = 3;
vars.TR = 2;
vars.hrfOffset = 6;
