#!/bin/bash

# @optiSS.sh
#
# bash \@optiSS.sh <input> <output>
#
# Posted 8/22/16 by PM to from https://afni.nimh.nih.gov/afni/community/board/read.php?1,152401,152403#msg-152403
# Downloaded 4/20/17 by DJ.
#
# based off procedures in:
# Lutkenhoff, E. S., Rosenberg, M., Chiang, J., Zhang, K., Pickard, J. D., Owen, A. D., & Monti, M. M. (2014).  Optimized Brain Extraction for Pathological Brains (optiBET).  PLOSone 9(12): e115551.  DOI:10.1371/journal.pone. 0115551.

# ---------------------------- OUTLINE ------------------------------
# 1. SkullStrip with 3dSkullStrip
# 2. Warp to MNI space with @auto_tlrc and/or 3dQwarp
# 3. Back-project brain only-mask from +tlrc to +orig
# 4. Mask out brain tissue with back-projected brain-only mask
# -------------------------------------------------------------------

if [ $# -lt 2 ]; then
	echo "@optiSS.sh"
	echo "USAGE: bash \@optiSS.sh <input> <output> <options>"
	echo "<options> not currently implemented. Sorry!"
	exit;
fi

if [ -e $2 ]; then
	echo "Final file $2 already exists.  I cannot overwrite it."
	exit;
fi

afnidirtemp=`which 3dSkullStrip`
afnidir=`echo $afnidirtemp | awk -F "3dSkullStrip" '{print $1}'`

# ---------------------------- STEP 1: Extraction ------------------------------
echo "Step 1: Skull Strip & Unifize"
3dSkullStrip -prefix tmp.s0 -input $1 -orig_vol
3dUnifize -prefix tmp.s1 -input tmp.s0+orig -GM

# ---------------------------- STEP 2: Warp to MNI ------------------------------
echo "Step 2: Affine warp to Template"
@auto_tlrc -base MNI152_T1_2009c+tlrc.HEAD -input tmp.s1+orig -no_ss

# ----------------------- STEP 3: Nonlinear Warp to MNI -------------------------
echo "Step 3: Nonlinear Warp to Template"
3dQwarp -base ${afnidir}/MNI152_T1_2009c+tlrc.HEAD -source tmp.s1+tlrc -prefix tmp.s3 \
-pblur -maxlev 3

# ----------------------- STEP 4: Nonlinear Warp to MNI -------------------------
echo "Step 4: Create Mask of Template"
3dAutomask -prefix tmp.s4.mask ${afnidir}/MNI152_T1_2009c+tlrc.HEAD

# ----------------------- STEP 5: Nonlinear Warp to MNI -------------------------
echo "Step 5: Invert warp and put template in subject space"
3dNwarpApply \
-prefix tmp.s5.TT_in_subject \
-source tmp.s4.mask+tlrc \
-nwarp 'tmp.s3_WARP+tlrc.HEAD tmp.s1.Xaff12.1D' \
-iwarp \
-master tmp.s1+orig \
-interp NN

# ------------------ STEP 6: Mask original image by warp ------------------------
echo "Step 6: AND the maps of template and original image"
3dcalc -a 'tmp.s0+orig.HEAD' -b 'tmp.s5.TT_in_subject+orig' -expr 'a*b' -prefix $2

# ------------------ STEP 7: Cleanup ------------------------
echo "Step 7: Delete temporary files"
rm tmp.*
