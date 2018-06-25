function atlasSound = SonifyAtlasTimecourses(atlasTc, slowFactor, option)

% atlasSound = SonifyAtlasTimecourses(atlasTc, slowFactor, option)
%
% INPUTS:
% -atlasTc is an nxp matrix containing the data in each ROI at each time
% point, where n is the # of ROIs and p is the # of time points.
% -slowFactor is a scalar indicating how much you want to slow it down.
% -option is a string indicating how you want to sonify. (TBD)
%
% OUTPUTS:
% -atlasSound is a p*slowFactor*Fs element vector, where Fs is the sound
% sampling frequency (currently 
%
% Created 12/19/17 by DJ.

if ~exist('slowFactor','var') || isempty(slowFactor)
    slowFactor = 1;
end
if ~exist('option','var') || isempty(option)
    option = 'pentatonic';
end    


switch option
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

baseNote = 440; % 440 = A4
freqs = 2.^(notes/12)*baseNote;

% Produce amplitude-modulated sound at these freqs
Fs = 8192; % default for MATLAB's sound function (in Hz)
atlasSound = zeros(1,nT*slowFactor*Fs);
t = (1:nT*slowFactor*Fs)/Fs;
for i=1:nRois
    fprintf('ROI %d/%d...\n',i,nRois)
    amp = interp(atlasTc(i,:),slowFactor*Fs);
    atlasSound = atlasSound + amp.*sin(2*pi*freqs(i)*t);
end
fprintf('Done!\n');