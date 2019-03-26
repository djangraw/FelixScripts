#!/bin/tcsh

# ----------------------------------------------------------------------
# Script: s.nimh_group_level_02_mema_bisided.tcsh
# Run on: openfmri/ds001_R2.0.4
# Date  : May, 2018
#
# Take a group of subjects processed for task-based FMRI, run 3dMEMA
# on their final statistical results.  Clustering is also performed
# here, using 3dClustSim (with the ACF blur estimation).  Some
# individual volumes of t-statistics and effect estimate maps are also
# output.  This provides an example of using the newest clusterizing
# program in AFNI, 3dClusterize (an update version of 3dclust).
#
# Used as an example of proper two-sided testing in:
#
#   A tail of two sides: Artificially doubled false positive rates in
#   neuroimaging due to the sidedness choice with t-tests
#
#   by Chen G, Glen DR, Rajendra JK, Reynolds RC, Cox RW, Taylor PA.
#      Scientific and Statistical Computing Core, NIMH/NIH/DHHS, USA.
#
# ... as applied to an earlier processed dataset from *this* study:
#
#   Some comments and corrections on FMRI processing with AFNI in
#   "Exploring the Impact of Analysis Software on Task fMRI Results"
#
#   by Taylor PA, Chen G, Glen DR, Rajendra JK, Reynolds RC, Cox RW.
#      Scientific and Statistical Computing Core, NIMH/NIH/DHHS, USA.
#
#   NOTE: The processing described in "Some comments..." includes sets
#   of processing commands correcting/improving upon some sets of
#   commands run in an earlier study by a different group (see therein
#   for more details).  However, even the "NIMH" set of commands still
#   includes some non-ideal features, as described there, for the
#   purposes of comparison with the other group's processing stream.
#   Please read the associated text carefully before using/adapting
#   those scripts.
#
# ----------------------------------------------------------------------
#
# To run for a single subject, for example:
#
#   tcsh -ef s.nimh_group_level_02_mema_bisided.tcsh
#
# On a cluster you might want to use scratch disk space for faster
# writing, and a lot of memory and CPUs, depending on the
# data/processing choices.  Syntax might be:
#
#   sbatch                       \
#      --partition=SOME_NAMES    \
#      --cpus-per-task=32        \
#      --mem=64g                 \
#      --gres=lscratch:80        \
#      s.nimh_group_level_02_mema_bisided.tcsh
#
# ----------------------------------------------------------------------

# ================ Set up paths and many params ======================

# specify group stats files
# set statsfolder = "/data/NIMH_Haskins/a182/GROUP_block_tlrc_d2/"
# set statsfile   = "ttest_allSubj_2grp"      # output effect+stats filename
# set statsfolder = "/data/NIMH_Haskins/a182/IscResults_d2/Group/"
# set statsfile   = "3dLME_2Grps_readScoreMedSplit_n42_Automask"      # output effect+stats filename
# set statsfile_space = "tlrc"
# set iMean       = "8"                 # volume label (or index) for stat result
# set iThresh     = "9"
# set cond_name   = "bot-topbot"
# set maskfile    = "MNI_mask_epiRes.nii"

# Cluster parameters
# set csim_folder = "/data/NIMH_Haskins/a182/ClustSimFiles"
# set csim_neigh  = 1         # neighborhood; could be NN=1,2,3
# set csim_NN     = "NN${csim_neigh}"  # other form of neigh
# set csim_sided  = "bisided" # test type; could be 1sided, 2sided or bisided
# set csim_pthr   = 0.01     # voxelwise thr (was higher, 0.01, in orig study)
# set csim_alpha  = 0.05      # nominal FWE
# set csim_pref   = "${statsfile}_${cond_name}_clust_p${csim_pthr}_a${csim_alpha}_${csim_sided}" # prefix for outputting stuff

# ==================== Cluster simulations =======================

# Get the volume threshold value from the ClustSim results, based on
# user's choice of parameters as set above.  The "-verb 0" means that
# just the threshold number of voxels is returned, so we can save that
# as a variable.
echo 1d_tool.py -verb 0                                \
                        -infile ${csim_folder}/ClustSim.grpACF.${csim_NN}_${csim_sided}.1D  \
                        -csim_pthr   $csim_pthr                       \
                        -csim_alpha "$csim_alpha"
set clust_thrvol = `1d_tool.py -verb 0                                \
                        -infile ${csim_folder}/ClustSim.grpACF.${csim_NN}_${csim_sided}.1D  \
                        -csim_pthr   $csim_pthr                       \
                        -csim_alpha "$csim_alpha"`

# Get the statistic value equivalent to the desired voxelwise p-value,
# for thresholding purposes.  Using the same p-value and sidedness
# that were selected in the ClustSim results.  This program also gets
# the number of degrees of freedom (DOF) from the header of the volume
# containing the statistic. The "-quiet" means that only the
# associated statistic value is returned, so we can save it to a
# variable.
#
# Note: actually, you can do this calculation within 3dClusterize
# directly now, specifying the threshold as a p-value.

# move to stats directory
cd $statsfolder

set voxstat_thr = `p2dsetstat -quiet                    \
                    -pval $csim_pthr                    \
                    "-${csim_sided}"                    \
                    -inset "${statsfile}+${statsfile_space}[${iThresh}]"`

echo "++ The final cluster volume threshold is:  $clust_thrvol"
echo "++ The voxelwise stat value threshold is:  $voxstat_thr"

# ================== Make cluster maps =====================

# Run the 'clusterize' program to make maps of the clusters (sorted by
# size) and to output a cluster-masked map of the effect estimate (EE)
# data, in this case %BOLD fluctuation values-- i.e., the stuff we
# should report.
#
# The main inputs are: dataset contain the statistic volume to be
# thresholded, a mask within which to find clusters, and the ClustSim
# parameters+outputs.  A common addition to this list of inputs is to
# specify the location of the EE volume in the input dset, for
# reporting the EE info within any found clusters.
#
# SPECS:
#  3dClusterize \
#      -inset      :input dset to get info from; like both stat and eff data
#      -ithr       :str label of stat vol in inset; or, use vol index: 1
#      -idat       :(opt) str label EE vol in inset; or, use vol index: 0
#      -mask       :same mask input to 3dClustSim (here, whole brain)
#      -bisided    :specify *type* of test; followed by threshold limit info
#      -NN         :what neighborhood definition was used?
#      -clust_nvox :cluster size threshold from 3dClustSim
#      -pref_map   :name for cluster map output vol
#      -pref_dat   :name for cluster-masked EE output vol
#      > ${csim_pref}_report.txt :dump text table of cluster report to file
#

rm -f ${csim_pref}_report.txt ${csim_pref}_EE.nii.gz ${csim_pref}_map.nii.gz

3dClusterize                                   \
    -inset  ${statsfile}+${statsfile_space}                           \
    -ithr   ${iThresh}                    \
    -idat   ${iMean}                     \
    -mask   ${maskfile}                        \
    -${csim_sided} -$voxstat_thr $voxstat_thr  \
    -NN             ${csim_neigh}              \
    -clust_nvox     ${clust_thrvol}            \
    -pref_map       ${csim_pref}_map.nii.gz    \
    -pref_dat       ${csim_pref}_EE.nii.gz     \
    > ${csim_pref}_report.txt

echo "++ Clusterizing complete."

echo "\n++ DONE with group level stats clustering!\n"

time ; exit 0
