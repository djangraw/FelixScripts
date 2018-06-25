% SonifyAtlasDemo.m
%
% Created 12/19/17 by DJ.

atlasTc = zeros(3,10);
atlasTc(1,:) = 1:10;
atlasTc(2,:) = 10:-1:1;
atlasTc(3,:) = ((-5:4).^2)/2;

% atlasSound = SonifyAtlasTimecourses(atlasTc,1,'pentatonic');
% Fs = 8192;
slowFactor = 1;
[atlasSound, Fs] = SonifyAtlasTimecourses_midi(atlasTc,1,'pentatonic','sine');

%% Plot & play
PlotAndPlaySonifiedData(atlasTc,slowFactor,atlasSound,Fs);

%% With real data
cd /Users/jangrawdc/Documents/PRJ15_FmriToSound/TestData
atlasTc = Read_1D('CogStates_SBJ06_Craddock200_WL045.1D')';

cd ..
slowFactor = 0.1;
iRois = [108, 146, 58, 82, 5, 44, 66, 174, 14, 109]; % pick useful ROIs(?) 108/44=l/rVis, 146/66=l/rSTG, 58/174=PCC, 82/14=l/rAG, 109/5=MFG, 
atlasTc_cropped = atlasTc(iRois,:);
percentileCutoff = 50;
atlasTc_scaled = (atlasTc_cropped-GetValueAtPercentile(atlasTc_cropped,percentileCutoff))*100;
atlasTc_scaled(atlasTc_scaled<0) = 0;

[atlasSound,Fs] = SonifyAtlasTimecourses_midi(atlasTc_scaled,slowFactor,'pentatonic','sine');
PlotAndPlaySonifiedData(atlasTc_scaled,slowFactor,atlasSound,Fs);