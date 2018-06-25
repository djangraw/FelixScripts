#!/bin/bash

#COMPLETELY DONE
# (7) DO INTENSITY NORMALIZATION AND ZCAT TO SET UP INPUT FOR TEDANA.PY
# ===========================

detrend_123_dump=/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/Bailey_Analysis/detrend_123_files

for SBJ in #'02' #'01'
do
  for S in #'01' '02' '03' '04' '05' '06' '07' '08' '09'
  do
    for Task in #'01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12' '13'
    do
      directory=/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/Bailey_Analysis/SBJ${SBJ}/S${S}/Task${Task}
      if [ -d "${directory}" ]; then
        cd ${directory}
        
        fileinfo=SBJ${SBJ}_S${S}_Task${Task}
        filesuffix=align_clp+orig
  
        # make sure all voxels have data at all time points
        3dAutomask -overwrite -prefix detrend_123_p04.${fileinfo}_e2.align.automask+orig -clfrac 0.3 -overwrite p04.${fileinfo}_e2.REF.${filesuffix}
  
        3dTstat -min -prefix tmp.MinValAlign -overwrite ${detrend_123_dump}/detrend_123_p04.${fileinfo}_e1.${filesuffix}
  
        3dcalc -a detrend_123_p04.${fileinfo}_e2.align.automask+orig -b tmp.MinValAlign+orig \
             -prefix detrend_123_p04.${fileinfo}_e2.align.mask -expr 'ispositive(a*b)' -overwrite

        # calculate the median value for the 5th value in the first echo
        3dBrickStat -mask detrend_123_p04.${fileinfo}_e2.align.mask+orig -percentile 50 1 50  ${detrend_123_dump}/detrend_123_p04.${fileinfo}_e1.${filesuffix}'[5]' > gms.1D
        gms=`cat gms.1D`; gmsa=($gms); p50=${gmsa[1]}

        for echo in e1 e2 e3
        do
          # scale all values by 10000/"the median value of volume 5 for the first echo"
          3dcalc -float -overwrite -a ${detrend_123_dump}/detrend_123_p04.${fileinfo}_${echo}.${filesuffix} \
                 -b detrend_123_p04.${fileinfo}_e2.align.mask+orig \
                 -expr "ispositive(b)*a*10000/${p50}" -prefix detrend_123_p05.${fileinfo}_${echo}.in.nii.gz
          
          # add the mean image to the time series (still not sure why Prantik does this mean addition)
          3dTstat -prefix detrend_123_p05.${fileinfo}_${echo}.mean.nii.gz detrend_123_p05.${fileinfo}_${echo}.in.nii.gz -overwrite
          3dcalc -float -overwrite -a detrend_123_p05.${fileinfo}_${echo}.in.nii.gz \
                 -b detrend_123_p05.${fileinfo}_${echo}.mean.nii.gz  -expr 'a+b' \
                 -prefix detrend_123_p06.${fileinfo}_${echo}.sm.nii.gz
          3dTstat -stdev -prefix detrend_123_p06.${fileinfo}_${echo}.std.nii.gz detrend_123_p06.${fileinfo}_${echo}.sm.nii.gz -overwrite
        done

        ZCatList=`ls detrend_123_p06.${fileinfo}_e*.sm.nii.gz`
        3dZcat -overwrite -prefix detrend_123_zcat_ffd_${fileinfo}.nii.gz  \
               ${ZCatList}
        3dcalc -float -overwrite -a detrend_123_zcat_ffd_${fileinfo}.nii.gz'[0]' -expr 'notzero(a)' \
               -prefix zcat_mask_${fileinfo}.nii.gz
      fi
    done
  done
done

#red -01
#orange -02
#yellow -03
#green -04
#blue -05
#purple -06
#grey -07
#red -08
#orange -09

#COMPLETELY DONE
# (8) RUN TEDANA.PY TO DENOISE RUNS AND CALCULATE OPTIMALLY COMBINED TIME SERIES
# ===========================

