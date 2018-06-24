function sigmamultiplier_wrapper(fracFirst,SNR_parallel,SNR_orthogonal,sigmamultiplier)

% A workaround that allows us to save smaller chunks of a large set of 
% fracFirst results.
%
% INPUTS: same as runCheck_fracFirstAndSnr
%
% OUTPUTS: fracfirstresults_{i}.mat will be saved in current directory,
% where each {i} signifies the results for sigmamultiplier(i).
%
% Created 12/13/11 by DJ

for i=1:numel(sigmamultiplier)
    runCheck_fracFirstAndSnr(fracFirst,SNR_parallel,SNR_orthogonal,sigmamultiplier(i));
    movefile('fracfirstresults_last.mat',sprintf('fracfirstresults_%d.mat',i));
end