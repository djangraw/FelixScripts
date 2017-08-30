function [U,S,V,PCtc] = PlotFcPca(FC,nPcsToPlot,demeanFC)

% Get and plot principal components of an FC timecourse.
%
% [U,S,V,PCtc] = PlotFcPca(FC,nPcsToPlot,demeanFC)
%
% INPUTS:
% -FC is an nxnxt matrix of functional connectivity between ROIs.
% -nPcsToPlot is a scalar indicating the number of principal components to
% be plotted.
% -demeanFC is a binary value indicating whether you'd like to subtract the
% mean (across time) before calculating the PCs.
% 
% OUTPUTS:
% -U, S, and V are the outputs of SVD. U is a txt matrix, S is a txp
% matrix, and V is a pxp matrix, where p=n*(n-1)/2 (the number of elements
% in the upper triangle of the FC, which contains all the info.
% -PCtc is a pxt matrix indicating the timecourse of each component.
%
% To assemble the weights in V(:,i) (PC #i) back to a symmetric matrix:
% >> Vmat = zeros(size(FC,1));
% >> uppertri = triu(ones(size(FC,1)),1); 
% >> Vmat(uppertri==1) = V(:,i); 
% >> Vmat(uppertri'==1) = V(:,i);
%
% Created 11/6/15 by DJ.
% Updated 11/10/15 by DJ - reassemble full PC matrices, added help header.
% Updated 12/21/15 by DJ - added no-plot option.
% Updated 2/12/16 by DJ - accommodate nans
% Updated 3/24/15 by DJ - fixed making matrix symmetric
% Updated 6/2/16 by DJ - switch to 'econ' version of SVD

% De-Mean FC matrices
if demeanFC
    fprintf('De-meaning FC...\n')
    meanFC = nanmean(FC,3);
    FC = FC - repmat(meanFC,1,1,size(FC,3));
end

fprintf('Assembling vector...\n')
% get upper triangular matrix to convert mat <-> vec
uppertri = triu(ones(size(FC,1)),1); % above the diagonal

% Turn each time point's matrix into a vector of the unique indices.
% (assume the elements above the diagonal contain all the information)
nT = size(FC,3);
nFC = sum(uppertri(:)); % number of unique elements 
FCvec = nan(nT,nFC);
for i=1:nT
    thisFC = FC(:,:,i); % save out for easy indexing
    FCvec(i,:) = thisFC(uppertri==1); % assume a symmetric matrix
end

% Run SVD to find PC's (slowest step)
fprintf('Running SVD...\n')
isOkRow = ~any(isnan(FCvec'));
[U,S,V] = svd(FCvec(isOkRow,:),'econ');
Snorm = diag(S)/sum(diag(S));

%% get timecourses
fprintf('Getting timecourses...\n')
PCtc = V'*FCvec'; % multiply each weight vec by each FC vec

%% plot results
if nPcsToPlot>0
    % plot singular values
    fprintf('Plotting singular values...\n')
    figure(111); clf;
    plot(Snorm);
    xlabel('principal component index')
    ylabel('singular value')
    % plot PCs
    fprintf('Plotting PCs & timecourses...\n')
    figure(112); clf;
    Vmat = zeros(size(FC,1));
    for i=1:nPcsToPlot    
        % form vector back to symmetric matrix
        Vmat(uppertri==1) = V(:,i);
        Vmat(uppertri'==1) = 1; % make lower half into 1s
        Vmat = Vmat.*Vmat'; % make symmetric
        % image matrix
        subplot(nPcsToPlot,2,2*i-1);
        imagesc(Vmat);
        % annotate plot
        ylabel(sprintf('PC #%d: SV=%.3g',i,Snorm(i)));
        axis square
        colorbar;    

        % plot timecourse
        subplot(nPcsToPlot,2,2*i); hold on
        plot(PCtc(i,:));
        % annotate plot
        xlabel('time of window start (samples)')
        ylabel('PC activation')
        grid on
        % plot horizontal line at zero
        plot([0 0],get(gca,'ylim'),'k-');
    end
end