% this script uses the time stamps for when DICOM slices were written on
% 3TC and outputs figures to show how they were processed

addpath('/home/handwerkerd/matlab');

cd /data/SFIMJGC/PRJ_MEGating/PrcsData/SBJ01/D00_OriginalData/DicomWritingTimeStamps/
timinglogfiles = {'FileTimeStamps_E8389_103114_s713.txt', 'FileTimeStamps_E8389_103114_s715.txt',  ...
                  'FileTimeStamps_E8389_103114_s718.txt',  'FileTimeStamps_E8389_103114_s719.txt',  ...
                  'FileTimeStamps_E8389_103114_s720.txt'};
 TR = [1.25 0.9 0.9 0.9 0.9];
 slicesperTR = 3.*[14 12 12 12 12];
 figure(2)
 [RatePerSec, TimeBins, WriteDuration, ScanDuration ] = ReadingTimeStampsFromDirectoryOutput(timinglogfiles, TR, slicesperTR);
 
 
 print('-depsc2', 'ME_Gating_SBJ01.eps');
 print('-djpeg100', 'ME_Gatign_SBJ01.jpg');