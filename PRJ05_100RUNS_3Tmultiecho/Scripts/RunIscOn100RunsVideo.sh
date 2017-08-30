#!/bin/bash

# Run inter-subject connectivity analysis on 100-runs data.
# RunIscOn100RunsVideo.sh
#
# INPUTS:
# 1. string to be used as prefix of output file.
# 2. mask of voxels to include (.BRIK)
# 3. list of filenames (array of .BRIK files) e.g., files=( $(ls *_R*.BRIK) ); ${files[@]:0:y}
# 
# OUTPUTS:
# saves ISC_file<x>of<y>+orig and ISC_ttest<y>files+orig to outdir (defined in script)
# 
# Created 2/9/15 by DJ as RunIsfc.sh.
# Updated 3/23/15 by DJ - converted to RunIsc.sh: switched to 3dTcorrelate, mask in separate step, changed 3dTtest++ options
# Updated 3/26/15 by DJ - converted to RunIscOn100RunsVideo.sh - specified new directories.
# Updated 3/30/15 by DJ - commented out file extensions (for .nii file compatibility), added outstarter input and subbrick selection option (unused).

# stop if error
set -e

# ---declare directory constants
# 100Runs, PERMUTATION VERSION
# datadir="/Users/jangraw# dc/Documents/PRJ02_100Runs/PrcsData/SBJ01/D03_PhaseScrambled/"
# outstarter="ISC_SBJ01-scrambled_"
# 100Runs, STANDARD VERSION
datadir="/data/jangrawdc/PRJ05_100RUNS_3Tmultiecho/PrcsData/SBJ01/"
#outstarter="ISC_SBJ01_"
outdir="/data/jangrawdc/PRJ05_100RUNS_3Tmultiecho/Results/SBJ01/ISC/"

cd $datadir

#parse inputs
outstarter=$1
shift
mask=$1 # mask filename
shift # remove input #1 from buffer
fileList=( "$@" )
nFiles=${#fileList[@]}

# remove file extensions (good for .BRIK, but not for .nii)
#for (( iFile=0; iFile<$nFiles; iFile++ ))
#do
#    fileList[$iFile]=${fileList[$iFile]%.*} # remove everything after first .
#done

# exclude first 10 and last 10 subbricks to avoid scanner artifacts
# nSubbricks=`3dinfo -nt ${fileList[0]}` # get file size
# iFirst=10 # exclude bricks 0:9
# let iLast=$nSubbricks-11 # exclude (end-10):end 

# give output to user
echo === Setting Up...
echo "$nFiles files given as input."
# echo fileList = ${fileList[*]}
echo mask = $mask
# echo "using subbricks $iFirst to $iLast."

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
    singlefile=${fileList[$iFile]} # correlate with
    fulliscfile="$outdir"IscNoMask_file"$iFile"of"$nFiles"+orig # output of 3dTcorrelate
    3dTcorrelate -prefix $fulliscfile $meanfile $singlefile # -automask to cut out small-value voxels
    # 3dTcorrelate -prefix $fulliscfile $meanfile[$iFirst..$iLast] $singlefile[$iFirst..$iLast]
    # apply mask
    echo Applying mask...
    outprefix[$iFile]="$outdir"ISC_file"$iFile"of"$nFiles"+orig # output
    echo ${outprefix[$iFile]}
    3dcalc -overwrite -a "$fulliscfile" -b $mask -expr 'a*notzero(b)' -prefix ${outprefix[$iFile]}
    # clean up
    echo Deleting Mean files...
    rm $meanfile*
	rm $fulliscfile*
done

# take mean across files
#echo === Getting mean across ISFC results...
#3dMean -prefix "$outdir"ISC_Mean"$nFiles"files+orig ${outprefix[*]}

# Run t-test against 0
echo === Getting t-test results across ISC results...
3dttest++ -overwrite -mask $mask -toz -prefix "$outdir""$outstarter""$nFiles"files+orig -setA ${outprefix[*]} #-DAFNI_AUTOMATIC_FDR=NO #don't apply FDR correction #>/dev/null # suppress stdout # output z scores instead of t values

echo === DONE! ===