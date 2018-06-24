% Map3dsEyePos.m
%
% Created 12/2/14 by DJ.

subjects = [22:30 32];
sessions_cell = {2:14, [3 6:17], 1:15, 1:15, 1:15, 1:15, 1:15, 1:15, [1:10 12:15], 2:16};
N = numel(subjects);
beh = cell(1,N);
for i=1:N
    beh{i} = loadBehaviorData(subjects(i),sessions_cell{i},'3DS');
end
%%
[sacstart,sacend] = deal(cell(1,N));
for i=1:N
    sacstart_cell = cell(1,numel(beh{i}));
    sacend_cell = cell(1,numel(beh{i}));
    for j=1:length(beh{i})
        sacstart_cell{j} = beh{i}(j).eyelink.saccade_start_positions;
        sacend_cell{j} = beh{i}(j).eyelink.saccade_positions;
    end
    
    sacstart{i} = cat(1,sacstart_cell{:});
    sacend{i} = cat(1,sacend_cell{:});
end

%%
MIN_XY = [0 0];%[-512 -384];
MAX_XY = [1024 768] + MIN_XY;
nBins = 128;
clim = [0 1e-4];

nRows = ceil(sqrt(N));
nCols = ceil(N/nRows);
density = cell(1,N);
for i=1:N
    % set up    
    sacdiff = sacend{i};%-sacstart{i};
%     scatter(sacdiff(:,1),sacdiff(:,2));
    [~,density{i},X,Y] = kde2d(sacdiff,nBins,MIN_XY,MAX_XY);
    % plot    
    subplot(nRows,nCols,i);
    imagesc(X(1,:),Y(:,1),density{i});
    % annotate
    set(gca,'clim',clim,'ydir','reverse');
    title(beh{i}(1).EDF_filename(1:end-4),'Interpreter','none');   
    xlabel('x (pixels)')
    ylabel('y (pixels)')
    colorbar 
end
subplot(nRows,nCols,N+1); cla;
meandens = mean(cat(3,density{:}),3);
imagesc(X(1,:),Y(:,1),meandens);
% annotate
set(gca,'clim',clim,'ydir','reverse');
title(sprintf('Mean across %d subjects',N));   
xlabel('x (pixels)')
ylabel('y (pixels)')
colorbar
MakeFigureTitle('Saccade Endpoint Density');

%% Get camera pos

% Get camera times
cam = cell(1,N);
for i=1:N
    fprintf('Subject %d/%d...\n',i,N);
    cam{i} = cell(1,numel(sessions_cell{i}));
    for j=1:numel(sessions_cell{i})
        ascfilename = sprintf('3DS-%d-%d.asc',subjects(i),sessions_cell{i}(j));
        cam{i}{j} = NEDE_ParseEvents(ascfilename,{'camera'},[],[]);
    end
end
disp('Done!');

%% Find Corridors
categories = {'still','north','south','east','right','left','other'};
colors = 'rgbcmyk';
camcat = cell(1,N);
for i=1:N
    camcat{i} = cell(1,numel(sessions_cell{i}));
    subplot(nRows,nCols,i); cla; hold on;
    for j=1:numel(sessions_cell{i})
        campos = cam{i}{j}.camera.position;
        camdiff = diff(campos,[],1);
        camdiff(abs(camdiff)<1E-3)=0; % round down
        % categorize        
        %still
        isstill = all(camdiff==0,2);
        camcat{i}{j}(isstill) = find(strcmp('still',categories));
        %north
        isnorth = (camdiff(:,1)==0 & camdiff(:,2)>0);
        camcat{i}{j}(isnorth) = find(strcmp('north',categories));
        %south 
        issouth = (camdiff(:,1)==0 & camdiff(:,2)<0);
        camcat{i}{j}(issouth) = find(strcmp('south',categories));
        %east
        iseast = (camdiff(:,1)>0 & camdiff(:,2)==0);
        camcat{i}{j}(iseast) = find(strcmp('east',categories));
        %right
        isright = (camdiff(:,1)>0 & camdiff(:,2)~=0 & campos(1:end-1,2)>100);
        camcat{i}{j}(isright) = find(strcmp('right',categories));
        %left
        isleft = (camdiff(:,1)>0 & camdiff(:,2)~=0 & campos(1:end-1,2)<100);
        camcat{i}{j}(isleft) = find(strcmp('left',categories));
        %other
        camcat{i}{j}(camcat{i}{j}==0) = find(strcmp('other',categories));

