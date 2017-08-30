#!/bin/bash
# 00_CommonVariables.sh
#
# Created 10/29/15 by DJ.
# Updated 5/16/16 by DJ - added subjects and folders arrays
# Updated 7/13/16 by DJ - added new subjects/folders
# Updated 1/13/17 by DJ - removced SBJ34 from ok subjects (prior knowledge), switched to 09-22 folders for everyone

PRJDIR=/data/jangrawdc/PRJ03_SustainedAttention

subjects=(SBJ09 SBJ10 SBJ11 SBJ12 SBJ13 SBJ14 SBJ15 SBJ16 SBJ17 SBJ18 SBJ19 SBJ20 SBJ21 SBJ22 SBJ23 SBJ24 SBJ25 SBJ26 SBJ27 SBJ28 SBJ29 SBJ30 SBJ31 SBJ32 SBJ33 SBJ34 SBJ35 SBJ36)

# folders=(AfniProc_MultiEcho_2016-01-19 AfniProc_MultiEcho_2016-02-05 AfniProc_MultiEcho_2016-02-05 AfniProc_MultiEcho_2016-02-09 AfniProc_MultiEcho_2016-02-24 AfniProc_MultiEcho_2016-02-24 AfniProc_MultiEcho_2016-02-26 AfniProc_MultiEcho_2016-02-26 AfniProc_MultiEcho_2016-03-04 AfniProc_MultiEcho_2016-03-04 AfniProc_MultiEcho_2016-03-18 AfniProc_MultiEcho_2016-03-18 AfniProc_MultiEcho_2016-03-08 AfniProc_MultiEcho_2016-04-13 AfniProc_MultiEcho_2016-04-13 AfniProc_MultiEcho_2016-04-13 AfniProc_MultiEcho_2016-04-19 AfniProc_MultiEcho_2016-05-02 AfniProc_MultiEcho_2016-05-02 AfniProc_MultiEcho_2016-05-03 AfniProc_MultiEcho_2016-05-13 AfniProc_MultiEcho_2016-05-16 AfniProc_MultiEcho_2016-07-12 AfniProc_MultiEcho_2016-05-25 AfniProc_MultiEcho_2016-06-06 AfniProc_MultiEcho_2016-06-06 AfniProc_MultiEcho_2016-06-10 AfniProc_MultiEcho_2016-07-08)

folders=(AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22 AfniProc_MultiEcho_2016-09-22)

iOkSubjects=(0 1 2 4 5 6 7 8 9 10 13 15 16 19 21 22 23 24 27)
# iOkSubjects=(4 5 6 7 8 9 10)
unset okSubjects
unset okFolders
let nOkSubjects=${#iOkSubjects[@]}
let iLastOkSubj=nOkSubjects-1
for i in `seq 0 $iLastOkSubj`; do
    okSubjects[$i]=${subjects[${iOkSubjects[$i]}]}
    okFolders[$i]=${folders[${iOkSubjects[$i]}]}
done
unset i

# okSubjects=(SBJ09 SBJ10 SBJ11 SBJ13 SBJ14 SBJ15 SBJ16 SBJ17 SBJ18 SBJ19 SBJ22 SBJ24 SBJ25 SBJ28 SBJ30 SBJ31 SBJ32 SBJ33 SBJ36)

# okFolders=(AfniProc_MultiEcho_2016-01-19 AfniProc_MultiEcho_2016-02-05 AfniProc_MultiEcho_2016-02-05 AfniProc_MultiEcho_2016-02-24 AfniProc_MultiEcho_2016-02-24 AfniProc_MultiEcho_2016-02-26 AfniProc_MultiEcho_2016-02-26 AfniProc_MultiEcho_2016-03-04 AfniProc_MultiEcho_2016-03-04 AfniProc_MultiEcho_2016-03-18 AfniProc_MultiEcho_2016-04-13 AfniProc_MultiEcho_2016-04-13 AfniProc_MultiEcho_2016-04-19 AfniProc_MultiEcho_2016-05-03 AfniProc_MultiEcho_2016-05-16 AfniProc_MultiEcho_2016-07-12 AfniProc_MultiEcho_2016-05-25 AfniProc_MultiEcho_2016-06-06 AfniProc_MultiEcho_2016-06-06 AfniProc_MultiEcho_2016-07-08)