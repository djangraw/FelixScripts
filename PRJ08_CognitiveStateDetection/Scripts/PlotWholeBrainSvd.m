function PlotWholeBrainSvd(U,S,V,mask,dof)

% Created 2/23/16 by DJ.

COMPS_TO_PLOT = 4;

if ischar(mask)
    fprintf('Loading %s...\n',mask);
    [err,mask,Info] = BrikLoad(mask);
end

[X,Y,Z] = size(mask);
T = size(U,2);


% Find elbow
foo = diag(S);
iElbow = getelbow(foo(1:dof)');

% Plot singular values
figure(351); clf;
hold on;
plot(foo);
plot(iElbow,foo(iElbow),'r*');
PlotVerticalLines(dof,'k:');
legend('all SVs','elbow','specified DOF');
xlabel('component rank');
ylabel('singular value');
fprintf('Done!\n');

% Plot PC timecourses
figure(352); clf;
subplot(211);
hold on;
imagesc(V(:,:)');
PlotHorizontalLines(iElbow,'r-');
PlotHorizontalLines(dof,'k:');
set(gca,'ydir','reverse');
ylim([0 T]+0.5);
xlim([0 T]+0.5);
xlabel('time');
ylabel('component');
title('SVD component timecourses');
colorbar;

subplot(212);
hold on;
imagesc(V(:,1:iElbow)');
set(gca,'ydir','reverse');
ylim([0 iElbow]+0.5);
xlim([0 T]+0.5);
xlabel('time');
ylabel('component');
title('Top component timecourses');
colorbar;

% Plot top spatial components
dim = 3;
nSlices = 6;
iSlices = round(linspace(1,size(mask,dim),nSlices+2));
iSlices = iSlices(2:end-1);
clim = [];
for i=1:COMPS_TO_PLOT
    brick = zeros(size(mask));
    brick(mask>0) = U(:,i);
    figure(352+i); clf
    hAxes = DisplaySlices(brick, dim, iSlices, [1 nSlices],clim);
    set(gcf,'Position',[0 1100-250*i 1000 250]);
    MakeFigureTitle(sprintf('Component #%d',i));
    colormap gray
end
