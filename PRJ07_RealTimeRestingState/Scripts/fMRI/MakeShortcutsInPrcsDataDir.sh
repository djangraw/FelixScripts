#!/bin/bash
# MakeShortcutsInPrcsDataDir subject
# 
# Should be called from inside the RawData directory containing the files you want to copy
# 
# Created 10/29/15 by DJ.

# stop if error
set -e

# Parse inputs
subject=$1

rawDataDir=/data/jangrawdc/PRJ03_SustainedAttention/RawData/${subject}
shortcutDir=/data/jangrawdc/PRJ03_SustainedAttention/PrcsData/${subject}/D00_OriginalData
if [ ! -d ${shortcutDir} ]
then
	echo "Making new directory ${shortcutDir}..."
	mkdir -p ${shortcutDir}
fi
nFiles=`ls ${rawDataDir}/${subject}* | wc -w`

echo "Sending ${nFiles} shortcuts from ${rawDataDir} to ${shortcutDir}..."
ln -s ${rawDataDir}/${subject}* ${shortcutDir}
echo "Done!"