%         plot(campos(:,1),campos(:,2),'k--')
    end
    % Plot camera position during last session
    for k=1:numel(categories)
        plot(campos(camcat{i}{j}==k,1),campos(camcat{i}{j}==k,2),'.','markeredgecolor',colors(k));
    end
    legend(categories)
end

%% Get blinks & saccades during each period
[nBlinks,nSaccs,nSec] = deal(cell(1,N));
for i=1:N
    [nBlinks{i},nSaccs{i},nSec{i}] = deal(zeros(1,numel(categories)));    
    for j=1:numel(sessions_cell{i})
        campos = cam{i}{j}.camera.position;
        camtime = cam{i}{j}.camera.time;
        camtype = camcat{i}{j};
        iCamSwitch = find(diff([0 camtype])~=0);
        for k=1:numel(iCamSwitch)-1
            thistype = camtype(iCamSwitch(k));
            blinktimes = beh{i}(j).eyelink.blink_times;
            sacctimes = beh{i}(j).eyelink.saccade_times;
            nNewblinks = sum(blinktimes>=camtime(iCamSwitch(k)) & blinktimes < camtime(iCamSwitch(k+1)));
            nNewsaccs = sum(sacctimes>=camtime(iCamSwitch(k)) & sacctimes < camtime(iCamSwitch(k+1)));
            nBlinks{i}(thistype) = nBlinks{i}(thistype) + nNewblinks;
            nSaccs{i}(thistype) = nSaccs{i}(thistype) + nNewsaccs;
            nSec{i}(thistype) = nSec{i}(thistype) + camtime(iCamSwitch(k+1)) - camtime(iCamSwitch(k));
        end
            
        
    end
end

