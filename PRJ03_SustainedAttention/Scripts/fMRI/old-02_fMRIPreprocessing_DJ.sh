#!/bin/bash
################################################################################################
# SCRIPT TO PRE-PROCESS DATA FOR THE RESTING STATE TMS STUDY
#
# USAGE:
#
# (1) This script runs per subject, on both sessions of data
# (2) The script is meant to be run in parts. Since some parts
#     submit swarm jobs to biowulf, it's probably best to run
#     the whole script on a biowulf interactive node:
#     qsub -I -V -l nodes=1 -q nimh
# (3) Use this script after the fMRI data are placed in the
#     "OriginalData" folder and 01_AnatomicalAlignments.sh is used
#     to align the anatomical images across sessions
# (4) The beginning of the script will need to be edited for the runs
#     of each subject as commented below
# (5) The only variable that needs to be set per subject is
#    sbjidx (first line of code). It's 0 for SBJ01, 1 for SBJ02, etc
# (6) It is possible to execute this as a script without copying and pasting
#     Just set the flags near the top to say which steps should be run for each
#     execution. The script can't currently be run straight through since you need
#     to wait for the steps submitted as swarms to complete before continuing.
#
# MAIN COLLABORATORS: DAVID PITCHER, GEENA IANNI, DANIEL HANDWERKER
# This script is primarily written by Daniel Handwerker based off of
#  another script by Javier Gonzalez Castillo
# Updated 02/24/2015: Dan mostly finished editing the script for this study
# Updated 4/14/15 by DJ - simplified for simple case with n runs, 1 anatomical scan
###############################################################################################

# COMMON STUFF
# ============
set -e # stop if error
source ./00_CommonVariables.sh

# USE THIS TO TAKE SUBJECT AS INPUT
SBJ=$1

# SET sbjidx TO THE SUBJECT YOU PLAN TO RUN
# 0=SBJ01, 1=SBJ02, etc
# sbjidx=1
#
# SBJLIST=(SBJ05)


# Uncomment the beginning and end of this for loop to make
# sure all the file names are correctly typed for each subject
# (Add most sbjidx numbers when more subjects are included.
#for sbjidx in 0 1 2 3 4 5 6; do

# SBJ=${SBJLIST[${sbjidx}]}

# Every subject has 4 multiecho rest runs, but there are some other single or multiecho rest runs too.
# The following variables should be set to list the multiecho runs (without the _e#) and the single echo run names
# MEruns are the multiecho runs
# SingleEchoRuns are the single echo runs (Possibly just in SBJ01)
# MErunsAlign lists the anatomical image to align each multiecho run to.
#  NOTE: FOR RUNS WHERE THERE WAS NO ANATOMICAL FOR POST TMS, ENTER THE PRETMS IMAGE FROM THE SAME
#  SESSION IN MerunsAlign
# SingleEchoRunsAlign lists the anatomical image to align each single echo run to.
# NOTE: I THINK I ASSUME ALL TASKS WERE IN THE PRETMS SESSION. I THINK THIS IS WRONG FOR ONE OR 
#  TWO VOLUNTEERS. IF ALIGNMENT LOOKS BAD FOR THESE RUNS, THIS SHOULD BE CORRECTED

# Each if statement below assigns these variables depending on sbjidx.
#  Since some subjects have the same runs, we don't need a separate list for each subject


# if  [ $SBJ -eq SBJ05 ]; then
   MEruns=(${SBJ}_Run01 ${SBJ}_Run02 ${SBJ}_Run03 ${SBJ}_Run04)
   AnatomyFile=${SBJ}_Anat_bc_ns+orig
# fi

# For preprocessing steps that are run on all volumes for all echos separately,
#   AllFMRIruns contains all fMRI file names
# RegistrationFMRIruns lists the file to register to anatomical images. This is the
#   middle echo for each multiecho run and the single echo volumes
AllFMRIruns=()
RegistrationFMRIruns=()
for merun in ${MEruns[@]}; do
  AllFMRIruns=(${AllFMRIruns[@]} ${merun}_e1  ${merun}_e2 ${merun}_e3)
  RegistrationFMRIruns=(${RegistrationFMRIruns[@]} ${merun}_e2)
done


echo "List of all fMRI runs:"
echo ${AllFMRIruns[@]}
echo "List of fMRI runs for registration to anatomicals:"
echo ${RegistrationFMRIruns[@]}

