#!/bin/bash
# 04_CleanUpAfterMeica
#
# USAGE:
#   bash 04_RunRegressionOnMeicaResults $subj $nRuns $outFolder
# 
# INPUTS:
# 	- subj is a string indicating the subject ID (default: SBJ05)
#	- nRuns is a scalar indicating how many runs are included (e.g., 4)
#   - outFolder is a string indicating the name of the folder where output should be placed
#
# OUTPUTS:
#	- meica.<subj>.Total is a directory containing info summarizing cross-run MEICA results.
#
# Created 11/23/15 by DJ based on 04_RunRegressionOnMeicaResults

# ======== SET UP ========
# Parse inputs and specify defaults
argv=("$@")
if [ ${#argv} > 0 ]; then
    subj=${argv[0]}
else
    subj=SBJ05
fi
if [ ${#argv} > 1 ]; then
    nRuns=${argv[1]}
else
    nRuns=4
fi
if [ ${#argv} > 2 ]; then
    outFolder=${argv[2]}
else
    outFolder=AfniProc_MultiEcho
fi

# Get project and output directory and run list
source ./00_CommonVariables.sh # Get PRJDIR
output_dir="${PRJDIR}/Results/${subj}/${outFolder}"
runs=(`count -digits 2 1 ${nRuns}`)

# Retrieve and relabel denoised time series
for run in ${runs[@]}
do
	# Create symbolic link to denoised time series
	ln -s ${output_dir}/TED.$subj.r${run}/dn_ts_OC.nii ${output_dir}/pb05.$subj.r${run}.meica.nii
	# specify that this is in TT_N27 atlas space
	3drefit -space TT_N27 ${output_dir}/pb05.$subj.r${run}.meica.nii
done
	
# Load Python Environment
module load Anaconda
source activate python27
# Create the combined report of tedana.py across all runs within this subject
cd ${output_dir}
python ${PRJDIR}/Scripts/Meica_Report/Meta_Report.py  -pattern_1 "meica.Report.${subj}*/meica_report.txt" -label meica.${subj}.Total -var_component 