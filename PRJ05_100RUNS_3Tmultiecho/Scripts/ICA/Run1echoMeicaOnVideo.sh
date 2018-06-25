#!/bin/bash
# Run1echoMeicaOnVideo SBJ
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
		MEICAINFILE=p06.${SBJ}_S${strSession}_Video${strRun}_e2.sm.nii.gz		
		# Check if file exists
		if [ ! -e ${MEICAINFILE} ] ; then
			echo ${MEICAINFILE} not found!
			continue
		fi
		# Get variance explained metrics
		MEICAINFOLDER=TED.${SBJ}_S${strSession}_R${strRun}_VIDEO_MEICA
		pcfrac=`cat ${MEICAINFOLDER}/pca_fracvarremoved.txt`
		icfrac=`cat ${MEICAINFOLDER}/ica_fracvarremoved.txt`
		# Run 1-ECHO VERSION OF MEICA
		echo "===MEICA WITH ${SBJ}, S${strSession}, R${strRun}==="
		echo "===pcfrac = ${pcfrac}, icfrac = ${icfrac} ==="		
		MEICAOUTFOLDER=${SBJ}_S${strSession}_R${strRun}_VIDEO_1ECHO
		python "../../../Scripts/tedana-1echo_d2.py" -d ${MEICAINFILE} -e 29.7 --sourceTEs=-1 --kdaw=10 \
		    --rdaw=1 --initcost=tanh --finalcost=tanh --conv=2.5e-5 --label=${MEICAOUTFOLDER} \
				--pcvarexfrac ${pcfrac} --icvarexfrac ${icfrac}
		echo "===DONE!==="		
	done

done