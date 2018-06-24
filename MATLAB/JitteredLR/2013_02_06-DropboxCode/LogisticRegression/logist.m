% logist() - Iterative recursive least squares algorithm for linear 
%	     logistic model
%
% Usage:
%   >> [v] = logist(x,y,vinit,show,regularize,lambda,lambdasearch,eigvalratio);
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
%
% CHANGED 3/25/11 by DJ and BC - to prevent convergence on first iteration
% (if v is initialized to zero), we set v=v+eps.  To prevent never
% converging, we needed to set the convergence threshold higher, so we made
% it a parameter (convergencethreshold).  At the advice of matlab, we 
% changed from inv(...)*grad to (...)\grad.  We also added a topoplot 
% (based on the channel locations in ALLEEG(1)) to the 'show' figure.  And
% we got rid of the line if regularize, lambda=1e-6; end.

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

function [v] = logist(x,y,v,show,regularize,lambda,lambdasearch,eigvalratio)

printoutput=0;
convergencethreshold = 1e-6; % look at plot (show=1) to find a good value here 

[N,D]=size(x);
iter=0; showcount=0;

if nargin<3 | isempty(v), v=zeros(D,1); vth=0; else vth=v(D+1); v=v(1:D); end;
if nargin<4 | isempty(show); show=0; end;
if nargin<5 | isempty(regularize); regularize=0; end
if nargin<6 | isempty(lambda); lambda=eps; end;
if nargin<7 | isempty(lambdasearch), lambdasearch=0; end
if nargin<8 | isempty(eigvalratio); eigvalratio=0; end;
% if regularize, lambda=1e-6; end

% subspace reduction if requested - electrodes might be linked
if eigvalratio
  [U,S,V] = svd(x,0);                        % subspace analysis
  V = V(:,find(diag(S)/S(1,1)>eigvalratio)); % keep significant subspace
  x = x*V;       % map the data to that subspace
  v = V'*v;      % reduce initialization to the subspace
  [N,D]=size(x); % less dimensions now
end

% combine threshold computation with weight vector.
x = [x ones(N,1)];
v = [v; vth]+eps; 
% v = randn(size(v))*eps;

vold=ones(size(v));

if regularize, lambda = [0.5*lambda*ones(1,D) 0]'; end

% clear warning as we will use it to catch conditioning problems
lastwarn('');

% If lambda increases, the maximum number of iterations is increased from
% maxiter to maxiterlambda
maxiter=100; maxiterlambda=1000;
singularwarning=0; lambdawarning=0; % Initialize warning flags

if show, figure; end

