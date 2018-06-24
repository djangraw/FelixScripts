function gatherGridPointers(Params, tmp_path, phaseX)
% function to gather gridpointers after the grid computing has ended
Priv = Params.PrivateParams;
Pub = Params.PublicParams;

%load([Pub.dataDestination 'memMaps'])

matFiles = findMatFiles(tmp_path,phaseX);


for k = 1:length(matFiles)
    if strcmp(matFiles(k).name, 'rerun')
        disp(['Analysis run earlier, no need to gather pointers. (file nr. ' num2str(k) ')'])
    else
        load([Pub.dataDestination 'memMaps'])
        
        switch phaseX
            %Phase 2 filterData
            case 2
                sessionNr = matFiles(k).params(1); %session
                subjectNr = matFiles(k).params(2); %subject
                
                load([Pub.dataDestination 'tmp/' num2str(sessionNr) '_' num2str(subjectNr) '_memMaps']) %load mmapDest
                memMaps.(Priv.filtMapName).([Priv.prefixSession num2str(sessionNr)]).([Priv.prefixSubjectFilt num2str(subjectNr)]) = mmapDest;
                save([Pub.dataDestination 'memMaps'],'memMaps');
                
                
            %Phase 3 calculateSimilarityMaps
            case 3
                nrBand = matFiles(k).params(1); %subject
                nrSession = matFiles(k).params(2); %session
                
                load([Pub.dataDestination 'tmp/' num2str(nrBand) '_' num2str(nrSession) '_memMaps']) %load flag
                pause(1)
                if ~exist('flags','var')
                    error('Flags are missing')
                end
                flags = logical(flags);%==1;
                if Pub.corOn
                    if ~flags(1)
                        memMaps.resultMap.whole.([Priv.prefixFreqBand...
                            num2str(nrBand)]).([Priv.prefixSession...
                            num2str(nrSession)]).cor.Writable = false;
                    end
                    if(Priv.nrTimeIntervals(nrSession) > 0)
                        if(~flags(1+4))
                            memMaps.resultMap.win.([Priv.prefixFreqBand...
                                num2str(nrBand)]).([Priv.prefixSession...
                                num2str(nrSession)]).cor.Writable = false;
                        end
                    end
                end
                if Pub.kenOn
                    if ~flags(4)
                        memMaps.resultMap.whole.([Priv.prefixFreqBand...
                            num2str(nrBand)]).([Priv.prefixSession...
                            num2str(nrSession)]).ken.Writable = false;
                    end
                    if (Priv.nrTimeIntervals(nrSession) > 0 )
                        if( ~flags(4+4))
                            memMaps.resultMap.win.([Priv.prefixFreqBand...
                                num2str(nrBand)]).([Priv.prefixSession...
                                num2str(nrSession)]).ken.Writable = false;
                        end
                    end
                end
                if Pub.ssiOn
                    if ~flags(2)
                        memMaps.resultMap.whole.([Priv.prefixFreqBand...
                            num2str(nrBand)]).([Priv.prefixSession...
                            num2str(nrSession)]).ssi.Writable = false;
                    end
                    if(Priv.nrTimeIntervals(nrSession) > 0)
                        if(~flags(4+2))
                            memMaps.resultMap.win.([Priv.prefixFreqBand...
                                num2str(nrBand)]).([Priv.prefixSession...
                                num2str(nrSession)]).ssi.Writable = false;
                        end
                    end
                end
                if Pub.nmiOn
                    if ~flags(3)
                        memMaps.resultMap.whole.([Priv.prefixFreqBand...
                            num2str(nrBand)]).([Priv.prefixSession...
                            num2str(nrSession)]).nmi.Writable = false;
                    end
                    if(Priv.nrTimeIntervals(nrSession) > 0 )
                        if( ~flags(3+4))
                            memMaps.resultMap.win.([Priv.prefixFreqBand...
                                num2str(nrBand)]).([Priv.prefixSession...
                                num2str(nrSession)]).nmi.Writable = false;
                        end
                    end
                end
                
                save([Pub.dataDestination 'memMaps'],'memMaps');
                
            %Phase 4 PearsonFilonAcrossSessions
            case 4
                bandNr = matFiles(k).params(1);
                load([Pub.dataDestination 'tmp/' num2str(bandNr) '_memMaps']) %load sessBlock
                
                for fr = 1:length(sessBlock)
                    memMaps.(Priv.PFmatMapSessionName).whole.([Priv.prefixFreqBand ...
                        num2str(bandNr)]).cor.([Priv.prefixSessComp ...
                        num2str(sessBlock(fr))]).Writable = false;
                end
                save([Pub.dataDestination 'memMaps'],'memMaps');
                
            %Phase 5 PearsonFilon
            case 5
                nrSession = matFiles(k).params(1);
                freqBlock = matFiles(k).params(2);

                load([Pub.dataDestination 'tmp/' num2str(nrSession) '_' num2str(freqBlock) '_memMaps']) %load freqBlock
                
                for fr = 1:length(freqBlock)
                    memMaps.(Priv.PFmatMapName).whole.([Priv.prefixSession ...
                        num2str(nrSession)]).cor.([Priv.prefixFreqComp num2str(freqBlock(fr))]).Writable = false;
                end
                save([Pub.dataDestination 'memMaps'],'memMaps');
                
            %Phase 6 calculateCorMats
            case 6
                nrBand = matFiles(k).params(1); %band
                nrSession = matFiles(k).params(2); %session
                
                memMaps.(Priv.cormatMapName).whole.([Priv.prefixFreqBand...
                    num2str(nrBand)]).([Priv.prefixSession...
                    num2str(nrSession)]).cor.Writable = false;
                for wfr = 1:Priv.nrTimeIntervals(nrSession)
                    memMaps.(Priv.cormatMapName).win.([Priv.prefixFreqBand...
                        num2str(nrBand)]).([Priv.prefixSession...
                        num2str(nrSession)]).cor.([Priv.prefixTimeVal ...
                        num2str(wfr)]).Writable = false;
                end
                save([Pub.dataDestination 'memMaps'],'memMaps');
                
            %Phase 7 calculateStatsMaps
            case 7
                nrBand = matFiles(k).params(1); %band
                nrSession = matFiles(k).params(2); %session
                memMaps.(Priv.statMapName).whole.([Priv.prefixFreqBand...
                    num2str(nrBand)]).([Priv.prefixSession...
                    num2str(nrSession)]).cor.Writable = false;
                
                if Priv.nrTimeIntervals(nrSession) > 0
                    memMaps.(Priv.statMapName).win.([Priv.prefixFreqBand...
                        num2str(nrBand)]).([Priv.prefixSession...
                        num2str(nrSession)]).cor.Writable = false;
                end
                save([Pub.dataDestination 'memMaps'],'memMaps');

            %Phase 8 calculatePhaseSynch
            case 8
                nrBand = matFiles(k).params(1); %band
                nrSession = matFiles(k).params(2); %session
                memMaps.(Priv.phaseMapName).([Priv.prefixSession...
                    num2str(nrSession)]).([Priv.prefixFreqBand...
                    num2str(nrBand)]).Writable = false;
                save([Pub.dataDestination 'memMaps'],'memMaps');
                
            %Phase 9 calclulateSynchCurves
            case 9
                nrBand = matFiles(k).params(1); %band
                nrSession = matFiles(k).params(2); %session
                load([Pub.dataDestination 'tmp/' num2str(nrBand) '_' num2str(nrSession) '_memMaps']) %load corSynch
                
                if corSynch
                    if memMaps.(Priv.synchMapName).([Priv.prefixSession num2str(nrSession)]).([...
                            Priv.prefixFreqBand num2str(nrBand)]).Writable == true
                        memMaps.(Priv.synchMapName).([Priv.prefixSession num2str(nrSession)]).([...
                            Priv.prefixFreqBand num2str(nrBand)]).Writable = false;
                    end
                end
                if Pub.calcPhase == 1
                    if memMaps.(Priv.phaseSynchMapName).([Priv.prefixSession num2str(nrSession)]).([...
                            Priv.prefixFreqBand num2str(nrBand)]).Writable == true
                        memMaps.(Priv.phaseSynchMapName).([Priv.prefixSession num2str(nrSession)]).([...
                            Priv.prefixFreqBand num2str(nrBand)]).Writable = false;
                    end
                end
                
                save([Pub.dataDestination 'memMaps'],'memMaps')
                
        end %case
        
