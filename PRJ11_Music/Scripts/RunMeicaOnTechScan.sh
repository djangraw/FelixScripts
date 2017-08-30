#!/bin/bash
# subj=SBJ01
# run=004
# echoTimes="13.0,31.36,49.72"
# subj=SBJ02
# run=006
# echoTimes="11.0,31.36,49.72"
subj=SBJ02
run=009
echoTimes="13.0,31.36,49.72"
echoes=(1 2 3)
PRJDIR=/data/jangrawdc/PRJ11_Music
output_dir=${PRJDIR}/Results/${subj}/run${run}
pythonPath="~/.conda/envs/python27/bin/python"

cd $output_dir

# make brain mask for input to MEICA
# 3dfractionize -input ${subj}_Anat_bc_ns_al_keep+tlrc -template pb03.$subj.r${runs[1]}_e${iRegEcho}.volreg+tlrc -clip 0.5 -overwrite -prefix rm.anatmask # resample skull-stripped, epi-aligned anat file to match epi resolution
# 3dcalc -a "rm.anatmask+tlrc" -expr 'notzero(a)' -overwrite -prefix rm.anatmask.bin # binarize
# 3dmask_tool -fill_holes -input rm.anatmask.bin+tlrc -overwrite -prefix rm.meicamask.bin+tlrc

# ==========NEW
3dcalc -a "full_mask.${subj}+orig" -expr 'notzero(a)' -overwrite -prefix rm.meicamask.bin+orig
# ==========NEW


# calculate the median value for the 5th value in the first echo
  # 3dBrickStat -mask full_mask.$subj+tlrc -percentile 50 1 50 pb03.$subj.r${run}_e1.volreg+tlrc'[4]' > gms.1D
3dBrickStat -mask rm.meicamask.bin+orig -percentile 50 1 50 pb03.$subj.r${run}_e1.volreg+orig'[4]' > gms.1D
gms=`cat gms.1D`
gmsa=($gms)
p50=${gmsa[1]} # tcsh is 1-based... this index would be [1] in bash.

# Rescale to the large values that ICA prefers
for iEcho in ${echoes[@]}; do
	# mask and scale all values by 10000/"the median value of volume 5 for the first echo"
	3dcalc -float -overwrite -a pb03.$subj.r${run}_e${iEcho}.volreg+orig \
	    -b rm.meicamask.bin+orig -expr "a*b*10000/${p50}" -overwrite -prefix rm.$subj.r${run}_e${iEcho}.meicain.nii.gz
done

# concatenate across echoes in the z direction
3dZcat -overwrite -prefix rm.zcat_ffd_$subj.r${run}.nii.gz  \
   rm.$subj.r${run}_e1.meicain.nii.gz \
   rm.$subj.r${run}_e2.meicain.nii.gz \
   rm.$subj.r${run}_e3.meicain.nii.gz

  # make sure slices are axial
  3daxialize -overwrite -prefix rm.zcat_ffd_$subj.r${run}.nii.gz rm.zcat_ffd_$subj.r${run}.nii.gz

# remove any old swarm commands
rm 03_TedanaSwarmCommand.$subj.r$run 03p5_MeicaReportSwarmCommand.$subj.r$run
rm -rf TED.$subj.r${run}

# Set up MEICA
cat <<EOF >> 03_TedanaSwarmCommand.$subj.r$run
module load Anaconda; source activate python27; module load matlab; OMP_NUM_THREADS=4; cd ${output_dir}; python ${PRJDIR}/Scripts/me-ica/meica.libs/tedana.py -e ${echoTimes} -d rm.zcat_ffd_${subj}.r${run}.nii.gz --sourceTEs=-1 --kdaw=10 --rdaw=1 --initcost=tanh --finalcost=tanh --conv=2.5e-5 --label=$subj.r${run};
EOF

# run MEICA
echo "swarm -g 8 -t 4 -f 03_TedanaSwarmCommand.$subj.r$run --partition=nimh,norm --job-name=$subj.r$run.tedana"
jobid2=$(swarm -g 8 -t 4 -f 03_TedanaSwarmCommand.$subj.r$run --partition=nimh,norm --job-name=$subj.r$run.tedana) # Must be run on Biowulf2, not Helix/Felix.
echo "--> Job $jobid2"

# Set up MEICA report
cat <<EOF >> 03p5_MeicaReportSwarmCommand.$subj.r$run
module load Anaconda; source activate python27; module load matlab; OMP_NUM_THREADS=4; cd ${output_dir}; ${pythonPath} ${PRJDIR}/Scripts/Meica_Report/meica_report.py -o ./meica.Report.$subj.r${run} -t TED.$subj.r${run} --overwrite  --motion dfile.r$run.1D
EOF

# Run MEICA report
# Run Swarm Job
echo "swarm -g 14 -t 4 -f 03p5_MeicaReportSwarmCommand.$subj.r$run --partition=nimh,norm --dependency afterok:$jobid2 --job-name=$subj.r$run.meicareport"
jobid3=$(swarm -g 14 -t 4 -f 03p5_MeicaReportSwarmCommand.$subj.r$run --partition=nimh,norm --dependency afterok:$jobid2 --job-name=$subj.r$run.meicareport) # Must be run on Biowulf2, not Helix/Felix.
echo "--> Job $jobid3"
