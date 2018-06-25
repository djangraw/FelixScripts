% IscOn100Runs_script.m
% Created 1/7/15 by DJ.

nRuns_all = [2, 5, 10, 20, 40, 60, 80, 100];
subjects = 1:3;
dorandperm = true;
nPerms = 1;
outputdir = sprintf('/data/jangrawdc/PRJ01_100Runs/Results/');
%%
for iSubj = 1:numel(subjects)
    subject = subjects(iSubj);
    inputdir = sprintf('/data/SFIM_100RUNS/jangrawdc/100RUNS/SBJ%02d/',subject);
    for i=1:numel(nRuns_all)
        nRuns = nRuns_all(i);
        for iPerm=1:nPerms
            if dorandperm
                outfile = sprintf('%sISC_SBJ%02d_%dRuns_randperm%03d',outputdir,subject,nRuns,iPerm);
            else
                outfile = sprintf('%sISC_SBJ%02d_%dRuns',outputdir,subject,nRuns);
            end
            if ~exist([outfile '.mat'],'file') % don't overwrite
                [coeff,pval] = RunIscOn100Runs(subject,1:nRuns,inputdir,dorandperm);
                save(outfile,'nRuns','coeff','pval');
            else
                fprintf('Skipping SBJ%02d, %d runs, perm %03d!\n',subject,nRuns,iPerm)
            end
        end
    end
end
    