#!/bin/bash
# 00__ImportDistractionData namestart nameend subject
#
# === BEFORE RUNNING THIS, RUN:
# === ON LOCAL MACHINE
# filename=LAST_FIRST_MIDDLE-07393611-20151023-11162-DICOM.tgz
# scp ~/Downloads/${filename} jangrawdc@felix.nimh.nih.gov:/data/jangrawdc/PRJ03_SustainedAttention/RawData/
#
# === ON FELIX:
# filename=LAST_FIRST_MIDDLE-07393611-20151023-11162-DICOM.tgz
# namestart=LAST_FIRST_MIDDLE-07393611
# nameend=20151023-11162
# subject=SBJ04
# 
# Created 10/28/15 by DJ.
# Updated 10/29/15 by DJ - added MakeShortcuts...
# Updated 10/30/15 by DJ - bugfix: added .sh extensions
# Updated 12/21/15 by DJ - removed name, added 00 prefix


# stop if error
set -e

# parse inputs
namestart=$1
nameend=$2
subject=$3

source ./00_CommonVariables.sh
scriptdir=${PRJDIR}/Scripts/fMRI
datadir=${PRJDIR}/RawData
cd ${datadir}

# unzip extraction data
bash ${scriptdir}/UnzipDistractionData.sh $namestart $nameend $subject
cd ${subject}/${nameend}

# reconstruct DIMON files
bash ${scriptdir}/ReconstructDimonFiles.sh $subject

# send shortcuts to corresponding PrcsData directory
bash ${scriptdir}/MakeShortcutsInPrcsDataDir.sh $subject

