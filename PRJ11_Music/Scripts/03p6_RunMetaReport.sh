#!/bin/bash
# 03p6_RunMetaReport.sh
#
# USAGE:
#   bash 03p6_RunMetaReport.sh $subj $outFolder
# 
# INPUTS:
# 	- subj is a string indicating the subject ID (default: SBJ05)
#   - outFolder is a string indicating the name of the folder where output should be placed
#
# OUTPUTS:
#	- meica.<subj>.Total is a directory containing info summarizing cross-run MEICA results.
#
# Created 9/19/16 by DJ based on 04_RunRegressionOnMeicaResults.sh.

# ======== SET UP ========
# Parse inputs and specify defaults
argv=("$@")
if [ ${#argv} > 0 ]; then
    subj=${argv[0]}
else
    subj=SBJ05
fi
if [ ${#argv} > 1 ]; then
    outFolder=${argv[2]}
else
    outFolder=AfniProc_MultiEcho
fi

# Get project and output directory and run list
source ./00_CommonVariables.sh # Get PRJDIR
output_dir="${PRJDIR}/Results/${subj}/${outFolder}"

# Load Python Environment
module load Anaconda
source activate python27
module load matlab
# Create the combined report of tedana.py across all runs within this subject
cd ${output_dir}
python ${PRJDIR}/Scripts/Meica_Report/Meta_Report.py  -pattern_1 "meica.Report.${subj}*/meica_report.txt" -label meica.${subj}.Total -var_component 