# Calling Bens version of tedana.py
#VIRTUAL_ENV_DISABLE_PROMPT=1 source /data/handwerkerd/Python/CanopyEnvironment/User/bin/activate
for SBJ in #'02' #'01'
do
  for S in  #'09' # '02' '03' '04' '05' '06' '07' '08' '09'
  do
    for Task in #'09' #'02' '03' '04' '05' '06' '07' '08' '19' '10' '11' '12' '13' 
    do
      directory=/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/Bailey_Analysis/SBJ${SBJ}/S${S}/Task${Task}
      if [ -d "${directory}" ]; then
        cd ${directory}
        fileinfo=SBJ${SBJ}_S${S}_Task${Task}
        echo ${fileinfo}
        EchoTimes="15.4,29.7,44.0"
        python /data/NIMH_SFIM/CommonScripts/me-ica_experimental/meica.libs/tedana.py -e ${EchoTimes} -d detrend_123_zcat_ffd_${fileinfo}.nii.gz --sourceTEs=-1 --kdaw=10 --rdaw=1 --initcost=tanh --finalcost=tanh --conv=2.5e-5
      fi
    done
  done
done


#COMPLETELY DONE
# (9) COMPUTE MOTION FIRST DERIVATIVE
# ==================================
for SBJ in #'01' '02'
do
  for S in #'01' '02' '03' '04' '05' '06' '07' '08' '09'
  do
    for Task in #'01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12' '13'
    do
      directory=/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/Bailey_Analysis/SBJ${SBJ}/S${S}/Task${Task}
      if [ -d "${directory}" ]; then
        cd ${directory}
        fileinfo=SBJ${SBJ}_S${S}_Task${Task}
  
        echo "#############################################################"
        echo "################    RUNNING MOT DERIV STEP ##################"
        echo "#############################################################"
        
        if [ -f ${fileinfo}_e2_Motion.demean.1D     ]; then rm ${fileinfo}_e2_Motion.demean.1D; fi
        if [ -f ${fileinfo}_e2_Motion.demean.der.1D ]; then rm ${fileinfo}_e2_Motion.demean.der.1D; fi
	echo "calling 1d_tool.py derivative on ${fileinfo}_e2_Motion.1D"
        1d_tool.py -infile ${fileinfo}_e2_Motion.1D -demean -derivative -write ${fileinfo}_e2_Motion.demean.der.1D
        echo "calling 1d_tool.py write on ${fileinfo}_e2_Motion.1D"
        1d_tool.py -infile ${fileinfo}_e2_Motion.1D -demean -write ${fileinfo}_e2_Motion.demean.1D
      fi
    done
  done
done

