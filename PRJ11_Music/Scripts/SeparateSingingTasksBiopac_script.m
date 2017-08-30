% SeparateSingingTasksBiopac_script.m
%
% Created 4/26/17 by DJ.

subjName = 'SBJ03';
vars = GetMusicVariables;
scriptDir = [vars.homedir '/Scripts'];
allSessionTypes = unique(vars.sessionTypes);
allSessionTypes(strcmp(allSessionTypes,'none')) = [];
allSessionTypes(strcmp(allSessionTypes,'improvise')) = {'improv'};

% Set up python
% system('module load Anaconda');
% system('source activate python27')
% system('easy_install bioread');

%%
for iType=1:numel(allSessionTypes)
    sessionType = allSessionTypes{iType};
    outName = sprintf('SBJ03_%s',sessionType);
    iSessions = find(strncmp(vars.sessionTypes,sessionType,length(sessionType)));

    % Move to output directory
    outDir = [vars.homedir '/PrcsData/' outName '/D02_Behavior'];

    % Convert to .1D files
    for i=1:numel(iSessions)    
        inFile = sprintf('%s/%s.acq',vars.physioDir,vars.biopacFilenames{iSessions(i)}(1:end-4));
        outFile = sprintf('%s/physio.%s.r%02d',outDir,outName,i);
        cmd = sprintf('python %s/Biopac_Organize.py -i %s -o %s -overwrite', scriptDir,inFile,outFile);
        fprintf('%s\n',cmd);
        % Then run this command from a terminal with Anaconda, python27, and bioread
    %     system(cmd);
    end
end

%% Crop to just the TRs in this task
Fs = 2000;
suffixes = {'ECG','Resp','Trigger'};
fprintf('====================================\n')
for iType=1:numel(allSessionTypes)
    sessionType = allSessionTypes{iType};
    outName = sprintf('SBJ03_%s',sessionType);
    iSessions = find(strncmp(vars.sessionTypes,sessionType,length(sessionType)));

    % Move to output directory
    outDir = [vars.homedir '/PrcsData/' outName '/D02_Behavior'];

    % Convert to .1D files
    for i=1:numel(iSessions)    
        outFile = sprintf('%s/physio.%s.r%02d',outDir,outName,i);
        M = Read_1D([outFile '_Trigger.1D']);
        iFirstTrigger = find(diff(M)>3, 1);
        if strcmp(sessionType,'task') && i==1
            iTriggers = find(diff(M)>3);
            iLastTrigger = iTriggers(157); % task run 1 was a little longer than the others - crop it to 156 TRs!
        else
            iLastTrigger = find(diff(M)>3, 1, 'last');
        end
        iLastToInclude = iLastTrigger + vars.TR*Fs; % add one TR on the end
        if iLastToInclude>numel(M) % for the wholesong version
            iLastToInclude = iLastTrigger;
        end
        
        for j=1:numel(suffixes)
            cmd = sprintf('1dcat %s_%s.1D''{%d..%d}'' > %s_%s_cropped.1D', ...
                outFile,suffixes{j}, iFirstTrigger,iLastToInclude, outFile,suffixes{j});
            fprintf('%s\n',cmd);
            % Then run this command from a terminal 
%             system(cmd);
        end
        
    end
end


%% Build retroTS call

% foo = load(sprintf('%s/%s_behavior.mat',outDir,outName));
% Fs = 1/(foo.data.physio.time(2)-foo.data.physio.time(1));
Fs = 2000;
retroTsDir = '/usr/local/apps/afni/current/linux_openmp_64';
fprintf('---commands to run---\n')
fprintf('module load afni\n')
fprintf('module load zlib\n')
fprintf('module load Anaconda\n')
fprintf('source activate python27\n')

for iType = 1:numel(allSessionTypes)
    sessionType = allSessionTypes{iType};
    outName = sprintf('SBJ03_%s',sessionType);
    iSessions = find(strncmp(vars.sessionTypes,sessionType,length(sessionType)));
    outDir = [vars.homedir '/PrcsData/' outName '/D02_Behavior'];
    for i=1:numel(iSessions)
        outPrefix = sprintf('%s/physio.%s.r%02d',outDir,outName,i);
        fprintf('python %s/RetroTS.py -r %s_Resp_cropped.1D -c %s_ECG_cropped.1D -p %g -n %g -v %g -prefix %s_retrots\n',retroTsDir,outPrefix,outPrefix,Fs,vars.nSlices,vars.TR,outPrefix);
        
    end
end
      