# Testing to make sure that the described files were correctly named
echo "Confirming described runs exist for subject ${SBJ}"
cd ${PRJDIR}/PrcsData/${SBJ}/D00_OriginalData/
for merun in ${MEruns[@]}; do
  ls ${merun}_e1+orig.HEAD  ${merun}_e2+orig.HEAD ${merun}_e3+orig.HEAD 
done
cd ${PRJDIR}/PrcsData/${SBJ}/D01_Anatomical/
ls ${AnatomyFile}.HEAD
# end of the for loop for going through all subject indices
# done

# Set the number of threads used for parallel jobs
# If it's less than or equal to 32, use all processing cores on the system
# If it's more than 32, then this is probably felix or helix
#  and you shouldn't use the entire system (use just 16 cores)
nthreads=`cat /proc/cpuinfo | grep processor | wc -l`
if [ $nthreads -le 32 ]; then
  export OMP_NUM_THREADS=${nthreads}
else
  export OMP_NUM_THREADS=16
fi

# FLAGS
# All the steps need to be run, but if you set some flags to 0, then you can execute the entire
# script from the command line and only have the parts set to 1 run.
# =====
SetupProcDir=1   # Setting up the preprocessing directory & linking the appropriate files there
Despike=1        # Y. DESPIKE BEFORE SLICE TIME CORRECTION
SliceTime=1      # Y. SLICE TIME CORRECTION.
BiasCorrect=0    # Y. BIAS CORRECTION IN SPM (REQURIES RUNNING A SWARM JOB ON BIOWULF)
SKIPBIASCORRECT=1 # ===== TEMPORARY!!!!
HeadMot=1        # Y. HEAD MOTION CORRECTION
Alignment=1      # Y. NEW_FOR_REVIEW: Ran on SBJ03 SINGLE ALIGNMENT INTERPOLATION STEP COMBINING ALL MATRICES
MeicaPreproc=0   # Y. INTENSITY NORMING AND ZCAT TO GET INPUT READY FOR TEDANA.PY
TedanaProc=0     # Y. RUN TEDANA.PY TO DO MULTIECHO DENOISING
EPImasks=0       # Y. GENERATE BRAIN MASKS FOR EACH DATASET
MotDer=0         # Y. OBTAIN FIRST DERIVATIVE OF MOTION
D03Create=0      # Y. MOVE KEY PREPROCESSED FILES TO D03_ANALYSES

# MORE GENERAL VARIABLES TO SET UP
RemoveVols=4     # The number of volumes to remove from the beginning of the scan.
                 # The removal is done as part of slice timing correction

echolist=(e1 e2 e3) # This assumes multiecho data has 3 echos with files suffixed _e1, _e2, and _e3

rootdir=${PRJDIR}/PrcsData/${SBJ}/D02_Preprocessing/


# (1) LINKING FMRI AND ANATOMICAL FILES FROM OTHER DIRECTORIES
# PREPROCESSING USES FMRI DATA IN THE OriginalData DIRECTORY AND
# THE ALIGNED ANATOMICAL DATA IN THE AnatomicalsProcessed DIRECTORY
# SYMBOLICALLY LINK THESE FILES in $rootdir
# ==================================
if [ $SetupProcDir -eq 1 ] ; then
  # Make directory if it doesn't exist
  cd ${PRJDIR}/PrcsData/${SBJ}
  if [ ! -d D02_Preprocessing ]; then mkdir D02_Preprocessing; fi
  # add link files
  echo "LINKING FILES TO " $rootdir
  cd $rootdir
  for sfx in HEAD BRIK; do
    for merun in ${MEruns[@]}; do
       ln -s ../D00_OriginalData/${merun}_e1+orig.${sfx} ./
       ln -s ../D00_OriginalData/${merun}_e2+orig.${sfx} ./
       ln -s ../D00_OriginalData/${merun}_e3+orig.${sfx} ./
    done
    ln -s ../D01_Anatomical/${AnatomyFile}.${sfx} ./    
  done

fi


