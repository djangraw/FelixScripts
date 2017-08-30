#!/bin/bash
# RunMetaReportForAllSubjects.sh
#
# Runs Meta_Report.py for all subjects.
#
#
# Created 7/6/16 by DJ based on 02to05_ProcessEpiData.sh.

# Load Python Environment
module load Anaconda
source activate python27

# Get variables
source /data/jangrawdc/PRJ03_SustainedAttention/Scripts/fMRI/00_CommonVariables.sh # Get PRJDIR

# Get subject-specific variables
for i in `seq 1 ${#subjects[@]}`
do
    # extract this subject's variables
    let iSubj=i-1
    subj=${subjects[$iSubj]}
    outFolder=${folders[$iSubj]}
    output_dir="${PRJDIR}/Results/${subj}/${outFolder}"

    # Create the combined report of tedana.py across all runs within this subject
    cd ${output_dir}
    python ${PRJDIR}/Scripts/Meica_Report/Meta_Report.py  -pattern_1 "meica.Report.${subj}*/meica_report.txt" -label meica.${subj}.Total -var_component 

done