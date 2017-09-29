function PlaySoundWithBar(rawBrick2d,Fs_play,dur)

% PlaySoundWithBar(rawBrick2d,Fs_play,dur)
%
% Created 9/28/17 by DJ.

% Set up plot
cla; hold on;
plot((1:numel(rawBrick2d))/Fs_play,rawBrick2d(:));
h.Bar = PlotVerticalLines(0,'k-');
xlabel('time (s)');
ylabel('signal (raw)');
xlim([0 dur]);

% create audioplayer and play
tAp = (1:Fs_play*dur)/Fs_play;
ap = audioplayer(rawBrick2d(1:Fs_play*dur),Fs_play);
play(ap);
while ap.isplaying
    AdvanceBar(ap);
end

% Helper function
function AdvanceBar(ap)
    tAudio = tAp(ap.CurrentSample);
    for iBar=1:numel(h.Bar)
        set(h.Bar(iBar),'XData',[NaN,1,1]*tAudio);
    end
%     iPos = find(tFinal>tAudio,1);
%     if size(VFinal,4)>1
%         set(h.Img,'CData',VFinal(:,:,:,iPos));
%     else
%         set(h.Img,'CData',VFinal(:,:,iPos));
%     end
    drawnow
end

end