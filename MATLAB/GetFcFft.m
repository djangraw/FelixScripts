function [FcFft3d,freq] = GetFcFft(tc,winLength,N,TR)

% [FcFft3d,freq] = GetFcFft(tc,winLength,N,TR)
%
% INPUTS:
% -tc is a DxT matrix of ROI timecourses, where D is the # of ROIs and T
% is the # of samples.
% -TR is a scalar indicating the number of seconds per sample.
% -winLength is a scalar indicating the number of samples in the FC window.
% -N is a scalar indicating the number of frequency bins you'd like.
%
% OUTPUTS:
% FcFft3d is a DxDxN/2 matrix in which FcFft3d(i,j,k) contains the FFT of
% the FC timecourse between rois i and j at frequency freq(k).
% freq is an N/2-element vector of the corresponding frequencies.
%
% Created 3/24/16 by DJ.

%% Declare defaults
if ~exist('N','var')
    N = [];
end
if ~exist('TR','var') || isempty(TR)
    TR = 1;
end

%% Get FC
fprintf('Getting functional connectivity...\n');
FC = GetFcMatrices(tc,'sw',winLength);

%% turn FC into a 2d matrix of the unique values
fprintf('Turning into 2d matrix...\n');
% get upper triangular matrix to convert mat <-> vec
D = size(FC,1);
uppertri = triu(ones(D),1); % above the diagonal

% Turn each time point's matrix into a vector of the unique indices.
% (assume the elements above the diagonal contain all the information)
nT = size(FC,3);
nFC = sum(uppertri(:)); % number of unique elements 
FcMat = nan(nT,nFC);
for i=1:nT
    thisFC = FC(:,:,i); % save out for easy indexing
    FcMat(i,:) = thisFC(uppertri==1); % assume a symmetric matrix
end


%% Take FFT
fprintf('Taking FFT...\n');
FcFft = fft(FcMat,N,1); % along dimension 1 (time)
N = size(FcFft,1);
FcFftPwr = abs(FcFft(1:floor(N/2),:)).^2;
% Get vector of corresponding frequencies 
nyquist = 1/TR/2;
freq = (1:N/2)/(N/2)*nyquist;

%% Convert back to 3d matrix
fprintf('Turning back into 3d matrix...\n');

nF = size(FcFftPwr,1);
FcFft3d = nan(D,D,nF);
for i=1:nF    
    % form vector back to symmetric matrix
    thisFc = nan(D);
    thisFc(uppertri==1) = FcFftPwr(i,:);
    thisFc(uppertri'==1) = 1;
    thisFc = thisFc.*thisFc';
    FcFft3d(:,:,i) = thisFc;
end
fprintf('Done!\n');
