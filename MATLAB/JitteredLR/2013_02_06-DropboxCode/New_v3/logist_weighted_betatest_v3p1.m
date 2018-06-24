% logist_weighted_betatest_v3p0() - Iterative recursive least squares 
%       algorithm for linear logistic model
%
% Usage:
%   >> [v] =
%   logist_weighted_betatest_v3p1(x,y,vinit,d,show,regularize,lambda,lambdasearch,eigvalratio,useOffset)
% 
% Inputs:
%   x - N input samples [N,D]
%   y - N binary labels [N,1] {0,1}
%
% Optional parameters:
%   vinit       - initialization for faster convergence
%   show        - if>0 will show first two dimensions
%   regularize  - [1|0] -> [yes|no]
%   lambda      - regularization constant for weight decay. Makes
%		  logistic regression into a support vector machine
%		  for large lambda (cf. Clay Spence). Defaults to 10^-6.
%   lambdasearch- [1|0] -> search for optimal regularization constant lambda
%   eigvalratio - if the data does not fill D-dimensional space,
%                   i.e. rank(x)<D, you should specify a minimum 
%		    eigenvalue ratio relative to the largest eigenvalue
%		    of the SVD.  All dimensions with smaller eigenvalues
%		    will be eliminated prior to the discrimination. 
%   useOffset   - binary value indicating whether the weights should
%           include an offset (that is, y = v(1:end-1)*x + v(end) ).
%
% Outputs:
%   v           - v(1:D) normal to separating hyperplane. v(D+1) slope
%
% Compute probability of new samples with p = bernoull(1,[x 1]*v);
%
% References:
%
% @article{gerson2005,
% author = {Adam D. Gerson and Lucas C. Parra and Paul Sajda},
% title = {Cortical Origins of Response Time Variability
%          During Rapid Discrimination of Visual Objects},
% journal = {{NeuroImage}},
% year = {in revision}}
%
% @article{parra2005,
% author = {Lucas C. Parra and Clay D. Spence and Paul Sajda},
% title = {Recipes for the Linear Analysis of {EEG}},
% journal = {{NeuroImage}},
% year = {in revision}}
%
% Authors: Adam Gerson (adg71@columbia.edu, 2004),
%          with Lucas Parra (parra@ccny.cuny.edu, 2004)
%          and Paul Sajda (ps629@columbia,edu 2004)

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2004 Adam Gerson, Lucas Parra and Paul Sajda
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
%
%
%
% Adapted from function logist.m by DJ and BC, 5/5/2011.
% Updated 8/24/11 by DJ - added convergencethreshold parameter, cleanup
% Updated 8/25/11 by BC to improve speed by removing examples where d==0
% Updated 10/26/11 by BC - added input for null distribution of y values
% Updated 12/5/11 by BC - comments
% Updated 12/6/11 by DJ - moved currtrialnumsc calculation up
% Updated 12/9/11 by DJ - optimization using profiler
% Updated 12/12/11 by DJ - added sigmamultiplier
% Updated 9/18/12 by DJ - assume smoothed data (don't take avg here)
% Updated 9/19/12 by DJ - Modified to not use offset
% Updated 10/5/12 by DJ - v2p1
% Updated 11/6/12 by DJ - added conditionPrior option
% Updated 11/15/12 by BC - v2p2, fixed f rounding to pass DerivativeCheck
% ...
% Updated 11/29/12 by DJ - added useOffset input, fixed defaults
% Updated 12/19/12 by DJ - no conditionPrior option, simplified inputs/code

function [v] = logist_weighted_betatest_v3p1(x,y,v,d,show,regularize,lambda,lambdasearch,eigvalratio,useOffset)

% Get data size
[N,D]=size(x);
    
% Handle defaults for optional inputs
if nargin<3 || isempty(v), v=zeros(D,1); vth=0; else vth=v(D+1); v=v(1:D); end;
if nargin<4 || isempty(d), d=ones(size(x)); end;
if nargin<5 || isempty(show); show=0; end;
if nargin<6 || isempty(regularize); regularize=0; end
if nargin<7 || isempty(lambda); lambda=eps; end;
if nargin<8 || isempty(lambdasearch), lambdasearch=0; end
if nargin<9 || isempty(eigvalratio); eigvalratio=0; end;
if nargin<10 || isempty(useOffset); useOffset=false; end;
%if regularize, lambda=1e-6; end

% Speed up computation by removing samples where d==0
locs = find(d<1e-8); % BC, 11/8/12 -- switched find(d==0) to find(d<1e-6)
x(locs,:) = [];
y(locs) = [];
d(locs) = [];

% subspace reduction if requested - electrodes might be linked
if eigvalratio && 0
  [U,S,V] = svd(x,0);                        % subspace analysis
  V = V(:,diag(S)/S(1,1)>eigvalratio); % keep significant subspace 
  x = x*V;       % map the data to that subspace
  v = V'*v;      % reduce initialization to the subspace
end
[N,D]=size(x); % less dimensions now

% combine threshold computation with weight vector.
if useOffset
    x = [x ones(N,1)]; % To use offset
else
    x = [x zeros(N,1)]; % To eliminate offset
end
v = [v; vth]+eps;

if regularize
    lambda = [0.5*lambda*ones(1,D) 0]'; 
end

% clear warning as we will use it to catch conditioning problems
lastwarn('');

if show, figure; end

xt = x'; % Added 11/8/12 BC
v = double(v);

% Run Optimization
opts = optimset('GradObj','on',...
                'Hessian','off',...
                'Display','notify',...
                'TolFun',1e-4,... 
                'TolX',1e-3,... % 11/8/12 BC
                'MaxIter',1000,...
                'DerivativeCheck','off');
%                     'Display','iter-detailed'); % for detailed info on every iteration
%                    'OutputFcn',@lwf_outfcn
%                    'DerivativeCheck','on',...
%                    'FinDiffType','central',...
% Set proper constraints on values of 
mabsx = max(sum(abs(x),2));
vlim = 100/mabsx;
v = fmincon(@lwf,v,[],[],[],[],-vlim*ones(size(v)),vlim*ones(size(v)),[],opts);
%v = fminunc(@lwf,v,opts);

