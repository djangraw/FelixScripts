#!/bin/bash
# Biowulf Wrapper for 03p1_CTask_ExtractTSviaSVD_RandParc.sh
#
# Created 2/22/16 by DJ.

# Get subjects
subjNums=(`count -digits 2 6 27`)

# For each subject, send a batch script to a biowulf node
for subjNum in ${subjNums[@]}
do
    # set up
    SBJ=SBJ$subjNum

    jobid=$(sbatch --partition=nimh --output=slurm-${SBJ}_SVD-RandParc.out 03p1_CTask_ExtractTSviaSVD_RandParc.sh ${SBJ})
    echo Subject ${SBJ}: Jobid = ${jobid}
done