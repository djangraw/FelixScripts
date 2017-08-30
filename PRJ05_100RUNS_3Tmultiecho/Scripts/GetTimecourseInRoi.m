function [Vroi_debased, t, Vbase] = GetTimecourseInRoi(filenames,mask,dir,baselinemask)

% GetTimecourseInRoi(filenames,mask,dir)
%
% INPUTS:
% - filenames is a cell array of strings of the AFNI files (pointers will
% not work!)
% - mask is a string or matrix
% - dir is a string of the prefix for the filenames (including final slash)
%  [default: current directory])
%
% OUTPUTS:
% - Vroi_debased is a T-element vector representing the timecourse of 
%   activity in the ROI with the baseline activity subtracted.
% - t is a T-element vector representing the corresponding times.
% - Vbase is a T-element vector containing the baseline activity.
%
% Created 4/20/15 by DJ.
% Updated 4/22/15 by DJ - added baselinemask input, Vroi and t outputs.
% Updated 4/24/15 by DJ - added option to not use baselinemask. Only plot
%   magnitude.

%% Handle inputs
if ischar(mask)
    [err,mask,MaskInfo,ErrMsg] = BrikLoad(mask);
end
if ~exist('baselinemask','var') 
    baselinemask = [];
elseif ischar(baselinemask)
    [err,baselinemask,BaselineMaskInfo,ErrMsg] = BrikLoad(baselinemask);
end
if ~exist('dir','var')
    dir = [cd '/'];
end

DENOISE = false;

%% Load data
nFiles = numel(filenames);
Info = cell(1,nFiles);
Vroi = cell(1,nFiles);
Vbase = cell(1,nFiles);
fprintf('Loading time series from ROI...\n');
for i=1:nFiles
    fprintf('File %d/%d...\n',i,nFiles);
    [err,V,Info{i},ErrMsg] = BrikLoad([dir, filenames{i}]);
    nT = size(V,4);
    
    if DENOISE
        Vinmask = zeros(sum(mask~=0),nT);
        for j=1:nT
            Vnow = V(:,:,:,j);
            Vinmask(:,j) = Vnow(mask~=0);
        end
        [U,S,V] = svd(Vinmask);
        Vroi{i} = U(1:2,:)*S(1:2,:)*V(1:2')'
    else
        for j=1:nT
            Vnow = V(:,:,:,j);
            Vroi{i}(j) = mean(Vnow(mask~=0));
            Vbase{i}(j) = mean(Vnow(baselinemask~=0));
        end
    end
end
fprintf('Done!\n')
Vroi = cat(1,Vroi{:});
Vbase = cat(1,Vbase{:});

%% De-mean each row (session)
% Vroi_debased = zeros(size(Vroi));
% for i=1:nFiles
%     Vroi_debased(i,:) = Vroi(i,:)-mean(Vroi(i,:));
% end

%% Subtract baseline
% normalize baseline
% From Hasson Science 2004, Note 19:
%To remove the nonselective component from the movie data set for the
%region-specific time course, we z-normalized the common “time course” of
%each subject (Fig.2B), smoothed it with a moving average of three time
%points, and then used it as a GLM predictor, which was fitted to the
%entire data set of the subject. The residual time course (which was not
%explained by the predictor) was saved as a new time course. 

Vroi_debased = nan(size(Vroi));
if isempty(baselinemask)
    % just de-mean the timecourse
    disp('Getting % Signal Change for each timecourse...')
    for i=1:nFiles
        Vroi_debased(i,:) = (Vroi(i,:)-mean(Vroi(i,:)))/mean(Vroi(i,:))*100;
    end
else
    disp('Using GLM to remove influence of baseline mask''s timecourse...')
    for i=1:nFiles
        % Z normalize baseline
        Vbase_norm = (Vbase(i,:) - mean(Vbase(i,:)))/std(Vbase(i,:)-mean(Vbase(i,:)));
        % smooth with 3-sample moving avg
        Vbase_smooth = conv(Vbase_norm,[1 1 1]/3,'same');
        % set up GLM with this and offset as regressors
        X = [Vbase_smooth; ones(size(Vbase_smooth))]';
        y = Vroi(i,:)';
        beta = (X'*X)\(X'*y);
        % use residuals as 'debased' timecourse
        yRecon = X*beta;
        Vroi_debased(i,:) = (y-yRecon)';
    end
end

%% Plot within ROI
TR = 2; % seconds per sample
t = (0:nT-1)*TR; % time course

legendstr = cell(1,nFiles+1);
for i=1:nFiles
    legendstr{i} = sprintf('run %d',i);
end
legendstr{end} = 'Mean';
% figure(156); clf;
% subplot(3,1,1);
cla; hold on;
plot(t,Vroi_debased(1,:),'m','linewidth',2);
plot(t,Vroi_debased([2:end],:));
% PlotUniqueLines(t, Vroi_demeaned);
plot(t,mean(Vroi_debased,1),'k','linewidth',2);
PlotHorizontalLines(0,'k--');
xlabel('time (s)');
ylabel('De-meaned timecourse (A.U.)')
title(sprintf('All %d sessions',nFiles));
legend(legendstr);

% subplot(3,1,2);cla; hold on;
% diff_V = diff(Vroi_debased,[],2); 
% plot(t(2:end),diff_V(1,:),'m','linewidth',2);
% plot(t(2:end),diff_V(2:end,:));
% % PlotUniqueLines(t, Vroi_demeaned);
% plot(t(2:end),mean(diff_V,1),'k','linewidth',2);
% PlotHorizontalLines(0,'k--');
% xlabel('time (s)');
% ylabel('Derivative of timecourse (A.U.)')
% % title(sprintf('All %d sessions',nFiles));
% % legend(legendstr);
% 
% 
% subplot(3,1,3); cla; hold on;
% ste_V = std(Vroi_debased,[],1)/sqrt(nFiles);
% ste_diff_V = std(diff_V,[],1)/sqrt(nFiles);
% plot(t,ste_V,'b');
% plot(t(2:end),ste_diff_V,'r');
% xlabel('time (s)');
% ylabel('standard error across sessions (A.U.)');
% legend('Activity','Derivative')