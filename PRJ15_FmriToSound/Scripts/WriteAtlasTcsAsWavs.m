function filenames = WriteAtlasTcsAsWavs(atlasTc,slowFactor,filePrefix,scaleType,synthType)

% filenames = WriteAtlasTcsAsWavs(atlasTc,slowFactor,filePrefix,scaleType,synthType)
%
% Make a wav file for each ROI in an atlas timecourse file.
%
% INPUTS:
%
% OUTPUTS:
%
% Created 12/27/17 by DJ.

% Declare defaults
% atlasTc = repmat([0 1],4,10);
if ~exist('slowFactor','var') || isempty(slowFactor)
    slowFactor = 0.5;
end
if ~exist('filePrefix','var') || isempty(filePrefix)
    filePrefix = 'TestNote';
end
if ~exist('scaleType','var') || isempty(scaleType)
    scaleType = 'pentatonic';
end
if ~exist('synthType','var') || isempty(synthType)
    synthType = 'sine';
end

% Write files
filenames = cell(1,size(atlasTc,1));
for i=1:size(atlasTc,1)
    % Create sound
    atlasTc_cropped = zeros(size(atlasTc));
    atlasTc_cropped(i,:) = atlasTc(i,:);
    [newSound, Fs] = SonifyAtlasTimecourses_midi(atlasTc_cropped, slowFactor, scaleType, synthType);
    % Write file
    filenames{i}=sprintf('%s_%02d_tc.wav',filePrefix,i);
    audiowrite(filenames{i},newSound*10,Fs);
end