function [tc,FC] = SaveDistractionFCs(datafile,atlasfile,winLength,outName)

% [tc,FC] = SaveDistractionFCs(datafile,atlasfile,winLength,outName)
% 
% Created 12/18/15 by DJ.


if isnumeric(datafile)
    subject=datafile;
    datafile=sprintf('errts.SBJ%02d.tproject+tlrc.BRIK',subject);
end
if isempty(atlasfile)
    atlasfile='CraddockAtlas_200Rois_epires+tlrc.BRIK';
end
if ~exist('winLength','var') || isempty(winLength)
    winLength = 10;
end
if ~exist('outName','var') || isempty(outName)
    outName = 'TEMP_FC_Results';
%     outName = 'SBJ05_FC_MultiEcho_2015-12-08_Craddock';
end

if isnumeric(atlasfile)
    atlas = atlasfile;
else
    fprintf('===Loading atlas...===\n');
    [err,atlas,atlasInfo,ErrMsg] = BrikLoad(atlasfile);
end

fprintf('===Getting timecourses...===\n');
tc = GetAtlasTimecourses(datafile,atlasfile);
fprintf('===Getting FC...===\n');
FC = GetFcMatrices(tc,'sw',winLength);

fprintf('===Saving as %s...===\n',outName);
save(outName,'tc','FC','winLength');