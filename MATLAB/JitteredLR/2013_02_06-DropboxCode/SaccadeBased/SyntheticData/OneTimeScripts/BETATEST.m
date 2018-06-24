% BETATEST.m
% Created for one-time use on 10/31/11 by DJ.

fracFirst = 1;
SNR_parallel = 1;
SNR_orthogonal = 1;

[ALLEEG, EEG, a] = SaveSyntheticData(2,fracFirst,SNR_parallel,SNR_orthogonal);

run_logisticregression_jittered_EM_saccades_wrapper('3DS-TAG-2-synth','allToObject_end',0,'10fold',[0 500]);