%        save([Pub.dataDestination 'memMaps'],'memMaps')
    end
end
%when everything is done delete the mat-files
delete([tmp_path tmp_path(end-3) '*.mat'])

function fileSTR=findMatFiles(tmp_path, phaseX)
%Function which lists all matfiles in struct and extracts the necessary
%information from the file:
% name   (string)
% params (vector)
%if the analysis is rerun the fileSTR.name is a string 'rerun'

fileSTR = struct('name', '','params', []);


if ~isempty(dir([tmp_path tmp_path(end-3) '*.mat']))
    %search the mat-files
    X = dir([tmp_path tmp_path(end-3) '*.mat']);
    %process the files
    for n = 1:length(X)
        fname=X(n).name;
        
        %if the analysis is rerun and phase is not computed at this time
        if strcmp(X(n).name(1:5), 'rerun')
            fileSTR(n).name = 'rerun';
        else
            gaps=strfind(fname,'_');
            gaps=[0,gaps];
            params = zeros(length(gaps)-1,1);
            for p = 1:length(gaps)-1
                params(p)=str2double(fname((1+gaps(p)):(gaps(p+1)-1)));
            end
            fileSTR(n).name = fname;
            fileSTR(n).params = params;
        end
    end
else
    error(['No mat-files found from tmp folder! Check the output logs from the case ' num2str(phaseX)] )
end
%end


