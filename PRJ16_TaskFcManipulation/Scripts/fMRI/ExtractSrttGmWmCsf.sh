#!/bin/bash
###################################################
# ExtractSrttGmWmCsf.sh
#
# Runs the program TsExtractWmCsfGs.py for all SRTT subjects in a list
#
# USAGE: bash ExtractSrttGmWmCsf.sh ${subjects[@]}
#
# INPUTS:
# -subjects is an array of subject names, e.g., tb0065.
#
# HISTORY:
# -Created 1/29/18 by DJ based on Extract_TS.sh.
#
###################################################
# module load python
# module load afni

# Get project directory and list of subjects
source 00_CommonVariables.sh
subjects=( "$@" )

cd ${PRJDIR}/Scripts/fMRI
echo "" > TEMP_SrttGmWmCsf_swarm
for SBJ in ${subjects[@]}; do
    echo ${SBJ}
    # Get results folder
    AfniProc=${PRJDIR}/RawData/${SBJ}/${SBJ}.srtt${folderSuffix}
    # Declare filenames
    maskFile=${AfniProc}/full_mask.${SBJ}+tlrc.HEAD
    atlasFile=${AfniProc}/Segsy/Classes+tlrc.HEAD # it's in MNI space
    epiFile=${AfniProc}/all_runs.${SBJ}+tlrc.HEAD
    # If atlasFile doesn't exist, run 3dSeg
    if [ ! -f $atlasFile ]; then
        echo "Running 3dSeg for subject ${SBJ}..."
        # cd $AfniProc
        # 3dSeg -anat anat_final.$SBJ+tlrc -mask AUTO -classes 'CSF ; GM ; WM'
        # cd ${PRJDIR}/Scripts/fMRI
        # python /data/jangrawdc/PRJ03_SustainedAttention/Scripts/fMRI/TsExtractGmWmCsfGs.py -Mask $maskFile -Atlas $atlasFile -EPI $epiFile -prefix $AfniProc
        echo "cd $AfniProc; 3dSeg -anat anat_final.$SBJ+tlrc -mask AUTO -classes 'CSF ; GM ; WM'; cd ${PRJDIR}/Scripts/fMRI; python /data/jangrawdc/PRJ03_SustainedAttention/Scripts/fMRI/TsExtractGmWmCsfGs.py -Mask $maskFile -Atlas $atlasFile -EPI $epiFile -prefix $AfniProc" >> TEMP_SrttGmWmCsf_swarm
        # echo "cd $AfniProc; 3dSeg -anat anat_final.$SBJ+tlrc -mask AUTO -classes 'CSF ; GM ; WM'; cd ${PRJDIR}/Scripts/fMRI; python /data/jangrawdc/PRJ03_SustainedAttention/Scripts/fMRI/TsExtractGmWmCsfGs.py -Mask $maskFile -Atlas $atlasFile -EPI $epiFile -prefix $AfniProc; bash RemoveSrttNuisanceRegressors.sh $SBJ true" >> TEMP_SrttGmWmCsf_swarm
    else
      # Run timeseries extraction script
      # python /data/jangrawdc/PRJ03_SustainedAttention/Scripts/fMRI/TsExtractGmWmCsfGs.py -Mask $maskFile -Atlas $atlasFile -EPI $epiFile -prefix $AfniProc
      # echo "bash RemoveSrttNuisanceRegressors.sh $SBJ true" >> TEMP_SrttGmWmCsf_swarm
      echo "python /data/jangrawdc/PRJ03_SustainedAttention/Scripts/fMRI/TsExtractGmWmCsfGs.py -Mask $maskFile -Atlas $atlasFile -EPI $epiFile -prefix $AfniProc" >> TEMP_SrttGmWmCsf_swarm
    fi
done

# Run resulting swarm command
swarm -g 3 -f TEMP_SrttGmWmCsf_swarm --partition=nimh,norm --module=python,afni --time=0:20:00 --job-name=WmCsf
