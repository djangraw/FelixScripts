function pdf = GetDiffusionPdf(t, params)%L, r, d)

% Gets the diffusion model approximation of the reaction time distribution.
%
% pdf = GetDiffusionPdf(t, params)
%
% Uses an equation ffrom Cox & Miller, 1965: The Theory of Stochastic
% Processes, as referenced in Gottlob, 2004: Location cuing and response 
% time distributions in visual attention.
%
% INPUTS:
% -t is a vector of time points (in ms) at which you want to calculate the 
%  PDF.
% -params.L is the boundary value [796]
% -params.r is the drift rate [1.31]
% -params.d is the drift rate variability [4.32]
% -params.center is the method for determining the ditribution center
% ['median']
%
% OUTPUTS:
% -pdf is a vector of the same length as t, representing the continuous pdf
%  sampled at the time points t. (NOTE: they will not sum to 1 - you must
%  normalize if you want this!)
%
% Created 3/24/11 by DJ.

% Handle defaults
if ~isfield(params,'L'); L=796; else L=params.L; end;
if ~isfield(params,'r'); r=1.31; else r=params.r; end;
if ~isfield(params,'d'); d=4.32; else d=params.d; end;
if ~isfield(params,'center'); center='median'; else center=params.center; end;

%if nargin<4
%    r = 1.31;
%    if nargin<3
%        d = 4.32;
%        if nargin<2
%            L = 796;
%        end
%    end
%end


% First, compute the mode of the distribution
t2 = 0:1000;
pdf = L ./ sqrt(2*pi*d^2 * t2.^3) .* exp(-(L-r*t2).^2 ./ (2*d^2*t2));

switch center
    case 'mode'
        [~,maxind] = max(pdf);
        t = t + t2(maxind);
    case 'mean'
        meantime = round(sum(t2.*pdf/sum(pdf)));
        t = t + meantime;
    case 'median'
        medianind = find(cumsum(pdf/sum(pdf))>=0.5, 1 );
        t = t + t2(medianind);
end

% Plug into equation
pdf = L ./ sqrt(2*pi*d^2 * t.^3) .* exp(-(L-r*t).^2 ./ (2*d^2*t));