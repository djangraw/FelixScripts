#!/bin/bash
###################################################
# TEMP_RunShenExtractionOnAllSubjects.sh
#
# Created 11/7/16 by DJ.
###################################################


# Get project directory and list of subjects
source 00_CommonVariables.sh
# SBJList=("${subjects[@]}") # (SBJ09 SBJ12) #
SBJList=(${okSubjects[@]})
echo ${PRJDIR}
# cd ${PRJDIR}/Results
# SBJList=( `ls -d SBJ30` )
suffix="" #"_Rose" #"" #"2"

cd ${PRJDIR}/Scripts/fMRI

for SBJ in ${SBJList[@]}; do
    echo "=== ${SBJ} ==="
    # Get results folder
    AfniProc="${PRJDIR}/Results/${SBJ}/AfniProc_MultiEcho_2016-09-22"
    outFolder=$( basename $AfniProc )
    # Declare filenames
    maskFile=${AfniProc}/full_mask.${SBJ}+tlrc.HEAD
    segsyClassFile=${AfniProc}/Segsy/Classes+tlrc.HEAD # it's in MNI space
    epiFile=${AfniProc}/all_runs.${SBJ}+tlrc.HEAD
    
    atlasFile=${PRJDIR}/Results/Shen_2013_atlas/shen_1mm_268_parcellation+tlrc.HEAD # it's in MNI space
    # for _Rose version (or others involving ApplyNormalTemporalFilterToAllSubjects.m)
    # errTsFile=${AfniProc}/errts_withSegTc${suffix}.${SBJ}.tproject_filtered+tlrc.HEAD # (ROSENBERG, 2015) VERSION WITH SEGMENTATION TIMECOURSES (WM, CSF, GM) ALSO REGRESSED OUT
    # for other version
    errTsFile=${AfniProc}/errts_withSegTc${suffix}.${SBJ}.tproject+tlrc.HEAD
    prefix=${AfniProc}/shen268_withSegTc${suffix}_${SBJ}_
    
    if [ -f $epiFile ]; then
    # if [ ! -f ${prefix}ROI_TS.1D ] && [ -f $epiFile ]; then
        rm ${AfniProc}/tmp.*
# cat <<EOF > 05p3_RegressionWithSegBatchCommand.${SBJ}${suffix}
# #!/bin/bash
# module load Anaconda; source activate python27; module load matlab; OMP_NUM_THREADS=4;
# python TsExtractGmWmCsfGs.py -Mask $maskFile -Atlas $segsyClassFile -EPI $epiFile -prefix $AfniProc
# ./05p3_RunRegressionWithSegTimecourses${suffix}.tcsh $SBJ $outFolder 2>&1 | tee output.05p3_RunRegressionWithSegTimecourses${suffix}.$SBJ.$outFolder
# bash ${PRJDIR}/Scripts/fMRI/MatlabFilter/run_ApplyNormalTemporalFilterToAllSubjects.sh /usr/local/matlab-compiler/v91 ${SBJ//[!0-9]/}
# python TsExtractByROIs.py -Mask $maskFile -Atlas $atlasFile -EPI $errTsFile -prefix $prefix
# EOF

cat <<EOF > 05p3_RegressionWithSegBatchCommand.${SBJ}${suffix}
#!/bin/bash
module load Anaconda; source activate python27; module load matlab; OMP_NUM_THREADS=4;
# python TsExtractGmWmCsfGs.py -Mask $maskFile -Atlas $segsyClassFile -EPI $epiFile -prefix $AfniProc
./05p3_RunRegressionWithSegTimecourses${suffix}.tcsh $SBJ $outFolder 2>&1 | tee output.05p3_RunRegressionWithSegTimecourses${suffix}.$SBJ.$outFolder
python TsExtractByROIs.py -Mask $maskFile -Atlas $atlasFile -EPI $errTsFile -prefix $prefix
EOF
        # print it
        cat 05p3_RegressionWithSegBatchCommand.${SBJ}${suffix}
        # submit it
        jobid=$(sbatch --partition=nimh,norm --time=8:00:00 05p3_RegressionWithSegBatchCommand.${SBJ}${suffix})
        echo "--> Job $jobid"
    fi

done
