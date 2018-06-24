function [memMaps, Params, flag] = changeDirectory(parentDir,atlasPath)

% This function changes file pointers in all memory-map objects and changes
% all necessary parameter -fields in parameter-struct. Function is a part of
% ISC toolbox and must be run if analysis data has been moved from its original
% location where memory mapping was performed.
%
% inputs:
%
% parentDir - full directory path name where analysis data is located.
%             e.g. if new data location is:
%                 /home/data/
%                 /home/data/results
%                 /home/data/fMRIpreprocessed
%                 /home/data/fMRIfiltered
%                 .......................
%
%             You must set: parentDir = /home/data/
%
% atlasPath - full directory path where (FSL nifti-format) atlas data is
% located. If this input is not given, only data destination directories will be updated.
% 
%
%
% outputs:
% memMaps - struct containing updated memory maps (data can be accesses through them)
% Params - updated analysis parameter -struct
%
% Note!! Outputs are optional and are needed just if user wants to access data and
% investigate Parameter changes via Matlab's workspace. Updated variables are automatically
% saved in the parentDir so there is no need to save the variables after running this function.

% Jukka-Pekka Kauppi
% 05.09.2010
%
% Last updated: 09.06.2014

flag = 1;
if nargin > 2
    error('Number of inputs must be at most 2!!')
else
    if (length(parentDir)<=1)
        parentDir = [cd parentDir]; %assuming that only filename is given (when the current folder must be the result folder)
    end
    if nargin == 1
        [flag,directories,Params,memMaps] = checkInputs(parentDir);
    else
        [flag,directories,Params,memMaps] = checkInputs(parentDir,atlasPath);
    end
    if ~flag
        return
    end
end

if nargin > 1
    % check atlas path:
    flag = checkMaskAndAtlas(atlasPath,Params);
    if ~flag
        disp('Invalid atlas path!')
        return
    else
        [flag,correctAtlasPath] = checkAndSetMaskAndAtlasPath(atlasPath,Params);
        setAtlasAndMaskPath(correctAtlasPath,Params,handles.paramFile);
    end
end

Priv = Params.PrivateParams;
Pub = Params.PublicParams;
%disp(' ')
%disp('Change mask path in the existing Params-struct.....')

Pub.dataDestination = parentDir;
Priv.PFDestination = [parentDir 'PF' parentDir(end)];
Priv.statsDestination = [parentDir 'stats' parentDir(end)];
Priv.subjectDestination = [parentDir 'fMRIpreprocessed' parentDir(end)];
Priv.subjectFiltDestination = [parentDir 'fMRIfiltered' parentDir(end)];
Priv.resultsDestination = [parentDir 'results' parentDir(end)];

Priv.PFsessionDestination = [parentDir 'PFsession' parentDir(end)];
Priv.withinDestination = [parentDir 'within' parentDir(end)];
Priv.phaseDifDestination = [parentDir 'phase' parentDir(end)];

R(1) = Pub.ssiOn;
R(2) = Pub.nmiOn;
R(3) = Pub.corOn;
R(4) = Pub.kenOn;
R = nonzeros(R.*(1:4));

endS = [{'.bin'},{'_win.bin'}];
disp(' ')
disp('Verify/update addressess of the results in the memory map pointers...')

%disp(' ')
%disp('ISC maps:')
try
    % update synchronization data parentDir names:
    fn = {'whole','win'};
    for k = 1:length(fn)
        for m = 0:Priv.maxScale + 1
            for n = 1:Priv.nrSessions
                for p = 1:length(R)
                    % get memMap:
                    if isfield(memMaps.(Priv.resultMapName),fn{k})
                        H = memMaps.(Priv.resultMapName).(fn{k}).([Priv.prefixFreqBand ...
                            num2str(m)]).([Priv.prefixSession num2str(n)]).(Priv.simM{R(p)});
                        
                        % set parentDirName:
                        FN = [parentDir directories{1} Priv.prefixResults '_' ...
                            Priv.simM{R(p)} '_' Priv.prefixFreqBand ...
                            num2str(m) '_' Priv.prefixSession num2str(n) '_' ...
                            Priv.transformType endS{k}];
                        H.fileName = FN;
                        memMaps.(Priv.resultMapName).(fn{k}).([Priv.prefixFreqBand ...
                            num2str(m)]).([Priv.prefixSession ...
                            num2str(n)]).(Priv.simM{R(p)}) = H;
                    end
                end
            end
        end
    end
%    disp('OK!')
catch
  %  disp(lasterr)
  %  disp('ISC maps not found, update ignored!')
end

