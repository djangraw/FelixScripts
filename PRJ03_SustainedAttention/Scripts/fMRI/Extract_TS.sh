#!/bin/bash
###################################################
# Extract_TS.sh
#
# Runs the program TsExtractByROI.py for all subjects in a list
# (edit this script to declare the list)
#
# USAGE: bash Extract_TS.sh $extractionScript
#        bash Extract_TS.sh CustomROIs $atlasFile
#
# INPUTS:
# -$extractionScript is the name of the script to use to extract the timecourses
# -$atlasFile is the name of the atlas you'd like to extract the data from. 
#   the errts EPI file and the full_mask mask will be used, and the $atlasFile 
#   filename with _SBJXX_ at the end will be the output.
#
# HISTORY:
# -Created 5/13/16 by BG.
# -Updated 5/16/16 by DJ - comments & header
# -Updated 5/17/16 by DJ - added warp
# -Updated 5/23/16 by DJ - switched TsExtractByROIs.py option to use _withSegTc suffix for input & output
# -Updated 8/25/16 by DJ - added CustomRois option
# -Updated 9/30/16 by DJ - removed -Warp options (we're already in MNI space now)
#
# DATE LAST MODIFICATION:
# * 08/25/2016
#
###################################################
#module load Anaconda
#source activate meica

# Get project directory and list of subjects
source 00_CommonVariables.sh
SBJList=("${okSubjects[@]}")
echo ${PRJDIR}
# cd ${PRJDIR}/Results
# SBJList=( `ls -d SBJ30` )
# SBJList=(SBJ09 SBJ10 SBJ11 SBJ13 SBJ14 SBJ15 SBJ16 SBJ17 SBJ18 SBJ19)

cd ${PRJDIR}/Scripts/fMRI
if [ $1 == "TsExtractByROIs.py" ]; then
    for SBJ in ${SBJList[@]}; do
        echo ${SBJ}
        # Get results folder
        AfniProc=( `ls -d ${PRJDIR}/Results/${SBJ}/AfniProc_MultiEcho*` )
        # Declare filenames
        maskFile=${AfniProc}/full_mask.${SBJ}+tlrc.HEAD
        atlasFile=${PRJDIR}/Results/Shen_2013_atlas/shen_1mm_268_parcellation+tlrc.HEAD # it's in MNI space
        # epiFile=${AfniProc}/errts.${SBJ}.tproject+tlrc.HEAD # STANDARD VERSION WITH MOTION AND BANDPASS TIMECOURSES REGRESSED OUT
        # prefix=${AfniProc}/shen268_${SBJ}_
        epiFile=${AfniProc}/errts_withSegTc.${SBJ}.tproject+tlrc.HEAD # (ROSENBERG, 2015) VERSION WITH SEGMENTATION TIMECOURSES (WM, CSF, GS) ALSO REGRESSED OUT
        prefix=${AfniProc}/shen268_withSegTc_${SBJ}_
        
        # Run timeseries extraction script
        #echo "TsExtractByROIs.py -Mask $maskFile -Atlas $atlasFile -EPI $epiFile -prefix $prefix"
        # python fMRI/TsExtractByROIs.py -Mask $maskFile -Atlas $atlasFile -EPI $epiFile -prefix $prefix
        python TsExtractByROIs.py -Mask $maskFile -Atlas $atlasFile -EPI $epiFile -prefix $prefix

    done
fi

if [ $1 == "TsExtractWmCsfGs.py" ]; then
    for SBJ in ${SBJList[@]}; do
        echo ${SBJ}
        # Get results folder
        AfniProc=( `ls -d ${PRJDIR}/Results/${SBJ}/AfniProc_MultiEcho*` )
        # Declare filenames
        maskFile=${AfniProc}/full_mask.${SBJ}+tlrc.HEAD
        atlasFile=${AfniProc}/Segsy/Classes+tlrc.BRIK # it's in MNI space
        epiFile=${AfniProc}/all_runs.${SBJ}+tlrc.BRIK
        # Run timeseries extraction script
        python TsExtractWmCsfGs.py -Mask $maskFile -Atlas $atlasFile -EPI $epiFile -prefix $AfniProc
        #echo $maskFile
        #echo $atlasFile
        #echo $epiFile
    done
fi


if [ $1 == "CustomROIs" ]; then
    atlasFile=$2
    for SBJ in ${SBJList[@]}; do
        echo ${SBJ}
        # Get results folder
        AfniProc=( `ls -d ${PRJDIR}/Results/${SBJ}/AfniProc_MultiEcho*` )
        # Declare filenames
        maskFile=${AfniProc}/full_mask.${SBJ}+tlrc.HEAD
        # extract atlas prefix filename (between / and +tlrc)
        atlasBase=$(basename $atlasFile)
        atlasPrefix=${atlasBase%+*}
        
        # epiFile=${AfniProc}/errts.${SBJ}.tproject+tlrc.HEAD # STANDARD VERSION WITH MOTION AND BANDPASS TIMECOURSES REGRESSED OUT
        # prefix=${AfniProc}/${atlasPrefix}_${SBJ}_

        # epiFile=${AfniProc}/all_runs.${SBJ}+tlrc.BRIK # EARLIER VERSION AFTER MEICA BUT BEFORE 3DDECONVOLVE
        # prefix=${AfniProc}/${atlasPrefix}-allruns_${SBJ}_
            
        epiFile=${AfniProc}/pb06.${SBJ}.scaled+tlrc.HEAD # VERSION WITH MOTION AND POLORT TIMECOURSES REGRESSED OUT, SCALED
        prefix=${AfniProc}/${atlasPrefix}-scaled_${SBJ}_

        # Run timeseries extraction script
        # echo "python TsExtractByROIs.py -Mask $maskFile -Atlas $atlasFile -EPI $epiFile -prefix $prefix -Warp"
        # python TsExtractByROIs.py -Mask $maskFile -Atlas $atlasFile -EPI $epiFile -prefix $prefix -Warp
cat <<EOF > 06_ExtractTsBatchCommand.$SBJ
#!/bin/bash
python TsExtractByROIs.py -Mask $maskFile -Atlas $atlasFile -EPI $epiFile -prefix $prefix
EOF
# print it
cat 06_ExtractTsBatchCommand.$SBJ
# submit it
jobid=$(sbatch --partition=nimh,norm 06_ExtractTsBatchCommand.$SBJ)
echo "--> Job $jobid"

        

    done
fi
