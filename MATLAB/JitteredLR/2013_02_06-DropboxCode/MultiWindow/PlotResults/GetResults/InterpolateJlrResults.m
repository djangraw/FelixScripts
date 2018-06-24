function [AzMean,fwdmodelsMean,AzInterp,fmInterp] = InterpolateJlrResults(Az,t,tMean,fwdmodels)

% Interpolate Az and weights/fwdmodels to other time points
%
% [AzMean,fwdmodelsMean,AzInterp,fmInterp] = InterpolateJlrResults(Az,t,tMean,fwdmodels)
%
% Az and t should be nSubjects x nTimepoints x nAnalyses
% fwdmodels should be nChans x nTimepoints x nSubjects x nAnalyses
%
% Created 12/6/12 by DJ.
% Updated 12/31/12 by DJ - added AzInter and fmInterp outputs.

if nargin<3 || isempty(tMean)
    tMean = linspace(min(t(:)),max(t(:)),1000)';
end
if nargin<4 || isempty(fwdmodels)
    doFwdmodels = false;
else
    doFwdmodels = true;
end

nPoints = length(tMean);
nAnalyses = size(Az,3);
nSubjects = size(Az,1);
AzInterp = nan(nPoints,nSubjects,nAnalyses);
AzMean = nan(nPoints,nAnalyses);
for i=1:nAnalyses    
    for j=1:nSubjects
        AzInterp(:,j,i) = interp1(t(j,:,i),Az(j,:,i),tMean,'linear',NaN)';%'extrap')';
    end     
    AzMean(:,i) = mean(AzInterp(:,:,i),2);
end


if doFwdmodels    
    nChans = size(fwdmodels,1);
    fwdmodelsMean = nan(nChans,nPoints,nAnalyses);
    fmInterp = nan(nChans,nPoints,nSubjects,nAnalyses);
    for i=1:nAnalyses                
        for j=1:nSubjects
            fmInterp(:,:,j,i) = interp1(t(j,:,i),fwdmodels(:,:,j,i)',tMean,'linear','extrap')';
        end
        fwdmodelsMean(:,:,i) = mean(fmInterp(:,:,:,i),3);
    end
else
    fwdmodelsMean = [];
end
        
        