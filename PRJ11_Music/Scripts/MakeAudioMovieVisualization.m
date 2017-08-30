function obj = MakeAudioMovieVisualization(h,wavData,tWavData,VFinal,tFinal,tLimits)

% Created 4/21/17 by DJ.

% common choices:
% tLimits = [5 40]; [60 95]; [115 145];
%  [165 200]; [220 255]; [275 305];

% Set x limits
xlim(h.Block,tLimits);

%% Set up audio
Fs = 1/(tWavData(2)-tWavData(1));
iFirstSample = find(tWavData>=tLimits(1),1);
iLastSample = find(tWavData>=tLimits(2),1);
tObj = tWavData(iFirstSample:iLastSample);
obj = audioplayer(wavData(iFirstSample:iLastSample), Fs);
play(obj);

% Slide bar across
while obj.isplaying
    AdvanceBar(obj);
end

% Helper function
function AdvanceBar(obj)
    tAudio = tObj(obj.CurrentSample);
    for iBar=1:numel(h.Bar)
        set(h.Bar(iBar),'XData',[NaN,1,1]*tAudio);
    end
    iPos = find(tFinal>tAudio,1);
    if size(VFinal,4)>1
        set(h.Img,'CData',VFinal(:,:,:,iPos));
    else
        set(h.Img,'CData',VFinal(:,:,iPos));
    end
    drawnow
end

end