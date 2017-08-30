function [readingLectures, ignoreSoundLectures,attendSoundLectures] = GetLectureNumbers(subjects)

% [readingLectures, ignoreSoundLectures,attendSoundLectures] = GetLectureNumbers(subjects)
%
% INPUTS:
% -subjects is an n-element vector of subject numbers.
%
% OUTPUTS:
% -timePerCondition_all is an nxm matrix in which element (i,k) is the
% seconds spent in condition k by subject i.
% -timePerCondition_runs is an n-element cell array containing pxm matrices
% where p is the number of runs for a subject. nSacc_runs{i}(j,k) is the
% number of saccades/s in subject i's run j, condition k.
%
% Created 4/6/17 by DJ.

nSubj = numel(subjects);
[readingLectures,ignoreSoundLectures,attendSoundLectures] = deal(cell(1,nSubj));

for i=1:nSubj
    fprintf('Loading subject %d/%d...\n',i,nSubj);
    beh = load(sprintf('/data/jangrawdc/PRJ03_SustainedAttention/Results/SBJ%02d/Distraction-SBJ%02d-Behavior.mat',subjects(i),subjects(i)));
    [readingLectures{i},ignoreSoundLectures{i},attendSoundLectures{i}] = deal(nan(numel(beh.data),1));
    for j=1:numel(beh.data)
        readingLectures{i}(j) = str2double(beh.data(j).params.imagePrefix(11:12));
        ignoreSoundLectures{i}(j) = str2double(beh.data(j).params.ignoreSoundFile(8:9));
        attendSoundLectures{i}(j) = str2double(beh.data(j).params.attendSoundFile(8:9));
    end
end
fprintf('Done!\n');