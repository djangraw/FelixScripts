#!/bin/bash

# This runs the unconstrained GLM for each run separately and uses that information to make a mask that removes high variance voxels

scantypes=(OptCombine Denoised)

for SBJ in 'SBJ01' 'SBJ02'
do
  for S in '01' '02' '03' '04' '05' '06' '07' '08' '09'
  do
    for Task in '01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12' '13'
    do
      directory=/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/Bailey_Analysis/${SBJ}/S${S}/Task${Task}
      if [ -d "${directory}" ]; then
        cd ${directory}
        filelist=`ls *+orig.HEAD`
        3drefit -view 'orig' -space ORIG $filelist
      fi
    done
  done

  for scanname in ${scantypes[@]}
  do
    cd /data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/Bailey_Analysis/${SBJ}/${scanname}
    maskloc=/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/Bailey_Analysis/${SBJ}
  #this is wrong but idk how to fix it, maybe i have this already#cp /data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/SBJ02_S04/D01_Version02.AlignByAnat.Cubic/Task${Task}/*Censor* /data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/Bailey_Analysis/SBJ02/${scanname}

    NumRuns=`ls ${SBJ}_${scanname}_Run???+orig.HEAD | wc -l`

    #if [ ! -f SINGLEGLMS ]; then
    #  mkdir SINGLEGLMS
    #fi
    cd SINGLEGLMS

    maskPrefix=${SBJ}_MaskAllTaskRuns

    for (( run=1; run<=${NumRuns}; run++ ))
    do
      runID=`printf %03d ${run}`
      echo Run $runID
      # Get the residual. Javier calculated the residual from the OSO model, I'm using the UNC model
      if [ -f ${SBJ}_${scanname}_Run${runID}.xmat.1D ]; then rm ${SBJ}_${scanname}_Run${runID}.xmat.1D; fi
      if [ -f ${SBJ}_${scanname}_Run${runID}.REML_cmd ]; then rm ${SBJ}_${scanname}_Run${runID}.REML_cmd; fi
      if [ -f ${SBJ}_${scanname}_Run${runID}.errts_REML+orig.HEAD ]; then rm ${SBJ}_${scanname}_Run${runID}.errts_REML+orig.*; fi
      if [ -f ${SBJ}_${scanname}_Run${runID}.bucket_REML+orig.HEAD ]; then rm ${SBJ}_${scanname}_Run${runID}.bucket_REML+orig.*; fi
      if [ -f ${SBJ}_${scanname}_Run${runID}.bucket_REMLvar+orig.HEAD ]; then rm ${SBJ}_${scanname}_Run${runID}.bucket_REMLvar+orig.*; fi
      censorLoc=/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/CrossRunAnalyses.AnatAlign/${SBJ}/MotionAndCensorFiles
      3dDeconvolve -overwrite -jobs 32 -mask ../../${maskPrefix}+orig -float -polort 3 -input ../${SBJ}_${scanname}_Run${runID}+orig \
         -censor ${censorLoc}/${SBJ}_Run${runID}_e2_Censor.1D \
         -num_stimts 1 \
         -stim_times 1 '1D: 2 62 122 182 242' 'TENT(0,58,30)' -stim_label 1 Task \
         -bucket ${SBJ}_${scanname}_Run${runID}.bucket \
         -errts ${SBJ}_${scanname}_Run${runID}.errts \
         -x1D_stop 
      chmod ug+x ${SBJ}_${scanname}_Run${runID}.REML_cmd 
      ./${SBJ}_${scanname}_Run${runID}.REML_cmd

      3dTstat -overwrite -mask ../../${maskPrefix}+orig -sigma -prefix ${SBJ}_${scanname}_Run${runID}.errts.sigma ${SBJ}_${scanname}_Run${runID}.errts_REML+orig
    done
  done
done
done

