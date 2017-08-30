I = imread('ellipse_wiki.png');
E = edge(rgb2gray(I),'canny');

% override some default parameters
params.minMajorAxis = 200;
params.maxMajorAxis = 500;

% note that the edge (or gradient) image is used
bestFits = ellipseDetection(E, params);

fprintf('Output %d best fits.\n', size(bestFits,1));

figure;
image(I);
%ellipse drawing implementation: http://www.mathworks.com/matlabcentral/fileexchange/289 
ellipse(bestFits(:,3),bestFits(:,4),bestFits(:,5)*pi/180,bestFits(:,1),bestFits(:,2),'k');

%% USED BY DJ FOR VIDEO
% iFrames = 50:50:1000;
% iFrames = (50:50:1000)/10;
iFrames = 1:20;
nRows = ceil(sqrt(numel(iFrames)));
nCols = ceil(numel(iFrames)/nRows);
clf;
objToDetect = 'Pupil'; % 'CR'; % 

% override some default parameters    
params.randomize = 0;
params.numBest = 1;
switch objToDetect
    case 'Pupil' % for Pupil detection
        params.minMajorAxis = 10;
        params.maxMajorAxis = 40;
        params.minMinorAxis = 10;
        params.maxMinorAxis = 40;    
        edgeThreshold = 0.2;
    case 'CR' % for Corneal Reflection detection
        params.minMajorAxis = 3;
        params.maxMajorAxis = 10;
        params.minMinorAxis = 3;
        params.maxMinorAxis = 10;
        edgeThreshold = 0.9;
end
for j = 1:numel(iFrames)
    iFrame = iFrames(j);
    fprintf('--- frame %d/%d...\n',j,numel(iFrames));
    xlim = [80 150];
    ylim = [130 200];
    I = video(xlim(1):xlim(2),ylim(1):ylim(2),iFrame);
    
    E = edge(I,'Canny',edgeThreshold);



    % note that the edge (or gradient) image is used
    nFits = 1;
    allFits = nan(params.numBest,6,nFits);
    for i=1:nFits
        allFits(:,:,i) = ellipseDetection(E, params);    
    end
    %
    bestFits = nanmedian(allFits,3);
    fprintf('Output %d best fits.\n', size(bestFits,1));
    %
    subplot(nRows,nCols,j);
    cla;
    I_scaled = double(I)/max(double(I(:)));
    imagesc(cat(3,I_scaled,I_scaled + double(E),I_scaled + double(E)));
    colormap gray
    set(gca,'clim',[0 max(E(:))])
    %ellipse drawing implementation: http://www.mathworks.com/matlabcentral/fileexchange/289 
    colors = 'rgbcmyk';
    for i=1:size(bestFits,1)
        h = ellipse(bestFits(i,3),bestFits(i,4),bestFits(:,5)*pi/180,bestFits(i,1),bestFits(i,2),colors(i));
        set(h,'linewidth',2);
    end
    title(sprintf('Frame %d',iFrame));
end
MakeFigureTitle(sprintf('%s detection for file %s',objToDetect,filename));