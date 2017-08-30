#!/bin/bash
# RunMeicaReportOnAllSubjects.sh
#
# USAGE:
#   bash RunPipelineOnAllSubjects.sh
#
# Created 9/12/16 by DJ.

source ./00_CommonVariables.sh # Get PRJDIR

echoTimes="14.6,26.8,39.0"
outFolder=AfniProc_MultiEcho_2016-09-22

# for subj in ${subjects[@]}; do
# for subj in ${okSubjects[@]}; do SBJ13 SBJ14 SBJ15 SBJ16 SBJ17 SBJ18 SBJ19
for subj in SBJ11 SBJ13 SBJ14 SBJ15 SBJ16 SBJ17 SBJ18 SBJ19; do
    # Get nRuns
    dataFolder=${PRJDIR}/PrcsData/$subj/D00_OriginalData
    nRuns=`ls ${dataFolder}/${subj}_Run*_e1+orig.HEAD | wc -w`

    # === 3. RUN MEICA-REPORT SWARM JOB
    # initialize Tedana swarm file
    if [ -f 03p5_MeicaReportSwarmCommand.$subj ]; then
    	rm 03p5_MeicaReportSwarmCommand.$subj # remove it if it exists
    fi
    touch 03p5_MeicaReportSwarmCommand.$subj

    output_dir="${PRJDIR}/Results/${subj}/${outFolder}"
    # Write each run's command to tedana swarm text file
    runs=(`count -digits 2 1 ${nRuns}`)
    for run in ${runs[@]}
    do
    	# Write this run's commands to a single semicolon-separated line so the commands are run in series
    #     cat <<EOF >> 03p5_MeicaReportSwarmCommand.$subj
    # module load Anaconda; source activate python27; module load matlab; OMP_NUM_THREADS=4; cd ${output_dir}; python ${PRJDIR}/Scripts/Meica_Report/meica_report.py -o ./meica.Report.$subj.r${run} -t TED.$subj.r${run} --overwrite  --motion dfile.r$run.1D
    # EOF
    	cat <<EOF >> 03p5_MeicaReportSwarmCommand.$subj
    module load matlab; OMP_NUM_THREADS=4; cd ${output_dir}; ${pythonPath} ${PRJDIR}/Scripts/Meica_Report/meica_report.py -o ./meica.Report.$subj.r${run} -t TED.$subj.r${run} --overwrite  --motion dfile.r$run.1D
EOF
    done

    # Run Swarm Job
    echo "swarm -g 14 -t 4 -f 03p5_MeicaReportSwarmCommand.$subj --partition=nimh,norm --job-name=$subj.meicareport"
    jobid3=$(swarm -g 14 -t 4 -f 03p5_MeicaReportSwarmCommand.$subj --partition=nimh,norm --job-name=$subj.meicareport) # Must be run on Biowulf2, not Helix/Felix.
    echo "--> Job $jobid3"
    
    # DO META-REPORT
    # cat 03p6_MetaReportBatchCommand.$subj
    # jobid4=$(sbatch --partition=nimh,norm --dependency afterok:$jobid3 03p6_MetaReportBatchCommand.$subj --job-name=$subj.metareport)
    # echo "--> Job $jobid4"
        
done
