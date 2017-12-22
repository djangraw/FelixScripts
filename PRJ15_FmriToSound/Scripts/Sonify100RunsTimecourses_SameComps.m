% Sonify100RunsTimecoureses_SameComps.m
%
% Created 12/21/17 by DJ.

% Load components
cd /Volumes/data/PRJ15_FmriToSound/TestData/100RUNS_3Tmultiecho
[icTcs_accepted,betas_accepted,iAccepted] = Get100RunsAcceptedCompTcs(1,1,1);
varex = var(icTcs_accepted)';
[varex_sorted,order] = sort(varex,'descend');
% icTcs_sorted = icTcs_this(:,order);
betas_sorted = betas_accepted.img(:,:,:,order);  
betas_cropped = betas_sorted(:,:,:,1:10);
varex_cropped = varex_sorted(1:10);

% Plot timecourses
figure(562); clf;
mask = any(betas_sorted~=0,4);
PlotComponents_3Planes(betas_cropped, mask, varex_sorted)

%% Load data
compTc = cell(1,3,13);
for i=1
    for j=1:3
        for k=1:13
            fprintf('subj %d, session %d, run %d...\n',i,j,k);
            filename = sprintf('SBJ%02d_S%02d_Task%02d_dn_ts_OC.nii',i,j,k);
            if exist(filename,'file')
                compTc{i,j,k} = GetComponentTimecourses(filename,betas_cropped);
            end
        end
    end
end
fprintf('Done!\n');

%% Append and Sonify
slowFactor = 0.1;
percentileCutoff = 70;
TR = 2;
% % Plot timecourse of task
% figure(3);
% imagesc(tTask_this*slowFactor/TR,1:3,taskTc_this);

% Append
fprintf('Appending & scaling...\n');
compTc_cropped = cat(2,compTc{:});

% scale IC TCs
icTcs_scaled = (compTc_cropped-GetValueAtPercentile(compTc_cropped,percentileCutoff))*100;
icTcs_scaled(icTcs_scaled<0) = 0;

fprintf('Sonifying...\n');
[atlasSound,Fs] = SonifyAtlasTimecourses_midi(icTcs_scaled,slowFactor,'pentatonic','sine');
fprintf('Plotting & Playing...\n');
PlotAndPlaySonifiedData(icTcs_scaled,slowFactor,atlasSound,Fs);
fprintf('Done!\n');