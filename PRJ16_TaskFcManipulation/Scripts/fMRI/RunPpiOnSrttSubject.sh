#!/bin/bash
set -e

# RunPpiOnSrttSubject.sh $subj $iROI
#
# Run Psychophysiological Interaction (PPI) analysis on SRTT data for a given
# subject and Shen ROI.
#
# Created 10/3/17 by DJ.

# Parse inputs
subj=$1
iROI=$2
maskFilename="shen_1mm_268_parcellation.${subj}+orig"
stimTimePath="/data/jangrawdc/PRJ16_TaskFcManipulation/RawData/ppiStimTimes"
# runs per subject
nruns=3
# number of time points per run in TR
n_tp=150
TR=2
# up-sample the data if stim times are not in multiples of TR
sub_TR=2
upsampleFactor=$(expr $TR / $sub_TR)
# order of polynomials to regress out
polortOrder=3
# seed label
sd=ROI$iROI
# declare conditions
condList=(c0_baseline c1_unstr c2_str)

# create Gamma impulse response function
waver -dt ${sub_TR} -GAM -peak 1 -inline 1@1 > GammaHR.1D

# for each run, extract seed time series, run deconvolution, and create interaction regressor
for cc in `count -digits 1 1 $nruns`; do
  # for iRoi in `seq 1 $nROI`; do
  #   # get seed name
  #   sd=ROI$iRoi
    # get avg timecourse in run
    echo `3dmaskave -mask $maskFilename -quiet pb03.$subj.r0${cc}.blur+orig` > Seed${cc}${sd}.1D
    # regress out polynomials from timecourse
    3dDetrend -polort $polortOrder -prefix SeedR${cc}${sd} Seed${cc}${sd}.1D
    1dtranspose SeedR${cc}${sd}.1D Seed_ts${cc}${sd}D.1D
    rm -f SeedR${cc}${sd}.1D
    # Upsample to make match stimulus timing
    if (("$upsampleFactor" > "1")); then
      1dUpsample $upsampleFactor Seed_ts${cc}${sd}D.1D > Seed_ts${cc}${sd}.1D
    else
      cp Seed_ts${cc}${sd}D.1D Seed_ts${cc}${sd}.1D
    fi
    # Deconvolve to estimate activity causing seed timecourse
    3dTfitter -RHS Seed_ts${cc}${sd}.1D -FALTUNG GammaHR.1D Seed_Neur${cc}${sd} 012 -1
    for cond in ${condList[@]}; do
      # Get stim times
      head -${cc} ${stimTimePath}/${cond}_stimtimes.txt |tail -1 > tmp.1D
      # Convolve stim times with HRF
      waver -dt ${sub_TR} -FILE ${sub_TR} GammaHR.1D -tstim `cat tmp.1D` -numout ${n_tp} > ${cond}${cc}${sd}.1D
      rm -f tmp.1D
      # Multiply HRF-convolved stim times by raw seed timecourse
      1deval -a Seed_Neur${cc}${sd}.1D\' -b ${cond}${cc}${sd}.1D -expr 'a*b' > Inter_neu${cond}${cc}${sd}.1D
      # Make final PPI regressor by convolving with HRF
      waver -GAM -peak 1 -TR ${sub_TR} -input Inter_neu${cond}${cc}${sd}.1D -numout ${n_tp} > Inter_hrf${cond}${cc}${sd}.1D
      # Resample back to original resolution
      if (("$upsampleFactor" > "1")); then
        1dcat Inter_hrf${cond}${cc}${sd}.1D"{0..$($upsampleFactor)}" > Inter_ts${cond}${cc}${sd}.1D
      else
        cp Inter_hrf${cond}${cc}${sd}.1D Inter_ts${cond}${cc}${sd}.1D
      fi
    # done
  done
done

for cond in ${condList[@]}; do
  # catenate the two regressors across runs
  cat Seed_ts?${sd}D.1D > Seed_ts${sd}.1D
  cat Inter_ts${cond}?${sd}.1D > Inter_ts${cond}${sd}.1D
done

# re-run regression analysis by adding the two new regressors
3dDeconvolve -input pb03.$subj.r*.blur+orig.HEAD                         \
    -censor censor_${subj}_combined_2.1D                                 \
    -polort 3                                                            \
    -local_times                                                         \
    -num_stimts 16                                                       \
    -stim_times_AM1 1 stimuli/bl1_c1_unstr.txt 'dmBLOCK(1)'              \
    -stim_label 1 uns1                                                   \
    -stim_times_AM1 2 stimuli/bl2_c1_unstr.txt 'dmBLOCK(1)'              \
    -stim_label 2 uns2                                                   \
    -stim_times_AM1 3 stimuli/bl3_c1_unstr.txt 'dmBLOCK(1)'              \
    -stim_label 3 uns3                                                   \
    -stim_times_AM1 4 stimuli/bl1_c2_str.txt 'dmBLOCK(1)'                \
    -stim_label 4 str1                                                   \
    -stim_times_AM1 5 stimuli/bl2_c2_str.txt 'dmBLOCK(1)'                \
    -stim_label 5 str2                                                   \
    -stim_times_AM1 6 stimuli/bl3_c2_str.txt 'dmBLOCK(1)'                \
    -stim_label 6 str3                                                   \
    -stim_file 7 motion_demean.1D'[0]' -stim_base 7 -stim_label 7 roll   \
    -stim_file 8 motion_demean.1D'[1]' -stim_base 8 -stim_label 8 pitch  \
    -stim_file 9 motion_demean.1D'[2]' -stim_base 9 -stim_label 9 yaw    \
    -stim_file 10 motion_demean.1D'[3]' -stim_base 10 -stim_label 10 dS  \
    -stim_file 11 motion_demean.1D'[4]' -stim_base 11 -stim_label 11 dL  \
    -stim_file 12 motion_demean.1D'[5]' -stim_base 12 -stim_label 12 dP  \
    -stim_file 13 Seed_ts${sd}.1D -stim_label 13 Seed \
    -stim_file 14 Inter_ts${condList[0]}${sd}.1D -stim_label 14 PPIA \
    -stim_file 15 Inter_ts${condList[1]}${sd}.1D -stim_label 15 PPIB \
    -stim_file 16 Inter_ts${condList[2]}${sd}.1D -stim_label 16 PPIC \
    -rout -tout \
    -bucket PPIstat${sd}
