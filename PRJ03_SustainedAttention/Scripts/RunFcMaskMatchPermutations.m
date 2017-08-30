function [r,p,score_pos,score_neg,score_combo,r_spearman,p_spearman] = RunFcMaskMatchPermutations(FC,fracCorrect,nets,nPerms,whichrand)

% [r,p,score_pos,score_neg,score_combo,r_spearman,p_spearman] = RunFcMaskMatchPermutations(FC,fracCorrect,nets,nPerms,whichrand)
%
% INPUTS:
% -FC
% -fracCorrect
% -nets
% -nPerms
% -whichRand can be 'edges' or 'behavior'
%
% OUTPUTS:
% -r and p are
% -score_pos/neg/combo
%
% Created 2/2/17 by DJ.
% Updated 2/23/17 by DJ - added Spearman coeffs

nets_vec = VectorizeFc(nets);
nEdges = length(nets_vec);
nSubj = size(FC,3);
[r,Rsq_adj,p,r_spearman,p_spearman] = deal(nan(nPerms,1));

switch whichrand
    case 'edges'
        % Randomize edges included in network, calculate scores, and
        % correlate with behavior.
        [score_pos,score_neg,score_combo] = deal(nan(nPerms,nSubj));
        for i=1:nPerms
            fprintf('Perm %d/%d...\n',i,nPerms);
            nets_this = UnvectorizeFc(nets_vec(randperm(nEdges)),0);
            [score_pos(i,:),score_neg(i,:),score_combo(i,:)] = GetFcMaskMatch(FC,nets_this>0,nets_this<0);
            [p(i),Rsq_adj(i)] = Run1tailedRegression(score_combo(i,:)',fracCorrect(:),true);
            r(i) = corr(score_combo(i,:)',fracCorrect);
            [r_spearman(i),p_spearman(i)] = corr(score_combo(i,:)',fracCorrect,'type','Spearman','tail','right');
        end
    case 'behavior'
        % Calculate scores, then correlate with Randomizd behavior
        [score_pos,score_neg,score_combo] = GetFcMaskMatch(FC,nets>0,nets<0);
        for i=1:nPerms
            fprintf('Perm %d/%d...\n',i,nPerms);
            fracCorrect_this = fracCorrect(randperm(nSubj));            
            [p(i),Rsq_adj(i)] = Run1tailedRegression(score_combo',fracCorrect_this(:),true);
            r(i) = corr(score_combo',fracCorrect_this(:));
            [r_spearman(i),p_spearman(i)] = corr(fracCorrect_this(:),score_combo','type','Spearman','tail','right');
        end
    otherwise
        fprintf('whichrand input ''%s'' not recognized!\n',whichrand);
end
