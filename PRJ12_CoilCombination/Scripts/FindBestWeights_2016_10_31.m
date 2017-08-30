function [w,fval,exitflag,output] = FindBestWeights(C,winit,useOffset)

% Usage:
%   >> [w,fval,exitflag,output] = FindBestWeights(C,winit,useOffset) 
% 
% Inputs:
%   C - T data points of dimension N [N,T]
%   winit - N initial weights [N,1] or [N+1,1]
%   useOffset - binary value indicating whether you'd like to add a
%   scalar offset
%
% Outputs:
%   w           - optimal weights [1,N] or [1,N+1] (if useOffset)
%   fval, exitflag, output - see help file for matlab funciton fmincon.
%
% Adapted from function logist_weighted_betatest_v3p1.m by DJ, 10/27/16

% Get data size
[N,T]=size(C);

% Handle defaults for optional inputs
if nargin<2 || isempty(winit)
    winit=ones(N,1)/N; wth=0; 
else 
    if numel(winit)>N
        wth=winit(N+1); 
    else
        wth = 0;
    end
    winit=winit(1:N);
end
if nargin<3 || isempty(useOffset)
    useOffset = true;
end
    
% combine threshold computation with weight vector
if useOffset
    C = [C; ones(1,T)]; % To use offset
    winit = double([winit(:); wth])+eps;
end
% add threshold to weight vector

% Declare constants for minimization term
a = repmat(1/T,T,1);
D = C*C'; % for squared term
E = C*a;
F = E*E'; % for mean term

% Run Optimization
% NOTE: This is designed for fminsearch and not fmincon, but it has been working ok.
% Should ideally switch to optimoptions.
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

% Set constraints on values of w
% wlim = 100/mabsC; % output v values must be between -wlim and wlim
wMin = -1; % output w values must be between wMin and wMax
wMax = 1; % output w values must be between wMin and wMax
% make weights sum to 1
Aeq = ones(size(winit))';
beq = 1;

% RUN MINIMIZATION
% w = fmincon(@tnsrfun,winit,[],[],ones(size(winit))',1,-wlim*ones(size(winit)),wlim*ones(size(winit)),[],opts);
[w,fval,exitflag,output] = fmincon(@tnsrfun,winit,[],[],Aeq,beq,wMin*ones(size(winit)),wMax*ones(size(winit)),[],opts);

        
    % TNSR = 1/TSNR function (tnsrfun)
    function [f,g,H] = tnsrfun(w)
    	% v is the current estimate for the spatial filter weights
    	% Returns:
    	%	f:  the objective to minimize, evaluated at w
    	%	g:  the gradient of the objective, evaluated at w
    	%	H:  the Hessian matrix of the objective, evaluated at w
    	%		Note:  the Hessian could be approximated by the identity matrix here (akin to gradient descent)
    	%
    	%	The function f(w) is given by:
    	%	f(w) = var(w'C)  
        %        = sum((w'C)^2)/T - mean(w'C)
        %        = (1/T w'Dw - w'Fw) / wDw )
        %   g(w) = 2/T w'D - 2 w'F
        %   h(w) = 2/T D - 2 F
    	
        % Reusable values
        wDw = w'*D*w;
        
        % OBJECTIVE
        % Get f value (variance of wC / sum(wC.^2))
        X = (wDw/T - w'*F*w);
        Y = w'*E;
        f = log(X) - 2*log(Y);
        
        % Produce warning/error if any f values are infinite (???)
        if isinf(f)
%            f=1e50;
            warning('Infinite objective value');
%            error('JLR:InfiniteFValue','objective f is infinite!')
        end

        % GRADIENT
        if nargout > 1 	 % Then we must also compute the gradient			
            g = (2/T*w'*D - 2*w'*F)'/X - 2*E/Y;
        end
        % HESSIAN
        if nargout > 2  % Then we must also compute the Hessian
            H = speye(size(w,1),size(w,1));
        end
    end

end