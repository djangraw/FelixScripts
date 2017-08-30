function [pos0_interp, pos1_interp, rad0_interp, rad1_interp, isOutlierAny] = FindPupilInVideo(video,roi,radius_range0,radius_range1,filename)

% [pos0_interp, pos1_interp, rad0_interp, rad1_interp, isOutlierAny] = FindPupilInVideo(video)
%
% Created 12/29/15 by DJ.
% Updated 12/30/15 by DJ - finished.
% Updated 2/10/16 by DJ - return outliers list

nFrames = size(video,3);
if ~exist('roi','var') || isempty(roi)
    roi = [144, 222, 63, 111]; % xmin xmax ymin ymax
end
if ~exist('radius_range0','var') || isempty(radius_range0)
    radius_range0 = [3 15]; % CR range (make [4 15] for Distraction-8-calib?)
end
if ~exist('radius_range1','var') || isempty(radius_range1)
    radius_range1 = [5 20]; % pupil range
end
if ~exist('filename','var') || isempty(filename)
    filename = 'UnknownFile'; % pupil range
end

%% find pupil and CR
[pos0,pos1] = deal(nan(nFrames,2));
[rad0,rad1] = deal(nan(nFrames,1));
nCircles = nan(nFrames,2);
one_pct = ceil(nFrames/100);
fprintf('===Looking for pupil and CR...===\n');

for i=1:nFrames
    if mod(i,one_pct)==0
        fprintf('%d%% done...\n',round(i/nFrames*100));
    end
    [centers0, radii0, metric0] = imfindcircles(video(:,:,i),radius_range0,'ObjectPolarity','bright'); % corneal reflection
    [centers1, radii1, metric1] = imfindcircles(video(:,:,i),radius_range1,'ObjectPolarity','dark'); % pupil
    if ~isempty(centers0)
        isInRoi0 = centers0(:,1)>roi(1) & centers0(:,1)<roi(2) & centers0(:,2)>roi(3) & centers0(:,2)<roi(4);
        centers0 = centers0(isInRoi0,:);
        radii0 = radii0(isInRoi0,:);
    %     metric0 = metric0(isInRoi0,:);
    end
    if ~isempty(centers1)
        isInRoi1 = centers1(:,1)>roi(1) & centers1(:,1)<roi(2) & centers1(:,2)>roi(3) & centers1(:,2)<roi(4);    
        centers1 = centers1(isInRoi1,:);
        radii1 = radii1(isInRoi1,:);
    %     metric1 = metric1(isInRoi0,:);
    end
    nCircles(i,:) = [numel(radii0), numel(radii1)];
    % If there's just one, option, use it!
    if size(centers0,1)==1 && size(centers1,1)==1
        pos0(i,:) = centers0;
        pos1(i,:) = centers1;
        rad0(i) = radii0;
        rad1(i) = radii1;
    % If there's just one pupil but >1 CR...
    elseif size(centers0,1)>=1 && size(centers1,1)==1
        distToCenter = rssq(centers0 - repmat(centers1,size(centers0,1),1),2);
        iInPupil = find(distToCenter<radii1);
        % If there's >1 CR in the pupil, pick the first (highest imfindcircles certainty) circle.
        if numel(iInPupil) >= 1   
            if numel(iInPupil) > 1
                fprintf('frame %d: %d inner circles found inside %d outer circle.\n',i,numel(iInPupil),size(centers1,1));
            end
            pos0(i,:) = centers0(iInPupil(1),:);
            pos1(i,:) = centers1;
            rad0(i) = radii0(iInPupil(1));
            rad1(i) = radii1;
        % If there's no CRs in the pupil, reject them all.
        else
            fprintf('frame %d: %d inner, %d outer circles found.\n',i,size(centers0,1),size(centers1,1));
%             break
        end
    % If there's just 1 CR but >1 pupil...
    elseif size(centers0,1)==1 && size(centers1,1)>=1
        distToCenter = rssq(centers1 - repmat(centers0,size(centers1,1),1),2);
        iInPupil = find(distToCenter<radii1);
        % If there's >1 pupil around CR, pick the first (highest imfindcircles certainty).
        if numel(iInPupil) >= 1
            if numel(iInPupil) > 1
                fprintf('frame %d: %d inner circles found inside %d outer circle.\n',i,numel(iInPupil),size(centers1,1));
            end
            pos0(i,:) = centers0;
            pos1(i,:) = centers1(iInPupil(1),:);
            rad0(i) = radii0;
            rad1(i) = radii1(iInPupil(1));     
        % If there's no pupils around the CR, reject them all.
        else
            fprintf('frame %d: %d inner, %d outer circles found.\n',i,size(centers0,1),size(centers1,1));