if eigvalratio && 0
  v = [V*v(1:D);v(D+1)]; % the result should be in the original space
end

        
    % logist-weighted function (lwf)
    function [f,g,H] = lwf(v)
    	% v is the current estimate for the spatial filter weights
    	% Returns:
    	%	f:  the objective to minimize, evaluated at v
    	%	g:  the gradient of the objective, evaluated at v
    	%	H:  the Hessian matrix of the objective, evaluated at v
    	%		Note:  the Hessian is approximated by the identity matrix here (akin to gradient descent)
    	%
    	%	The function f(v) is given by:
    	%	f(v) = -1*sum_{i=1}^N d_i*(y_i*x_i*v - log(1+exp(x_i*v))) ...	The usual weighted LR objective
    	%			+ 0.5*v'*diag(lambda)*v ...	The regularization (energy of the weights)
    	%			- sum_{i=1}^N d_i*log(fy_i)	The log-posterior term
    	%		fy_i = p(s_i|x,v) -- the posterior probability of the saccade
    	%		The posterior probability takes the following functional form:
    	%			fy_i = fynum_i/fyden_i  (numerator / denominator)
    	%			Where fynum_i = (1 - exp(-(xv_i-pMu)^2/(2*pStdDev^2))) -- (1 - gaussian)
    	%				Notice here that xv is used in fynum, to ensure that each sample from the saccade has the same posterior prob. value
    	%			Since fy_i is a probability over saccades, the sum of fy_i over all samples from a trial must equal 1
    	%			fyden_i is the normalization constant:
    	%				fyden_i = sum_j fynum_j
    	%					Where j indexes over all samples that belong to the same trial as sample i
    	
        % OBJECTIVE
    	% compute current y-values (xv) and label probabilities (pvals)
        xv = x*v;
        % Get f value (assume conditionPrior is off)
        f = sum(d.*(log(1+exp(xv)) - y.*xv)) + 0.5*sum(v.*(lambda.*v));

        % Produce warning/error if any f values are infinite (???)
        if isinf(f)
%            f=1e50;
            warning('Infinite objective value');
%            error('JLR:InfiniteFValue','objective f is infinite!')
        end

        % GRADIENT
        if nargout > 1 	 % Then we must also compute the gradient			
            pvals = 1./(1+exp(-xv)); % Bernoulli function of p values
            g = xt*(d.*(pvals-y)) + lambda.*v; % Assume conditionPrior is off!
        end
        % HESSIAN
        if nargout > 2
            H = speye(size(v,1),size(v,1));
        end
    end

end