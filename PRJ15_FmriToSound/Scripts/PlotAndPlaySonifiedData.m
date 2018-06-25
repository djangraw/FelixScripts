function PlotAndPlaySonifiedData(atlasTc,TR,atlasSound, Fs)

% PlotAndPlaySonifiedData(atlasTc,TR, atlasSound, Fs)
%
% Created 12/19/17 by DJ.

figure(512); clf;
subplot(2,1,1); cla; hold on;
[nComps,nT] = size(atlasTc);
% tAtlas = ((1:nT)-0.5)*slowFactor; % to match sound
tAtlas = (0:nT-1)*TR;
tAtlasMax = tAtlas(end);
imagesc(tAtlas, 1:nComps,atlasTc);
hBar1 = PlotVerticalLines(0,'k');
set(hBar1,'linewidth',2);
xlabel('scan time (s)');
ylabel('Component');
axis([0 tAtlasMax 0.5 nComps+0.5])

% plot sound
tSound = (0:numel(atlasSound)-1)/Fs;
subplot(2,1,2); cla; hold on;
plot(tSound,atlasSound);
xlabel('sound time (s)');
ylabel('sound amplitude');
xlim([0 tSound(end)]);
hBar2 = PlotVerticalLines(0,'k');
set(hBar2,'linewidth',2);
% linkaxes(GetSubplots(gcf),'x');
% play sound
soundsc(atlasSound, Fs);
% move bar
tic;
tNow = 0;
while tNow < tAtlasMax
    tNow = toc;
    set(hBar1,'xdata',[1 1]*tNow*tAtlasMax/tSound(end));
    set(hBar2,'xdata',[1 1]*tNow);
    drawnow;
end