%             break
        end
    % If >1 inner and outer circles were found, use the ones closest to the
    % ones in the previous frame.
    elseif size(centers0,1)>=1 && size(centers1,1)>=1 && i>1 && ~isnan(rad0(i-1))
        distToLast = rssq(centers0 - repmat(pos0(i-1,:),size(centers0,1),1),2);
        [~,iMin0] = min(distToLast);
        distToLast = rssq(centers1 - repmat(pos1(i-1,:),size(centers1,1),1),2);
        [~,iMin1] = min(distToLast);
        pos0(i,:) = centers0(iMin0,:);
        pos1(i,:) = centers1(iMin1,:);
        rad0(i) = radii0(iMin0);
        rad1(i) = radii1(iMin1);
    else
        fprintf('frame %d: %d inner, %d outer circles found.\n',i,size(centers0,1),size(centers1,1));
%         break
    end
end
fprintf('100%% done!\n');

%% USE THIS CODE CELL TO SKIP INTERPOLATION
% pos0_interp = pos0;
% pos1_interp = pos1;
% rad0_interp = rad0;
% rad1_interp = rad1;

%% Plot specific frame
% A = video(:,:,i);
% cla;
% imagesc(A); colormap gray; hold on;
% [centers0, radii0, metric0] = imfindcircles(video(:,:,i),[4 15],'ObjectPolarity','bright'); % corneal reflection
% [centers1, radii1, metric1] = imfindcircles(video(:,:,i),[5 20],'ObjectPolarity','dark'); % pupil
% fprintf('%d inner, %d outer circles found.\n',size(centers0,1),size(centers1,1));
% viscircles(centers0, radii0,'EdgeColor','b');
% viscircles(centers1, radii1,'EdgeColor','r');

%% find blinks (no circles found) and interpolate outliers
isBlink = isnan(pos0(:,1));

isOutlier0 = ([false; abs(diff(pos0(:,1)))>20] & [abs(diff(pos0(:,1)))>20; false]);
switch filename
    case 'Distraction-8-calib-quicktime.mov'
        fprintf('Excluding manually specified outliers...\n')
%         isOutlier0([359, 558, 1405, 1452, 2083]) = true;
        isOutlier0(pos0(:,1)<190) = true;        
        isOutlier0(pos0(:,2)<60) = true;
    case 'Distraction-8-1-quicktime.mov'
        fprintf('Excluding manually specified outliers...\n')        
        isOutlier0(pos0(:,1)>210 | pos0(:,1)<180) = true;
        isOutlier0(pos0(:,2)>90 | pos0(:,2)<70) = true; 
    case 'Distraction-8-2-quicktime.mov'
        fprintf('Excluding manually specified outliers...\n')        
        isOutlier0(pos0(:,1)>210 | pos0(:,1)<180) = true;
        isOutlier0(pos0(:,2)>87 | pos0(:,2)<60) = true; 
    case 'Distraction-8-3-quicktime.mov'
        fprintf('Excluding manually specified outliers...\n')        
        isOutlier0(pos0(:,1)>210 | pos0(:,1)<180) = true;
        isOutlier0(pos0(:,2)>80 | pos0(:,2)<50) = true; 
    case 'Distraction-8-4-quicktime.mov'
        fprintf('Excluding manually specified outliers...\n')        
        isOutlier0(pos0(:,1)<185) = true;
        isOutlier0(pos0(:,2)>70 | pos0(:,2)<38) = true; 
end
pos0_interp = pos0;
pos0_interp(isOutlier0,1) = interp1(find(~isOutlier0 & ~isBlink),pos0(~isOutlier0 & ~isBlink,1),find(isOutlier0));
pos0_interp(isOutlier0,2) = interp1(find(~isOutlier0 & ~isBlink),pos0(~isOutlier0 & ~isBlink,2),find(isOutlier0));
rad0_interp = rad0;
rad0_interp(isOutlier0) = interp1(find(~isOutlier0 & ~isBlink),rad0(~isOutlier0 & ~isBlink),find(isOutlier0));

isOutlier1 = ([false; abs(diff(pos1(:,1)))>1] & [abs(diff(pos1(:,1)))>1; false]);
switch filename
    case 'Distraction-8-calib-quicktime.mov'
        fprintf('Excluding manually specified outliers...\n')
%         isOutlier1([1405, 1447]) = true;
    case 'Distraction-8-1-quicktime.mov'
        fprintf('Excluding manually specified outliers...\n')        
        isOutlier1(pos1(:,1)>210 | pos1(:,1)<180) = true;
        isOutlier1(pos1(:,2)>100) = true;
    case 'Distraction-8-2-quicktime.mov'
        fprintf('Excluding manually specified outliers...\n')        
        isOutlier1(pos1(:,2)>90) = true;
    case 'Distraction-8-4-quicktime.mov'
        fprintf('Excluding manually specified outliers...\n')        
        isOutlier1(pos1(:,1)<185) = true;
