subplot(311);
imagesc(dimRedTS(:,1:20)');
colorbar
xlabel('time (samples)')
ylabel('component rank');
title('SBJ06 200-ROI PCA activity');

subplot(312);
imagesc(S(1:20,1:20)*V(:,1:20)'/250);
colorbar
xlabel('time (samples)')
ylabel('component rank');
title('SBJ06 Voxelwise PCA activity');

subplot(313);
cla; hold on;
plot(dimRedTS(:,1));
plot(S(1,1)*V(:,1)'/250)
legend('200-ROI PC#1','Vowelwise PC#1')
xlim([0 1017]);

r = corr(V(:,1),dimRedTS(:,1));
title(sprintf('r = %.3f',r))
xlabel('time (samples)')
ylabel('activity (A.U.)');