%disp(' ')
%disp('Original fMRI data:')
try
    % update original data matrix parentDir names:
    for n = 1:Priv.nrSubjects
        for m = 1:Priv.nrSessions
            % get memMap:
            H2 = memMaps.(Priv.origMapName).([Priv.prefixSession ...
                num2str(m)]).([Priv.prefixSubject num2str(n)]);
            
            % set parentDirName:
            H2.fileName = [parentDir directories{3} Priv.prefixSubject num2str(n) ...
                Priv.prefixSession num2str(m) endS{1}];
                        
            memMaps.(Priv.origMapName).([Priv.prefixSession ...
                num2str(m)]).([Priv.prefixSubject num2str(n)]) = H2;
        end
    end
%    disp('OK!')
catch
  %  disp(lasterr)
  %  disp('Data not found, update ignored!')
end


%disp(' ')
%disp('Wavelet filtered fMRI data:')
try
    % update filtered data matrix parentDir names:
    for n = 1:Priv.nrSubjects
        for m = 1:Priv.nrSessions
            for p = 1:Priv.maxScale + 1
                % get memMap:
                H3 = memMaps.(Priv.filtMapName).([Priv.prefixSession ...
                    num2str(m)]).([Priv.prefixSubjectFilt ...
                    num2str(n)]).([Priv.prefixFreqBand num2str(p)]);
                
                % set parentDir name:
                H3.fileName = [parentDir directories{2} ...
                    Priv.prefixSubjectFilt num2str(n) ...
                    '_' Priv.prefixFreqBand num2str(p) '_' ...
                    Priv.prefixSession num2str(m) '_' ...
                    Priv.transformType '.bin'];
                
                memMaps.(Priv.filtMapName).([...
                    Priv.prefixSession ...
                    num2str(m)]).([Priv.prefixSubjectFilt ...
                    num2str(n)]).([Priv.prefixFreqBand ...
                    num2str(p)]) = H3;
            end
        end
    end
 %   disp('OK!')
catch
  %  disp(lasterr)
  %  disp('Data not found, update ignored!')
end

%disp(' ')
%disp('Intersubject phase synchronization maps:')
try
    % update phase map parentDir names:
    for m = 1:Priv.nrSessions
        for p = 0:Priv.maxScale + 1
            % get memMap:
            H3 = memMaps.(Priv.phaseMapName).([Priv.prefixSession ...
                num2str(m)]).([Priv.prefixFreqBand num2str(p)]);
            
            % set parentDir name:
            H3.fileName = [parentDir directories{6} ...
                'phase_' Priv.prefixFreqBand num2str(p) '_' ...
                Priv.prefixSession num2str(m) '_' ...
                Priv.transformType '.bin'];
            
            memMaps.(Priv.phaseMapName).([Priv.prefixSession ...
                num2str(m)]).([Priv.prefixFreqBand num2str(p)]) = H3;
        end
    end
 %   disp('OK!')
catch
 %   disp(lasterr)
 %   disp('Data not found, update ignored!')
end

%disp(' ')
%disp('Time-varying ISC curves:')
try
    % update synchronization curve parentDir names:
    for n = 1:Priv.nrSessions
        for m = 0:Priv.maxScale + 1
            memMaps.(Priv.synchMapName).(...
                [Priv.prefixSession num2str(n)]).([Priv.prefixFreqBand ...
                num2str(m)]).fileName = [parentDir directories{1} Priv.prefixSyncResults ...
                Priv.prefixSession num2str(n) ...
                Priv.prefixFreqBand num2str(m) '.bin'];
        end
    end
 %   disp('OK!')
catch
 %   disp(lasterr)
 %   disp('Curves not found, update ignored!')
end

%disp(' ')
%disp('Intersubject phase synchronization curves:')
try
    % update synchronization curve parentDir names:
    for n = 1:Priv.nrSessions
        for m = 0:Priv.maxScale + 1
            memMaps.(Priv.phaseSynchMapName).(...
                [Priv.prefixSession num2str(n)]).([Priv.prefixFreqBand ...
                num2str(m)]).fileName = [parentDir directories{6} Priv.prefixPhaseSyncResults ...
                Priv.prefixSession num2str(n) ...
                Priv.prefixFreqBand num2str(m) '.bin'];
            
        end
    end
 %   disp('OK!')
catch
 %   disp(lasterr)
 %   disp('Curves not found, update ignored!')
end



