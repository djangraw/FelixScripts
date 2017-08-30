function [allEllipses,brightness,isOutlier] = DetectUsingEllipses(video,iFrames,objToDetect,doPlot,ROI)

% DetectUsingEllipses.m
%
% Created 4/16 by DJ
% Updated 5/3/16 by DJ.

%% LOAD VIDEOS
% filename='Distraction-9-calib1-quicktime.mov';
if ~exist('video','var') || isempty(video)
    video='Distraction-9-5-quicktime.mov';
end
if ~exist('iFrames','var')
    iFrames = []; % [] for all frames
end
if ~exist('objToDetect','var') || isempty(objToDetect)
    objToDetect = 'Pupil'; % 'CR'; % 
end
if ~exist('doPlot','var') || isempty(doPlot)
    doPlot = false;
end
if ~exist('ROI','var') || isempty(ROI)
    ROI = [80 150 130 200];
end

% Get video
if ischar(video) % if it's a filename    
    % load video
    filename = video;
    nFrames = iFrames;
    iFrames = [];
    video = ReadInEyeVideo(filename,nFrames);
else
    filename = '';
end
% Interpret empty iFrames as all frames in video
if isempty(iFrames)
    iFrames = 1:size(video,3);
end

%% DETECT PUPIL OR CR!

% Get ROI limits in image
iROI = ROI(1):ROI(2); % rows
jROI = ROI(3):ROI(4); % columns

% Get sub-image index matrices
[X,Y] = meshgrid(1:numel(jROI),1:numel(iROI));

% override some default ellipse detection parameters    
params.randomize = 0; % don't randomize search
params.numBest = 1; % pick 1 best ellipse
switch objToDetect
    case 'Pupil' % for Pupil detection
        params.minMajorAxis = 10;
        params.maxMajorAxis = 40;
        params.minMinorAxis = 10;
        params.maxMinorAxis = 40;    
        edgeThreshold = 0.3;
    case 'CR' % for Corneal Reflection detection
        params.minMajorAxis = 3;
        params.maxMajorAxis = 10;
        params.minMinorAxis = 3;
        params.maxMinorAxis = 10;
        edgeThreshold = 0.9;
end
% Set up
allEllipses = nan(numel(iFrames),6); % (xc,yc,a,b,rot,score)
brightness = nan(numel(iFrames),2); % (mean,std)
if doPlot
    figure(622); clf;
    nRows = ceil(sqrt(numel(iFrames)));
    nCols = ceil(numel(iFrames)/nRows);    
    MakeFigureTitle(sprintf('%s detection for file %s',objToDetect,filename));
end
% Do main plot
for i = 1:numel(iFrames)
    iFrame = iFrames(i);
    fprintf('--- frame %d/%d...\n',i,numel(iFrames));
    
    % Crop image to ROI
    I = double(video(iROI,jROI,iFrame));
    
    % Get edge image
    E = edge(I,'Canny',edgeThreshold);

    % Get best ellipse fit
    % note that the edge (or gradient) image is used
    allEllipses(i,:) = ellipseDetection(E, params);        
    
    % Get mean & std brightness inside ellipse 
    xc = allEllipses(i,1);
    yc = allEllipses(i,2);
    a = allEllipses(i,3);
    b = allEllipses(i,4);
    t = allEllipses(i,5);
    isInEllipse = ((X-xc)*cos(t)-(Y-yc)*sin(t)).^2/a^2 + ...
 ((X-xc)*sin(t)+(Y-yc)*cos(t)).^2/b^2 <= 1;
    brightness(i,1) = mean(I(isInEllipse));
    brightness(i,2) = std(I(isInEllipse));
    
    %% plot results
    if doPlot        
        subplot(nRows,nCols,i);
        cla;
        I_scaled = I/max(I(:));
        imagesc(cat(3,I_scaled,I_scaled + double(E),I_scaled + double(E)));
        colormap gray
        set(gca,'clim',[0 max(E(:))])
        %ellipse drawing implementation: http://www.mathworks.com/matlabcentral/fileexchange/289 
        h = ellipse(allEllipses(i,3),allEllipses(i,4),allEllipses(i,5)*pi/180,allEllipses(i,1),allEllipses(i,2),'r');
        set(h,'linewidth',2);        
        title(sprintf('Frame %d',iFrame));
    end
end

%% Find outliers
isOutlier = false(numel(iFrames),1);
% Size is not in specified ranges
isOutlier(allEllipses(:,3)<params.minMajorAxis | allEllipses(:,3)>params.maxMajorAxis) = true;
isOutlier(allEllipses(:,4)<params.minMinorAxis | allEllipses(:,4)>params.maxMinorAxis) = true;
% Brightness is not as expected
switch objToDetect
    case 'Pupil'
        
    case 'CR'
        
end

% Interpolate outliers


%% Plot ellipse histograms
figure(623); clf;
colNames = {'x_{center}','y_{center}', 'major axis','minor axis','angle (deg)', 'score','mean brightness','std brightness'};
for j=1:8
    subplot(2,4,j); 
    if j<=6
        xHist = linspace(min(allEllipses(:,j)),max(allEllipses(:,j)),20);
        hist(allEllipses(:,j),xHist);
    else
        xHist = linspace(min(brightness(:,j-6)),max(brightness(:,j-6)),20);
        hist(brightness(:,j-6),xHist);
    end    
    xlabel(colNames{j});
    ylabel('# frames');
end
MakeFigureTitle(sprintf('%s ellipse histograms for file %s',objToDetect,filename));
%% Plot timecourses
figure(624); clf;
for j=1:8
    subplot(2,4,j); hold on;
    if j<=6
        plot(iFrames,allEllipses(:,j));
        plot(iFrames(isOutlier),allEllipses(isOutlier,j),'ro');
    else
        plot(iFrames,brightness(:,j-6));
        plot(iFrames(isOutlier),brightness(isOutlier,j-6),'ro');
    end
    ylabel(colNames{j});
    xlabel('time (frames)');
    legend('all','outliers');
end
MakeFigureTitle(sprintf('%s ellipse timecourses for file %s',objToDetect,filename));



