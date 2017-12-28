function filename = WriteRoiLocationsForSounds(roiLocs,filePrefix)

% filename = WriteRoiLocationsForSounds(roiLocs,filePrefix)
%
% Writes info for each ROI (x,y,z,wavFilename) to a text file:
% <filePrefix>_locs.txt .
%
% INPUTS:
% 
% OUTPUTS:
%
% Created 12/27/17 by DJ.

if ~exist('filePrefix','var') || isempty(filePrefix)
    filePrefix = 'TestNote';
end

filename = sprintf('%s_locs.txt',filePrefix);
fprintf('Writing text file %s...\n',filename);
fid = fopen(filename);
for i=1:size(roiLocs,1)
    % Write location and sound filename to file
    fprintf(fid,'%.3f %.3f %.3f %s_%02d_tc.wav\n',roiLocs(i,1),roiLocs(i,2),roiLocs(i,3),filePrefix);
end
% Clean up
fclose(fid);
fprintf('Done!\n');