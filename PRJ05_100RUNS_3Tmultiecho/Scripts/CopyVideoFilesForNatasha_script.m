% CopyVideoFilesForNatasha_script.m
%
% Created 8/25/16 by DJ. 

subject = 1;
sessions = 1:9;
runs = 1:2;
targetDir = sprintf('/data/jangrawdc/PRJ10_VideoForDiagnosis/100RunsVideo/SBJ%02d/',subject);

for iSess=1:numel(sessions)
    session = sessions(iSess);
    for iRun = 1:numel(runs)
        run = runs(iRun);
        
        % navigate to 
%         cd(sprintf('/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/SBJ%02d_S%02d/D01_Version02.AlignByAnat.Cubic/Video%02d/TED/',subject,session,run));
        folderName = sprintf('/data/SFIM_100RUNS/100RUNS_3Tmultiecho/PrcsData/SBJ%02d_S%02d/D01_Version02.AlignByAnat.Cubic/Video%02d/TED/',subject,session,run);
        if exist(folderName,'dir')
            fprintf('SBJ%02d, S%02d, R%02d...\n',subject,session,run);
            cd(folderName);

            targetFname = sprintf('SBJ%02d_S%02d_R%02d_Video_MeicaDenoised.nii',subject,session,run);
            copyfile('dn_ts_OC.nii',sprintf('%s/%s',targetDir,targetFname));
        end
    end
end