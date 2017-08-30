% Created 11/21/16 by DJ. 

nZeros  =nan(nSubj,1);
for i=1:nSubj
    nZeros(i) = sum(all(isnan(FCavg(:,:,i))));
end

[r_zeros,p_zeros] = corr(fracCorrect, nZeros);

figure(263); clf;
lm = fitlm(fracCorrect,nZeros,'Linear','VarNames',{'fracCorrect','nZeroedRois'}); % least squares
lm.plot; % plot line & CI
% scatter(behav, pred_glm)
title(sprintf('nZeros r = %.3g, p = %.3g',r_glm,p_glm))