# (11) FOR JUST TASK VOLUMES (Optimally Combined, and Denoised )
#  A. Remove the beginning and ending volumes for fMRI data and Motion and Censored 1D files
#  B. Intensity Normalize
# ============================================
echo "There should be 1 unmodeled volume in each run to keep the GLM happy"
echo "This will be done by removing the first 8 volumes from each run so that the task begins at time=2"
echo "For most runs, the first 4 volumes were already removed in preprocessing so only remove another 4 before putting the data into the GLM"
echo "For most runs, also remove the last 5 volumes which are after the last 40s recovery"
echo "For subject 1, runs 1-3 only remove 0 volumes at the beginning and none at the end"
echo "For subject 1, runs 4-11, only remove 0 volumes at the beginning and 5 at the end."
for SBJ in #'SBJ01' 'SBJ02'
  do
  for DAY in #'S01' 'S02' 'S03' 'S04' 'S05' 'S06' 'S07' 'S08' 'S09'
    do
    cd /data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/Bailey_Analysis/${SBJ}/${DAY}
    EndTaskRun=`ls Task*/${SBJ}_${DAY}_Task*e1+orig.HEAD | wc -l`
    unset StartVol EndVol
    if [ $SBJ == 'SBJ01' ] && [ $DAY == 'S01' ]
    then
      StartVol=( 0 0 0 0 0 0 0 0 0 0 0 )
      EndVol=( 150 150 150 150 150 150 150 150 150 150 150 )
    else
      StartVol=4
      EndVol=154
      for (( run=1; run<${EndTaskRun}; run++ ))
      do
        StartVol=( ${StartVol[@]} 4 )
        EndVol=( ${EndVol[@]} 154 )
      done
    fi
    echo "SBJ ${SBJ} Day ${DAY} Start Volumes ${StartVol[@]}"
    echo "End Volumes ${EndVol[@]}"

    unset RunLabels
    RunLabels=''
    for (( run=1; run<=${EndTaskRun}; run++ ))
    do
      RunLabels=( ${RunLabels[@]} `printf Task%02d ${run}` )
    done

    scantypes=(echo2 OptCombine Denoised)

    # Removing the preceding and final volumes to leave only the 151 vols (5 minutes) of the task
    # (One volume before task begins is included)
    rootdir=/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/Bailey_Analysis/${SBJ}/${DAY}
    for (( run=0; run<${EndTaskRun}; run++ ))
    do    
      CurrRun=${RunLabels[${run}]}
      cd ${rootdir}/${CurrRun}    
      3dcalc -overwrite -a detrend_123_p06.${SBJ}_${DAY}_${CurrRun}_e2.sm.nii.gz'['${StartVol[$run]}'..'${EndVol[$run]}']' \
             -prefix p07.${SBJ}_${DAY}_${CurrRun}_echo2_151vols+orig -float -expr 'a'
      3drefit -view 'orig' -space ORIG p07.${SBJ}_${DAY}_${CurrRun}_echo2_151vols+tlrc


      3dcalc -overwrite -a  ./TED/ts_OC.nii'['${StartVol[$run]}'..'${EndVol[$run]}']'\
             -prefix p07.${SBJ}_${DAY}_${CurrRun}_OptCombine_151vols+orig -float -expr 'a'

      3dcalc -overwrite -a  ./TED/dn_ts_OC.nii'['${StartVol[$run]}'..'${EndVol[$run]}']'\
             -prefix p07.${SBJ}_${DAY}_${CurrRun}_Denoised_151vols+orig -float -expr 'a'
    done
  
  # Intensity normalization (divide by mean & multiply by 100)
    for (( run=0; run<${EndTaskRun}; run++ ))
    do
      for scanname in ${scantypes[@]}
      do
        CurrRun=${RunLabels[${run}]}
        cd ${rootdir}/${CurrRun} 
        echo $CurrRun $scanname
        3dTstat -overwrite -mean -prefix  p07.${SBJ}_${DAY}_${CurrRun}_${scanname}_mean \
             p07.${SBJ}_${DAY}_${CurrRun}_${scanname}_151vols+orig
        3dcalc -overwrite -a p07.${SBJ}_${DAY}_${CurrRun}_${scanname}_mean+orig \
               -b p07.${SBJ}_${DAY}_${CurrRun}_${scanname}_151vols+orig \
               -prefix p08.${SBJ}_${DAY}_${CurrRun}_${scanname}_intensitynorm \
               -expr '100*b/a' -float
      done
    done
  done
done


