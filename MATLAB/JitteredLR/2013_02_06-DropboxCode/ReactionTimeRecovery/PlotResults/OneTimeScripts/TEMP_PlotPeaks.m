% Make plots to compare ideal algorithm's stim time recovery with JLR's max
% posterior times (recovered stim times).
%
% Created 10/8/12 by DJ for one-time use.
% Updated 1/2/13 by DJ - Colormaps of Stim-locked time used in each Resp-locked window
% Updated 1/15/13 by DJ - comments

%% Get the time of peak posterior for each subject 
% (use TEMP_CompareJlrAndLr first to compile results)
tPrior = JLRavg{1}.postTimes;
nwin = length(JLR{i}.trainingwindowoffset);
[pks tPks jitter truth RTall] = deal(cell(1,numel(subjects)));
for i=1:numel(subjects)
    for j=1:nwin
        [~,pks{i}(:,j)] = max(JLRavg{i}.post_truth(:,:,j),[],2);        
        tPks{i}(:,j) = tPrior(pks{i}(:,j)) + JLP{i}.ALLEEG(1).times(JLR{i}.trainingwindowoffset(j) + JLR{i}.trainingwindowlength/2);        
        [jitter{i},truth{i},RTall{i}] = GetJitter(JLP{i}.ALLEEG,'facecar');
        
    end
end

%% Plot true stim times and max posterior time in each window
figure(15); clf;
for i=1:6
    t=JLP{i}.ALLEEG(1).times(JLR{i}.trainingwindowoffset + JLR{i}.trainingwindowlength/2); 

    % Image stim-locked time at each resp-locked window
    subplot(6,2,2*i-1); cla;
