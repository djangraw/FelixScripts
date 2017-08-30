#!/bin/bash

# Run inter-subject functional connectivity analysis on 100-runs data.
# RunIsfc.sh
#
# INPUTS:
# 1. mask of voxels to include (.BRIK)
# 2. list of filenames (array of .BRIK files) e.g. $(ls *_R*.BRIK)
# 
# OUTPUTS:
# saves ISFC_file<x>of<y>+orig.BRIK/HEAD to outdir (defined in script)
# 
# Created 2/9/15 by DJ.

# declare directory constants
datadir="/Users/jangrawdc/Documents/PRJ02_100Runs/PrcsData/SBJ01/D03_PhaseScrambled/"
outdir="/Users/jangrawdc/Documents/PRJ02_100Runs/Results/ISFC/Scrambled/"

cd $datadir

#parse inputs
mask=$1 # mask filename
shift # remove input #1 from buffer
fileList=( "$@" )
nFiles=${#fileList[@]}

# remove file extensions
for (( iFile=0; iFile<$nFiles; iFile++ ))
do
    fileList[$iFile]=${fileList[$iFile]%.*} # remove everything after first .
done

echo "$nFiles files given as input."
# echo fileList = ${fileList[*]}
echo mask = $mask

# Loop 1: mean across files
echo === Getting ISCs across files...
for (( iFile=0; iFile<$nFiles; iFile++ ))
do
    echo File $iFile/$nFiles: ${fileList[$iFile]}
    # average other files
    echo Calculating mean across files...
    fileListOther=("${fileList[@]}")
    unset fileListOther[$iFile] # remove the key file
    meanfile="$outdir"Mean_file"$iFile"of"$nFiles"+orig # output of 3dMean
    3dMean -prefix $meanfile ${fileListOther[*]}
    # get ISCs
    echo Running ISC...
    seedfile=${fileList[$iFile]} # correlate with
    outprefix[$iFile]="$outdir"ISFC_file"$iFile"of"$nFiles"+orig # output
    3dTcorrMap -input $meanfile -seed $seedfile -mask $mask -CorrMap ${outprefix[$iFile]} -CorrMask
    # clean up
    echo Deleting Mean files...
    rm $meanfile*
done

# take mean across files
#echo === Getting mean across ISFC results...
#3dMean -prefix "$outdir"ISFC_Mean"$nFiles"files+orig ${outprefix[*]}

# Set AFNI environment variable to 0 as suggested in help file and
# Run t-test against 0
echo === Getting t-test results across ISFC results...
3dttest++ -brickwise -mask $mask -toz -prefix "$outdir"ISFC_ttest"$nFiles"files+orig -setA ${outprefix[*]} -DAFNI_AUTOMATIC_FDR=NO #>/dev/null # suppress stdout # output z scores instead of t values

echo === DONE! ===