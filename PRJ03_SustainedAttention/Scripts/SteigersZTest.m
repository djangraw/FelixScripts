function [z,p] = SteigersZTest(r12,r13,r23,n)

% [z,p] = SteigersZTest(r12,r13,r23,n)
% [z.p] = SteigersZTest(v1,v2,v3)
% 
% INPUTS:
% -r12 (a scalar) is the correlation coefficient between vectors 1 and 2.
% -r13 (a scalar) is the correlation coefficient between vectors 1 and 3.
% -r23 (a scalar) is the correlation coefficient between vectors 2 and 3.
% -n is the number of elements in each vector.
% -v1, v2, and v3 are n-element column vectors.
%
% OUTPUTS:
% -z is the Z value based on a Steiger's Z test (is the correlation between
% v1 and v3 significantly different from that between v2 and v3?)
% -p is the p value derived from that Z value.
% 
% Created 12/30/16 by DJ.

% allow vector input
if numel(r12)>1
    v1 = r12;
    v2 = r13;
    v3 = r23;
    r12 = corr(v1,v2);
    r13 = corr(v1,v3);
    r23 = corr(v2,v3);
    n = numel(v1);
end

fz13     = 0.5*log((1+r13)/(1-r13));         % Fisher's z-value for r13
fz23     = 0.5*log((1+r23)/(1-r23));         % Fisher's z-value for r23
psi = r12*(1-r13^2-r23^2) - 1/2*(r13*r23)*(1-r13^2-r23^2-r12^2);
C = psi/((1-r13^2)*(1-r23^2));
S = sqrt((2-2*C) / (n-3));
z = (fz13-fz23)/S;
p = 2*(1-normcdf(abs(z))); % two-tailed