# (X) PHYSIOLOGICAL NOISE CORRECTION
# CURRENTLY NOT ADAPTED TO FUNCTION - DH
# ==================================
#if [ ${PhysCorr} -eq 1 ];then
# for (( run = $StartRun; run<=$EndRun; run++ ))
# do
#   RunID=`printf %03d $run`
#   ln -s ./D00_OriginalData/${SBJ}_${DAY}_${CurrRun}+orig.BRIK.gz p01.${SBJ}_${DAY}_${CurrRun}.ricor+orig.BRIK.gz
#   ln -s ./D00_OriginalData/${SBJ}_${DAY}_${CurrRun}+orig.HEAD    p01.${SBJ}_${DAY}_${CurrRun}.ricor+orig.HEAD
# done
#fi


# (2) DESPIKING
# Despiking removed very big fluctuations in time series. This seems particularly useful for
# multi-echo denoising and single-echo fMRI too
if [ ${Despike} -eq 1 ];then
 cd $rootdir
 for fMRIrun in ${AllFMRIruns[@]}; do
    if [ -f p01.${fMRIrun}.despike+orig.HEAD ]; then rm p01.${fMRIrun}.despike+orig.*; fi
    echo "3dDespike -overwrite -ignore ${RemoveVols} -prefix p01.${fMRIrun}.despike ${fMRIrun}+orig"
    3dDespike -overwrite -ignore ${RemoveVols} -prefix p01.${fMRIrun}.despike ${fMRIrun}+orig
  done
fi


# (3) SLICE TIME CORRECTION
# THE FIRST FEW NON-STEADY STATE VOLUMES ARE ALSO REMOVED IN THIS STEP
# NOTE: REGISTRATION BETWEEN RUNS AND TO THE ANATOMICAL IMAGES IS DONE ON THE DESPIKED
# DATA THAT STILL INCLUDES THE FIRST VOLUME WITH HIGHER GRAY/WHITE CONTRAST
# =========================
if [ ${SliceTime} -eq 1 ];then
 cd $rootdir
 for fMRIrun in ${AllFMRIruns[@]}; do
    if [ -f p02.${fMRIrun}.tshift+orig.HEAD ]; then rm p01.${fMRIrun}.tshift+orig.*; fi
    echo "3dTshift -overwrite -tzero 0 -quintic -prefix  p02.${fMRIrun}.tshift p01.${fMRIrun}.despike+orig"'['${RemoveVols}'..$]'
    3dTshift -overwrite -tzero 0 -quintic -prefix  p02.${fMRIrun}.tshift p01.${fMRIrun}.despike+orig'['${RemoveVols}'..$]'
 done
fi

# (4) BIAS CORRECTION IN SPM
# THESE DATA ARE VERY NON-UNIFORM. THIS BIAS NEEDS TO BE CORRECTED FOR MASKING AND ALIGNMENT ACROSS
# RUNS TO WORK WELL
# NOTE: THERE IS A swarm COMMAND IN THIS SECTION THAT SHOULD BE RUN ON BIOWULF
#   WAIT FOR THIS swarm job to finish (qstat -u USERID) BEFORE CONTINUING TO RUN THE NEXT FEW LINES OF CODE
# =========================
# Create a reference image from the first (non-steady state) volume in the despiked time series
# Registration is being done on echo 2
if [ ${BiasCorrect} -eq 1 ]; then
 if [ -f ${SBJ}.fMRIBiasCorrectSwarm.sh ]; then rm ${SBJ}.fMRIBiasCorrectSwarm.sh; fi
 touch ${SBJ}.fMRIBiasCorrectSwarm.sh
 for fMRIrun in ${RegistrationFMRIruns[@]}; do
   # make the reference volumes in .nii format so SPM can use them
   3dcalc -overwrite -a p01.${fMRIrun}.despike+orig'[0]' -prefix p01a.${fMRIrun}.REF.nii -expr 'a'

   echo "cd /data/SFIMLBC/PRJ01_RestTMSMultiEcho/Scripts/D01_Preprocessing/; matlab -nodesktop -minimize -nosplash -r \"SPMBiasCorrect('${rootdir}p01a.${fMRIrun}.REF.nii')\"" >> ${SBJ}.fMRIBiasCorrectSwarm.sh
 done
  
 #RUN ON BIOWULF AND WAIT FOR JOB TO FINISH BEFORE CONTINUING
 swarm -g 2 -R matlab=1 -q nimh -f ${SBJ}.fMRIBiasCorrectSwarm.sh



 # Convert the bias corrected reference images back to BRIK format and
 #   adjust the headers to correct for how SPM messed up the orientation and obliquity
 for fMRIrun in ${RegistrationFMRIruns[@]}; do 
  cd $rootdir
  3dcopy -overwrite mp01a.${fMRIrun}.REF.nii p01b.${fMRIrun}.REF.bc+orig
  3drefit -view 'orig' -space ORIG  -atrcopy p01.${fMRIrun}.despike+orig ORIENT_SPECIFIC -oblique_origin \
         -duporigin p01.${fMRIrun}.despike+orig p01b.${fMRIrun}.REF.bc+orig 

  3dAutomask -overwrite -prefix p01b.${fMRIrun}.REF.bc.mask+orig p01b.${fMRIrun}.REF.bc+orig 
  3dcalc -overwrite -a p01b.${fMRIrun}.REF.bc+orig -b p01b.${fMRIrun}.REF.bc.mask+orig \
                     -expr 'a*ispositive(b)' -float  \
                     -prefix p01b.${fMRIrun}.REF.ns+orig
 done 
 