%% Plot histos
[bps,sps] = deal(zeros(N,numel(categories)));
for i=1:N
    subplot(nRows,nCols,i);
    cla;
    bps(i,:) = nBlinks{i}./nSec{i};
    sps(i,:) = nSaccs{i}./nSec{i};
    bar([bps(i,2:end-1); sps(i,2:end-1)]');
    set(gca,'xtick',1:numel(categories)-2,'xticklabel',categories(2:end-1));
    ylabel('frequency (events/s)')
    xlabel('movement/turn direction')
    title(sprintf('Subject %d',i));
end
subplot(nRows,nCols,i+1); cla; hold on;
meanbps = mean(bps,1);
sembps = std(bps,[],1)/sqrt(N);
meansps = mean(sps,1);
semsps = std(sps,[],1)/sqrt(N);
bar([meanbps(2:end-1); meansps(2:end-1)]');
errorbar((1:5)-.15,meanbps(2:end-1),sembps(2:end-1),'.');
errorbar((1:5)+.15,meansps(2:end-1),semsps(2:end-1),'.');
set(gca,'xtick',1:numel(categories)-2,'xticklabel',categories(2:end-1));
title(sprintf('Mean across %d subjects',N))
ylabel('frequency (events/s)')
xlabel('movement/turn direction')
legend('Blinks','Saccades','stderr')
MakeFigureTitle('Blink & Sacccade Frequencies');

%% Adjust spatial positions
campos_cell = cell(1,N);
iNorth = 2;
iSouth = 3;
for i=1:N
    campos_cell{i} = cell(1,numel(sessions_cell{i}));
    for j=1:numel(sessions_cell{i})
        campos = cam{i}{j}.camera.position(1:end-1,:);
        campos(camcat{i}{j}==iNorth,1) = 0;
        campos(camcat{i}{j}==iSouth,1) = 15;
        isTop = ~ismember(camcat{i}{j},[iNorth iSouth]) & campos(:,2)'>100;
        campos(isTop,1) = campos(isTop,1) - 15*floor(campos(isTop,1)/15);
        isBot = ~ismember(camcat{i}{j},[iNorth iSouth]) & campos(:,2)'<=100;
        campos(isBot,1) = campos(isBot,1) - 15*floor(campos(isBot,1)/15)+15;
        campos_cell{i}{j} = campos;        
    end
    subplot(nRows,nCols,i); cla;
    plot(campos(:,1),campos(:,2),'.');
end

%% Log blink locations
[blinkloc, sacloc,blinkloc_all,sacloc_all] = deal(cell(1,N));
for i=1:N
    [blinkloc{i}, sacloc{i}] = deal(cell(1,numel(sessions_cell{i})));
    for j=1:numel(sessions_cell{i})
        campos = campos_cell{i}{j};
        camtime = cam{i}{j}.camera.time(1:end-1);
        blinktimes = beh{i}(j).eyelink.blink_times;
        % big saccades only
        saccsize = sqrt(sum((beh{i}(j).eyelink.saccade_positions-beh{i}(j).eyelink.saccade_start_positions).^2,2));
        sacctimes = beh{i}(j).eyelink.saccade_times(saccsize>100); 
%         % all saccades
%         sacctimes = beh{i}(j).eyelink.saccade_times;
        % all blinks
        blinkloc{i}{j} = zeros(length(blinktimes),2);
        sacloc{i}{j} = zeros(length(sacctimes),2);
        if ~isempty(blinktimes)
            blinkloc{i}{j}(:,1) = interp1(camtime,campos(:,1),blinktimes,'linear','extrap');
            blinkloc{i}{j}(:,2) = interp1(camtime,campos(:,2),blinktimes,'linear','extrap');
        end
        sacloc{i}{j}(:,1) = interp1(camtime,campos(:,1),sacctimes,'linear','extrap');
        sacloc{i}{j}(:,2) = interp1(camtime,campos(:,2),sacctimes,'linear','extrap');
    end
    blinkloc_all{i} = cat(1,blinkloc{i}{:});
    sacloc_all{i} = cat(1,sacloc{i}{:});
end

    
%% plot spatial heat maps
MIN_XY = [-135 -50];%[-512 -384];
MAX_XY = [250 250] + MIN_XY;
nBins = 64;%128;
clim = [0 .0008];%.02];
clf;
density = cell(1,N);
h = zeros(1,N+1);
for i=1:N
    % set up    
    [~,density{i},X,Y] = kde2d(sacloc_all{i},nBins,MIN_XY,MAX_XY);
%     [~,density{i},X,Y] = kde2d(blinkloc_all{i},nBins,MIN_XY,MAX_XY);
    % plot    
    h(i) = subplot(nRows,nCols,i); cla;
    imagesc(X(1,:),Y(:,1),density{i});
    % annotate
    set(gca,'clim',clim,'ydir','normal');
    title(sprintf('Subject %d',i));   
    xlabel('x pos (m)')
    ylabel('z pos (m)')
    axis([-5 40 -10 170])
    colorbar 
end
h(N+1) = subplot(nRows,nCols,N+1); cla;
meandens = mean(cat(3,density{:}),3);
imagesc(X(1,:),Y(:,1),meandens);
% annotate
set(gca,'clim',clim,'ydir','normal');
title(sprintf('Mean across %d subjects',N));   
xlabel('x pos (m)')
ylabel('z pos (m)')
axis([-5 40 -10 170])
colorbar
linkaxes(h)
MakeFigureTitle('Density of Large Saccades (size>100 pixels)');
% MakeFigureTitle('Blink Density');