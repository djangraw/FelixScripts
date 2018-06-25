#!/bin/bash
# MakeMeicaInputShortcuts SBJ
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
SOURCEDIR="/data/NIMH_SFIM/100RUNS_3Tmultiecho/"
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
		MEICAINFILE=${SOURCEDIR}/PrcsData/${SBJ}_S${strSession}/D01_Version02.AlignByAnat.Cubic/Video${strRun}/zcat_ffd_${SBJ}_S${strSession}_Video${strRun}.nii.gz		
		ECHO2INFILE=${SOURCEDIR}/PrcsData/${SBJ}_S${strSession}/D01_Version02.AlignByAnat.Cubic/Video${strRun}/p06.${SBJ}_S${strSession}_Video${strRun}_e2.sm.nii.gz
		# Make shortcuts
		[ -e ${MEICAINFILE} ] && ln -s ${MEICAINFILE} . || echo ${MEICAINFILE} not found!
		[ -e ${ECHO2INFILE} ] && ln -s ${ECHO2INFILE} . || echo ${ECHO2INFILE} not found!
	done

done