%% Load in video
subject = 9;
sessionstr = 'calib1';
filename=sprintf('Distraction-%d-%s-quicktime.mov',subject,sessionstr);
% video = ReadInEyeVideo(filename);
%% Get CR & pupil 
ROI = [80 160 120 220];
doPlot = false;
nFrames = size(video,3);
% iFrames = round(linspace(1,nFrames,100));
iFrames = 1:nFrames;
%% Get Pupil
[allEll,bri,isOut] = DetectUsingEllipses(video,iFrames,'Pupil',doPlot,ROI);
%% Same for CR
[allEll_CR,bri_CR,isOut_CR] = DetectUsingEllipses(video,iFrames,'CR',doPlot,ROI);

%% Plot results in movie
figure(152); clf; hold on;
hImg = imagesc(video(:,:,iFrames(1)));
i=1;
hPup = ellipse(allEll(i,3),allEll(i,4),allEll(i,5)*pi/180,allEll(i,1),allEll(i,2),'r');
hCR = ellipse(allEll_CR(i,3),allEll_CR(i,4),allEll_CR(i,5)*pi/180,allEll_CR(i,1),allEll_CR(i,2),'b');
set([hPup,hCR],'linewidth',2);
colormap gray

for i=1:numel(iFrames)
    set(hImg,'cdata',video(ROI(1):ROI(2),ROI(3):ROI(4),iFrames(i)));
    delete([hPup hCR]);
    hPup = ellipse(allEll(i,3),allEll(i,4),allEll(i,5)*pi/180,allEll(i,1),allEll(i,2),'r');
    hCR = ellipse(allEll_CR(i,3),allEll_CR(i,4),allEll_CR(i,5)*pi/180,allEll_CR(i,1),allEll_CR(i,2),'b');
    set([hPup,hCR],'linewidth',2);
    title(sprintf('Frame %d',iFrames(i)));
    drawnow;
    if isOut(i) || isOut_CR(i)
        pause;
    end
end

%% Save results
ellipses_pupil = allEll;
ellipses_CR = allEll_CR;
brightness_pupil = bri;
brightness_CR = bri_CR;
isOutlier_pupil = isOut;
isOutlier_CR = isOut_CR;
save(sprintf('Distraction-%d-%s-ellipses.mat',subject,sessionstr),'ellipses_*','brightness_*','isOutlier_*');

%% Interpolate outliers
% interpolate
isOutlier = isOutlier_pupil | isOutlier_CR;
ellipses_pupil_interp = ellipses_pupil;
ellipses_pupil_interp(isOutlier,:) = interp1(find(~isOutlier),ellipses_pupil(~isOutlier,:),find(isOutlier));
brightness_pupil_interp = brightness_pupil;
brightness_pupil_interp(isOutlier,:) = interp1(find(~isOutlier),brightness_pupil(~isOutlier,:),find(isOutlier));
ellipses_CR_interp = ellipses_CR;
ellipses_CR_interp(isOutlier,:) = interp1(find(~isOutlier),ellipses_CR(~isOutlier,:),find(isOutlier));
brightness_CR_interp = brightness_CR;
brightness_CR_interp(isOutlier,:) = interp1(find(~isOutlier),brightness_CR(~isOutlier,:),find(isOutlier));

%% Get pos & PD
eyePos = ellipses_pupil_interp(:,1:2) - ellipses_CR_interp(:,1:2);
PD = pi*prod(ellipses_pupil_interp(:,3:4),2);

%% Get saccades & fixations

