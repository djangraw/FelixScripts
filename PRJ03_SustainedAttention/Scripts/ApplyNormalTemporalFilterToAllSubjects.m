function ApplyNormalTemporalFilterToAllSubjects(subjects,afniProcFolder,inFileSuffix)

% ApplyNormalTemporalFilterToAllSubjects(subjects,afniProcFolder,inFileSuffix)
%
% Created 11/17/16 by DJ.
% Updated 2/22/17 by DJ - added /Results to homedir

vars = GetDistractionVariables;
if ~exist('subjects','var')
    vars.okSubjects;
elseif ischar(subjects)
    subjects = str2num(subjects); %#ok<ST2NM>
end
if ~exist('afniProcFolder','var')
    afniProcFolder = 'AfniProc_MultiEcho_2016-09-22';
end
if ~exist('suffix','var')
    inFileSuffix = '_Rose';
end
nSubj = numel(subjects);

for i=1:nSubj
    fprintf('Subj %d/%d...\n',i,nSubj);
    cd(sprintf('%s/Results/SBJ%02d/%s',vars.homedir,subjects(i),afniProcFolder));
    inputFilename=sprintf('errts_withSegTc%s.SBJ%02d.tproject+tlrc',inFileSuffix,subjects(i));
    outputFilename=sprintf('errts_withSegTc%s.SBJ%02d.tproject_filtered',inFileSuffix,subjects(i));
    filterVec = normpdf(-3:3,0,1);
    ApplyTemporalFilter(inputFilename,filterVec,outputFilename);
end
fprintf('Done!\n');