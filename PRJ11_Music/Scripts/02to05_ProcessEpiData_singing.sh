#!/bin/bash
# 02to05_ProcessEpiData_singing.sh
#
# Run this on Biowulf to do all 3 parts of processing in a row.
#
# USAGE:
#   bash 02to05_ProcessEpiData_singing.sh $subj $nRuns $echoTimes $outFolder
#
# INPUTS:
# 	- subj is a string indicating the subject ID (default: SBJ05)
#	  - nRuns is a scalar indicating how many runs are included (e.g., 4): if nRuns==0 it'll be found automatically
#   - echoTimes is a string with 3 comma-separated values for the echo times in ms
#   - outFolder is a string indicating the name of the folder where output should be placed
#
# OUTPUTS:
#	- Many, many files.
#
# Created 11/20/15 by DJ.
# Updated 12/7/15 by DJ - switched to correct motion files in meica input
# Updated 12/17/15 by DJ - appended ".$outFile" to all outputs to avoid overwriting
# Updated 1/20/16 by DJ - change appending to ".$subj.$outFile" for clarity
# Updated 4/19/16 by DJ - switched afterany dependencies to afterok
# Updated 9/15/16 by DJ - added Meica_Report swarm job as separate from the tedana calls (and in parallel with later scripts so they don't have to wait).
# Updated 9/19/16 by DJ - added 03p6_MetaReportCommand.
# Updated 11/3/16 by DJ - added automatic nRuns calculation

