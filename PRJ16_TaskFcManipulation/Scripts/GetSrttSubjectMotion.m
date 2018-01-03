function subjMotion = GetSrttSubjectMotion(subjects)

% Set Up
motionStr = 'average motion (per TR)';
subjMotion = nan(1,numel(subjects));
% Get Motion
for i=1:numel(subjects)
    % Get text from file
    filename = sprintf('/data/jangrawdc/PRJ16_TaskFcManipulation/RawData/%s/%s.srtt_v2/out.ss_review.%s.txt',subjects{i},subjects{i},subjects{i});
    if ~exist(filename,'file')
        fprintf('Skipping %s...\n',subjects{i});
    else
        fid = fopen(filename);
        allText = textscan(fid,'%s %s','delimiter',':');
        fclose(fid);
        % Extract motion value
        isAvgMotionLine = strncmpi(allText{1},motionStr,length(motionStr));
        subjMotion(i) = str2double(allText{2}{isAvgMotionLine});
    end
end
    

