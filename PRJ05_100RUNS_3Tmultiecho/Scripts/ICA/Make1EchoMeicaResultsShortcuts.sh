#!/bin/bash
# Make1EchoMeicaResultsShortcuts SBJ
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
cd ${PRJDIR}/PrcsData/${SBJ}


# CREATE FILE SHORTCUTS
# =====================
for (( iSession=1; iSession<14; iSession++ )) 
do
	printf -v strSession "%02d" $iSession
	
	for (( iRun=1; iRun<=3; iRun++ ))
	do
		printf -v strRun "%02d" $iRun
		# find file
		MEICARESULTSFOLDER=ICAtest/TED.${SBJ}_S${strSession}_R${strRun}_VIDEO_1ECHO
		MEICAOUTFILE=${SBJ}_S${strSession}_R${strRun}_1ECHO.nii
		# Make shortcut
		[ -e ${MEICARESULTSFOLDER} ] && ln -s ${MEICARESULTSFOLDER}/dn_ts_OC.nii ./${MEICAOUTFILE} || echo ${MEICARESULTSFOLDER} not found!
		# find file
		MEICARESULTSFOLDER=ICAtest/TED.${SBJ}_S${strSession}_R${strRun}_VIDEO_MEICA
		MEICAOUTFILE=${SBJ}_S${strSession}_R${strRun}_MEICA.nii
		# Make shortcut
		[ -e ${MEICARESULTSFOLDER} ] && ln -s ${MEICARESULTSFOLDER}/dn_ts_OC.nii ./${MEICAOUTFILE} || echo ${MEICARESULTSFOLDER} not found!
	done
done