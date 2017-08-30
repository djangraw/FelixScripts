#!/bin/bash
# CleanUp1echoMeicaData SBJ
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
		# Check if file exists
		MEICAOUTFOLDER=TED.${SBJ}_S${strSession}_R${strRun}_VIDEO_1ECHO
		if [ ! -e ${MEICAOUTFOLDER} ] ; then
			echo ${MEICAOUTFOLDER} not found!
			continue
		fi
		echo "===CLEANING UP 1-ECHO MEICA FOR ${SBJ}, S${strSession}, R${strRun}==="
		cd ${MEICAOUTFOLDER}
		rm s0v.nii t2sv.nii t2sF.nii ts_OC.nii hik_ts_OC.nii lowk_ts_OC.nii betas_hik_OC.nii feats_OC2.nii
		cd ..
		echo "===DONE!==="		
	done

done