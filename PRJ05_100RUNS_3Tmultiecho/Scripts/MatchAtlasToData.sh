#!/bin/bash
# MatchAtlasToData.sh
#
# Warp and resample an atlas so that it matches a given 'target' dataset.
#  
# USAGE:
#   bash MatchAtlasToData.sh $atlas $anat $target $outFile
#   bash MatchAtlasToData.sh $atlas $warpMat $target $outFile
# 
# INPUTS:
# 	- atlas is the name of the atlas file
#   - anat is the anatomy file for warping into a template space
#	- target is the 'target' file whose sampling you wish to copy
#   - outFile is the name of the file where output should be placed
#   - warpMat is a .1D file that can be used to warp the atlas into the target's space
#
# OUTPUTS:
#	- files called $outFile.BRIK and $outFile.HEAD will be placed in the current directory.
#
# Created 12/8/15 by DJ.

# ======== SET UP ========
# stop if error
set -e
# Parse inputs and specify defaults
argv=("$@")
if [ ${#argv} > 0 ]; then
    atlas=${argv[0]}
else
    atlas='Craddock+tlrc'
fi
if [ ${#argv} > 1 ]; then
    anat=${argv[1]}
else
    anat='anat+orig'
fi
if [ ${#argv} > 2 ]; then
    target=${argv[2]}
else
    target='target+orig'
fi
if [ ${#argv} > 3 ]; then
    outFile=${argv[3]}
else
    outFile=$atlas_targetres
fi

# ======== RUN ========
# remove extensions
atlasShort="${atlas%+*}"
atlasView="${atlas##*+}"
atlasView="${atlasView%.*}"
anatShort="${anat%+*}"
anatExt="${anat##*.}"
targetShort="${target%+*}"
targetView="${target##*+}"
targetView="${targetView%.*}"

if [ anatExt == '1D' ]; then
	# Input anat was a 1D warping file: warp, then resample
	targetSpace=`3dinfo -space $target`
	# apply warp matrix to atlas
	echo Applying transform...
	warpMat=$anat
	3dWarp -matvec_out2in $warpMat -prefix $atlas.warped $atlas
	# update view
	3drefit -view +$targetView $atlas.warped+tlrc
	# resample
	echo Resampling atlas to match target...
	3dresample -master $target -prefix $outFile -inset $atlas.warped+$targetView -overwrite
else
	# Input anat was a dataset: register, warp, then resample
	# get spaces
	atlasSpace=`3dinfo -space $atlas`
	anatSpace=`3dinfo -space $anat`
	targetSpace=`3dinfo -space $target`
	# check matches
	if [ targetSpace != anatSpace ]; then
		echo "Target and Anat spaces don't match!"
	fi
	if [ atlasSpace != anatSpace ]; then
		echo Registering anat file to $atlasSpace atlas...
		# warp to get transform
		@auto_tlrc -base ${atlasSpace}+tlrc -input $anat #-no_ss
		# invert transform
		echo Inverting transform...
		cat_matvec -MATRIX $anatShort.Xat.1D -I -prefix $anatShort.Xat.rev.1D
		# apply transform
		echo Applying transform...
		3dWarp -matvec_out2in $anatShort.Xat.rev.1D -prefix $atlas.warped+$atlasView $atlas
		3drefit -view +$targetView $atlas.warped+$atlasView
	fi
	# resample
	echo Resampling atlas to match target...
	3dresample -master $target -prefix $outFile -inset $atlas.warped+$targetView -overwrite
	
fi
# clean up
# rm $anatShort.Xat.1D $anatShort.Xat.rev.1D $atlas.warped*