%disp(' ')
%disp('Sum ZPF maps:')
try
    
    % update freq band comparison parentDir names:
    fc = ((Priv.maxScale+2)^2-(Priv.maxScale+2))/2;
    %fn = {'whole','win'};
    fn = {'whole'};
    for k = 1:length(fn)
        for n = 1:Priv.nrSessions
            for p = 1:fc
                % get memMap:
                H = memMaps.(Priv.PFmatMapName).(fn{k}).([...
                    Priv.prefixSession num2str(n)]).(...
                    Priv.simM{3}).([Priv.prefixFreqComp num2str(p)]);
                % set parentDirName:
                H.fileName = [parentDir directories{5} Priv.prefixPFMat '_' ...
                    Priv.simM{3} '_' Priv.prefixSession num2str(n) '_' ...
                    Priv.transformType Priv.prefixFreqComp num2str(p) endS{k}];
                memMaps.(Priv.PFmatMapName).(fn{k}).([...
                    Priv.prefixSession num2str(n)]).(...
                    Priv.simM{3}).([Priv.prefixFreqComp num2str(p)]) = H;
            end
        end
    end
  %  disp('OK!')
catch
   % disp(lasterr)
   % disp('Maps not found, update ignored!')
end

%disp(' ')
%disp('Stats maps:')
try
    % update stats data parentDir names:
    fn = {'whole','win'};
    for k = 1:length(fn)
        for m = 0:Priv.maxScale + 1
            for n = 1:Priv.nrSessions
                if isfield(memMaps.(Priv.statMapName),fn{k})                    
                    % get memMap:
                    H = memMaps.(Priv.statMapName).(fn{k}).([Priv.prefixFreqBand ...
                        num2str(m)]).([Priv.prefixSession num2str(n)]).(Priv.simM{3});
                    % set parentDirName:
                    H.fileName = [parentDir directories{4} Priv.prefixTMap '_' ...
                        Priv.simM{3} '_' Priv.prefixFreqBand ...
                        num2str(m) '_' Priv.prefixSession num2str(n) '_' ...
                        Priv.transformType endS{k}];
                    memMaps.(Priv.statMapName).(fn{k}).([Priv.prefixFreqBand ...
                        num2str(m)]).([Priv.prefixSession num2str(n)]).(Priv.simM{3}) = H;
                end
            end
        end
    end
   % disp('OK!')
catch
   % disp(lasterr)
   % disp('Maps not found, update ignored!')
end
%disp(' ')
%disp('ISC matrices:')
try
    % update correlation matrix data parentDir names:
    fn = {'whole','win'};
    for k = 1:length(fn)
        for m = 0:Priv.maxScale + 1
            for n = 1:Priv.nrSessions
                % get memMap:
                H = memMaps.(Priv.cormatMapName).(fn{k}).([Priv.prefixFreqBand ...
                    num2str(m)]).([Priv.prefixSession num2str(n)]).(Priv.simM{3});
                % set parentDirName:
                H.fileName = [parentDir directories{4} Priv.prefixCorMat '_' ...
                    Priv.simM{3} '_' Priv.prefixFreqBand ...
                    num2str(m) '_' Priv.prefixSession num2str(n) '_' ...
                    Priv.transformType endS{k}];
                memMaps.(Priv.cormatMapName).(fn{k}).([Priv.prefixFreqBand ...
                    num2str(m)]).([Priv.prefixSession num2str(n)]).(Priv.simM{3}) = H;
            end
        end
    end 
  %  disp('OK!')
catch
%    disp(lasterr)
%    disp('ISC matrices not found, update ignored!')
end

try
    
    % update ZPF session comparison maps:
    sc = (Priv.nrSessions^2-Priv.nrSessions)/2;
    %fn = {'whole','win'};
    fn = {'whole'};
    for k = 1:length(fn)
        for p = 0:(Priv.maxScale + 1)
            for n = 1:sc
                % get memMap:
                H = memMaps.(Priv.PFmatMapSessionName).(fn{k}).([Priv.prefixFreqBand num2str(p)]).(...
                [Priv.simM{3}]).([Priv.prefixSessComp num2str(n)]);
                % set parentDirName:
                H.fileName = [parentDir directories{6} Priv.prefixPFMat '_' ...
                    Priv.simM{3} '_' Priv.prefixFreqBand num2str(p) '_' ...
                    Priv.transformType Priv.prefixSessComp num2str(n) endS{k}];
                memMaps.(Priv.PFmatMapSessionName).(fn{k}).([Priv.prefixFreqBand num2str(p)]).(...
                [Priv.simM{3}]).([Priv.prefixSessComp num2str(n)]) = H;
            end
        end
    end
  %  disp('OK!')
catch
   % disp(lasterr)
   % disp('Maps not found, update ignored!')
end


%disp(' ')
%disp(['Saving updated variables to ' parentDir])

% Save updated project destination also to the Params-struct:
Pub.dataDestination = parentDir;

Params.PublicParams = Pub;
Params.PrivateParams = Priv;

save([Pub.dataDestination Pub.dataDescription '.mat'],'Params')
save([Pub.dataDestination 'memMaps.mat'],'memMaps')


%disp(' ')
%disp('done!')
