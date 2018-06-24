function [Az, t, vout, fwdmodels] = CompileJlrResults_AcrossSubjects(subjects,taglist)

% Created 12/6/12 by DJ.

% Set up
nSubjects = numel(subjects);
nAnalyses = numel(taglist);
[JLR,JLP] = LoadJlrResults_AcrossSubjects(subjects,taglist{1});
nOffsets = size(JLR{1}.Azloo,2);
nChannels = JLP{1}.ALLEEG(1).nbchan;

% Declare variables
Az = nan(nSubjects,nOffsets,nAnalyses);
t = nan(nSubjects,nOffsets,nAnalyses);
vout = nan(nChannels+1,nOffsets,nSubjects,nAnalyses);
fwdmodels = nan(nChannels,nOffsets,nSubjects,nAnalyses);

% Load and compile data
for i=1:nAnalyses
    if i>1
        [JLR,JLP] = LoadJlrResults_AcrossSubjects(subjects,taglist{i});
    end
    [Az(:,:,i),t(:,:,i),vout(:,:,:,i),fwdmodels(:,:,:,i)] = AverageJlrResults_AcrossSubjects(JLR,JLP);
end
