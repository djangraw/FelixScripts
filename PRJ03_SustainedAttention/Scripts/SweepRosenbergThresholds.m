function [maskSizePos,maskSizeNeg,Rsq,p,r,p_spearman,r_spearman] = SweepRosenbergThresholds(cp,cr,FC,fracCorrect,thresholds,doPlot)

% [maskSizePos,maskSizeNeg,Rsq,p,r,p_spearman,r_spearman] = SweepRosenbergThresholds(cp,cr,FC,fracCorrect,thresholds,doPlot)
%
% INPUTS:
% -cp and cr are mxmxn matrices (m = # ROIs, n = # subjects) of the
% p-values and r-values for the correlation of FC with behavior
% (fracCorrect). Only the upper triangular parts will be used.
% -FC is an mxmxn matrix of FC matrices for each subject.
% -thresholds is an l-element vector of the thresholds you'd like to test.
% -doPlot is a scalar indicating whether you'd like to plot the results.
% [default=false]
%
% OUTPUTS:
% -maskSizePos and maskSizeNeg are l-element vectors of the sizes of the
% positive (high-performance) and negative (low-performance) masks for each
% threshold.
% -Rsq, p, and r are lx4 matrices of the adjusted Rsq value, one-tailed p
% value, and un-adjusted r value for the correlation between fracCorrect
% and the positive match scores, fracCorrect and the negative match scores, 
% the positive and negative match scores, and fracCorrect and the combined
% matrix match scores (each of these is a column).
% -p_spearman,r_spearman are p and r but with Spearman correlations instead
% of Pearson.
% 
% Created 12/19/16 by DJ.
% Updated 1/11/17 by DJ - added r output
% Updated 2/9/17 by DJ - added doPlot input, comments
% Updated 2/23/17 by DJ - added p_spearman, r_spearman outputs

% Declare defaults
if ~exist('doPlot','var') || isempty(doPlot)
    doPlot = false;
end

% Remove lower triangular part
cp = UnvectorizeFc(VectorizeFc(cp),nan,false);
cr = UnvectorizeFc(VectorizeFc(cr),nan,false);
FC = UnvectorizeFc(VectorizeFc(FC),nan,false);

% Set up variables
nSubj = numel(fracCorrect);
nThresh = numel(thresholds);
[maskSizePos_subj,maskSizeNeg_subj] = deal(nan(nThresh,nSubj));
[matchPos,matchNeg,matchBoth] = deal(nan(nThresh,nSubj));
[maskSizePos,maskSizeNeg] = deal(nan(nThresh,1));
[p,r,Rsq,p_spearman,r_spearman] = deal(nan(nThresh,4));
for i=1:nThresh
    [isPos_subj, isNeg_subj] = deal(nan(size(cp)));
    for j=1:nSubj
        % Get mask
        isPos = cp(:,:,j)<thresholds(i) & cr(:,:,j)>0;
        isNeg = cp(:,:,j)<thresholds(i) & cr(:,:,j)<0;
        isPos_subj(:,:,j) = isPos;
        isNeg_subj(:,:,j) = isNeg;
        % Get mask size
        maskSizePos_subj(i,j) = sum(isPos(:));
        maskSizeNeg_subj(i,j) = sum(isNeg(:));
        % Get FC match scores
        matchPos(i,j) = GetFcTemplateMatch(FC(:,:,j),isPos,[],[],'meanmult');
        matchNeg(i,j) = GetFcTemplateMatch(FC(:,:,j),isNeg,[],[],'meanmult');
        matchBoth(i,j) = GetFcTemplateMatch(FC(:,:,j),double(isPos)-double(isNeg),[],[],'meanmult');
    end
    
    if ~any(isnan(matchPos(i,:)))
        % get overlap mask sizes
        isPos_all = all(isPos_subj,3);
        isNeg_all = all(isNeg_subj,3);
        maskSizePos(i) = sum(isPos_all(:));
        maskSizeNeg(i) = sum(isNeg_all(:));
        % Get predictive power
        % Assess
        [p1,Rsq1,lm] = Run1tailedRegression(fracCorrect,matchPos(i,:),true);
        r1 = sqrt(lm.Rsquared.Ordinary);
        [r1_spearman,p1_spearman] = corr(fracCorrect(:),matchPos(i,:)','type','Spearman','tail','right');
        [p2,Rsq2,lm] = Run1tailedRegression(fracCorrect,matchNeg(i,:),false);
        r2 = sqrt(lm.Rsquared.Ordinary);
        [r2_spearman,p2_spearman] = corr(fracCorrect(:),matchNeg(i,:)','type','Spearman','tail','left');
        [p3,Rsq3,lm] = Run1tailedRegression(matchPos(i,:),matchNeg(i,:),false);
        r3 = sqrt(lm.Rsquared.Ordinary);
        [r3_spearman,p3_spearman] = corr(matchPos(i,:)',matchNeg(i,:)','type','Spearman','tail','left');
        [p4,Rsq4,lm] = Run1tailedRegression(fracCorrect,matchBoth(i,:),true);
        r4 = sqrt(lm.Rsquared.Ordinary);
        [r4_spearman,p4_spearman] = corr(fracCorrect(:),matchBoth(i,:)','type','Spearman','tail','right');
        
        % append
        p(i,:) = cat(2,p1,p2,p3,p4);
        r(i,:) = cat(3,r1,r2,r3,r4);
        Rsq(i,:) = cat(2,Rsq1,Rsq2,Rsq3,Rsq4);
        p_spearman(i,:) = cat(2,p1_spearman,p2_spearman,p3_spearman,p4_spearman);
        r_spearman(i,:) = cat(3,r1_spearman,r2_spearman,r3_spearman,r4_spearman);
        
        % Print results
        fprintf('===Threshold = %.3g...\n',thresholds(i));
        fprintf('Pos v fracCorrect: R^2 = %.3g, p = %.3g\n',Rsq1,p1);
        fprintf('Neg v fracCorrect: R^2 = %.3g, p = %.3g\n',Rsq2,p2);
        fprintf('Pos v Neg: R^2 = %.3g, p = %.3g\n',Rsq3,p3);
        fprintf('Pos-Neg v fracCorrect: R^2 = %.3g, p = %.3g\n',Rsq4,p4);
    end
   
end
fprintf('===Done!\n');

if doPlot
    % Plot mask sizes
    subplot(1,2,1);
    plot(thresholds,[maskSizePos,maskSizeNeg]);
    xlabel('threshold');
    ylabel('mask size');
    legend('high-attention','low-attention');
    % Plot prediction accuracy
    subplot(1,2,2);
    h = plotyy(thresholds,Rsq(:,4),thresholds,p(:,4));
    xlabel('threshold');
    ylabel(h(1),'R^2');
    ylabel(h(2),'p');
end