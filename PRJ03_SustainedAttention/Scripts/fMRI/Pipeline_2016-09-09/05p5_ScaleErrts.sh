#!/bin/tcsh -xef
# 05p6_ScaleErrts.sh
#
# USAGE:
#   bash 05p5_ScaleErrts.sh $subj $outFolder 2>&1 | tee output.05p5_ScaleErrts.$subj.$outFolder
# 
# INPUTS:
# 	- subj is a string indicating the subject ID (default: SBJ05)
#   - outFolder is a string indicating the name of the folder where output should be placed
#
# OUTPUTS:
#	- pb06 file
#
# Created 9/1/16 by DJ.

# ======== SET UP ========
# exit if error
set -e

# Parse inputs and specify defaults
argv=("$@")
if [ ${#argv} > 0 ]; then
    subj=${argv[0]}
else
    subj=SBJ05
fi
if [ ${#argv} > 1 ]; then
    outFolder=${argv[1]}
else
    outFolder=AfniProc_MultiEcho
fi

# Get project and output directory and run list
source ./00_CommonVariables.sh # Get PRJDIR
output_dir="${PRJDIR}/Results/${subj}/${outFolder}"
cd $output_dir

# ======== SCALE ========
# Get filenames
errTsFile=errts.${subj}.tproject+tlrc
cBucketFile=cbucket.${subj}+tlrc
maskFile=full_mask.${subj}+tlrc
# Scale each file separately
nRuns=$(ls pb05.${subj}.r0* | wc -w) # number of runs
nT=$(3dinfo -nt pb05.${subj}.r01.meica.nii) # time points per run
for iRun in `seq 1 $nRuns`; do
    # Extract data for this run
    iFirst=$(echo "($iRun - 1) * $nT" | bc)
    iLast=$(echo "($iRun * $nT) - 1" | bc)
    # Extract cBucket brick for this run
    iCBucket=$(echo "($iRun - 1)*5" | bc)
    # Scale
    3dcalc -a ${errTsFile}[${iFirst}..${iLast}] -b ${cBucketFile}[${iCBucket}] -c ${maskFile} -expr 'c*a/b *step(b-0.01) * 100' -overwrite -prefix tmp.${subj}.r0${iRun}.scaled
done

# Re-combine across runs
3dTcat -prefix -overwrite pb06.${subj}.scaled tmp.$subj.r*.scaled+tlrc.HEAD

# Remove temporary files
# rm tmp.${subj}.r*.scaled*