# (12) MAPPING DAYS TO RUNS
# THIS IS TO BE DONE FOR ALL DAYS OF A SUBJECT AT ONCE
#========================================================
for SBJ in 'SBJ02' # 'SBJ01'
do
  if [ $SBJ == 'SBJ01' ]
  then
    TaskNums=(01 02 03 04 05 06 07 08 09 10 11 \
               01 02 03 04 05 06 07 08 09 10 11 12 13 \
               01 02 03 04 05 06 07 08 09 10 11 12 13 \
	       01 02 03 04 05 06 07 08 09 10 11 \
               01 02 03 04 05 06 07 08 09 10 11 12 13 \
	       01 02 03 04 05 06 07 08 09 10 11 12  \
	       01 02 03 04 05 06 07 08 09 10 11 12 13 \
	       01 02 03 04 05 06 07 08 09 10 \
	       01 02 03 04 05 06 07)
   SessionNums=(01 01 01 01 01 01 01 01 01 01 01 \
               02 02 02 02 02 02 02 02 02 02 02 02 02 \
               03 03 03 03 03 03 03 03 03 03 03 03 03 \
	       04 04 04 04 04 04 04 04 04 04 04 \
               05 05 05 05 05 05 05 05 05 05 05 05 05 \
	       06 06 06 06 06 06 06 06 06 06 06 06 \
	       07 07 07 07 07 07 07 07 07 07 07 07 07 \
	       08 08 08 08 08 08 08 08 08 08 \
	       09 09 09 09 09 09 09)

   # This assignment of StartVol and EndVol is also done for each run separately in step 11 "FOR JUST TASK VOLUMES" above
   # More of an explanation is also there
   # Here a single vector is created for all runs
   # Make sure the mapping is the same in both places 
   unset StartVol EndVol 
   StartVol=( 0 0 0 0 0 0 0 0 0 0 0 \
            4 4 4 4 4 4 4 4 4 4 4 4 4 \
            4 4 4 4 4 4 4 4 4 4 4 4 4 \
            4 4 4 4 4 4 4 4 4 4 4 \
            4 4 4 4 4 4 4 4 4 4 4 4 4 
	    4 4 4 4 4 4 4 4 4 4 4 4 \
	    4 4 4 4 4 4 4 4 4 4 4 4 4 \
	    4 4 4 4 4 4 4 4 4 4 \
	    4 4 4 4 4 4 4)
   EndVol=( 150 150 150 150 150 150 150 150 150 150 150 \
           154 154 154 154 154 154 154 154 154 154 154 154 154 \
           154 154 154 154 154 154 154 154 154 154 154 154 154 \
           154 154 154 154 154 154 154 154 154 154 154 \
           154 154 154 154 154 154 154 154 154 154 154 154 154 \
	   154 154 154 154 154 154 154 154 154 154 154 154 \
	   154 154 154 154 154 154 154 154 154 154 154 154 154 \
	   154 154 154 154 154 154 154 154 154 154 \
	   154 154 154 154 154 154 154)
    RunNums=(`count -digits 3 1 ${#TaskNums[@]}`)
  fi

  if [ $SBJ == 'SBJ02' ]
  then
    TaskNums=( 01 02 03 04 05 06 07 08 09 10 \
               01 02 03 04 05 06 07 08 09 10 11 12 \
               01 02 03 04 05 06 07 08 09 10 11 12 13 \
	       01 02 03 04 05 06 07 08 09 10 11 12\
               01 02 03 04 05 06 07 08 09 10 11 12 13 \
	       01 02 03 04 05 06 07 08 09 10 11 12 13 \
	       01 02 03 04 05 06 07 08 09 10 11 12 \
	       01 02 03 04 05 06 07 08 09 10 11 12 13\
	       01 02 03 04 05 06 )
   SessionNums=(01 01 01 01 01 01 01 01 01 01 \
               02 02 02 02 02 02 02 02 02 02 02 02 \
               03 03 03 03 03 03 03 03 03 03 03 03 03 \
	       04 04 04 04 04 04 04 04 04 04 04 04\
               05 05 05 05 05 05 05 05 05 05 05 05 05 \
	       06 06 06 06 06 06 06 06 06 06 06 06 06 \
	       07 07 07 07 07 07 07 07 07 07 07 07 \
	       08 08 08 08 08 08 08 08 08 08 08 08 08 \
	       09 09 09 09 09 09 )

   # This assignment of StartVol and EndVol is also done for each run separately in step 11 "FOR JUST TASK VOLUMES" above
   # More of an explanation is also there
   # Here a single vector is created for all runs
   # Make sure the mapping is the same in both places 
   unset StartVol EndVol 
   StartVol=( 4 4 4 4 4 4 4 4 4 4 \
              4 4 4 4 4 4 4 4 4 4 4 4 \
              4 4 4 4 4 4 4 4 4 4 4 4 4 \
              4 4 4 4 4 4 4 4 4 4 4 4\
              4 4 4 4 4 4 4 4 4 4 4 4 4 \
	      4 4 4 4 4 4 4 4 4 4 4 4 4 \
	      4 4 4 4 4 4 4 4 4 4 4 4 \
	      4 4 4 4 4 4 4 4 4 4 4 4 4 \
	      4 4 4 4 4 4 )
   EndVol=( 154 154 154 154 154 154 154 154 154 154 \
            154 154 154 154 154 154 154 154 154 154 154 154 \
            154 154 154 154 154 154 154 154 154 154 154 154 154 \
            154 154 154 154 154 154 154 154 154 154 154 154 \
            154 154 154 154 154 154 154 154 154 154 154 154 154 \
	    154 154 154 154 154 154 154 154 154 154 154 154 154 \
	    154 154 154 154 154 154 154 154 154 154 154 154 \
	    154 154 154 154 154 154 154 154 154 154 154 154 154
	    154 154 154 154 154 154 )
    RunNums=(`count -digits 3 1 ${#TaskNums[@]}`)
  fi
  scantypes=(OptCombine Denoised)


  cd /data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/Bailey_Analysis/${SBJ}
  mkdir echo2 OptCombine Denoised MotionAndCensorFiles
 
  for (( run=0; run<${#TaskNums[@]}; run++ ))
  do
    for scanname in ${scantypes[@]}
    do
     echo S${SessionNums[$run]} Task${TaskNums[$run]} $scanname
     3dcopy -overwrite \
        /data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/Bailey_Analysis/${SBJ}/S${SessionNums[$run]}/Task${TaskNums[$run]}/p08.${SBJ}_S${SessionNums[$run]}_Task${TaskNums[$run]}_${scanname}_intensitynorm+orig.HEAD \
         ./${scanname}/${SBJ}_${scanname}_Run${RunNums[$run]}
    done
  done

  echo "Making sure the echo2 images all have the same grid"
  3dinfo -header_name -header_line -same_all_grid ./echo2/${SBJ}_echo2_Run???+orig.HEAD
  echo "Making sure the OptCombine images all have the same grid"
  3dinfo -header_name -header_line -same_all_grid ./OptCombine/${SBJ}_OptCombine_Run???+orig.HEAD
  echo "Making sure the Denoised images all have the same grid"
  3dinfo -header_name -header_line -same_all_grid ./Denoised/${SBJ}_Denoised_Run???+orig.HEAD
  echo "Making sure the first echo2, Optcombine, and Denoised images all have the same grid"
  3dinfo -header_name -header_line -same_all_grid \
        ./echo2/${SBJ}_echo2_Run001+orig.HEAD \
        ./OptCombine/${SBJ}_OptCombine_Run001+orig.HEAD \
        ./Denoised/${SBJ}_Denoised_Run001+orig.HEAD

# MAKE SURE THEY ARE RUN WITH THE VARIABLES FOR STARTVOL TASKRUNS ETC
######
  # Compute and mean centered motion and first derivative of motion for the common 5 minute of task data.
  # Move and relabel the runs across sessions to 1-X
  cd /data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/Bailey_Analysis/${SBJ}
  benpath=/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/CrossRunAnalyses.AnatAlign/${SBJ}
  benpath2=/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData
  for (( run=0; run<${#TaskNums[@]}; run++ ))
  do
    echo Run ${run} Session ${SessionNums[$run]} Task ${TaskNums[$run]}
    commonfilename=${SBJ}_S${SessionNums[$run]}_Task${TaskNums[$run]}
   if [ -f ./MotionAndCensorFiles/${SBJ}_echo2_Run${RunNums[$run]}_Motion.demean.der.1D    ]; then rm ./MotionAndCensorFiles/${SBJ}_echo2_Run${RunNums[$run]}_Motion.demean.der.1D; fi
   if [ -f ./MotionAndCensorFiles/${SBJ}_echo2_Run${RunNums[$run]}_Motion.demean.1D ]; then rm ./MotionAndCensorFiles/${SBJ}_echo2_Run${RunNums[$run]}_Motion.demean.1D; fi
   1d_tool.py \
     -infile ${benpath2}/${SBJ}_S${SessionNums[$run]}/D01_Version02.AlignByAnat.Cubic/Task${TaskNums[$run]}/${commonfilename}_e2_Motion.1D'{'${StartVol[$run]}'..'${EndVol[$run]}'}' \
     -demean -derivative -write ./MotionAndCensorFiles/${SBJ}_echo2_Run${RunNums[$run]}_Motion.demean.der.1D

   1d_tool.py \
     -infile ${benpath2}/${SBJ}_S${SessionNums[$run]}/D01_Version02.AlignByAnat.Cubic/Task${TaskNums[$run]}/${commonfilename}_e2_Motion.1D'{'${StartVol[$run]}'..'${EndVol[$run]}'}' \
     -demean -write ./MotionAndCensorFiles/${SBJ}_echo2_Run${RunNums[$run]}_Motion.demean.1D
  done

  for (( run=0; run<${#TaskNums[@]}; run++ ))
  do
     ln -s ${benpath}/MotionAndCensorFiles/${SBJ}_echo2_Run${RunNums[$run]}_Motion.demean.1D ./echo2/${SBJ}_echo2_Run${RunNums[$run]}_Motion.demean.1D
     ln -s ${benpath}/MotionAndCensorFiles/${SBJ}_echo2_Run${RunNums[$run]}_Motion.demean.1D ./OptCombine/${SBJ}_echo2_Run${RunNums[$run]}_Motion.demean.1D
     ln -s ${benpath}/MotionAndCensorFiles/${SBJ}_echo2_Run${RunNums[$run]}_Motion.demean.1D ./Denoised/${SBJ}_echo2_Run${RunNums[$run]}_Motion.demean.1D
     ln -s ${benpath}/MotionAndCensorFiles/${SBJ}_echo2_Run${RunNums[$run]}_Motion.demean.der.1D ./echo2/${SBJ}_echo2_Run${RunNums[$run]}_Motion.demean.der.1D
     ln -s ${benpath}/MotionAndCensorFiles/${SBJ}_echo2_Run${RunNums[$run]}_Motion.demean.der.1D ./OptCombine/${SBJ}_echo2_Run${RunNums[$run]}_Motion.demean.der.1D
     ln -s ${benpath}/MotionAndCensorFiles/${SBJ}_echo2_Run${RunNums[$run]}_Motion.demean.der.1D ./Denoised/${SBJ}_echo2_Run${RunNums[$run]}_Motion.demean.der.1D
  done

  #####
  # Relabel the censor time series by run number and keep only the common 5 minutes of task data
  baileypath=/data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/Bailey_Analysis/${SBJ}
  cd /data/NIMH_SFIM/100RUNS_3Tmultiecho/PrcsData/CrossRunAnalyses.AnatAlign/${SBJ}
  for (( run=0; run<${#TaskNums[@]}; run++ ))
  do 
   echo Run ${run} Session ${SessionNums[$run]} Task ${TaskNums[$run]}
   commonfilename=${SBJ}_S${SessionNums[$run]}_Task${TaskNums[$run]} 
   1deval -expr 'a' -a ../../${SBJ}_S${SessionNums[${run}]}/D01_Version02.AlignByAnat.Cubic/Task${TaskNums[${run}]}/${commonfilename}_e2_Censor.1D'{'${StartVol[$run]}'..'${EndVol[$run]}'}' \
      >   ./MotionAndCensorFiles/${SBJ}_Run${RunNums[${run}]}_e2_Censor.1D
   done
  for (( run=0; run<${#TaskNums[@]}; run++ ))
  do
     ln -s ../MotionAndCensorFiles/${SBJ}_Run${RunNums[${run}]}_e2_Censor.1D ${baileypath}/echo2/${SBJ}_Run${RunNums[${run}]}_e2_Censor.1D
     ln -s ../MotionAndCensorFiles/${SBJ}_Run${RunNums[${run}]}_e2_Censor.1D ${baileypath}/Denoised/${SBJ}_Run${RunNums[${run}]}_e2_Censor.1D
     ln -s ../MotionAndCensorFiles/${SBJ}_Run${RunNums[${run}]}_e2_Censor.1D ${baileypath}/OptCombine/${SBJ}_Run${RunNums[${run}]}_e2_Censor.1D
  done
done
