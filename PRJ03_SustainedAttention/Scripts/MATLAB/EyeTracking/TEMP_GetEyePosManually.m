% TEMP_GetEyePosManually.m
%
% Created 2/9/16 by DJ.

%% Little by little, read the video

iOk = 4000+(1:1000);
roi = [110, 214, 26, 96]; % xmin xmax ymin ymax
radius_range0 = [3 15]; % CR range
radius_range1 = [5 20]; % pupil range
[pos0_interp, pos1_interp, rad0_interp, rad1_interp,isOutlier] = FindPupilInVideo(video(:,:,iOk),roi,radius_range0,radius_range1,filename_data);

%%
pos_pup = pos1_interp;
pos_cr = pos0_interp;
rad_pup = rad1_interp;
rad_cr = rad0_interp;

h = CleanUpEyeVideo(video(:,:,iOk),pos_pup,rad_pup,pos_cr,rad_cr,[],[],isOutlier);
% Make sure to save!

%%
for i=1:5
    filename = sprintf('DistractionTask-12-1_Manual_frame%d-%d.mat',(i-1)*1000+1,i*1000);
    foo(i) = load(filename);
end
pos_pup = cat(1,foo.pos_pup);
rad_pup = cat(1,foo.rad_pup);
pos_cr = cat(1,foo.pos_cr);
rad_cr = cat(1,foo.rad_cr);
iOk = 1:5000;
h = CleanUpEyeVideo(video(:,:,iOk),pos_pup,rad_pup,pos_cr,rad_cr); % no outliers

%% Use fake calibration and put in eye movie

% pos_diff = pos_pup-pos_cr;
pos_x = (pos_diff(:,1)-12)*(960/10);
pos_y = (pos_diff(:,2)-7)*(709/8);
MakeEyeMovie_video(video(:,:,iOk),pos_pup,rad_pup,pos_cr,rad_cr,[pos_x, pos_y],[],[1024 768],[],[pos_x,pos_y],{'x','y'});
