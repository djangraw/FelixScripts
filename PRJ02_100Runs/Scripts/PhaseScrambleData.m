function scrambledData = PhaseScrambleData(originalData)

% Take scramble the phase of a dataset while preserving the magnitude.
% scrambledData = PhaseScrambleData(originalData)
%
% INPUTS:
% -originalData is an n-dimensional matrix of real values.
%
% OUTPUTS:
% -scrambledData is a matrix of equal size that has the same magnitude
% spectrum as originalData but whose phase has been randomly permuted.
%
% Created 1/8/15 by DJ.

% get n-dimensional FFT
fData = fftn(originalData);
% calculate magnitude & phase
magF = abs(fData);
phaseF = angle(fData);
% randomly permute phase
randomPhaseF_vec = phaseF(randperm(numel(phaseF))); % scramble phase completely
randomPhaseF = reshape(randomPhaseF_vec,size(fData));
scrambledFData = magF.*(exp(randomPhaseF*1i)); % back to complex #
% bring back to domain
scrambledData = abs(ifftn(scrambledFData));