# ======== SET UP ========
# Parse inputs and specify defaults
argv=("$@")
if [ ${#argv} > 0 ]; then
    subj=${argv[0]}
else
    subj=SBJ03_task
fi
if [ ${#argv} > 1 ]; then
    nRuns=${argv[1]}
else
    nRuns=0
fi
if [ ${#argv} > 2 ]; then
    echoTimes=${argv[2]}
else
    echoTimes="11.0,23.96,36.92"
fi
if [ ${#argv} > 3 ]; then
    outFolder=${argv[3]}
else
    outFolder=AfniProc_MultiEcho
fi

# Display inputs
# echo "$subj $nRuns \"$echoTimes\" $outFolder"

# Get project and output directory
source ./00_CommonVariables.sh # Get PRJDIR
output_dir="${PRJDIR}/Results/${subj}/${outFolder}"
pythonPath="~/.conda/envs/python27/bin/python"

# Get nRuns if not specified
if [ "$nRuns" == "0" ]; then
    nRuns=`ls ${PRJDIR}/PrcsData/${subj}/D00_OriginalData/${subj}_Run*_e2+orig.HEAD | wc -w`
fi

SKIP_EARLY_STUFF=1

if [ $SKIP_EARLY_STUFF == 0 ]; then

# ======== RUN ========
# === 1. PREPROCESS AND SET UP MEICA
# cat <<EOF > 02_PreprocBatchCommand.$subj
# #!/bin/bash
# ./02_PreprocessForMeica_singing.tcsh $subj $nRuns "$echoTimes" $outFolder 2>&1 | tee output.02_PreprocessForMeica_singing.$subj.$outFolder
# EOF
# cat <<EOF > 02_PreprocBatchCommand.$subj
# #!/bin/bash
# ./02_PreprocessForMeica_singing_ricor.tcsh $subj $nRuns "$echoTimes" $outFolder 2>&1 | tee output.02_PreprocessForMeica_singing_ricor.$subj.$outFolder
# EOF
cat <<EOF > 02_PreprocBatchCommand.$subj
#!/bin/bash
./02_PreprocessForMeica_singing_ricor_qwarp.tcsh $subj $nRuns "$echoTimes" $outFolder 2>&1 | tee output.02_PreprocessForMeica_singing_ricor_qwarp.$subj.$outFolder
EOF
cat 02_PreprocBatchCommand.$subj
jobid1=$(sbatch --cpus-per-task=8 --mem=3g --time=8:00:00 --partition=nimh,norm 02_PreprocBatchCommand.$subj --job-name=$subj.preproc)
echo "--> Job $jobid1"


# === 2. RUN MEICA SWARM JOB
# initialize Tedana swarm file
if [ -f 03_TedanaSwarmCommand.$subj ]; then
	rm 03_TedanaSwarmCommand.$subj # remove it if it exists
fi
touch 03_TedanaSwarmCommand.$subj
# Write each run's command to tedana swarm text file
runs=(`count -digits 2 1 ${nRuns}`)
for run in ${runs[@]}
do
	# Write this run's commands to a single semicolon-separated line so the commands are run in series
	cat <<EOF >> 03_TedanaSwarmCommand.$subj
module load Anaconda; source activate python27; module load matlab; OMP_NUM_THREADS=4; cd ${output_dir}; python ${PRJDIR}/Scripts/me-ica/meica.libs/tedana.py -e ${echoTimes} -d zcat_ffd_$subj.r${run}.nii.gz --sourceTEs=-1 --kdaw=10 --rdaw=1 --initcost=tanh --finalcost=tanh --conv=2.5e-5 --label=$subj.r${run};
EOF

done

# Run Swarm Job
echo "swarm -g 8 -t 4 -f 03_TedanaSwarmCommand.$subj --partition=nimh,norm --dependency afterok:$jobid1 --job-name=$subj.tedana"
jobid2=$(swarm -g 8 -t 4 -f 03_TedanaSwarmCommand.$subj --partition=nimh,norm --dependency afterok:$jobid1 --job-name=$subj.tedana) # Must be run on Biowulf2, not Helix/Felix.
echo "--> Job $jobid2"

else
  jobid1="41767066"
  jobid2="41767066"
fi

# === 3. RUN MEICA-REPORT SWARM JOB
# initialize Tedana swarm file
if [ -f 03p5_MeicaReportSwarmCommand.$subj ]; then
	rm 03p5_MeicaReportSwarmCommand.$subj # remove it if it exists
fi
touch 03p5_MeicaReportSwarmCommand.$subj
# Write each run's command to tedana swarm text file
runs=(`count -digits 2 1 ${nRuns}`)
for run in ${runs[@]}
do
	# Write this run's commands to a single semicolon-separated line so the commands are run in series
#     cat <<EOF >> 03p5_MeicaReportSwarmCommand.$subj
# module load Anaconda; source activate python27; module load matlab; OMP_NUM_THREADS=4; cd ${output_dir}; python ${PRJDIR}/Scripts/Meica_Report/meica_report.py -o ./meica.Report.$subj.r${run} -t TED.$subj.r${run} --overwrite  --motion dfile.r$run.1D
# EOF
	cat <<EOF >> 03p5_MeicaReportSwarmCommand.$subj
module load Anaconda; source activate python27; module load matlab; OMP_NUM_THREADS=4; cd ${output_dir}; ${pythonPath} ${PRJDIR}/Scripts/Meica_Report/meica_report.py -o ./meica.Report.$subj.r${run} -t TED.$subj.r${run} --overwrite  --motion dfile.r$run.1D
EOF
done

# Run Swarm Job
echo "swarm -g 14 -t 4 -f 03p5_MeicaReportSwarmCommand.$subj --partition=nimh,norm --dependency afterok:$jobid2 --job-name=$subj.meicareport"
jobid3=$(swarm -g 14 -t 4 -f 03p5_MeicaReportSwarmCommand.$subj --partition=nimh,norm --dependency afterok:$jobid2 --job-name=$subj.meicareport) # Must be run on Biowulf2, not Helix/Felix.
echo "--> Job $jobid3"

# === 4. RUN META-REPORT SLURM JOB
cat <<EOF > 03p6_MetaReportBatchCommand.$subj
#!/bin/bash
./03p6_RunMetaReport.sh $subj $outFolder 2>&1 | tee output.03p6_RunMetaReport.$subj.$outFolder
EOF
cat 03p6_MetaReportBatchCommand.$subj
jobid4=$(sbatch --partition=nimh,norm --dependency afterok:$jobid3 03p6_MetaReportBatchCommand.$subj --job-name=$subj.metareport)
echo "--> Job $jobid4"

# === 5. RUN MEICA CLEANUP
cat <<EOF > 04_CleanupBatchCommand.$subj
#!/bin/bash
./04_CleanUpAfterMeica.sh $subj $nRuns $outFolder 2>&1 | tee output.04_CleanUpAfterMeica.$subj.$outFolder
EOF
cat 04_CleanupBatchCommand.$subj
# Depends on jobid2 (tedana)... doesn't need to wait for jobid3 (meica_report)!
jobid5=$(sbatch --partition=nimh,norm --dependency=afterok:$jobid2 04_CleanupBatchCommand.$subj --job-name=$subj.cleanup)
echo "--> Job $jobid5"


# === 6. RUN REGRESSION
cat <<EOF > 05_RegressionBatchCommand.$subj
#!/bin/bash
./05_RunRegressionOnMeicaResults_singing.tcsh $subj $nRuns "$echoTimes" $outFolder 2>&1 | tee output.05_RunRegressionOnMeicaResults_singing.$subj.$outFolder
EOF
cat 05_RegressionBatchCommand.$subj
jobid6=$(sbatch --partition=nimh,norm --dependency=afterok:$jobid5 05_RegressionBatchCommand.$subj --job-name=$subj.regression)
echo "--> Job $jobid6"
