% GetMeicaRejectedComponentsAndVariance.m
%
% Created 9/18/17 by DJ.

vars = GetDistractionVariables;
subjects = vars.okSubjects;
[nComps,nRej,varex_rej,varex_max] = deal(cell(1,numel(subjects)));
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
        varex_max{i}(j) = max(varex([rejComps,midkComps]+1));
    end
end

%% Print median & range
fprintf('===MEICA results for %d subjects:\n',numel(subjects));
fprintf('Removed %d-%d (med %.1f) of %d-%d (med %.1f) components\n',...
    min([nRej{:}]),max([nRej{:}]),median([nRej{:}]), ...
    min([nComps{:}]),max([nComps{:}]),median([nComps{:}]) );

pctRej = [nRej{:}]./[nComps{:}]*100;
fprintf('Removed %.1f-%.1f (med %.1f) %% of %d-%d (med %.1f) components\n',...
    min(pctRej),max(pctRej),median(pctRej), ...
    min([nComps{:}]),max([nComps{:}]),median([nComps{:}]) );

fprintf('Removed %.1f-%.1f (med %.1f) %% of variance\n',...
    min([varex_rej{:}]),max([varex_rej{:}]),median([varex_rej{:}]) );

%% Print median & IQR
fprintf('===MEICA results for %d subjects:\n',numel(subjects));
fprintf('Removed med %.1f (IQR %.1f) of med %.1f (IQR %.1f) components\n',...
    median([nRej{:}]), iqr([nRej{:}]), ...
    median([nComps{:}]),iqr([nComps{:}]) );

pctRej = [nRej{:}]./[nComps{:}]*100;
fprintf('Removed med %.1f (IQR %.1f) %% of med %.1f (IQR %.1f) components\n',...
    median(pctRej),iqr(pctRej), ...
    median([nComps{:}]),iqr([nComps{:}]) );

fprintf('Removed med %.1f (IQR %.1f) %% of variance\n',...
    median([varex_rej{:}]),iqr([varex_rej{:}]) );


%% Check on results of 3dTProject commands
subjects = vars.okSubjects;
nSubj = numel(subjects);
[meanPreVar, meanPostVar] = deal(nan(1,nSubj));
for i=1:nSubj
    fprintf('Subj %d/%d...\n',i,nSubj);
    % Load mask, pre, and post data
    cd(sprintf('%s/Results/SBJ%02d/AfniProc_MultiEcho_2016-09-22',vars.homedir,subjects(i)));
    preDataFiles = dir('pb04.*_e2.*');
    preData = BrikLoad(sprintf('TEMP_e2.all+tlrc.HEAD'));
    mask = any(preData~=0,4);
    postData = BrikLoad(sprintf('TEMP_e2.errts.SBJ%02d.tproject+tlrc.HEAD',subjects(i)));
    % Get mean in-mask variance of pre-3dD data
    preVar = var(preData,[],4);
    meanPreVar(i) = mean(preVar(mask));
    
    % Get mean in-mask variance of post-3dD data
    postVar = var(postData,[],4);
    meanPostVar(i) = mean(postVar(mask));
end
fprintf('Done!\n');

%% Print results
pctRemoved = (1-meanPostVar./meanPreVar)*100;
fprintf('%% removed: median = %g, IQR = %g\n',...
    median(pctRemoved),iqr(pctRemoved));