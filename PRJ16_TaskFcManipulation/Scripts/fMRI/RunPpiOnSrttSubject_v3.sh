#!/bin/bash
set -e

# RunPpiOnSrttSubject_v3.sh $subj $iROI
#
# Run Psychophysiological Interaction (PPI) analysis on SRTT data for a given
# subject and Shen ROI.
#
# Created 10/3/17 by DJ.
# Updated 5/1/18 by DJ.

# Parse inputs
subj=$1
# iRoi=$2
shift
rois=($@)

# Declare constants
maskFilename="/data/jangrawdc/PRJ16_TaskFcManipulation/RawData/shen_1mm_268_parcellation_EpiRes+tlrc"
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
# sd=ROI$iROI
# declare conditions
condList=(c0_baseline c1_unstr c2_str)
# skip creation of 1D files
skip=0

# Move to directory containing subject data
cd $subj/$subj.srtt_v3

# create Gamma impulse response function
if (( skip == 0 )); then
waver -dt ${sub_TR} -GAM -peak 1 -inline 1@1 > GammaHR.1D

for iRoi in ${rois[@]}; do
  # get seed name
  sd=ROI$iRoi
  roiMask="${maskFilename}<$iRoi>"
  # for each run, extract seed time series, run deconvolution, and create interaction regressor
  for cc in `count -digits 2 1 $nruns`; do
    # get avg timecourse in run
    echo `3dmaskave -mask $roiMask -quiet pb05.${subj}.r${cc}.scale+tlrc.HEAD` > Seed${cc}${sd}.1D
    # regress out polynomials from timecourse
    3dDetrend -polort $polortOrder -prefix SeedR${cc}${sd} -overwrite Seed${cc}${sd}.1D
    rm -f Seed_ts${cc}${sd}D.1D
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
    done
  done

  # combine across runs
  for cond in ${condList[@]}; do
    # catenate the two regressors across runs
    cat Seed_ts??${sd}D.1D > Seed_ts${sd}.1D
    cat Inter_ts${cond}??${sd}.1D > Inter_ts${cond}${sd}.1D
  done
done

fi


