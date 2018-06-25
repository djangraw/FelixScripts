#!/bin/bash
######
# OrigToMniWhereami.sh
#
# Transform a point from original space into MNI space, then use whereami to find corresponding areas.
#
# USAGE:
# >> OrigToMniWhereami x y z transform
#
# INPUTS:
# -(x, y, z) is the position of the point in a subject's native (+orig) space
# -transform is the name of a .1D file that can be used to transform from +orig to +tlrc space.
#
# Created 4/21/15 by DJ.
######

# stop if error 
set -e

# check nInputs
if [[ $# -ne 4 ]]; then
	echo "USAGE: OrigToMniWhereami x y z mniBrain"
fi

x=$1
y=$2
z=$3
mniBrain=$4

# write position to tmp file
echo "$x $y $z" >> tmp+orig.1D

# transform point into +tlrc space
Vecwarp -apar $mniBrain -input tmp.1D >> tmp+mni.1D

# use atlas
whereami -input tmp+mni.1D -space MNI -atlas CA_ML_18_MNIA

# clean up
rm tmp+orig.1D tmp+mni.1D