%     subplot(2,6,i); cla;
    ImageSortedData(repmat(t,sum(truth{i}==0),1)-repmat(-RTall{i}(truth{i}==0)',1,nwin),t,1:sum(truth{i}==0),-RTall{i}(truth{i}==0));
    ImageSortedData(repmat(t,sum(truth{i}==1),1)-repmat(-RTall{i}(truth{i}==1)',1,nwin),t,sum(truth{i}==0)+1:numel(truth{i}),-RTall{i}(truth{i}==1));
    colorbar
    title(sprintf('Subject %d: LR',i));
    ylabel('<-- cars  |  faces -->')
%     xlim([-max(RTall{i}),0])
    xlim([-800,0])
    ylim([0 length(RTall{i})]+0.5)
    set(gca,'clim',[-500 1000])

    % Image stim-locked time of inferred peak at each resp-locked window
    subplot(6,2,2*i); cla;
%     subplot(2,6,6+i); cla;
    ImageSortedData(tPks{i}(truth{i}==0,:)-repmat(-RTall{i}(truth{i}==0)',1,nwin),t,1:sum(truth{i}==0),-RTall{i}(truth{i}==0));
    ImageSortedData(tPks{i}(truth{i}==1,:)-repmat(-RTall{i}(truth{i}==1)',1,nwin),t,sum(truth{i}==0)+1:numel(truth{i}),-RTall{i}(truth{i}==1));
    colorbar
    title(sprintf('Subject %d: JLR',i));
    % set(gca,'clim',[0 100])
    ylabel('<-- cars  |  faces -->')
%     xlim([-max(RTall{i}),0])
    xlim([-800,0])
    ylim([0 length(RTall{i})]+0.5)
    set(gca,'clim',[-500 1000])
%     xlabel('Time of resp-locked window center')
end
subplot(6,2,11);
xlabel('Time of resp-locked window center')
subplot(6,2,12);
xlabel('Time of resp-locked window center')
MakeFigureTitle('Stimulus-locked time used in each Response-locked window');
%% Plot max posterior times in all windows as dots

figure(16); clf;

for i=1:6
    cars = find(truth{i}==0);
    faces = find(truth{i}==1);
    [~,order] = sort(-RTall{i}(cars));
    cars_sorted = cars(order);
    [~,order] = sort(-RTall{i}(faces));
    faces_sorted = faces(order);
    % Plot RT-locked
    subplot(6,2,2*i-1); cla; hold on;
    for j=1:numel(cars_sorted)
        scatter(tPks{i}(cars_sorted(j),:),j+0.4*rand(1,size(tPks{i},2)),'b.');
    end
    for j=1:numel(faces_sorted)
        scatter(tPks{i}(faces_sorted(j),:),numel(cars_sorted)+j+0.4*rand(1,size(tPks{i},2)),'r.');
    end
    plot([0 0],[0 length(truth{i})],'k--');
    plot([0 0]-mean(RTall{i}),[0 length(truth{i})],'k--');
    plot(-RTall{i}(cars_sorted),1:numel(cars_sorted),'k-','linewidth',2);
    plot(-RTall{i}(faces_sorted),numel(cars_sorted)+(1:numel(faces_sorted)),'k-','linewidth',2);
    ylim([0 length(truth{i})]);
    xlim([-1000 200])
    ylabel(subjects{i})
    % Plot stim-locked
    subplot(6,2,2*i); cla; hold on;
    for j=1:numel(cars_sorted)
        scatter(tPks{i}(cars_sorted(j),:)+RTall{i}(cars_sorted(j)),j+0.4*rand(1,size(tPks{i},2)),'b.');
    end
    for j=1:numel(faces_sorted)
        scatter(tPks{i}(faces_sorted(j),:)+RTall{i}(faces_sorted(j)),numel(cars_sorted)+j+0.4*rand(1,size(tPks{i},2)),'r.');
    end
    plot([0 0],[0 length(truth{i})],'k--');
    plot([0 0]+mean(RTall{i}),[0 length(truth{i})],'k--');
    plot(RTall{i}(cars_sorted),1:numel(cars_sorted),'k-','linewidth',2);
    plot(RTall{i}(faces_sorted),numel(cars_sorted)+(1:numel(faces_sorted)),'k-','linewidth',2);
    ylim([0 length(truth{i})]);
    xlim([-400 800])
end
subplot(6,2,11);
xlabel('time from response (ms)')
subplot(6,2,12);
xlabel('time from stimulus (ms)')
MakeFigureTitle('Peak Posterior Times in all windows');

%% Plot max posterior times in all windows as grayscale image
figure(18); clf;
for i=1:6
    % Set up
    cars = find(truth{i}==0);
    faces = find(truth{i}==1);    
    % Get
    xhist = -1200:400;
    y=zeros(length(truth{i}),length(xhist));
    for j=1:length(truth{i})
        y(j,:) = hist(tPks{i}(j,:),xhist);
    end
    % Smooth
    sigma = 20; 
    gaussian = normpdf(-500:500,0,sigma);
    gaussian = gaussian/sum(gaussian);
    y = conv2(y,gaussian,'same');
%     y = conv2(y,ones(1,50),'same');
    % Plot
    subplot(6,2,2*i-1); cla; hold on;
    ImageSortedData(y(cars,:),xhist,1:numel(cars),-RTall{i}(cars));
    ImageSortedData(y(faces,:),xhist,numel(cars)+(1:numel(faces)),-RTall{i}(faces));
    colormap gray
    % Annotate    
    plot([0 0],[0 length(truth{i})],'k--');
    plot([0 0]-mean(RTall{i}),[0 length(truth{i})],'k--');
%     plot(-RTall{i}(cars_sorted),1:numel(cars_sorted),'k-','linewidth',2);
%     plot(-RTall{i}(faces_sorted),numel(cars_sorted)+(1:numel(faces_sorted
%     )),'k-','linewidth',2);
    plot([xhist(1) xhist(end)],[0 0]+length(cars),'k')
    ylim([0 length(truth{i})]);
    xlim([-1000 200])
    title(subjects{i})
    ylabel('<-- cars  |  faces -->')
    
    
    % Stim-locked
    % Get
    xhist = -600:1000;
    y=zeros(length(truth{i}),length(xhist));
    for j=1:length(truth{i})
        y(j,:) = hist(tPks{i}(j,:)+RTall{i}(j),xhist);
    end
    % Smooth
    gaussian = normpdf(-500:500,0,sigma);
    gaussian = gaussian/sum(gaussian);
    y = conv2(y,gaussian,'same');
%     y = conv2(y,ones(1,50),'same');
    % Plot
    subplot(6,2,2*i); cla; hold on;    
    ImageSortedData(y(cars,:),xhist,1:numel(cars),RTall{i}(cars),'descend');
    ImageSortedData(y(faces,:),xhist,numel(cars)+(1:numel(faces)),RTall{i}(faces),'descend');
    plot([0 0],[0 length(truth{i})],'k--');
    plot([0 0]+mean(RTall{i}),[0 length(truth{i})],'k--');
%     plot(RTall{i}(cars_sorted),1:numel(cars_sorted),'k-','linewidth',2);
%     plot(RTall{i}(faces_sorted),numel(cars_sorted)+(1:numel(faces_sorted)),'k-','linewidth',2);
    plot([xhist(1) xhist(end)],[0 0]+length(cars),'k')
    ylim([0 length(truth{i})]);
    xlim([-400 800])
    title(subjects{i})
    ylabel('<-- cars  |  faces -->')        
end
colormap(1-colormap('gray'))
subplot(6,2,11);
xlabel('time from response (ms)')
subplot(6,2,12);
xlabel('time from stimulus (ms)')
MakeFigureTitle('Peak Posterior Times in all windows');