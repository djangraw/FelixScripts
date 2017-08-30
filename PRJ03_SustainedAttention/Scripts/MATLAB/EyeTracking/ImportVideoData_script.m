% ImportVideoData_script
% Created 12/30/15 by DJ.

subject = 9;

switch subject
    case 8
        nFiles = 4;
        rois = {[144, 222, 63, 111], [144, 222, 57, 111], [144, 222, 36, 81], [144, 222, 30, 81]}; % xmin xmax ymin ymax
        doFilter = true;
        calibNum = [];
    case 9
        nFiles = 5;
        rois = repmat({[118, 206, 86, 146]},1,nFiles); % xmin xmax ymin ymax
        doFilter = false;
        calibNum = 1;
end
radius_range0 = [3 15]; % CR range
radius_range1 = [5 20]; % pupil range
Fs = 30;
%%
for i=1:nFiles
    filename = sprintf('Distraction-%d-%d-quicktime.mov',subject,i);
    roi = rois{i};
    fprintf('###(%s) %s: roi = [%s]###\n',datestr(now),filename,num2str(roi));
    video = ReadInEyeVideo(filename);
    if doFilter
        video = MedianFilterVideo(video);
    end
    [pos0_interp, pos1_interp, rad0_interp, rad1_interp] = FindPupilInVideo(video,roi,radius_range0,radius_range1,filename);
    fileout = sprintf('Distraction-%d-%d-rawpos.mat',subject,i);
    save(fileout,'pos0_interp','pos1_interp','rad0_interp','rad1_interp');
end

%%
% get events
calibFile = sprintf('Distraction-%d-calib%d-data.mat',subject,calibNum);
foo = load(calibFile,'A');
A = foo.A;
thresholds = struct('outlierDist',100,'winLength',0.5,'minBlinkDur',0,'minIbi',50,'minSacDur',0,'minIsi',50,'velThresh',2); 
eventsVid = cell(1,nFiles);
for i=1:nFiles    
    fileout = sprintf('Distraction-%d-%d-rawpos.mat',subject,i);
    fprintf('###(%s) %s: getting events###\n',datestr(now),fileout);  
    load(fileout);
    pos_calib = ApplyCalibrationToPupCr(pos0_interp,pos1_interp,A);
    eventsVid{i} = GetEyeEvents_Engbert(pos_calib,rad1_interp,Fs,thresholds);
end

%% Add to data structs
switch subject
    case 8
        cd /Users/jangrawdc/Documents/PRJ03_SustainedAttention/Pilots/fMRI/S08_2015-12-29        
        offsets = [10000 -3500 5500 6500]; % ms to shift video to match idf file
    case 9
        cd /Users/jangrawdc/Documents/PRJ03_SustainedAttention/Pilots/fMRI/S09_2016-01-15
        offsets = [0 0 0 0 0];
end
dataFilename = sprintf('Distraction-%d-QuickRun.mat',subject);
load(dataFilename);
for i=1:nFiles
    tStart = data(i).events.samples.time(1);
    data(i).events.samples = eventsVid{i}.samples;
    data(i).events.samples.time = data(i).events.samples.time + tStart + offsets(i);
    data(i).events.saccade = eventsVid{i}.saccade;
    data(i).events.saccade.time_start = data(i).events.saccade.time_start + tStart + offsets(i);
    data(i).events.saccade.time_end = data(i).events.saccade.time_end + tStart + offsets(i);
    data(i).events.fixation = eventsVid{i}.fixation;
    data(i).events.fixation.time_start = data(i).events.fixation.time_start + tStart + offsets(i);
    data(i).events.fixation.time_end = data(i).events.fixation.time_end + tStart + offsets(i);    
end
%% Run later cells of ProcessReadingData_script to get new features and save results!!!
% save as Distraction-<subject>-QuickRun-Video.mat

%% Make eye movie to check alignment
i=4; % select run
% prepare eye movie variables
samples = data(i).events.samples.position;
pupilsize = rssq(data(i).events.samples.PD,2);
times = data(i).events.samples.time;
screenSize = data(i).params.screenSize;
imageSize = cellfun(@str2num,data(i).params.imageSize);
image_pos = [screenSize/2-imageSize/2, imageSize];
events = data(i).events;
isPage = strncmp('Page',events.display.name,length('Page'));
events.display.image = repmat({''},size(events.display.name));
events.display.image(isPage) = data(i).pageinfo.filenames;
events.display.type = repmat({'Other'},size(events.display.name));
events.display.type(isPage) = data(i).events.soundstart.name(ismember(data(i).events.soundstart.name,{'whiteNoiseSound','ignoreSound','attendSound'}));
% allow timeplot defaults for now
timeplot = [];
timeplotlabel = '';

% to make page images available
cd(sprintf('/Users/jangrawdc/Documents/PRJ03_SustainedAttention/Visuals/%s',data(i).pageinfo.filenames{1}(1:length('Greeks_Lec02_stretch_gray'))))
MakeEyeMovie_simple(data(i).events.samples.position,data(i).events.samples.PD,data(i).events.samples.time,screenSize,events);