#################################
# Write 3dDeconvolve statement with new PPI regressors
echo "Writing 3dDeconvolve command to TEMP_Ppi3dDeconvolve.sh..."
let nReg=18+4*${#rois[@]}
let nGlt=10+2*${#rois[@]}

rm -f TEMP_Ppi3dDeconvolve.sh

cat <<EOF >> TEMP_Ppi3dDeconvolve.sh
#!/bin/bash

3dDeconvolve -input pb05.$subj.r*.scale+tlrc.HEAD                        \\
    -censor censor_${subj}_combined_2.1D                                 \\
    -polort $polortOrder                                                 \\
    -local_times                                                         \\
    -num_stimts $nReg                                                    \\
    -stim_times_AM1 1 stimuli/bl1_c1_unstr.txt 'dmBLOCK(1)'              \\
    -stim_label 1 uns1                                                   \\
    -stim_times_AM1 2 stimuli/bl2_c1_unstr.txt 'dmBLOCK(1)'              \\
    -stim_label 2 uns2                                                   \\
    -stim_times_AM1 3 stimuli/bl3_c1_unstr.txt 'dmBLOCK(1)'              \\
    -stim_label 3 uns3                                                   \\
    -stim_times_AM1 4 stimuli/bl1_c2_str.txt 'dmBLOCK(1)'                \\
    -stim_label 4 str1                                                   \\
    -stim_times_AM1 5 stimuli/bl2_c2_str.txt 'dmBLOCK(1)'                \\
    -stim_label 5 str2                                                   \\
    -stim_times_AM1 6 stimuli/bl3_c2_str.txt 'dmBLOCK(1)'                \\
    -stim_label 6 str3                                                   \\
    -stim_file 7 motion_demean.1D'[0]' -stim_base 7 -stim_label 7 roll_01    \\
    -stim_file 8 motion_demean.1D'[1]' -stim_base 8 -stim_label 8 pitch_01   \\
    -stim_file 9 motion_demean.1D'[2]' -stim_base 9 -stim_label 9 yaw_01     \\
    -stim_file 10 motion_demean.1D'[3]' -stim_base 10 -stim_label 10 dS_01   \\
    -stim_file 11 motion_demean.1D'[4]' -stim_base 11 -stim_label 11 dL_01   \\
    -stim_file 12 motion_demean.1D'[5]' -stim_base 12 -stim_label 12 dP_01   \\
    -stim_file 13 motion_deriv.1D'[0]' -stim_base 13 -stim_label 13 roll_02  \\
    -stim_file 14 motion_deriv.1D'[1]' -stim_base 14 -stim_label 14 pitch_02 \\
    -stim_file 15 motion_deriv.1D'[2]' -stim_base 15 -stim_label 15 yaw_02   \\
    -stim_file 16 motion_deriv.1D'[3]' -stim_base 16 -stim_label 16 dS_02    \\
    -stim_file 17 motion_deriv.1D'[4]' -stim_base 17 -stim_label 17 dL_02    \\
    -stim_file 18 motion_deriv.1D'[5]' -stim_base 18 -stim_label 18 dP_02    \\
EOF

for i in "${!rois[@]}"; do
  # get seed and seed name
  iRoi=${rois[i]}
  sd=ROI$iRoi
  # get indices
  let i1=18+4*${i}+1
  let i2=18+4*${i}+2
  let i3=18+4*${i}+3
  let i4=18+4*${i}+4
  cat <<EOF >>  TEMP_Ppi3dDeconvolve.sh
    -stim_file $i1 Seed_ts${sd}.1D -stim_label $i1 Seed_${sd} \\
    -stim_file $i2 Inter_ts${condList[0]}${sd}.1D -stim_label $i2 PPI_${sd}_rest \\
    -stim_file $i3 Inter_ts${condList[1]}${sd}.1D -stim_label $i3 PPI_${sd}_uns  \\
    -stim_file $i4 Inter_ts${condList[2]}${sd}.1D -stim_label $i4 PPI_${sd}_str  \\
EOF
done

cat <<EOF >>  TEMP_Ppi3dDeconvolve.sh
    -num_glt $nGlt                                                           \\
    -gltsym 'SYM: +0.33*uns1 +0.33*uns2 +0.33*uns3'                          \\
    -glt_label 1 unstructured                                                \\
    -gltsym 'SYM: +0.33*str1 +0.33*str2 +0.33*str3'                          \\
    -glt_label 2 structured                                                  \\
    -gltsym 'SYM: +str1 +str2 +str3 -uns1 -uns2 -uns3'                       \\
    -glt_label 3 structured-unstructured                                     \\
    -gltsym 'SYM: +str1 -uns1'                                               \\
    -glt_label 4 'structured-unsructured BL1'                                \\
    -gltsym 'SYM: +str2 -uns2'                                               \\
    -glt_label 5 'structured-unstructured BL2'                               \\
    -gltsym 'SYM: +str3 -uns3'                                               \\
    -glt_label 6 'structured-unstructured BL3'                               \\
    -gltsym 'SYM: +0.167*uns1 +0.167*uns2 +0.167*uns3 +0.167*str1 +0.167*str2 +0.167*str3'  \\
    -glt_label 7 task                                                        \\
    -gltsym 'SYM: +0.5*uns1 +0.5*str1'                                       \\
    -glt_label 8 'task BL1'                                                  \\
    -gltsym 'SYM: +0.5*uns2 +0.5*str2'                                       \\
    -glt_label 9 'task BL2'                                                  \\
    -gltsym 'SYM: +0.5*uns3 +0.5*str3'                                       \\
    -glt_label 10 'task BL3'                                                 \\
EOF

for i in "${!rois[@]}"; do
  iROI=${rois[$i]}
  sd=ROI${iROI}
  # get GLT indices
  let i1=10+2*${i}+1
  let i2=10+2*${i}+2

  # PPI GLTs
  cat <<EOF >>  TEMP_Ppi3dDeconvolve.sh
    -gltsym 'SYM: +0.5*PPI_${sd}_uns +0.5*PPI_${sd}_str -PPI_${sd}_rest'           \\
    -glt_label $i1 PPI_${sd}_task-rest                                              \\
    -gltsym 'SYM: +PPI_${sd}_uns -PPI_${sd}_str'                                   \\
    -glt_label $i2 PPI_${sd}_uns-str                                                \\
EOF
done

# desired outputs
cat <<EOF >>  TEMP_Ppi3dDeconvolve.sh
    -rout -tout -overwrite \\
    -bucket PPIstats
EOF

# Run 3dDeconvolve command
bash TEMP_Ppi3dDeconvolve.sh
