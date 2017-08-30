% GetSpatialTemplateMatch_script.m
%
% Created 5/2/16 by DJ.

% Set up
subject = 'SBJ09';
templateFilename = '/spin1/users/jangrawdc/PRJ03_SustainedAttention/Collaborations/CatieChang/spmT_0001.nii';
tcFilename = sprintf('errts.%s.tproject+tlrc',subject);
maskFilename = sprintf('full_mask.%s+tlrc',subject);
winLength = 10; % in TRs
TR = 2; % in seconds

% Load data
fprintf('Loading data...\n')
[err,template,Info,errMsg] = BrikLoad(templateFilename);
[err,timecourse,Info,errMsg] = BrikLoad(tcFilename);
[err,mask,Info,errMsg] = BrikLoad(maskFilename);

%% Normalize each voxel's timecourse
fprintf('Normalizing voxel-wise timecourses...\n')
nT = size(timecourse,4);
tcMean = mean(timecourse,4);
tcStd = std(timecourse,[],4);
timecourse_norm = (timecourse-repmat(tcMean,1,1,1,nT))./repmat(tcStd,1,1,1,nT);

%% Get match timecourse
fprintf('Getting match timecourses...\n')
isInMask = mask>0;
arousalTemplate_vec = template(isInMask);
templateMatch = nan(1,nT);
for i=1:nT
    tcNow = timecourse_norm(:,:,:,i);
    tcNow_vec = tcNow(isInMask);
    templateMatch(i) = corr(tcNow_vec(~isnan(tcNow_vec)),arousalTemplate_vec(~isnan(tcNow_vec)));
end
    
%% Plot results
fprintf('Plotting match timecourses...\n')
t = (1:nT)*TR;
plot(t,templateMatch);
xlabel('time (s)');
ylabel('match strength (correlation coeff)')
title(subject)
