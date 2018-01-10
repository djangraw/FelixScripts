#!/bin/bash
# 00_CommonVariables.sh
#
# Created 7/24/17 by DJ.
# Updated 12/19/17 by DJ - updated folderSuffix to _v2
# Updated 12/21/17 by DJ - defined and dealt with 4 badSubjects.
# Updated 1/2/18 by DJ - updated folderSuffix to _v3
# Updated 1/4/18 by DJ - added high-motion subjs to badSubjects
# Updated 1/8/18 by DJ - added some badSubjects for more stringent motion censoring, duplicates.
# Updated 1/9/18 by DJ - fixed subject list

PRJDIR=/data/jangrawdc/PRJ16_TaskFcManipulation
scriptDir=${PRJDIR}/Scripts/fMRI

subjects=(tb0027 tb0065 tb0093 tb0094 tb0137 tb0138 tb0169 tb0170 tb0202 tb0275 tb0276 tb0312 tb0313 tb0349 tb0456 tb0498 tb0543 tb0593 tb0716 tb0717 tb0782 tb1063 tb1147 tb1208 tb1249 tb1313 tb1314 tb1401 tb1524 tb5688 tb5689 tb5762 tb5833 tb5868 tb5896 tb5914 tb5976 tb5985 tb5986 tb6048 tb6082 tb6121 tb6150 tb6162 tb6163 tb6199 tb6236 tb6301 tb6333 tb6366 tb6367 tb6419 tb6487 tb6521 tb6562 tb6563 tb6601 tb6631 tb6663 tb6704 tb6812 tb6813 tb6842 tb6843 tb6874 tb6899 tb6930 tb6964 tb7000 tb7001 tb7065 tb7066 tb7125 tb7153 tb7187 tb7224 tb7345 tb7375 tb7376 tb7427 tb7428 tb7490 tb7521 tb7657 tb7658 tb7693 tb7729 tb7763 tb7764 tb8034 tb8035 tb8068 tb8101 tb8111 tb8135 tb8136 tb8159 tb8199 tb8291 tb8329 tb8357 tb8393 tb8403 tb8437 tb8461 tb8462 tb8503 tb8561 tb8562 tb8595 tb8630 tb8632 tb8641 tb8703 tb8704 tb8748 tb8777 tb8818 tb8848 tb8883 tb8930 tb8941 tb8965 tb8989 tb9026 tb9027 tb9065 tb9077 tb9100 tb9148 tb9149 tb9158 tb9219 tb9292 tb9331 tb9332 tb9354 tb9355 tb9367 tb9368 tb9369 tb9392 tb9405 tb9406 tb9425 tb9434 tb9439 tb9440 tb9462 tb9482 tb9512 tb9614 tb9639 tb9660 tb9661 tb9692 tb9727 tb9728 tb9769 tb9804 tb9841 tb9881 tb9941)
# get number of subjects
nSubj=${#subjects[@]}
let nSubjm1=nSubj-1

# get folder names
# folders=()
folderSuffix=_v3
unset folders
for i in `seq 0 $nSubjm1`; do
    folders[$i]=${subjects[$i]}.srtt${folderSuffix}
done

# Remove bad subjects from iOkSubjects list
# wrong data duration: tb0138 tb5688 tb8101 tb8357
# motion >0.2mm/TR: tb7521 tb8111 tb8848
# censored >40% in any condition: tb7521 tb8111 tb8848 tb8930 tb9332 tb9368 tb9692
# badSubjects=(tb0138 tb5688 tb8101 tb8357 tb7521 tb8111 tb8848 tb8930 tb9332 tb9368 tb9692)
# censored >20% in any condition: tb0094 tb1314 tb1401 tb5833 tb5976 tb7224 tb7521 tb7764 tb8111 tb8704 tb8848 tb8930 tb8989 tb9026 tb9149 tb9292 tb9332 tb9368 tb9369 tb9692
# duplicate subject: tb7657 tb9439 (see behavior xls file, SubjectsScanned2x sheet)
# badSubjects=(tb0138 tb5688 tb8101 tb8357 tb7521 tb8111 tb8848 \
# tb0094 tb1314 tb1401 tb5833 tb5976 tb7224 tb7521 tb7764 tb8111 tb8704 \
# tb8848 tb8930 tb8989 tb9026 tb9149 tb9292 tb9332 tb9368 tb9369 tb9692 \
# tb7657 tb9439)
# iOkSubjects=()
# for i in `seq 0 $nSubjm1`; do
#   isBadSubj=0
#   # if it matches any of the bad subjects, mark it as bad.
#   for badSubj in ${badSubjects[@]}; do
#     if [[ $badSubj = "${subjects[$i]}" ]]; then
#       isBadSubj=1
#     fi
#   done
#   # if it survived, add the index to the iOkSubjects list
#   if [[ $isBadSubj = 0 ]]; then
#     iOkSubjects+=( $i )
#   fi
# done

# Define okSubjects and okFolders arrays
# iOkSubjects=(`seq 0 $nSubjm1`)
# unset okSubjects
# unset okFolders
# let nOkSubjects=${#iOkSubjects[@]}
# let iLastOkSubj=nOkSubjects-1
# for i in `seq 0 $iLastOkSubj`; do
#     okSubjects[$i]=${subjects[${iOkSubjects[$i]}]}
#     okFolders[$i]=${subjects[${iOkSubjects[$i]}]}${folderSuffix}
# done
# unset i

# New 1/8/18 version that uses only subjects with all data available,no more
# than 20% motion-censored TRs, and no less than 50% correct in any block.
okSubjects=(tb0065 tb0093 tb0094 tb0137 tb0169 tb0170 tb0275 tb0312 tb0313 \
tb0349 tb0456 tb0498 tb0543 tb0716 tb0782 tb1063 tb1147 tb1208 tb1313 \
tb1524 tb5762 tb5833 tb5868 tb5914 tb5976 tb5985 tb6048 tb6082 tb6150 \
tb6162 tb6199 tb6301 tb6366 tb6487 tb6562 tb6563 tb6601 tb6631 tb6704 \
tb6813 tb6842 tb6843 tb6874 tb6899 tb6930 tb7065 tb7153 tb7428 tb7763 \
tb7764 tb8068 tb8135 tb8159 tb8403 tb8461 tb8462 tb8503 tb8561 tb8562 \
tb8630 tb8632 tb8748 tb8818 tb8883 tb8965 tb9026 tb9027 tb9065 tb9148 \
tb9149 tb9158 tb9331 tb9354 tb9369 tb9392 tb9405 tb9425 tb9512 tb9614 \
tb9639 tb9660 tb9661 tb9692 tb9727 tb9728 tb9769 tb9804 tb9841 tb9881 tb9941)
# Find indices and folders of these subjects
unset iOkSubjects
unset okFolders
let nOkm1=${#okSubjects[@]}-1
for i in `seq 0 $nOkm1`; do
  for j in `seq 0 $nSubjm1`; do
    if [[ "${okSubjects[$i]}" = "${subjects[$j]}" ]]; then
      iOkSubjects[$i]=$j
      okFolders[$i]=${folders[$j]}
    fi
  done
done
