% DeleteRmFiles.m
%
% Created 4/29/19 by DJ.

basedir='/gpfs/gsfs8/users/jangrawdc/PRJ03_SustainedAttention/Results';
for subj = 5:36
    fprintf('Subj %d:\n',subj)
    cd(sprintf('%s/SBJ%02d',basedir,subj));
    dirs = dir('AfniProc*');
    for iDir=1:numel(dirs)
        thisDir=dirs(iDir);
        thisDir = sprintf('%s/%s',thisDir.folder,thisDir.name);
        fprintf('   %s:\n',thisDir);
        cd(thisDir)
        rmFiles = dir('rm*');
        fprintf('      found %d rm files.\n',numel(rmFiles));
        if numel(rmFiles)>0
            delete(rmFiles.name);
        end
    end
end
fprintf('Done!\n');