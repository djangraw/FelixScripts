#!/bin/bash
# RunPipelineOnAllSubjects.sh
#
# USAGE:
#   bash RunPipelineOnAllSubjects.sh
#
# Created 9/12/16 by DJ.

source ./00_CommonVariables.sh # Get PRJDIR

echoTimes="14.6,26.8,39.0"
outFolder=AfniProc_MultiEcho_2016-09-22

# for Rosenberg analysis
bash Extract_TS.sh TsExtractWmCsfGs.py

# for subj in ${subjects[@]}; do
# for subj in ${okSubjects[@]}; do
for subj in SBJ11 SBJ13 SBJ14 SBJ15 SBJ16 SBJ17 SBJ18 SBJ19; do
    # Get nRuns
    dataFolder=${PRJDIR}/PrcsData/$subj/D00_OriginalData
    nRuns=`ls ${dataFolder}/${subj}_Run*_e1+orig.HEAD | wc -w`
    # Run pipeline
    # bash 02to05_ProcessEpiData.sh $subj $nRuns $echoTimes $outFolder
    # Extract tcs from Craddock Atlas
    # bash 06_WarpCraddockAtlasToEpiSpace.sh $subj $outFolder
    # for Rosenberg analysis
    tcsh -xef 05p3_RunRegressionWithSegTimecourses.tcsh $subj $outFolder 2>&1 | tee output.05_RunRegressionWithSegTimecourses.$subj.$outFolder
done

# for Rosenberg analysis
bash Extract_TS.sh TsExtractByROIs.py