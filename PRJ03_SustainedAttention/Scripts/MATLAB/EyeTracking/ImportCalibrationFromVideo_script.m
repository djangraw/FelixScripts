% ImportCalibrationFromVideo_script
%
% Created 12/30/15 by DJ.

%% Get video
subject = 9;
calibnum = 1;
filename = sprintf('Distraction-%d-calib%d-quicktime.mov',subject,calibnum);
video = ReadInEyeVideo(filename);

%% find pupil
switch subject
    case 8
        roi = [144, 222, 30, 81]; % xmin xmax ymin ymax
    case 9
        roi = [118, 206, 86, 146]; % xmin xmax ymin ymax
end
radius_range0 = [3 15]; % CR range
radius_range1 = [5 20]; % pupil range
[pos0_interp, pos1_interp, rad0_interp, rad1_interp] = FindPupilInVideo(video,roi,radius_range0,radius_range1,filename);

%% klugey correction
% pos0_interp(854:867,1) = interp1([853 868],pos0_interp([853 868],1),854:867);
% pos0_interp(854:867,2) = interp1([853 868],pos0_interp([853 868],2),854:867);

%% get calibration
screen_res = [1024 768];
switch subject
    case 8
        iOk = 200:1230; % specific to subject 8
    case 9
        iOk = 25:880;
end
Fs = 30;
thresholds = [];
[A, events_calib] = GetCalibrationFromPupilAndCr(pos0_interp, pos1_interp, rad1_interp, screen_res, iOk, Fs, thresholds);

%% Get movie
pos_calib = events_calib.samples.position;
tSamples = events_calib.samples.time;
MakeEyeMovie_video(video,pos1_interp,rad1_interp,pos0_interp,rad0_interp,pos_calib,tSamples,screen_res,events_calib,pos_calib,{'x_{gaze}','y_{gaze}'});

%% Save results
fileout = sprintf('Distraction-%d-calib%d-data.mat',subject,calibnum);
save(fileout,'events_calib','A','pos0_interp','pos1_interp','rad0_interp','rad1_interp');