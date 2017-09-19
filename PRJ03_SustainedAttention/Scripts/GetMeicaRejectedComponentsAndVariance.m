% GetMeicaRejectedComponentsAndVariance.m
%
% Created 9/18/17 by DJ.

vars = GetDistractionVariables;
subjects = vars.okSubjects;
[nComps,nRej,varex_rej] = deal(cell(1,numel(subjects)));
for i=1:numel(subjects)
    cd(fullfile(vars.homedir,'Results',sprintf('SBJ%02d',subjects(i)),'AfniProc_MultiEcho_2016-09-22'));
    nRuns = numel(dir('TED*'));
    [nComps{i},nRej{i},varex_rej{i}] = deal(nan(1,nRuns));
    for j=1:nRuns
        rejComps = csvread(sprintf('TED.SBJ%02d.r%02d/rejected.txt',subjects(i),j));
        try
            midkComps = csvread(sprintf('TED.SBJ%02d.r%02d/midk_rejected.txt',subjects(i),j));
        catch
            fprintf('SBJ%02d.r%02d: midk empty\n',subjects(i),j);
        end                
        varex = csvread(sprintf('TED.SBJ%02d.r%02d/varex_norm.txt',subjects(i),j));
        nComps{i}(j) = numel(varex);
        nRej{i}(j) = numel(rejComps) + numel(midkComps,1);
        varex_rej{i}(j) = sum(varex([rejComps,midkComps]+1)); % lists are 0-based, matlab 1-based
    end
end

%% Print median & range
fprintf('===MEICA results for %d subjects:\n',numel(subjects));
fprintf('Removed %d-%d (med %.1f) of %d-%d (med %.1f) components\n',...
    min([nRej{:}]),max([nRej{:}]),median([nRej{:}]), ...
    min([nComps{:}]),max([nComps{:}]),median([nComps{:}]) );

fprintf('Removed %.1f-%.1f (med %.1f) %% of variance\n',...
    min([varex_rej{:}]),max([varex_rej{:}]),median([varex_rej{:}]) );