% IRLS for binary classification of experts (bernoulli distr.)
while ((subspace(vold,v)>convergencethreshold)&&(iter<=maxiter)&&(~singularwarning)&&(~lambdawarning))||iter==0, 
    
    vold=v;
    mu = bernoull(1,x*v);   % recompute weights
    w = mu.*(1-mu); 
    e = (y - mu);
    grad = x'*e; % - lambda .* v;
    if regularize,
      % lambda=(v'*v)./2;
      % grad=grad-lambda;
      
      grad=grad - lambda .* v; 
    end
    %inc = inv(x'*diag(w)*x+eps*eye(D+1)) * grad;
    inc = (x'*(repmat(w,1,D+1).*x)+diag(lambda)*eye(D+1)) \ grad;
    
    if strncmp(lastwarn,'Matrix is close to singular or badly scaled.',44)
        warning('Bad conditioning. Suggest reducing subspace.')
        singularwarning=1;
    end
    
    if (norm(inc)>=1000)&regularize, 
        if ~lambdasearch, warning('Data may be perfectly separable. Suggest increasing regularization constant lambda'); end
        lambdawarning=1; 
    end; 
    
    % avoid funny outliers that happen with inv    
    if (norm(inc)>=1000)&regularize&lambdasearch, 
        % Increase regularization constant lambda
        lambda=sign(lambda).*abs(lambda.^(1/1.02));
        lambdawarning=0;
        
        if printoutput,
            fprintf('Bad conditioning.  Data may be perfectly separable.  Increasing lambda to: %6.2f\n',lambda(1));
        end
        
        maxiter=maxiterlambda;
        
    elseif (~singularwarning)&(~lambdawarning), 
        % update
        v = v + inc; 
        
        if show
            showcount=showcount+1;
            
            subplot(1,3,1)
            ax=[min(x(:,1)), max(x(:,1)), min(x(:,2)), max(x(:,2))];
            hold off; h(1)=plot(x(y>0,1),x(y>0,2),'bo');
            hold on; h(2)=plot(x(y<1,1),x(y<1,2),'r+'); 
            xlabel('First Dimension','FontSize',14); ylabel('Second Dimension','FontSize',14);
            title('Discrimination Boundary','FontSize',14);
            legend(h,'Dataset 1','Dataset 2'); axis square;
            
            if norm(v)>0, 
                tmean=mean(x); 
                tmp = tmean; tmp(1)=0; t1=tmp; t1(2)=ax(3); t2=tmp; t2(2)=ax(4);
                xmin=median([ax(1), -(t1*v)/v(1), -(t2*v)/v(1)]);
                xmax=median([ax(2), -(t1*v)/v(1), -(t2*v)/v(1)]);
                tmp = tmean; tmp(2)=0; t1=tmp; t1(1)=ax(1); t2=tmp; t2(1)=ax(2);
                ymin=median([ax(3), -(t1*v)/v(2), -(t2*v)/v(2)]);
                ymax=median([ax(4), -(t1*v)/v(2), -(t2*v)/v(2)]);
                if v(1)*v(2)>0, tmp=xmax;xmax=xmin;xmin=tmp;end;
                if ~(xmin<ax(1)|xmax>ax(2)|ymin<ax(3)|ymax>ax(4)),
                    h=plot([xmin xmax],[ymin ymax],'k','LineWidth',2);
                end;
            end; 
            
            subplot(1,3,2);
            vnorm(showcount) =  subspace(vold,v);
            
            if vnorm(showcount)==0, vnorm(showcount)=nan; end
            
            plot(log(vnorm)/log(10)); title('Subspace between v(t) and v(t+1)','FontSize',14);
            xlabel('Iteration','FontSize',14); ylabel('Subspace','FontSize',14);
            
            axis square;
            
            subplot(1,3,3);
            ALLEEG = evalin('base','ALLEEG');
            topoplot(v(1:(end-1)),ALLEEG(1).chanlocs,'electrodes','on');
            title('Spatial weights for this iteration')
            colorbar;
            drawnow;
            
        end;
        
        
        % exit if converged
        if subspace(vold,v)<convergencethreshold, % CHANGED
            
            if printoutput,
                disp(['Converged... ']);
                disp(['Iterations: ' num2str(iter)]);
                disp(['Subspace: ' num2str(subspace(vold,v))]);
                disp(['Lambda: ' num2str(lambda(1))]);
            end
            
        end;
        
    end
    
    % exit if taking too long 
    
    iter=iter+1;
    if iter>maxiter, 
        
        if printoutput,
            disp(['Not converging after ' num2str(maxiter) ' iterations.']); 
            disp(['Iterations: ' num2str(iter-1)]);
            disp(['Subspace: ' num2str(subspace(vold,v))]);
            disp(['Lambda: ' num2str(lambda(1))]);
        end
    end;   
end;

if eigvalratio
  v = [V*v(1:D);v(D+1)]; % the result should be in the original space
end


function [p]=bernoull(x,eta);
% bernoull() - Computes Bernoulli distribution of x for "natural parameter" eta.
%
% Usage:
%   >> [p] = bernoull(x,eta)
%
% The mean m of a Bernoulli distributions relates to eta as,
% m = exp(eta)/(1+exp(eta));

p = exp(eta.*x - log(1+exp(eta)));