fi

# ======= TEMPORARY KLUGE: NO BIAS CORRECTION!!!!! ======= #
if [ ${SKIPBIASCORRECT} -eq 1 ]; then
 for fMRIrun in ${RegistrationFMRIruns[@]}; do
  cd $rootdir
  # Copy reference image (1st despiked volume), use it to calculate mask, and mask the reference image
  3dcalc -overwrite -a p01.${fMRIrun}.despike+orig'[0]' -prefix p01b.${fMRIrun}.REF+orig -expr 'a'
  3dAutomask -overwrite -prefix p01b.${fMRIrun}.REF.mask+orig p01b.${fMRIrun}.REF+orig
  3dcalc -overwrite -a p01b.${fMRIrun}.REF+orig -b p01b.${fMRIrun}.REF.mask+orig \
                    -expr 'a*ispositive(b)' -float  \
                    -prefix p01b.${fMRIrun}.REF.ns+orig
 done
fi

# (5)a: INTRA-RUN HEAD MOTION CORRECTION
#  NOTE: THE MOTION CORRECTED TIME SERIES AREN'T DIRECTLY USED, BUT THE MOTION PARAMETERS ARE APPLIED
#  LATER AS PART OF A SINGLE TRANSFORM
# ====================================
if [ ${HeadMot} -eq 1 ];then
 firstFMRIrun=${RegistrationFMRIruns[0]} # DJ adjustment
 for fMRIrun in ${RegistrationFMRIruns[@]}; do 
  cd $rootdir 
  
  3dvolreg -verbose -1Dmatrix_save ${fMRIrun}_matrix_intrarun \
             -overwrite \
             -maxdisp1D     ${fMRIrun}_MaxMot.1D  \
             -1Dfile        ${fMRIrun}_Motion.1D  \
             -base          p01.${firstFMRIrun}.despike+orig'[0]' \
             -prefix        p03.${fMRIrun}.volreg \
                            p02.${fMRIrun}.tshift+orig # DJ adjustment (changed base)
  
  
  1d_tool.py -overwrite -infile ${fMRIrun}_MaxMot.1D -derivative -write ${fMRIrun}_MaxMot.rel.1D
  1d_tool.py -overwrite -infile ${fMRIrun}_Motion.1D \
              -set_nruns 1 -derivative -collapse_cols euclidean_norm \
              -moderate_mask -0.5 0.5 \
              -show_censor_count \
              -write_censor ${fMRIrun}_Censor.1D \
              -write_CENSORTR ${fMRIrun}_CensorTR.txt
  
 done
fi

# (5)b: ALIGNMENT
# ALIGN THE REFERENCE FMRI VOLUMES ACROSS RUNS
# THERE ARE 3-4 ANATOMICAL IMAGES PER VOLUNTEER.
# FIRST, APPLY THE TRANSFORM FOR EACH ANATOMICAL IMAGE INTO MNI SPACE TO THE
#   CORRESPONDING FMRI REFERENCE VOLUMES. THIS PUTS ALL FMRI REFERENCE VOLUMES
#   INTO APPROXIMATELY THE SAME SPACE
# SECOND, ALIGN ALL FMRI REFERENCE IMAGES TO THE FMRI REFERENCE IMAGE FROM RUN 0
# BY FIRST DOING A ROUGH ALIGNMENT AND THEN ALIGNING EPIS TO EACHOTHER, THE RESULTING
#   VOXELWISE ALIGNMENT ACROSS RUNS TURNED OUT WELL
# THIRD APPLY THE TRANSFORM MATRICES FROM THE ANATOMICAL ALIGNMENT, REFERNCE EPI ALIGNMENT
#   AND MOTION CORRECTION TO THE FULL TIME SERIES FOR EACH ECHO

