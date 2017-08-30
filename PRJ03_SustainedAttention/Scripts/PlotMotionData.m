function PlotMotionData(motion_file,deriv_file,censor_file,TR,nRuns)

% PlotMotionData(motion_file,deriv_file,censor_file,TR,nRuns)
%
% Created 2/11/16 by DJ. 
% Updated 11/15/16 by DJ - allow empty censor_file.

% Declare defaults
if ~exist('TR','var') || isempty(TR)
    TR = 1;
end
if ~exist('nRuns','var') || isempty(nRuns)
    nRuns=1;
end
if ~exist('censor_file','var')
    censor_file=[];
end

% Read in files
if ischar(motion_file)
    [err,motion] = Read_1D(motion_file);
else
    motion = motion_file;
    motion_file = 'Unknown Filename';
end
if ischar(deriv_file)
    [err,deriv] = Read_1D(deriv_file);
else
    deriv = deriv_file;
end
if isempty(censor_file)
    keep = ones(size(motion,1),1);
else
    [err,keep] = Read_1D(censor_file);
end

% turn binary censor vector into time list
censor_start = find(diff([0; ~keep; 0])>0);
censor_end = find(diff([0; ~keep; 0])<0);    

% Get times
nSamples = size(motion,1);
times = (1:nSamples)*TR;

% Get inter-run gaps
nSamplesPerRun = round(nSamples/nRuns);
run_switch_indices = nSamplesPerRun:nSamplesPerRun:nSamples-1;

%% Plot files
% labels = {'\Delta A-P (mm)','\DeltaR-L (mm)','\DeltaI-S (mm)','Yaw (\circ)','Pitch (\circ)','Roll (\circ)'};
labels = {'\Delta A-P','\DeltaR-L','\DeltaI-S','Yaw','Pitch','Roll'};
colors = distinguishable_colors(7);
clf;
for i=1:6
    % Draw motion
    h(i) = subplot(6,2,i*2-1); 
    cla; hold on;
    plot(times, motion(:,i),'color',colors(i,:));
    xlabel('time')
    ylabel(labels{i})
    yl = get(gca,'ylim');
    % add censor rectangles
    for j=1:numel(censor_start)
        p = patch(([censor_start(j), censor_end(j),censor_end(j),censor_start(j), censor_start(j)]-1/2)*TR,...
            [yl(1),yl(1),yl(2),yl(2),yl(1)],colors(end,:));
        set(p,'FaceAlpha',0.5,'EdgeAlpha',0)
    end
    PlotVerticalLines((run_switch_indices-0.5)*TR,'k:');
    PlotHorizontalLines(0,'k-');
    ylim(yl);
    
    % draw derivative
    subplot(6,2,i*2); 
    cla; hold on;
    plot(times, deriv(:,i),'color',colors(i,:));
    xlabel('time')
    ylabel(['d/dt ' labels{i}])
    yl = get(gca,'ylim');
    % add censor rectangles
    for j=1:numel(censor_start)
        p = patch(([censor_start(j), censor_end(j),censor_end(j),censor_start(j), censor_start(j)]-1/2)*TR,...
            [yl(1),yl(1),yl(2),yl(2),yl(1)],colors(end,:));
        set(p,'FaceAlpha',0.5,'EdgeAlpha',0)
    end
    PlotVerticalLines((run_switch_indices-0.5)*TR,'k:');
    PlotHorizontalLines(0,'k-');
    ylim(yl);
end

linkaxes(h,'x');
% Add figure labels
title(subplot(6,2,1),'Demeaned motion');
title(subplot(6,2,2),'Motion derivative');
MakeFigureTitle(motion_file);