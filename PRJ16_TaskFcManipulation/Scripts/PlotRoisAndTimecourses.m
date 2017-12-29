function PlotRoisAndTimecourses(rois,brick,mask,taskTc)

% PlotRoisAndTimecourses(rois,brick,mask,taskTc)
%
% Created 12/28/17 by DJ.

% Set up   
nROIs = max(rois(:));
nT = size(brick,4);
% Declare defaults
if ~exist('taskTc','var') || isempty(taskTc)
    taskTc = nan(nT,1);
end

% Get timecourses
timecourses = nan(nT,nROIs);
fprintf('Getting %d time points...\n',nT);
for i=1:nT
%     fprintf('%d/%d time points...\n',i,nT);
    brickThis = brick(:,:,:,i);
    for j=1:nROIs
        timecourses(i,j) = mean(brickThis(rois==j));
    end
end
fprintf('Plotting...\n');

% Plot
maskScaled = (mask~=0)*.5;
for i=1:nROIs
    % Image ROI with crosshairs at ROI center of mass
    subplot(nROIs,2,2*i-1);
    cla;
    roisThis = (rois==i)*.5;
    slicecoords = round(GetCenterOfMass(roisThis,0));
    Plot3Planes(cat(4,maskScaled,maskScaled+roisThis,maskScaled),slicecoords);
    % Annotate plot
    axis([0 3 0 1]);
    set(gca,'ytick',[],'xtick',0.5:1:2.5,'xticklabel',{'sag','cor','axi'});
    ylabel(sprintf('ROI %d',i));
    % Plot Timecourse
    subplot(nROIs,2,2*i); 
    cla; hold on;
    ax = plotyy(1:nT,timecourses(:,i),1:nT,taskTc);
    xlabel('time (samples)')
    ylabel(ax(1),'mean signal')
    ylabel(ax(2),'task condition')
end

% Finish
fprintf('Done!\n')
