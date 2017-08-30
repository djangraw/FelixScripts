#!/bin/bash

# Run inter-subject connectivity analysis on 100-runs data.
# RunIscOn100RunsVideo_pairwise.sh
#
# SAMPLE USAGE:
# bash RunIscOn100RunsVideo_pairwise.sh subject outstarter mask file1 file2 ...
#
# INPUTS:
# 1. string indicating subject # (e.g., SBJ01)
# 2. string to be used as prefix of output file.
# 3. mask of voxels to include (.BRIK)
# 4. list of filenames (array of .BRIK files) e.g., files=( $(ls *_R*.BRIK) ); ${files[@]:0:y}
# 
# OUTPUTS:
# saves ISC_file<x>of<y>+orig and ISC_ttest<y>files+orig to outdir (defined in script)
# 
# Created 2/9/15 by DJ as RunIsfc.sh.
# Updated 3/23/15 by DJ - converted to RunIsc.sh: switched to 3dTcorrelate, mask in separate step, changed 3dTtest++ options
# Updated 3/26/15 by DJ - converted to RunIscOn100RunsVideo.sh - specified new directories.
# Updated 3/30/15 by DJ - commented out file extensions (for .nii file compatibility), added outstarter input and subbrick selection option (unused).
# Updated 4/2/15 by DJ - converted to RunIscOn100RUnsVideo_pairwise, switched to pairwise comparisons.
# Updated 5/1/15 by DJ - added subject input

# stop if error 
set -e

#parse inputs
subject=$1
shift
outstarter=$1
shift
mask=$1 # mask filename
shift # remove input #1 from buffer
fileList=( "$@" )
nFiles=${#fileList[@]}

# ---declare directory constants
# 100Runs, PERMUTATION VERSION
# datadir="/Users/jangraw# dc/Documents/PRJ02_100Runs/PrcsData/SBJ01/D03_PhaseScrambled/"
# outstarter="ISC_SBJ01-scrambled_"
# 100Runs, STANDARD VERSION
datadir="/data/jangrawdc/PRJ05_100RUNS_3Tmultiecho/PrcsData/$subject/"
#outstarter="ISC_SBJ01_"
outdir="/data/jangrawdc/PRJ05_100RUNS_3Tmultiecho/Results/$subject/ISC/"
cd $datadir

# remove file extensions (good for .BRIK, but not for .nii)
#for (( iFile=0; iFile<$nFiles; iFile++ ))
#do
#    fileList[$iFile]=${fileList[$iFile]%.*} # remove everything after first .
#done

# exclude first 10 and last 10 subbricks to avoid scanner artifacts
# nSubbricks=`3dinfo -nt ${fileList[0]}` # get file size
# iFirst=10 # exclude bricks 0:9
# let iLast=$nSubbricks-11 # exclude (end-10):end 

DATE=`date +%H_%M_%S`
# give output to user
echo === Setting Up...
echo "$nFiles files given as input."
# echo fileList = ${fileList[*]}
echo mask = $mask
# echo "using subbricks $iFirst to $iLast."

# Loop 1: mean across files
echo === Getting ISCs across files...
let iOutFile=0 1 # iOutFile = output file indexb (add 1 to keep from exiting)
for (( iFile=0; iFile<$nFiles; iFile++ ))
do
	for (( iFile2=$iFile+1; iFile2<$nFiles; iFile2++ ))
	do
	    echo ---File $iFile vs. $iFile2/$nFiles: ${fileList[$iFile]} vs. ${fileList[$iFile2]}
	    # get ISCs
	    echo Running ISC...
	    fulliscfile="$outdir"IscNoMask_file"$iFile"vs"$iFile2"of"$nFiles"_"$DATE"+orig # output of 3dTcorrelate
	    3dTcorrelate -prefix $fulliscfile ${fileList[$iFile]} ${fileList[$iFile2]} # -automask to cut out small-value voxels
		# 3dTcorrelate -prefix $fulliscfile ${fileList[$iFile]}[$iFirst..$iLast] ${fileList[$iFile2]}[$iFirst..$iLast]
		# apply mask
	    echo Applying mask...
	    outprefix[$iOutFile]="$outdir"ISC_file"$iFile"vs"$iFile2"of"$nFiles"_"$DATE"+orig # output
	    echo ${outprefix[$iOutFile]}
	    3dcalc -overwrite -a "$fulliscfile" -b $mask -expr 'a*notzero(b)' -prefix ${outprefix[$iOutFile]}
       	    let iOutFile+=1 1 # advance output file index
	    # clean up
	    echo Deleting Temporary files...
	    rm $fulliscfile*
	done
done

# take mean across files
#echo === Getting mean across ISFC results...
#3dMean -prefix "$outdir"ISC_Mean"$nFiles"files+orig ${outprefix[*]}

# Run t-test against 0
echo === Getting t-test results across ISC results...
3dttest++ -overwrite -mask $mask -toz -prefix "$outdir""$outstarter""$nFiles"files+orig -setA ${outprefix[*]} #-DAFNI_AUTOMATIC_FDR=NO #don't apply FDR correction #>/dev/null # suppress stdout # output z scores instead of t values

# Clean up
echo === Deleting Pairwise Correlation Files...
for tempfile in ${outprefix[*]}
do
    rm ${tempfile}.*
done

echo === DONE! ===