#!/bin/bash
# UnzipDistractionData namestart nameend subject
#
# === BEFORE RUNNING THIS, RUN:
# === ON LOCAL MACHINE
# filename=KOURDI_CAROLYN_LOUISE-07393611-20151023-11162-DICOM.tgz
# scp ~/Downloads/${filename} jangrawdc@felix.nimh.nih.gov:/data/jangrawdc/PRJ03_SustainedAttention/RawData/
#
# === ON FELIX:
# filename=KOURDI_CAROLYN_LOUISE-07393611-20151023-11162-DICOM.tgz
# namestart=KOURDI_CAROLYN_LOUISE-07393611
# nameend=20151023-11162
# subject=SBJ04
# 
# Created 10/28/15 by DJ.


# stop if error
set -e

# parse inputs
namestart=$1
nameend=$2
subject=$3

# extract data
filename=${namestart}-${nameend}-DICOM.tgz
tar -zxvf ${filename}
mv ${namestart} ${subject}