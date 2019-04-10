function z = r2z(r)
% function z = r2z(r)
% convert r value to z score.
%
% Created 4/9/19 by DJ.

  z = 0.5*log((1+r)./(1-r));
