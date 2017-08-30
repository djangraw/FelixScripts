#!/bin/bash
# 00_CommonVariables.sh
#
# Created 10/29/15 by DJ.
# Updated 5/16/16 by DJ - added subjects and folders arrays
# Updated 7/13/16 by DJ - added new subjects/folders
# Updated 1/13/17 by DJ - removced SBJ34 from ok subjects (prior knowledge), switched to 09-22 folders for everyone

PRJDIR=/data/jangrawdc/PRJ11_Music

subjects=(SBJ00)

folders=(AfniProc)

iOkSubjects=(0)
unset okSubjects
unset okFolders
let nOkSubjects=${#iOkSubjects[@]}
let iLastOkSubj=nOkSubjects-1
for i in `seq 0 $iLastOkSubj`; do
    okSubjects[$i]=${subjects[${iOkSubjects[$i]}]}
    okFolders[$i]=${folders[${iOkSubjects[$i]}]}
done
unset i
