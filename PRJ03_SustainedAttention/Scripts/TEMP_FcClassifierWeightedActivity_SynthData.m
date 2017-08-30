function TEMP_FcClassifierWeightedActivity_SynthData
% TEMP_FcClassifierWeightedActivity_SynthData.m
%
% Created 4/18/16 by DJ.


% set up time constants
nT = 1000;
fs = 10;
% t_events = [10 50 90];
% nT = 1000;
% t_1 = 10; t_2 = 50; t_3 = 90;
t_events = [10 30 50 70 90];

fcWinLength = 100;

t = (1:nT)/fs;

% declare blocks
nCond = numel(t_events)-1;
isCond = false(nCond,length(t));
for i=1:nCond
    isCond(i,:) = t>=t_events(i) & t<t_events(i+1);
end
isBaseline = t<t_events(1) | t>=t_events(end);

% Make synthetic data
% ROIs 1 & 2 are informative
if nCond==2
    nROIs = 3;
    data = nan(nROIs,nT);
    data(:,isBaseline) = 0;

    data(1,isCond(1,:)) = 3*sin(t(isCond(1,:))*2*pi/10);
    data(1,isCond(2,:)) = 3*sin(t(isCond(2,:))*2*pi/10);
    data(2,isCond(1,:)) = 2*-sin(t(isCond(1,:))*2*pi/10);
    data(2,isCond(2,:)) = 2*sin(t(isCond(2,:))*2*pi/10);
    data(3,isCond(1,:)) = sin(t(isCond(1,:))*2*pi/5);
    data(3,isCond(2,:)) = sin(t(isCond(2,:))*2*pi/5);
    % Make synthetic events
    iFcEventSample = [20:5:40, 60:5:80]*fs;
else
    % ROIs 1&2 in 1st & 2nd, ROIs 3&4 in 3rd & 4th
    nROIs = 4;
    data = nan(nROIs,nT);
    data(:,isBaseline) = 0;
    data([1 3],~isBaseline) = repmat(sin(t(~isBaseline)*2*pi/5),2,1);
    data([2 4],~isBaseline) = repmat(cos(t(~isBaseline)*2*pi/5),2,1);
    data(1,isCond(1,:)) = 3*sin(t(isCond(1,:))*2*pi/10);
    data(1,isCond(2,:)) = 3*sin(t(isCond(2,:))*2*pi/10);
    data(2,isCond(1,:)) = 2*-sin(t(isCond(1,:))*2*pi/10);
    data(2,isCond(2,:)) = 2*sin(t(isCond(2,:))*2*pi/10);
    data(3,isCond(3,:)) = 1*sin(t(isCond(3,:))*2*pi/10);
    data(3,isCond(4,:)) = 1*sin(t(isCond(4,:))*2*pi/10);
    data(4,isCond(3,:)) = .5*-sin(t(isCond(3,:))*2*pi/10);
    data(4,isCond(4,:)) = .5*sin(t(isCond(4,:))*2*pi/10);
    % Make synthetic events
    iFcEventSample = [t_events(1)+10:5:t_events(end)-10]*fs;
end
% data = data + randn(size(data))*.2;

% Plot synthetic data
figure(455); clf;
X = data;
maxX = max(abs(X(:)));
ylimits = [-1 1]*maxX*1.2;
for i=1:nROIs
    subplot(nROIs,1,i);
    if i==1
        title('Raw Signal in ROIs')
    end
    hold on;
    % draw blocks
    drawBlocks(t_events,ylimits);
    % draw lines
    plot(t,data(i,:));
    ylim(ylimits)
    PlotVerticalLines(t_events,'r--');
    grid on
    ylabel(sprintf('ROI %d',i));
end
xlabel('time (samples)')


% iFcEventSample = [120:5:480, 520:5:880];
truth = zeros(size(iFcEventSample));
for i=1:nCond
    if mod(i,2)==0
        truth(isCond(i,iFcEventSample)) = 1;
    end
end
fracFcVarToKeep = 1;

% Run through FcClassifier
[D,C,B,Z,Vx,Y,AzLoo] = GetFcClassifierWeightedActivity(X,fracFcVarToKeep,iFcEventSample,truth,fcWinLength);

% Plot weights
figure(456); clf;
maxB = max(abs(B(:)));
ylimits = [-.2 1]*maxB*1.2;
tB = t((1:size(B,2))+round(fcWinLength/2));
for i=1:nROIs
    subplot(nROIs,1,i);
    hold on;
    if i==1
        title('Weight on ROIs')
    end
    % draw blocks
    drawBlocks(t_events,ylimits);
    % draw lines
    plot(tB,B(i,:));
    ylim(ylimits)
    PlotVerticalLines(t_events,'r--');
    grid on
%     ylabel(sprintf('ROI-PC %d',i)); % technically right
    ylabel(sprintf('ROI %d',i)); % simpler
end
xlabel('time (samples)')

% Plot results
figure(457); clf;
maxD = max(abs(D(:)));
ylimits = [-1 1]*maxD;
for i=1:nROIs
    subplot(nROIs,1,i);
    hold on;
    if i==1
        title('Weighted Signal in ROIs')
    end
    % draw blocks
    drawBlocks(t_events,ylimits);
    % draw lines
    plot(t(1:size(D,2)),D(i,:));
    ylim(ylimits)
    PlotVerticalLines(t_events,'r--');
    grid on
    ylabel(sprintf('ROI %d',i));
end
xlabel('time (samples)')

figure(458); clf;
maxZ = max(abs(Z(:)));
ylimits = [-1 1]*maxZ*1.2;
for i=1:nROIs
    subplot(nROIs,2,i*2-1);
    hold on;
    bar(Vx(:,i));
    ylabel(sprintf('weight of \nROI in ROI-PC %d',i));
    subplot(nROIs,2,i*2);
    hold on;
    % draw blocks
    drawBlocks(t_events,ylimits);
    % draw lines
    plot(t(1:size(Z,2)),Z(i,:));
    ylim(ylimits)
    PlotVerticalLines(t_events,'r--');
    grid on
    ylabel(sprintf('activity of \nROI-PC %d',i));
end
xlabel('time (samples)')




function h = drawBlocks(t_events,ylimits)
    nCond = length(t_events)-1;
    for j=1:nCond
        if mod(j,2)==1
            h(j) = patch([t_events(j),t_events(j+1), t_events(j+1),t_events(j)],...
                [ylimits(1), ylimits(1), ylimits(2), ylimits(2)],...
                'g','facecolor','g','facealpha',0.25);
        else
            h(j) = patch([t_events(j),t_events(j+1), t_events(j+1),t_events(j)],...
                [ylimits(1), ylimits(1), ylimits(2), ylimits(2)],...
                'r','facecolor','r','facealpha',0.25);
        end
    end