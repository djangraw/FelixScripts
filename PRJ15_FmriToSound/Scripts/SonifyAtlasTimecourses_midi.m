function [atlasSound, Fs] = SonifyAtlasTimecourses_midi(atlasTc, slowFactor, scaleType, synthType)

% atlasSound = SonifyAtlasTimecourses_midi(atlasTc, slowFactor, scaleType, synthType)
%
% INPUTS:
% -atlasTc is an nxp matrix containing the data in each ROI at each time
% point, where n is the # of ROIs and p is the # of time points.
% -slowFactor is a scalar indicating how much you want to slow it down. Set
% this to TR if you want it to play back in the time you collected it.
% -scaleType is a string indicating the scale you want to use to sonify
% with (options, major, minor, pentatonic)
% -synthType is the midi option you want to use to turn it into sound (fm,
% sine, saw) [default = 'fm']
%
% OUTPUTS:
% -atlasSound is a p*slowFactor*Fs element vector, where Fs is the sound
% sampling frequency 
% -Fs is the sampling frequency output by midi2audio.
%
% Requires the matlab-midi package (downloaded 12/19/17 from
% https://github.com/kts/matlab-midi )
%
% Created 12/19/17 by DJ.

if ~exist('slowFactor','var') || isempty(slowFactor)
    slowFactor = 1;
end
if ~exist('scaleType','var') || isempty(scaleType)
    scaleType = 'pentatonic';
end    
if ~exist('synthType','var') || isempty(synthType)
    synthType = 'fm';
end    


switch scaleType
    case 'pentatonic'
        % Pentatonic version: each ROI is mapped onto a note in the pentatonic scale.
        notes_1oct = [0 2 4 7 9]; % in half-steps
    otherwise % half-steps
        notes_1oct = 0:11;
end
[nRois, nT] = size(atlasTc);
nOctaves = ceil(nRois/numel(notes_1oct));
notes = repmat(notes_1oct,nOctaves,1)'+12.*repmat(0:nOctaves-1,numel(notes_1oct),1);
notes = notes(1:nRois);

baseNote = 48; % 60 = middle C
notes = notes+baseNote; % offset so they're relative to baseNote

% Produce midi file
% initialize matrix:
N = nT*nRois;  % number of notes
M = zeros(N,6); % midi matrix

for i=1:nRois
    iThis = (1:nT)+(i-1)*nT;
    M(iThis,1) = 1;         % all in track 1
    M(iThis,2) = 1;         % all in channel 1
    M(iThis,3) = notes(i);      % note numbers (in half-steps, middleC=60)
    M(iThis,4) = round(atlasTc(i,:))';  % lets have volume ramp up 80->120
    M(iThis,5) = ((1:nT)*slowFactor)';  % note on:  notes start every 1 seconds
    M(iThis,6) = ((2:nT+1)*slowFactor)';  % note off: each note has duration 1 seconds
end

midi_new = matrix2midi(M);
Fs = 8192; % default for MATLAB's sound function (in Hz)
atlasSound = midi2audio(midi_new, Fs, synthType);
% writemidi(midi_new, 'testout.mid');

fprintf('Done!\n');