function [p,Rsq,lm] = Run1tailedRegression(x,y,isPosExpected)

% [p,Rsq,lm] = Run1tailedRegression(x,y,isPosExpected)
%
% INPUTS:
% -x and y are vetors whose relationship you want to test.
% -isPosExpected is a binary value that's true if you expect a positive
% relationship between x and y.
%
% OUTPUTS:
% -p is the one-tailed p value 
% -Rsq is the adjusted R^2 value from fitlm.
% -lm is a linear model from MATLAB's fitlm command.
%
% Created 12/21/16 by DJ.
% Updated 12/30/16 by DJ - added lm output.

lm = fitlm(x,y,'Linear'); % least squares
% Print results
[p,F,d] = coefTest(lm);
% Adjust for one-tailed test
if (lm.Coefficients.Estimate(2)>0 && isPosExpected) || (lm.Coefficients.Estimate(2)<0 && ~isPosExpected) % positive correlation exepected
    p = p/2; % one-tailed test
else
    p = 1-p/2;
end
Rsq = lm.Rsquared.Adjusted;
