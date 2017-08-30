% CheckIfPreprocIsDone.m
%
% Created 11/7/16 by DJ.

subjects = [9:22, 24:25, 27:36];
homedir = '/data/jangrawdc/PRJ03_SustainedAttention/Results/';
afniProcFolder = 'AfniProc_MultiEcho_2016-09-22';

fprintf('-----------\n');
for i=1:numel(subjects)
    cd(sprintf('%sSBJ%02d/%s/',homedir,subjects(i),afniProcFolder));
    foo = dir('pb00*e1.tcat+orig.BRIK');
    nRuns = numel(foo);
    % Check if done
    if ~exist(sprintf('errts.SBJ%02d_REML+tlrc.BRIK',subjects(i)),'file')
        fprintf('SBJ%02d not done\n',subjects(i));
        % Check if TEDANA is done
        for j=1:nRuns
            foo = dir(sprintf('TED.SBJ%02d.r%02d/accepted*',subjects(i),j));
            if isempty(foo)
                fprintf('  SBJ%02d, tedana run %d\n',subjects(i),j);
            end
        end
    end
end