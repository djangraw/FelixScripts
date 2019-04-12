function tcInRoi = GetTimecourseInRoi(timecourse,roi,iRoi)

% tcInRoi = GetTimecourseInRoi(timecourse,roi,iRoi)
%
% Created 4/11/19 by DJ.

% Load files if necessary
if ischar(timecourse)
    fprintf('Loading timecourse from %s...\n',timecourse);
    timecourse = BrikLoad(timecourse);
end
if ischar(roi)
    fprintf('Loading mask from %s...\n',roi);
    roi = BrikLoad(roi);
end
% Turn ROI into binary mask
if exist('iRoi','var')
    isInRoi = (roi==iRoi);
else
    isInRoi = (roi>0);
end

% Make 2D
nT = size(timecourse,4);
nVox = numel(timecourse)/nT;
timecourse = reshape(timecourse,[nVox,nT]);
isInRoi = reshape(isInRoi,[nVox,1]);

% Get mean timecourse
tcInRoi = nanmean(timecourse(isInRoi,:),1)';