if [ ${Alignment} -eq 1 ]; then
 cd $rootdir
 
 for (( run=0; run<${#RegistrationFMRIruns[@]}; run++ )); do
  cd $rootdir


   if [ ${run} -eq 0 ]; then
       # The first run is aligned to the high res anatomy image in ORIG space
       align_epi_anat.py -overwrite -anat ${AnatomyFile} \
      -epi p01b.${RegistrationFMRIruns[$run]}.REF.ns+orig \
      -epi_base 0 -epi2anat -anat_has_skull no -epi_strip None \
      -deoblique on  # CHANGED epi file
   else
       # All subsequent runs are aligned to the first fMRI reference image in ORIG space
       align_epi_anat.py -overwrite -dset1 p01b.${RegistrationFMRIruns[0]}.REF.ns_al+orig \
      -dset2 p01b.${RegistrationFMRIruns[$run]}.REF.ns+orig \
      -epi_base 0 -dset2to1 -anat_has_skull no -epi_strip None \
      -deoblique on # CHANGED dset1 and dset2
   fi

   # This is the combined spatial transform matrix that includes alignment to MNI
   #  space and motion correction. It is applied to all fMRI time series volumes
   cat_matvec p01b.${RegistrationFMRIruns[$run]}.REF.ns_al_mat.aff12.1D \
             ${RegistrationFMRIruns[$run]}_matrix_intrarun.aff12.1D \
             > ${RegistrationFMRIruns[$run]}_matrix_total.aff12.1D
   
    # Bringing just the reference volumes into MNI space
    3dAllineate -float -final wsinc5 -overwrite \
                  -input p01b.${RegistrationFMRIruns[$run]}.REF.ns+orig \
                  -1Dmatrix_apply p01b.${RegistrationFMRIruns[$run]}.REF.ns_al_mat.aff12.1D \
                  -master p01.${firstFMRIrun}.despike+orig'[0]' \
                  -prefix p04.${RegistrationFMRIruns[$run]}.REF.align

 done


 # For multi-echo data, the alignment is calculated on the middle echo
 # Apply the calculated alignment parameters to the time series for all 3 echos
 echolist=(e1 e2 e3)
 for fMRIrun in ${MEruns[@]}; do 
  cd $rootdir    
  for enum in ${echolist[@]}; do
    3dAllineate -float -final cubic -overwrite \
                  -input p02.${fMRIrun}_${enum}.tshift+orig \
                  -1Dmatrix_apply ${fMRIrun}_e2_matrix_total.aff12.1D \
                  -master p01.${firstFMRIrun}.despike+orig'[0]' \
                  -prefix p04.${fMRIrun}_${enum}.align # CHANGED master to the EPI frame we aligned to.
   done
 done



 # Concatinating the reference images to check alignment across runs (CHANGED Fililist string (since there's no conversion to MNI space))
 cd $rootdir
 # Filelist=`ls p04*REF*+tlrc.HEAD`
 Filelist=`ls p04*REF*+orig.HEAD`
 3dTcat -overwrite -prefix ${SBJ}_REF.align ${Filelist}

 SubBrikLabels=`echo $Filelist | sed 's/+orig.HEAD//g'`
 echo $SubBrikLabels >> tmp.txt
 3drefit -relabel_all tmp.txt ${SBJ}_REF.align+orig 
 rm tmp.txt
 
 # Concatenating the first volume of the middle echo time series to make sure that alignment also looks good (CHANGED to orig space)
 Filelist=()
 SubBrikLabels=()
 for fMRIrun in ${RegistrationFMRIruns[@]}; do
  echo ${fMRIrun}
  Filelist=(${Filelist[@]} p04.${fMRIrun}.align+orig\'[0]\')
  SubBrikLabels=(${SubBrikLabels[@]} p04.${fMRIrun}.align)
 done
 echo ${Filelist[@]}
 echo 3dTcat -overwrite -prefix ${SBJ}_e2FirstVol.align ${Filelist[@]} > tmpcmd.sh 
 # echo 3drefit -relabel_all_str "'${SubBrikLabels[@]}'" ${SBJ}_e2FirstVol.align+orig >> tmpcmd.sh
 echo "echo '${SubBrikLabels[@]}' >> tmp.txt" >> tmpcmd.sh
 echo 3drefit -relabel_all tmp.txt ${SBJ}_e2FirstVol.align+orig >> tmpcmd.sh
 echo "rm tmp.txt" >> tmpcmd.sh
 chmod u+x tmpcmd.sh
 ./tmpcmd.sh

fi

# NOTE NOTE NOTE NOTE:
# Look at ${SBJ}_REF.align+orig to check the alignment of the reference images and
#  ${SBJ}_e2FirstVol.align+orig to check the alignment of the first volumes of the middle 
#  echo across all runs. ${SBJ}_REF.align+orig should also align well with ${SBJ}_Anat_bc_ns+orig
# Moving through the runs like a time series highlights mis-alignments
# It's a good idea to check some of the echo1 and echo3 volumes to make sure they look ok
# But the registration should be identical to echo2

# PREPROCESSING FOR SINGLE ECHO RUNS ENDS HERE
# THE FOLLOWING STEPS ARE MEICA-SPECIFIC




# (6) DO INTENSITY NORMALIZATION AND ZCAT TO SET UP INPUT FOR TEDANA.PY
# INTENSITY NORMALIZATION SCALES EACH ECHO BY THE MEDIAN VALUE OF THE FIRST ECHO
#   THE RESULT IS THAT THE MEDIAN VALUE OF THE FIRST ECHO IS 1
# TEDANA.PY REQUIRES A VOLUME OF THE 3 ECHOS ON TOP OF EACHOTHER. 3DZCAT DOES THIS.
# ===========================
if [ ${MeicaPreproc} -eq 1 ]; then

 for fMRIrun in ${MEruns[@]}; do
   cd ${rootdir}

  # make sure all voxels have data at all time points
  3dAutomask -overwrite -prefix p04.${fMRIrun}.align.automask+orig -clfrac 0.3 -overwrite p04.${fMRIrun}_e2.REF.align+orig
  3dTstat -min -prefix tmp.MinValAlign -overwrite p04.${fMRIrun}_e1.align+orig
  3dcalc -a p04.${fMRIrun}.align.automask+orig -b tmp.MinValAlign+orig \
       -prefix p04.${fMRIrun}.align.mask -expr 'ispositive(a*b)' -overwrite

   # calculate the median value for the 5th value in the first echo
   3dBrickStat -mask p04.${fMRIrun}.align.mask+orig -percentile 50 1 50  p04.${fMRIrun}_e1.align+orig'[5]' > gms.1D
    gms=`cat gms.1D`; gmsa=($gms); p50=${gmsa[1]}

   
   for enum in ${echolist[@]}; do
     # scale all values by 10000/"the median value of volume 5 for the first echo"
      3dcalc -float -overwrite -a p04.${fMRIrun}_${enum}.align+orig \
           -b p04.${fMRIrun}.align.mask+orig \
           -expr "ispositive(b)*a*10000/${p50}" -prefix p05.${fMRIrun}_${enum}.in.nii.gz
     # I'm not adding the mean image to the time series to give it a double mean
     # This is part of the original meica preprocessing by Prantik, but Javier thinks it's an
     # artifact of a now unused preprocessing step that detrended and de-meaned the data
     # 3dTstat -prefix p05.${fMRIrun}_${enum}.mean.nii.gz p05.${fMRIrun}_${enum}.in.nii.gz
     # 3dcalc -float -overwrite -a p05.${fMRIrun}_${enum}.in.nii.gz \
     #       -b p05.${fMRIrun}_${enum}.mean.nii.gz  -expr 'a+b' \
     #       -prefix p06.${fMRIrun}_${enum}.sm.nii.gz
     # 3dTstat -stdev -prefix p06.${fMRIrun}_${enum}.std.nii.gz p06.${fMRIrun}_${enum}.sm.nii.gz
   done

    3dZcat -overwrite -prefix zcat_ffd_${fMRIrun}.nii.gz  \
          p05.${fMRIrun}_e1.in.nii.gz \
          p05.${fMRIrun}_e2.in.nii.gz \
          p05.${fMRIrun}_e3.in.nii.gz
    3dcalc -float -overwrite -a zcat_ffd_${fMRIrun}.nii.gz'[0]' -expr 'notzero(a)' \
          -prefix zcat_mask_${fMRIrun}.nii.gz
  done

fi



# (8) RUN TEDANA.PY TO DENOISE RUNS AND CALCULATE OPTIMALLY COMBINED TIME SERIES
# ===========================
# CREATES A SWARM CALL THAT RUNS TEDANA.PY FOLLOWED BY Ben Gutierrez' MEICA_REPORT.PY FOR EACH RUN

# Calling Ben's version of tedana.py
# I started using Canopy Python for this step because Prantik liked it. Other versions should work too.
# That said, meica_report.py benefits from the mpld3 library. I've installed that library in my version of
# python used here, but it's not in any of the biowulf default python modules



if [ ${TedanaProc} -eq 1 ]; then
 if [ -f tedana_swarm.txt ]; then rm tedana_swarm.txt; fi
 touch tedana_swarm.txt
 for fMRIrun in ${MEruns[@]}; do
   cd ${rootdir}
   echo "VIRTUAL_ENV_DISABLE_PROMPT=1 source /data/handwerkerd/Python/CanopyEnvironment/User/bin/activate; OMP_NUM_THREADS=4; cd ${rootdir}; python /data/NIMH_SFIM/CommonScripts/me-ica_experimental/meica.libs/tedana.py -e 15.4,29.7,44.0  -d zcat_ffd_${fMRIrun}.nii.gz --sourceTEs=-1 --kdaw=10 --rdaw=1 --initcost=tanh --finalcost=tanh --conv=2.5e-5 --label=${fMRIrun}; 3dcalc -a  ${AnatomyFile} -prefix ${SBJ}_Anat_bc_ns.nii.gz -expr 'a' -overwrite; python ../../../Scripts/meica_report/meica_report.py -setname . -anat ${SBJ}_Anat_bc_ns.nii.gz -TED TED.${fMRIrun} -sag -ax -overwrite -title ${fMRIrun} -label Report.${fMRIrun} -motion ${fMRIrun}_e2_Motion.1D" >> tedana_swarm.txt # CHANGED echo times
 done

 swarm -g 8 -t 4 -q nimh -f tedana_swarm.txt

 # I've combined tedana.py and meica_report into one swarm, but if meica_report is improved, it can be rerun with the currently commented out code
 # if [ -f report_swarm.txt ]; then rm report_swarm.txt; fi
 # touch report_swarm.txt
 # for fMRIrun in ${MEruns[@]}; do
 #  cd ${rootdir}
 #    echo "VIRTUAL_ENV_DISABLE_PROMPT=1 source /data/handwerkerd/Python/CanopyEnvironment/User/bin/activate; cd ${rootdir}; python ../../../Scripts/meica-figure/meica_report.py -setname . -anat ${SBJ}_MeanAnat.bc.ns.nii.gz -TED TED.${fMRIrun} -sag -ax -overwrite -title ${fMRIrun} -label Report.${fMRIrun} -motion ${fMRIrun}_e2_Motion.1D" >> report_swarm.txt
 # done
 # swarm -g 2 -q nimh -f report_swarm.txt

 # Create the combined report of tedana.py across all runs within this subject
VIRTUAL_ENV_DISABLE_PROMPT=1 source /data/handwerkerd/Python/CanopyEnvironment/User/bin/activate
 python ../../../Scripts/Meta_Report.py  -pattern_1 "meica.Report.${SBJ}*/meica_report.txt" -label meica.${SBJ}.Total -var_component # TODO: GET ACCESS AND RUN THIS!

fi



# (9) COMPUTE DEMEANED MOTION AND MOTION FIRST DERIVATIVES
# MIGHT BE USEFUL PARAMETERS TO REGRESS OUT IN ANALYSES
# ==================================
if [ ${MotDer} -eq 1 ]; then
 echo "#############################################################"
 echo "################    RUNNING MOT DERIV STEP ##################"
 echo "#############################################################"
 for fMRIrun in ${RegistrationFMRIruns[@]}; do
   cd ${rootdir}
   
   if [ -f ${fMRIrun}_Motion.demean.1D     ]; then rm ${fMRIrun}_Motion.demean.1D; fi
   if [ -f ${fMRIrun}_Motion.demean.der.1D ]; then rm ${fMRIrun}_Motion.demean.der.1D; fi
   1d_tool.py -infile ${fMRIrun}_Motion.1D -demean -derivative -write ${fMRIrun}_Motion.demean.der.1D
   1d_tool.py -infile ${fMRIrun}_Motion.1D -demean -write             ${fMRIrun}_Motion.demean.1D
 done
fi


# (10) COMPUTE MASK BASED ON ALL AVAILABLE RUNS
# ============================================
# This mask can be used to make sure only voxels with data in all runs
#   are used
if [ ${EPImasks} -eq 1 ]; then
 echo "#############################################################"
 echo "################    RUNNING EPI MASKS STEP ##################"
 echo "#############################################################"
 cd $rootdir

 MaskList=`ls ${rootdir}/p04.*align.mask+orig.HEAD` # CHANGED to orig space

 3dTcat -overwrite -prefix ${SBJ}_AllTedanaMasks ${MaskList}
 3dTstat -overwrite -mean -prefix ${SBJ}_MaskPercentRunsIncluded ${SBJ}_AllTedanaMasks+orig
 3dcalc -overwrite -a ${SBJ}_MaskPercentRunsIncluded+orig -prefix ${SBJ}_MaskAllTaskRuns+orig -expr "ispositive(a-0.9999)" # CHANGED to orig space

fi



# (11) CONVERT TEDANA OUTPUT BACK TO TLRC AND COPY PREPROCESSED DATA TO D03_Analysis
# Also 3drefits the files to make sure they're correctly labeled as +tlrc in MNI space
if [ ${D03Create} -eq 1 ]; then
 cd $rootdir
 mkdir ../D03_Analysis
 for fMRIrun in ${MEruns[@]}; do
  # CHANGED: now all runs are task runs.
  echo Task Run $fMRIrun
  3dTstat -overwrite -mean -prefix p04.${fMRIrun}_e2.meanalign p04.${fMRIrun}_e2.align+orig
  3dcalc -overwrite -a p04.${fMRIrun}_e2.align+orig -b p04.${fMRIrun}_e2.meanalign+orig \
         -prefix ../D03_Analysis/Echo2.${fMRIrun}.in -expr '100*a/b' -float

  3dTstat -overwrite -mean -prefix ./TED.${fMRIrun}/dn_ts_OC_mean.nii ./TED.${fMRIrun}/dn_ts_OC.nii
  3dcalc -overwrite -a ./TED.${fMRIrun}/dn_ts_OC.nii -b ./TED.${fMRIrun}/dn_ts_OC_mean.nii \
          -prefix ../D03_Analysis/Denoised.${fMRIrun}.in+orig -expr '100*a/b' -float
  # 3drefit -view 'tlrc' -space MNI  ../D03_Analysis/Denoised.${fMRIrun}.in+orig

  3dTstat -overwrite -mean -prefix ./TED.${fMRIrun}/ts_OC_mean.nii ./TED.${fMRIrun}/ts_OC.nii
  3dcalc -overwrite -a ./TED.${fMRIrun}/ts_OC.nii -b ./TED.${fMRIrun}/ts_OC_mean.nii \
          -prefix ../D03_Analysis/OptComb.${fMRIrun}.in+orig -expr '100*a/b' -float
  # 3drefit -view 'tlrc' -space MNI  ../D03_Analysis/OptComb.${fMRIrun}.in+orig
	
 done

  3dcopy -overwrite ${SBJ}_MaskAllTaskRuns+orig ../D03_Analysis/${SBJ}_MaskAllTaskRun
  3dcopy -overwrite ${AnatomyFile} ../D03_Analysis/${AnatomyFile} # assumed bs.ns was a typo
  3dcopy -overwrite ${SBJ}_REF.align+orig ../D03_Analysis/${SBJ}_REF.align+orig
  
  # THIS COMMAND OUTPUTS A BUNCH OF 1's and 0's to the screen
  # 1's mean that volumes have the same dimensions, orientations, etc
  # The output should be all 1's except for ${SBJ}_Anat_bc_ns+orig
  # which should have a different "dim" and "delt" (i.e. different voxel sizes)

  # NOTE NOTE NOTE: LOOK AT THE RESULT OF THIS COMMAND
  3dinfo -header_name -header_line -same_all_grid ../D03_Analysis/*.HEAD

  cp *Motion.demean.1D *Motion.demean.der.1D *Censor.1D *CensorTR.txt *MaxMot.rel.1D ../D03_Analysis/
fi

