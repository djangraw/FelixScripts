#!/bin/bash
set -e

# Run inter-subject connectivity analysis on Haskins Story data.
# RunStoryIsc.sh
#
# INPUTS:
# 1. mask of voxels to include (.BRIK)
# 2. list of filenames (array of .BRIK files) e.g., files=( $(ls *_R*.BRIK) ); ${files[@]:0:y}
#s
# OUTPUTS:
# saves ISC_file<x>of<y>+orig and ISC_ttest<y>files+orig to outDir (defined in script)
#
# Created 5/17/18 by DJ based on RunIsc.sh (100-runs version).
# Updated 5/22/18 by DJ - storyISC_d2 directory

# ---declare directory constants
source /data/jangrawdc/PRJ18_HaskinsStory/Scripts/00_CommonVariables.sh
outstarter="storyISC_"
outDir=${dataDir}/IscResults/

cd $dataDir

# get mask
mask=${dataDir}/${okSubj[0]}/${okSubj[0]}.storyISC_d2/mask_epi_anat.${okSubj[0]}+tlrc # mask filename for subj 1 (should be similar for all subjects)
# get file list
nFiles=${#okSubj[@]}
for (( i=0; i<$nFiles; i++ ))
do
  fileList[$i]="${okSubj[$i]}/${okSubj[$i]}.storyISC_d2/errts.${okSubj[$i]}.tproject+tlrc"
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
    meanfile="$outDir"Mean_file"$iFile"of"$nFiles"+tlrc # output of 3dMean
    3dMean -prefix $meanfile ${fileListOther[*]}
    # get ISCs
    echo Running ISC...
    singlefile=${fileList[$iFile]} # correlate with
    fulliscfile="$outDir"IscNoMask_file"$iFile"of"$nFiles"+tlrc # output of 3dTcorrelate
    3dTcorrelate -automask -prefix $fulliscfile $meanfile $singlefile # automask to cut out small-value voxels
	# apply mask
	echo Applying mask...
	outprefix[$iFile]="$outDir"ISC_file"$iFile"of"$nFiles"+tlrc # output
	echo ${outprefix[$iFile]}
	3dcalc -overwrite -a $fulliscfile -b $mask -expr 'a*notzero(b)' -prefix ${outprefix[$iFile]}
    # clean up
    echo Deleting Mean files...
    rm $meanfile*
	rm $fulliscfile*
done

# take mean across files
#echo === Getting mean across ISFC results...
#3dMean -prefix "$outDir"ISC_Mean"$nFiles"files+tlrc ${outprefix[*]}

# Run t-test against 0
echo === Getting t-test results across ISC results...
3dttest++ -overwrite -mask $mask -toz -prefix "$outDir""$outstarter""$nFiles"files+tlrc -setA ${outprefix[*]} #-DAFNI_AUTOMATIC_FDR=NO #don't apply FDR correction #>/dev/null # suppress stdout # output z scores instead of t values

echo === DONE! ===
