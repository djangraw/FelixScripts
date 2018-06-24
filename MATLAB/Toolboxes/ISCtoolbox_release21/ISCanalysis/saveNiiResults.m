function saveNiiResults(Params)
% function generates nii files from the computed results
%

disp('Saving results to nii:')
Priv = Params.PrivateParams;
Pub = Params.PublicParams;

%load Memmaps and one original header to get the voxel dimensions
load([Pub.dataDestination 'memMaps'])
%nii_orighdr = load_nii_hdr(Pub.subjectSource{1});

disp('   Saving the correlation statistics')
for nrBand = 0:Pub.nrFreqBands
  disp(['      Band ' num2str(nrBand)])
  for nrSession = 1:Priv.nrSessions
        disp(['         Session ' num2str(nrSession)])      
        %read the data from the memmaps
        img=memMaps.resultMap.whole.(['band' num2str(nrBand)]).(['Session' num2str(nrSession)]).cor.Data.xyz;

        % generate nii structure
        %nii_out = make_nii(img, nii_orighdr.dime.pixdim(2:4),[],[],'ISCtoolbox');
        nii_out = make_nii(img, Priv.dataSize(nrSession,1:3) ,[],[],'ISCtoolbox'); 

        % save the nii to the result folder of destination
        save_nii(nii_out,[Priv.resultsDestination 'ISCcorrmapBand' num2str(nrBand) 'Session' num2str(nrSession) '.nii']);
  end
end


if Params.PublicParams.freqCompOn
    disp('   Saving the frequency band comparisons')
    freqComps = ((Priv.maxScale+2)^2-(Priv.maxScale+2))/2;
    nrSubjPairs = ((Priv.nrSubjects)^2-(Priv.nrSubjects))/2;
    % here comes the save nii based on:
    % PearsonFilon(Params,nrSession,freqComp);
    
    for nrSession = 1:Priv.nrSessions
        disp(['      Session ' num2str(nrSession)])
        mMapmatResultWhole = memMaps.(Priv.PFmatMapName).whole.([Priv.prefixSession num2str(nrSession)]).cor;
        for fr = 1:freqComps
            disp(['         Frequency comparison ' num2str(fr)])
            %get the data
            img=mMapmatResultWhole.([Priv.prefixFreqComp num2str(fr)]).Data.xyzc;
            % generate nii structure
            nii_out = make_nii(img, [Priv.dataSize(nrSession,1:3)] ,[],[],'ISCtoolbox'); 

            % save the nii to the result folder of destination
            save_nii(nii_out,[Priv.resultsDestination 'ISCPFmatMapFreqComp' num2str(fr) 'Session' num2str(nrSession) '.nii']);
            
        end
    end
end

if Params.PublicParams.calcCorMatrices
    % here comes the save nii based on:
    % calculateCorMats(Params,nrBand,nrSession);
    %
end

if Params.PublicParams.calcStats
    % here comes the save nii based on:
    % calculateStatsMaps(Params,nrBand,nrSession);
    %
    disp('   Saving the extra statistics maps')
    mMapStat = memMaps.(Priv.statMapName);
    for nrBand = 0:Pub.nrFreqBands
        disp(['      Band ' num2str(nrBand)])
        for nrSession = 1:Priv.nrSessions
            disp(['         Session ' num2str(nrSession)])
            img = mMapStat.whole.([Priv.prefixFreqBand num2str(nrBand)]).([Priv.prefixSession num2str(nrSession)]).cor.Data.xyz;
            nii_out = make_nii(img, [Priv.dataSize(nrSession,1:3)] ,[],[],'ISCtoolbox'); 
            % save the nii to the result folder of destination
            save_nii(nii_out,[Priv.resultsDestination 'ISCstatmapBand' num2str(nrBand) 'Session' num2str(nrSession) '.nii']);

            %if time window analysis is selected
            if(Priv.nrTimeIntervals(nrSession) ~= 0)
                for wfr = 1:Priv.nrTimeIntervals(nrSession)
                    disp(['         Time window ' num2str(wfr)])
                    img = mMapStat.win.([Priv.prefixFreqBand num2str(nrBand)]).([Priv.prefixSession num2str(nrSession)]).cor.Data(wfr).xyz;
                    nii_out = make_nii(img, [Priv.dataSize(nrSession,1:3)] ,[],[],'ISCtoolbox'); 
                    % save the nii to the result folder of destination
                    save_nii(nii_out,[Priv.resultsDestination 'ISCstatmapWin' num2str(wfr) 'Band' num2str(nrBand) 'Session' num2str(nrSession) '.nii']);

                end
            end
        end
    end
end

if Params.PublicParams.calcPhase
    % here comes the save nii based on:
    % calculatePhaseSynch(Params,nrBand,nrSession);
    %
end

if Params.PublicParams.calcPhase || Params.PublicParams.winOn
    % here comes the save nii based on:
    % calculateSynchCurves(Params,nrBand,nrSession);
end

clear memMaps;