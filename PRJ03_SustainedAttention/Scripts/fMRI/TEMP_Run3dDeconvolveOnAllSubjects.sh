#!/bin/bash
###################################################
# TEMP_Run3dDeconvolveOnAllSubjects.sh
#
# Created 9/6/16 by DJ.
###################################################


# Get project directory and list of subjects
source 00_CommonVariables.sh
SBJList=("${okSubjects[@]}") # (SBJ09 SBJ12) #
echo ${PRJDIR}
# cd ${PRJDIR}/Results
# SBJList=( `ls -d SBJ30` )
nRuns=0
echoTimes="14.6,26.8,39.0"

cd ${PRJDIR}/Scripts/fMRI

for SBJ in ${SBJList[@]}; do
    echo "=== ${SBJ} ==="
    # Get results folder
    AfniProc=( `ls -d ${PRJDIR}/Results/${SBJ}/AfniProc_MultiEcho*` )
    outFolder=$( basename $AfniProc )
    
cat <<EOF > 05_RegressionBatchCommand.$SBJ
#!/bin/bash
./05_RunRegressionOnMeicaResults.tcsh $SBJ $nRuns "$echoTimes" $outFolder 2>&1 | tee output.05_RunRegressionOnMeicaResults.$SBJ.$outFolder
bash 05p5_ScaleErrts.sh $SBJ $outFolder 2>&1 | tee output.05p5_ScaleErrts.$SBJ.$outFolder
bash 06_WarpCraddockAtlasToEpiSpace.sh $SBJ $outFolder 2>&1 | tee output.06_WarpCraddockAtlasToEpiSpace.$SBJ.$outFolder
EOF
# print it
cat 05_RegressionBatchCommand.$SBJ
# submit it
jobid=$(sbatch --partition=nimh 05_RegressionBatchCommand.$SBJ)
echo "--> Job $jobid"

done
