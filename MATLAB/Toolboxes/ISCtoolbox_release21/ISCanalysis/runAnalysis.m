function runAnalysis(Params)

% This is the main function that performs ISC analysis for
% preprocessed fMRI data. Analysis parameters (see initParams.m)
% must be set by the user before running the analysis.
%
% Input fMRI data must be either in "nii" or "mat" -format
% (see initParams.m). Output data is mapped into the memory and
% can be quickly accessed through memory pointer objects.
%
% COMMAND LINE ANALYSIS:
%
% After running the analysis, memory pointer objects can be loaded
% to the Matlab's workspace by typing:
% load memMaps % objects are saved in analysis destination folder.
%
% GRAPHICAL USER INTERFACE (GUI):
%
% Specific GUI has been designed to visualize and analyze the results.
% After running the analysis, GUI can be launched by typing:
% load Tag % Tag is saved in the analysis destination folder
% ISCtool(Tag); % launch GUI from your GUI folder
%
% Note: when you launch GUI make sure you have cleared all memory
% map pointer objects from Matlab workspace.
%
% See also: ISCANALYSIS, MEMMAPDATA, INITPARAMS

% Updated: 7.11.2013 by Jukka-Pekka Kauppi
% University of Helsinki
% Department of Computer Science
% email: jukka-pekka.kauppi@helsinki.fi
%
% Updated: 23.6.2014 by Juha Pajula
% Tampere University of Technology
% Department of Signal Processing
% e-mail: juha.pajula@tut.fi
%creating the log folder, this should be moved to params struct (and edited
%to setPrivParams.m as well as setDataPaths.m

% STAGE 0: 
% ###################################
% Initialization of the processes
% Setting the logs, checking the environment, creating tmp
total_time = tic;
if ~exist([Params.PublicParams.dataDestination,'scripts'],'dir')
    mkdir([Params.PublicParams.dataDestination,'scripts']); %create folder for scripts
else %if the folder already exists the old analysis is run again -> delete old logs and scripts 
    disp('Clearing the log and script files from scripts directory')
    try 
        rmdir([Params.PublicParams.dataDestination,'scripts/'],'s'); %this may fail sometimes due to filesystem problems -> move folder to new name "scripts_old"
    catch
        warning('scripts/ folder cannot be deleted, changing the name of the folder to scripts_old/')
        movefile([Params.PublicParams.dataDestination,'scripts/'], [Params.PublicParams.dataDestination,'scripts_old/'])
    end
    mkdir([Params.PublicParams.dataDestination,'scripts']);
end
log_path=[Params.PublicParams.dataDestination,'scripts'];

%saving the Log from command window:
diary([log_path, Params.PublicParams.dataDestination(end), 'main_log.txt']);
disp(datestr(now))
% Init run for grid
gridOff=Params.PublicParams.disableGrid;
if gridOff
    grid_type=''; %disable grid computing;
    disp('Grid computing disabled')
else
    grid_type=testGrid; %test if cluster environments (slurm/SGE) are here
end

tmp_path=[Params.PublicParams.dataDestination,'tmp']; %define temp path
if ~exist([Params.PublicParams.dataDestination,'tmp'],'dir') %check if it exists or not
    mkdir([Params.PublicParams.dataDestination,'tmp']); %create folder for temp files
else
    delete([tmp_path tmp_path(end-3) '*.mat']) %empty folder if exists
end


pauset = 6; %check interval for waitGrid in seconds


% STAGE 1:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize parameters. Note: user must set all public parameters
% in initParams.m before running the analysis.
%Params = initParams;
% initialize data matrices into the disk and create pointers
% using dynamic memory mapping:

if(~isempty(grid_type))
    [~,outpt,ID]=gridParser('memMapData',Params,{},grid_type,'ISC_1');
    disp(outpt);
else
    memMapData(Params);
end
%if submitted to grid, waiting that all processes are finished before next
%Batch
if(~isempty(grid_type))
    waitGrid(grid_type,pauset,log_path,ID)
end

%reload the params after memMapping
load([Params.PublicParams.dataDestination, Params.PublicParams.dataDescription])
Priv = Params.PrivateParams;
Pub = Params.PublicParams;

% STAGE 2:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Filter all data through stationary wavelet filter bank.
% Computationally faster way is to distribute the
% calculations across several processors.
if (Pub.nrFreqBands ~= 0)
    if(Pub.calcStandard)
        disp(' ')
        disp('Filtering:')
        idList=[];
        for nrSubject = 1:Priv.nrSubjects
            for nrSession = 1:Priv.nrSessions
                disp(['Subject: ' num2str(nrSubject) ' , Session: ' num2str(nrSession) ':'])
                if(~isempty(grid_type))
                    [~,outpt,ID]=gridParser('filterData',Params,{nrSubject,nrSession},grid_type,'ISC_2');
                    disp(outpt);
                    idList=[idList,',',ID];
                else
                    filterData(Params,nrSubject,nrSession);
                end
            end
        end

        %if submitted to grid, waiting that all processes are finished before next
        %Batch
        if(~isempty(grid_type))
            waitGrid(grid_type,pauset,log_path,idList(2:end))
        end
        gatherGridPointers(Params,tmp_path,2)

    end
end
% STAGE 3:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate intersubject synchronization maps.
% Computationally faster way is to distribute the calculations over several processors.
% Here, nrBand 0 stands for full frequency band.
if Pub.calcStandard
    disp(' ')
    disp('Calculating basic ISC maps:')
    idList=[];
    for nrBand = 0:Pub.nrFreqBands
        for nrSession = 1:Priv.nrSessions
            disp(['Band: ' num2str(nrBand) ', Session: ' num2str(nrSession)])
            if(~isempty(grid_type))
                [~,outpt,ID]=gridParser('calculateSimilarityMaps',Params,{nrBand,nrSession},grid_type,'ISC_3_1');
                disp(outpt);
                idList=[idList,',',ID];
            else
                calculateSimilarityMaps(Params,nrBand,nrSession);
            end
        end
    end

    %if submitted to grid, waiting that all processes are finished before next
    if(~isempty(grid_type))
        waitGrid(grid_type,pauset,log_path,idList(2:end))
    end
    gatherGridPointers(Params,tmp_path,3)
end
% Compute resampling distribution for statistical si:
% Generate permutation (null) distributions:
if Pub.calcStandard 
%    if ~(~Pub.winOn && winOn)
    disp(' ')
    disp('Calculating permutation distributions for each ISC map:')
    idList=[];
    for nrSession = 1:Priv.nrSessions
        for permSetIdx = 1:Priv.nrPermutationSets
            if(~isempty(grid_type))
                [~,outpt1,ID1]=gridParser('permutationTest',Params,{nrSession,permSetIdx,0},grid_type,'ISC_3_2a');
                [~,outpt2,ID2]=gridParser('permutationTest',Params,{nrSession,permSetIdx,1},grid_type,'ISC_3_2b');
                disp(outpt1);
                disp(outpt2);
                idList=[idList,',',ID1,',',ID2];
            else
                permutationTest(Params,nrSession,permSetIdx,0); % across session
                permutationTest(Params,nrSession,permSetIdx,1); % time-windows
            end
        end
    end

    %if submitted to grid, waiting that all processes are finished before next
    if(~isempty(grid_type))
        waitGrid(grid_type,pauset,log_path,idList(2:end))
    end
%    end
end

if Pub.sessionCompOn ~= 0
    if Pub.corOn
        if Pub.calcStandard
    
            % Calculate session comparison maps (sum ZPF statistic).
            disp(' ')
            disp('Calculating session comparison statistics:')
            idList=[];
            % Get total number of session comparisons:
            sessComps = ((Priv.nrSessions)^2-(Priv.nrSessions))/2;
            %  Calculate null distributions for all comparisons:
            
            for nrBand = 0:Priv.maxScale + 1
                for sessComp = 1:sessComps
                    if(~isempty(grid_type))
                        [~,outpt1,ID]=gridParser('PearsonFilonAcrossSessions',Params,{nrBand,sessComp},grid_type,'ISC_3_2c');
                        disp(outpt1);
                        idList=[idList,',',ID];
                    else
                        PearsonFilonAcrossSessions(Params,nrBand,sessComp);
                    end
                end
            end

            %if submitted to grid, waiting that all processes are finished before next
            if(~isempty(grid_type))
                waitGrid(grid_type,pauset,log_path,idList(2:end))
            end
            gatherGridPointers(Params,tmp_path,4)
        end
    end
end

if Params.PublicParams.sessionCompOn
    % Assess statistical significance for session differences through
    % permutation testing.
    disp(' ')
    disp('Calculating permutation distributions for session comparisons:')
    idList=[];
    for nrBand = 0:Priv.maxScale + 1
        for sessComp = 1:sessComps
            if(~isempty(grid_type))
                [~,outpt1,ID]=gridParser('permutationPFAcrossSessions',Params,{nrBand,sessComp},grid_type,'ISC_3_2d');
                disp(outpt1);
                idList=[idList,',',ID];
            else
                permutationPFAcrossSessions(Params,nrBand,sessComp);
            end
        end
    end
    
    %if submitted to grid, waiting that all processes are finished before next
    if(~isempty(grid_type))
        waitGrid(grid_type,pauset,log_path,idList(2:end))
    end
end



% Calculate frequency comparison maps (sum ZPF statistic).
% Get total number of frequency band comparisons:
if Params.PublicParams.freqCompOn
    disp(' ')
    disp('Calculating statistics for frequency-band comparisons:')
    idList=[];
    freqComps = ((Priv.maxScale+2)^2-(Priv.maxScale+2))/2;
    %  Calculate null distributions for all comparisons indexed from
    % 1 to freqComps. To distribute computations, you can also call
    % function  by giving subblocks as input, e.g. call function
    % separately with comparisons 1:3, 4:6, 7:9, 10:12, and 13:15.
    for nrSession = 1:Priv.nrSessions
        for freqComp = 1:freqComps
            if(~isempty(grid_type))
                [~,outpt,ID]=gridParser('PearsonFilon',Params,{nrSession,freqComp},grid_type,'ISC_3_3');
                disp(outpt);
                idList=[idList,',',ID];
            else
                PearsonFilon(Params,nrSession,freqComp);
            end
        end
    end
    
    %if submitted to grid, waiting that all processes are finished before next
    if(~isempty(grid_type))
        waitGrid(grid_type,pauset,log_path,idList(2:end))
    end
    gatherGridPointers(Params,tmp_path,5)
    
    % Assess statistical significance between frequency bands through
    % permutation testing:
    disp(' ')
    disp('Calculating permutation distributions for frequency band comparisons:')
    idList=[];
    for nrSession = 1:Priv.nrSessions
        for freqComp = 1:freqComps
            if(~isempty(grid_type))
                [~,outpt,ID]=gridParser('permutationPF',Params,{nrSession,freqComp},grid_type,'ISC_3_4');
                disp(outpt);
                idList=[idList,',',ID];
            else
                permutationPF(Params,nrSession,freqComp)
            end
        end
    end
    
    %if submitted to grid, waiting that all processes are finished before next
    if(~isempty(grid_type))
        waitGrid(grid_type,pauset,log_path,idList(2:end))
    end
end


if Params.PublicParams.calcCorMatrices
    % Calculate full intersubject correlation matrices. These calculations
    % are required if subject-wise correlations are investigated
    % (average ISC is calculated using the function
    % calculateSimilarityMaps.m but it saves only the mean correlation values).
    disp(' ')
    disp('Calculating ISC matrices:')
    idList=[];
    for nrBand = 0:Pub.nrFreqBands
        for nrSession = 1:Priv.nrSessions
            disp(['Band: ' num2str(nrBand) ', Session: ' num2str(nrSession)])
            if(~isempty(grid_type))
                [~,outpt,ID]=gridParser('calculateCorMats',Params,{nrBand,nrSession},grid_type,'ISC_3_5');
                disp(outpt);
                idList=[idList,',',ID];
            else
                calculateCorMats(Params,nrBand,nrSession);
            end
        end
    end
    
    %if submitted to grid, waiting that all processes are finished before next
    if(~isempty(grid_type))
        waitGrid(grid_type,pauset,log_path,idList(2:end))
    end
    gatherGridPointers(Params,tmp_path,6)
end


if Params.PublicParams.calcStats
    % calculate other ISC maps (t-stats, median ISC map, percentile ISC maps):
    disp(' ')
    disp('Calculating other ISC maps:')
    idList=[];
    for nrBand = 0:Pub.nrFreqBands
        for nrSession = 1:Priv.nrSessions
            disp(['Band: ' num2str(nrBand) ', Session: ' num2str(nrSession)])
            if(~isempty(grid_type))
                [~,outpt,ID]=gridParser('calculateStatsMaps',Params,{nrBand,nrSession},grid_type,'ISC_3_6');
                disp(outpt);
                idList=[idList,',',ID];
            else
                calculateStatsMaps(Params,nrBand,nrSession);
            end
        end
    end
    
    %if submitted to grid, waiting that all processes are finished before next
    if(~isempty(grid_type))
        waitGrid(grid_type,pauset,log_path,idList(2:end))
    end
    gatherGridPointers(Params,tmp_path,7)
end

if Params.PublicParams.calcPhase
    disp(' ')
    disp('Calculating inter-subject phase synchronization maps:')
    idList=[];
    for nrBand = 0:Pub.nrFreqBands
        for nrSession = 1:Priv.nrSessions
            disp(['Band: ' num2str(nrBand) ', Session: ' num2str(nrSession)])
            if(~isempty(grid_type))
                [~,outpt,ID]=gridParser('calculatePhaseSynch',Params,{nrBand,nrSession},grid_type,'ISC_3_7');
                disp(outpt);
                idList=[idList,',',ID];
            else
                calculatePhaseSynch(Params,nrBand,nrSession);
            end
        end
    end
    
    %if submitted to grid, waiting that all processes are finished before next
    if(~isempty(grid_type))
        waitGrid(grid_type,pauset,log_path,idList(2:end))
    end
    gatherGridPointers(Params,tmp_path,8)
end

% STAGE 4:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate ISC map thresholds using the resampling distribution and FDR:
disp(' ')
disp('Calculating critical thresholds:')
idList=[];
for nrSession = 1:Priv.nrSessions
    if(~isempty(grid_type))
        [~,outpt1,ID1]=gridParser('calculateThresholds',Params,{nrSession,0},grid_type,'ISC_4_1a');
        [~,outpt2,ID2]=gridParser('calculateThresholds',Params,{nrSession,1},grid_type,'ISC_4_1b');
        disp(outpt1);
        disp(outpt2);
        idList=[idList,',',ID1,',',ID2];
    else
        calculateThresholds(Params,nrSession,0); % across session
        calculateThresholds(Params,nrSession,1); % time-windows
    end
end
%if submitted to grid, waiting that all processes are finished before next
if(~isempty(grid_type))
    waitGrid(grid_type,pauset,log_path,idList(2:end))
end

if Params.PublicParams.sessionCompOn
    % calculate session comparison thresholds according to maximal statistic:
    idList=[];
    if(~isempty(grid_type))
        [~,outpt1,ID]=gridParser('calculateThresholdsPFsessions',Params,{},grid_type,'ISC_4_2a');
        disp(outpt1);
        idList=[idList,',',ID];
    else
        calculateThresholdsPFsessions(Params);
    end
    
    if(~isempty(grid_type))
        waitGrid(grid_type,pauset,log_path,idList(2:end))
    end
end


if Params.PublicParams.freqCompOn
    % calculate frequency comparison thresholds according to maximal statistic:
    idList=[];
    if(~isempty(grid_type))
        [~,outpt,ID]=gridParser('calculateThresholdsPF',Params,{},grid_type,'ISC_4_2b');
        disp(outpt);
        idList=[idList,',',ID];
    else
        calculateThresholdsPF(Params);
    end
    %if submitted to grid, waiting that all processes are finished before next
    if(~isempty(grid_type))
        waitGrid(grid_type,pauset,log_path,idList(2:end))
    end
end

% STAGE 5:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate intersubject synchronization curves from time-windowed data:
if Params.PublicParams.calcPhase || Params.PublicParams.winOn
    
    disp(' ')
    disp('Calculating inter-subject synchronization curves:')
    idList=[];
    if Pub.useTemplate
        for nrBand = 0:Pub.nrFreqBands
            for nrSession = 1:Priv.nrSessions
                disp(['Band: ' num2str(nrBand) ', Session: ' num2str(nrSession)])
                if(~isempty(grid_type))
                    [~,outpt,ID]=gridParser('calculateSynchCurves',Params,{nrBand,nrSession},grid_type,'ISC_5');
                    disp(outpt);
                    idList=[idList,',',ID];
                else
                    calculateSynchCurves(Params,nrBand,nrSession);
                end
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %if submitted to grid, waiting that all processes are finished before next
        if(~isempty(grid_type))
            waitGrid(grid_type,pauset,log_path,idList(2:end))
        end
        gatherGridPointers(Params,tmp_path,9)
    else
        disp('Standard templates not in use, cannot compute ROI-based curves...')
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% STAGE 6 (experimental):
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save results to Nii-files
disp(' ')
disp('Saving Nii')

saveNiiResults(Params)

% BATCH 7 Memmapped sourcedata removal:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% removing the memmapped source data to save disk space, if this Batch is
% selected the data must be memmapped again to be able to run the analysis
disp(' ')

removeMemmapData(Params)




disp(' ')
disp('Finished!!')

toc(total_time)
disp(datestr(now))
diary off