end
pos1_interp = pos1;
pos1_interp(isOutlier1,1) = interp1(find(~isOutlier1 & ~isBlink),pos1(~isOutlier1 & ~isBlink,1),find(isOutlier1));
pos1_interp(isOutlier1,2) = interp1(find(~isOutlier1 & ~isBlink),pos1(~isOutlier1 & ~isBlink,2),find(isOutlier1));
rad1_interp = rad1;
rad1_interp(isOutlier1) = interp1(find(~isOutlier1 & ~isBlink),rad1(~isOutlier1 & ~isBlink),find(isOutlier1));

distToCenter = rssq(pos0 - pos1,2);
isOutlierMatch = distToCenter>rad1;

%% interpolate blinks

pos0_interp(isBlink,1) = interp1(find(~isOutlier0 & ~isBlink),pos0(~isOutlier0 & ~isBlink,1),find(isBlink));
pos0_interp(isBlink,2) = interp1(find(~isOutlier0 & ~isBlink),pos0(~isOutlier0 & ~isBlink,2),find(isBlink));
rad0_interp(isBlink) = interp1(find(~isOutlier0 & ~isBlink),rad0(~isOutlier0 & ~isBlink),find(isBlink));
pos1_interp(isBlink,1) = interp1(find(~isOutlier1 & ~isBlink),pos1(~isOutlier1 & ~isBlink,1),find(isBlink));
pos1_interp(isBlink,2) = interp1(find(~isOutlier1 & ~isBlink),pos1(~isOutlier1 & ~isBlink,2),find(isBlink));
rad1_interp(isBlink) = interp1(find(~isOutlier1 & ~isBlink),rad1(~isOutlier1 & ~isBlink),find(isBlink));

%% plot outliers
isOutlierAny = isOutlier0 | isOutlier1 | isOutlierMatch | isBlink;
figure;
subplot(2,1,1);
cla; hold on;
plot([pos0_interp(:,1), pos1_interp(:,1)]);
plot(find(isOutlierAny),[pos0_interp(isOutlierAny,1) pos1_interp(isOutlierAny,1)],'o');
plot(find(isBlink),repmat(nanmean(pos0_interp(:,1)),1,sum(isBlink)),'.');
xlabel('time (samples)');
ylabel('x position (pixels)')
legend('CR','pupil','outlier (CR)','outlier (pupil)','blink');
title(filename);

subplot(2,1,2);
cla; hold on;
plot([pos0_interp(:,2), pos1_interp(:,2)]);
plot(find(isOutlierAny),[pos0_interp(isOutlierAny,2) pos1_interp(isOutlierAny,2)],'o');
plot(find(isBlink),repmat(nanmean(pos1_interp(:,2)),1,sum(isBlink)),'.');
xlabel('time (samples)');
ylabel('y position (pixels)')
legend('CR','pupil','outlier (CR)','outlier (pupil)','blink');

%% plot positions and sizes
figure;
subplot(2,3,1);
plot(pos0_interp);
xlabel('time (samples)')
ylabel('CR pos (pixels)');
legend('x','y');
subplot(2,3,2);
plot(rad0_interp);
xlabel('time (samples)')
ylabel('CR radius (pixels)');
% put title on top middle plot
title(sprintf('%s: detection results',filename),'interpreter','none');
subplot(2,3,3);
plot(nCircles(:,1));
xlabel('time (samples)')
ylabel('# CR circles found (pixels)');
subplot(2,3,4);
plot(pos1_interp);
xlabel('time (samples)')
ylabel('pupil pos (pixels)');
legend('x','y');
subplot(2,3,5);
plot(rad1_interp);
xlabel('time (samples)')
ylabel('pupil radius (pixels)');
subplot(2,3,6);
plot(nCircles(:,2));
xlabel('time (samples)')
ylabel('# pupil circles found (pixels)');

%% play video
% i=1;
% figure(2); clf;
% hImg = imagesc(video(:,:,i));
% hCir0 = viscircles(pos0_interp(i,:),rad0_interp(i),'EdgeColor','b');
% hCir1 = viscircles(pos1_interp(i,:),rad1_interp(i),'EdgeColor','r');
% for i=1:nFrames
%     set(hImg,'CData',video(:,:,i));
%     delete([hCir0 hCir1]);
%     hCir0 = viscircles(pos0_interp(i,:),rad0_interp(i),'EdgeColor','b');
%     hCir1 = viscircles(pos1_interp(i,:),rad1_interp(i),'EdgeColor','r');
%     pause(0.01);
% end