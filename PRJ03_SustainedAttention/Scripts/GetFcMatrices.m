function FC = GetFcMatrices(tc,method,winLength)

% Construct functional connectivity matrices using the sliding window
% correlation method, tapered window correlation method, or DCC method.
%
% FC = GetFcMatrices(tc,method,winLength)
%
% INPUTS:
% -tc is a nxt matrix containing the timecourse of activity in each ROI (as
% extracted, for example, using GetTimecourseInRoi.m.
% -method is a string that can be 'sw' for sliding window, 'tw' for tapered
% window (Hamming window of width 1/3 the window length with 1's in
% between, based on Handwerker, NeuroImage 2012), or 'dcc' for dynamic
% conditional correlation (requires the DC_toolbox from Martin Lindquist). 
% [default: 'tw']
% -winLength is a scalar indicating the width of the window to use for
% correlation (in samples. Not used for DCC method). [default: 8]
%
% OUTPUTS:
% -FC is an nxnxp matrix in which FC(i,j,k) is the functional
% connectivity between ROI i and ROI j at time k. If method is 'sw', this
% includes data in the window containing times k-1+(1:winLength), and p =
% (t-winLength+1). If method is 'dcc', p=t.
% 
% Created 11/6/15 by DJ.
% Updated 11/10/15 by DJ - comments.
% Updated 11/18/15 by DJ - nWin = nT-winLength+1
% Updated 11/19/15 by DJ - added DCC option and tapered window option
% Updated 11/24/15 by DJ - made sure lHam is a multiple of 2
% Updated 2/12/16 by DJ - ignore nans in calls to corr
% Updated 11/22/16 by DJ - fixed nan-ignoring corr call ('pairwise')

% Handle defaults
if ~exist('method','var') || isempty(method)
    method = 'tw';
end
if ~exist('winLength','var') || isempty(winLength)
    if strcmpi(method,'sw') || strcmpi(method,'tw')
        winLength = 8; % determined more or less at random
        fprintf('winLength set to default value of %d\n',winLength);
    end
end

% Calculate functional connectivity
switch lower(method)
    case 'dcc'
        % Use Martin Lindquist's DCC measure (with default params)
        fprintf('Getting DCC FC measure...\n');
        FC = DCC(tc');        
    case 'sw' % simple sliding window
        % get # of windows
        [nParc,nT] = size(tc);
        nWin = nT - winLength + 1;
        % get FC between them
        fprintf('Getting sliding-window FC in %d windows...\n',nWin);
        FC = nan(nParc,nParc,nWin);
        for i=1:nWin
%             fprintf('window %d/%d...\n',i,nWin)
            iInWin = (1:winLength) + i - 1; % indices in window
            FC(:,:,i) = corr(tc(:,iInWin)','rows','pairwise'); % find corellation between all ROIs at once
        end
    case 'tw' % tapered window method
        % get # of windows
        [nParc,nT] = size(tc);
        nWin = nT - winLength + 1;
        % get FC between them
        fprintf('Getting sliding-window FC in %d windows...\n',nWin);
        FC = nan(nParc,nParc,nWin);
        lHam = floor(winLength/3);
        if mod(lHam,2)==1; lHam = lHam+1; end % make a multiple of 2
        hamWin = hamming(lHam)';        
        weights = [hamWin(1:floor(lHam/2)), ones(1,winLength-lHam), hamWin(floor(lHam/2)+1:end)];
        % plot window shape
        cla;
        plot(weights);
        xlabel('time (TRs)')
        ylabel('Tapered window weights')
        weightsRep = repmat(weights,nParc,1);
        for i=1:nWin
%             fprintf('window %d/%d...\n',i,nWin)
            iInWin = (1:winLength) + i - 1; % indices in window
            FC(:,:,i) = corr((weightsRep.*tc(:,iInWin))','rows','complete'); % find corellation between all ROIs at once
        end
        
end
fprintf('Done!\n')