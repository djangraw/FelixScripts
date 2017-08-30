function FCavg = GetAvgFcAcrossTasks(FC,fcTasks,taskNames)

% FCavg = GetAvgFcAcrossTasks(FC,fcTasks,taskNames)
%
% Created 11/23/16 by DJ.


% Declare defaults
if ~exist('fcTasks','var') || isempty(fcTasks)
    fcTasks = {'REST','BACK','VIDE','MATH'};

end
if ~exist('taskNames','var') || isempty(taskNames)
    taskNames = {'REST01-001','BACK01-001','VIDE01-001','MATH01-001','BACK02-001','REST02-001','MATH02-001','VIDE02-001'};
end

% Compile and average across tasks
isOkTask = false(size(FC,3),1);
for i=1:numel(fcTasks)
    isOkTask = isOkTask | strncmp(fcTasks{i},taskNames,length(fcTasks{i}));
end
FCavg = squeeze(nanmean(FC(:,:,isOkTask,:),3));

% Remove ROIs missing in any subject
isBadRoi = false(1,size(FC,1));
nSubj = size(FCavg,3);
for i=1:nSubj
    isBadRoi_this = all(isnan(FCavg(:,:,i)) | FCavg(:,:,i)==0);
    isBadRoi = isBadRoi | isBadRoi_this;
end
FCavg(isBadRoi,:,:) = NaN;
FCavg(:,isBadRoi,:) = NaN;

