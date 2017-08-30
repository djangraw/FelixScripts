#!/bin/bash
# RunMeicaOnVideo SBJ
# 
# Created 9/29/15 by DJ.

# stop if error
set -e

# READ INPUT PARAMETERS
# =====================
if [ $# -ne 1 ]; then
 echo "Usage: $basename $0 SBJID"
 exit
fi
SBJ=$1

# DECLARE DIRECTORIES
# ===================
PRJDIR="/data/jangrawdc/PRJ05_100RUNS_3Tmultiecho/"
cd ${PRJDIR}/PrcsData/${SBJ}/ICAtest


# CREATE FILE SHORTCUTS
# =====================
for (( iSession=1; iSession<14; iSession++ )) 
do
	printf -v strSession "%02d" $iSession
	
	for (( iRun=1; iRun<=3; iRun++ ))
	do
		printf -v strRun "%02d" $iRun
		# find files
		MEICAINFILE=zcat_ffd_${SBJ}_S${strSession}_Video${strRun}.nii.gz		
		# Check if file exists
		if [ ! -e ${MEICAINFILE} ] ; then
			echo ${MEICAINFILE} not found!
			continue
		fi
		# Run MEICA
		echo "===MEICA WITH ${SBJ}, S${strSession}, R${strRun}==="		
		MEICAOUTFOLDER=${SBJ}_S${strSession}_R${strRun}_VIDEO_MEICA
		python "../../../Scripts/tedana-savevarex.py" -d ${MEICAINFILE} -e 15.3,29.7,44.0 --sourceTEs=-1 --kdaw=10 \
		    --rdaw=1 --initcost=tanh --finalcost=tanh --conv=2.5e-5 --label=${MEICAOUTFOLDER}
		echo "===DONE!==="		
	done

done